// Phase-1 SSO auth store.
//
// The identity provider is an external Laravel API. `login()` exchanges
// credentials for an HS256 JWT, which is kept in memory + localStorage so
// a page reload keeps the session. Every network layer (REST client,
// WHEP, control WebSocket) reads the token through `getToken()`.

const STORAGE_KEY = "todd_studio_jwt";
const EMAIL_KEY = "todd_studio_email";

/** Relative URL → same-origin: nginx on studio.traceodd.com proxies
 * `/api/v1/studio/*` to the Laravel admin-panel PHP-FPM on the same server
 * (no admin.traceodd.com DNS or CORS needed). The `VITE_STUDIO_LOGIN_URL`
 * env var can still override this default. */
const DEFAULT_LOGIN_URL = "/api/v1/studio/login";

let cachedToken: string | null | undefined;
let cachedEmail: string | null | undefined;

type AuthListener = () => void;
const listeners = new Set<AuthListener>();

function notify(): void {
  listeners.forEach((listener) => listener());
}

/** Returns the stored JWT, or null when signed out. */
export function getToken(): string | null {
  if (cachedToken === undefined) {
    try {
      cachedToken = window.localStorage.getItem(STORAGE_KEY);
    } catch {
      cachedToken = null;
    }
  }
  return cachedToken;
}

/** Email the director typed on the login form (display-only). */
export function getEmail(): string | null {
  if (cachedEmail === undefined) {
    try {
      cachedEmail = window.localStorage.getItem(EMAIL_KEY);
    } catch {
      cachedEmail = null;
    }
  }
  return cachedEmail;
}

/** Stores the JWT (and the login email) and notifies subscribers. */
export function setToken(token: string, email: string | null = null): void {
  cachedToken = token;
  cachedEmail = email;
  try {
    window.localStorage.setItem(STORAGE_KEY, token);
    if (email) window.localStorage.setItem(EMAIL_KEY, email);
    else window.localStorage.removeItem(EMAIL_KEY);
  } catch {
    // Storage unavailable (private mode etc.) — memory-only session.
  }
  notify();
}

/** Drops the JWT (sign out) and notifies subscribers. */
export function clearToken(): void {
  cachedToken = null;
  cachedEmail = null;
  try {
    window.localStorage.removeItem(STORAGE_KEY);
    window.localStorage.removeItem(EMAIL_KEY);
  } catch {
    // Ignore storage errors; the in-memory state is already cleared.
  }
  notify();
}

interface JwtPayload {
  sub?: string | number;
  role?: string;
  perms?: string[];
  exp?: number;
}

function decodePayload(token: string): JwtPayload | null {
  const parts = token.split(".");
  if (parts.length < 2) return null;
  try {
    const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    return JSON.parse(atob(base64)) as JwtPayload;
  } catch {
    return null;
  }
}

/** True when a token is present and its `exp` claim is still in the
 * future. Malformed tokens are treated as expired. */
export function isAuthenticated(): boolean {
  const token = getToken();
  if (!token) return false;
  const payload = decodePayload(token);
  if (!payload || typeof payload.exp !== "number") return false;
  return payload.exp * 1000 > Date.now();
}

/** Subscribes to auth changes; returns an unsubscribe function. */
export function onAuthChange(listener: AuthListener): () => void {
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
}

/** Resolves the Phase-1 login endpoint (env var or default). */
export function loginUrl(): string {
  return import.meta.env.VITE_STUDIO_LOGIN_URL || DEFAULT_LOGIN_URL;
}

/** Exchanges credentials for the SSO JWT and stores it. Throws a readable
 * Error (always including the HTTP status) on any failure. */
export async function login(email: string, password: string): Promise<void> {
  let res: Response;
  try {
    res = await fetch(loginUrl(), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    });
  } catch (cause) {
    throw new Error(
      `Login failed: cannot reach the sign-in endpoint (${
        cause instanceof Error ? cause.message : String(cause)
      })`,
    );
  }

  if (!res.ok) {
    let detail = "";
    try {
      const body = (await res.json()) as { error?: string; message?: string };
      detail = body.message ?? body.error ?? "";
    } catch {
      // Non-JSON error body — the status is enough.
    }
    throw new Error(
      detail
        ? `Login failed (HTTP ${res.status}): ${detail}`
        : `Login failed (HTTP ${res.status})`,
    );
  }

  const data = (await res.json()) as { token?: string; access_token?: string };
  const token = data.token ?? data.access_token;
  if (!token) {
    throw new Error("Login failed: the sign-in endpoint returned no token");
  }
  setToken(token, email);
  scheduleRefresh();
}

