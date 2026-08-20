import { useState, type FormEvent } from "react";
import { login, loginUrl } from "../lib/auth/authStore";
import { Button } from "./ui/Button";

export interface LoginProps {
  /** Called after a successful login so the app re-renders into the
   * director UI. */
  onAuthenticated: () => void;
}

/** Phase-1 SSO login card — dark themed to match the director app. */
export function Login({ onAuthenticated }: LoginProps) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
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
            <input
              type="password"
              autoComplete="current-password"
              className="rounded-md border border-input bg-background px-3 py-2 text-sm text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              placeholder="••••••••"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
            />
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
      </form>
    </div>
  );
}
