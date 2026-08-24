import { useState, type FormEvent } from "react";
import { login, loginUrl } from "../lib/auth/authStore";
import { openDownload } from "../lib/docs";
import { Button } from "./ui/Button";
import logoUrl from "../assets/logo.svg";

export interface LoginProps {
  /** Called after a successful login so the app re-renders into the
   * director UI. */
  onAuthenticated: () => void;
}

/** Phase-1 SSO login card — dark themed to match the director app. */
export function Login({ onAuthenticated }: LoginProps) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const canSubmit = email.trim().length > 0 && password.length > 0 && !busy;

  const submit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!canSubmit) return;
    setBusy(true);
    setError(null);
    try {
      await login(email.trim(), password);
      onAuthenticated();
    } catch (loginError) {
      setError(loginError instanceof Error ? loginError.message : String(loginError));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-background p-4">
      <form
        onSubmit={submit}
        className="w-full max-w-sm rounded-lg border border-border bg-muted/40 p-6 shadow-2xl"
      >
        <header className="mb-6 text-center">
          <img
            src={logoUrl}
            alt="Trace Odd"
            className="mx-auto mb-3 h-20 w-20"
          />
          <p className="mb-1 text-sm font-extrabold tracking-[0.3em] text-[#C9A24B]">
            TRACE ODD
          </p>
          <h1 className="text-xl font-semibold tracking-wide">Todd Studio</h1>
          <p className="mt-1 text-xs text-muted-foreground">
            Sign in to the broadcast director
          </p>
        </header>

        <div className="flex flex-col gap-3">
          <label className="flex flex-col gap-1 text-xs text-muted-foreground">
            Email
            <input
              type="email"
              autoComplete="email"
              autoFocus
              className="rounded-md border border-input bg-background px-3 py-2 text-sm text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              placeholder="director@studio"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
            />
          </label>

          <label className="flex flex-col gap-1 text-xs text-muted-foreground">
            Password
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                autoComplete="current-password"
                className="w-full rounded-md border border-input bg-background px-3 py-2 pr-10 text-sm text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                placeholder="••••••••"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
              />
              <button
                type="button"
                aria-label={showPassword ? "Hide password" : "Show password"}
                title={showPassword ? "Hide password" : "Show password"}
                onClick={() => setShowPassword((visible) => !visible)}
                className="absolute inset-y-0 right-0 flex w-10 items-center justify-center text-muted-foreground hover:text-foreground"
                tabIndex={-1}
              >
                {showPassword ? <EyeOffIcon /> : <EyeIcon />}
              </button>
            </div>
          </label>

          {error && (
            <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">
              {error}
            </div>
          )}

          <Button type="submit" disabled={!canSubmit} className="w-full">
            {busy ? "Signing in…" : "Sign in"}
          </Button>
        </div>

        <p className="mt-4 text-center text-[10px] text-muted-foreground">
          Identity provider: <span className="font-mono">{loginUrl()}</span>
        </p>

        <div className="mt-4 border-t border-border pt-3 text-center">
          <Button
            type="button"
            variant="outline"
            className="w-full text-xs"
            onClick={openDownload}
          >
            ⬇ Download the desktop app
          </Button>
        </div>
      </form>
    </div>
  );
}

function EyeIcon() {
  return (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  );
}

function EyeOffIcon() {
  return (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c6.5 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68" />
      <path d="M6.61 6.61A13.526 13.526 0 0 0 2 12s3.5 7 10 7a9.74 9.74 0 0 0 5.39-1.61" />
      <line x1="2" x2="22" y1="2" y2="22" />
      <path d="M14.12 14.12a3 3 0 1 1-4.24-4.24" />
    </svg>
  );
}
