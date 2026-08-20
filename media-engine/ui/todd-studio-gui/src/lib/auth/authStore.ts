// Phase-1 SSO auth store.
//
// The identity provider is an external Laravel API. `login()` exchanges
// credentials for an HS256 JWT, which is kept in memory + localStorage so
// a page reload keeps the session. Every network layer (REST client,
// WHEP, control WebSocket) reads the token through `getToken()`.

const STORAGE_KEY = "todd_studio_jwt";
const EMAIL_KEY = "todd_studio_email";

/** The Phase-1 login endpoint does not exist in this repo yet, so it is
 * configurable via `VITE_STUDIO_LOGIN_URL` with this production default. */
const DEFAULT_LOGIN_URL = "https://admin.traceodd.com/api/v1/studio/login";

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
}