/** Resolves the Phase-1 token refresh endpoint (same Laravel module as
 * the login URL, so `VITE_STUDIO_LOGIN_URL` overrides both). */
export function refreshUrl(): string {
  const base = loginUrl();
  return base.replace(/\/login\/?$/, "") + "/refresh";
}

let refreshPromise: Promise<string | null> | null = null;
let refreshTimer: ReturnType<typeof setTimeout> | undefined;

/** Seconds of `exp` remaining for the stored token (negative = expired).
 * Returns null when no token is present or it has no readable `exp`. */
export function tokenExpirySeconds(): number | null {
  const token = getToken();
  if (!token) return null;
  const payload = decodePayload(token);
  if (!payload || typeof payload.exp !== "number") return null;
  return payload.exp - Date.now() / 1000;
}

/**
 * Exchanges the stored JWT for a fresh one via `POST /api/v1/studio/refresh`.
 *
 * Concurrent 401s (WHEP watch + REST + WebSocket) all await the same
 * in-flight promise, so a single refresh serves every retry. Returns the
 * new token, or null when there is nothing to refresh or the issuer
 * rejected the request (the token is NOT cleared here — callers decide).
 */
export function refreshToken(): Promise<string | null> {
  if (refreshPromise) return refreshPromise;

  refreshPromise = (async () => {
    const current = getToken();
    if (!current) return null;
    try {
      const res = await fetch(refreshUrl(), {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${current}`,
        },
      });
      if (!res.ok) return null;
      const data = (await res.json()) as { token?: string };
      const fresh = data.token;
      if (!fresh) return null;
      setToken(fresh, getEmail());
      scheduleRefresh();
      return fresh;
    } catch {
      return null;
    } finally {
      refreshPromise = null;
    }
  })();

  return refreshPromise;
}

/** Refreshes the token when one is stored, silently ignoring failures.
 * Used by callers that need *a* valid token without caring about errors. */
export async function ensureFreshToken(): Promise<string | null> {
  const remaining = tokenExpirySeconds();
  if (remaining !== null && remaining > 60) return getToken();
  return refreshToken();
}

/** Schedules a silent refresh ~60s before the token expires, so long
 * broadcast sessions never hit a 401 from an expired SSO JWT. Safe to
 * call after every setToken — it always replaces the previous timer. */
export function scheduleRefresh(): void {
  if (refreshTimer) clearTimeout(refreshTimer);
  const remaining = tokenExpirySeconds();
  if (remaining === null) return;
  // Refresh at 60s before expiry, or at half-life for very short tokens.
  const delaySeconds = Math.max(30, remaining - 60);
  refreshTimer = setTimeout(() => {
    void refreshToken();
  }, delaySeconds * 1000);
}

/**
 * Phase 1 unified SSO: consumes a `?sso=<media-engine JWT>` deep-link
 * parameter (minted by the Cricket Manager panel via
 * `POST /api/v1/studio/exchange`) and adopts it as the session token.
 *
 * The token is validated by shape only — the Rust engine re-verifies the
 * signature/claims on every API and WebSocket request, so an invalid
 * ticket simply fails downstream and the app falls back to the login
 * screen. The query parameter is stripped so the token never lingers in
 * the address bar / browser history.
 */
export function applySsoFromUrl(): void {
  const url = new URL(window.location.href);
  const sso = url.searchParams.get("sso");
  if (!sso) return;

  url.searchParams.delete("sso");
  window.history.replaceState(null, "", url.toString());

  // Compact JWS shape check: header.payload.signature.
  if (sso.split(".").length !== 3) return;
  setToken(sso);
  scheduleRefresh();
}

/**
 * Reads a `?match=<id>` deep-link parameter (set by "Open Todd Studio")
 * so the director can land on the manager's active match even before the
 * engine's push feed delivers the context. Stripped from the URL.
 */
export function takeMatchHint(): string | null {
  const url = new URL(window.location.href);
  const match = url.searchParams.get("match");
  if (!match) return null;

  url.searchParams.delete("match");
  window.history.replaceState(null, "", url.toString());
  return match;
}
