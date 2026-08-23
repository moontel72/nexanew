// In-app auto-update manager (desktop only).
//
// - On mount (desktop shell): silently checks the remote manifest
//   (https://traceodd.com/api/desktop-update.json) and shows the update
//   dialog when a newer version exists.
// - A manual "Check for Updates" button dispatches the
//   `todd:check-updates` window event; this component listens and shows
//   the dialog with "up to date" / "error" states too.
// - "Update & Restart Now" downloads, verifies the signature (native,
//   against the pubkey baked into tauri.conf.json), installs and
//   relaunches — no browser redirect.
//
// On the web build all updater calls are skipped (the plugin is only
// available inside the Tauri shell).

import { useEffect, useState } from "react";
import { check } from "@tauri-apps/plugin-updater";
import type { Update } from "@tauri-apps/plugin-updater";
import { relaunch } from "@tauri-apps/plugin-process";
import { Button } from "./ui/Button";

const inTauri =
  typeof window !== "undefined" && "__TAURI_INTERNALS__" in window;

type Phase =
  | "hidden"
  | "checking"
  | "available"
  | "upToDate"
  | "downloading"
  | "error";

interface UpdateState {
  phase: Phase;
  version?: string;
  notes?: string | null;
  error?: string | null;
  update?: Update;
}

const IDLE: UpdateState = { phase: "hidden" };

export function UpdateManager() {
  const [state, setState] = useState<UpdateState>(IDLE);

  const runCheck = async (silent: boolean) => {
    setState({ phase: "checking" });
    try {
      const update = await check();
      if (update) {
        setState({
          phase: "available",
          version: update.version,
          notes: update.body ?? null,
          update,
        });
      } else {
        setState(silent ? IDLE : { phase: "upToDate" });
      }
    } catch (error) {
      if (!silent) {
        setState({
          phase: "error",
          error: error instanceof Error ? error.message : String(error),
        });
      } else {
        setState(IDLE);
      }
    }
  };

  useEffect(() => {
    if (!inTauri) return;
    // Silent startup check.
    void runCheck(true);

    // Manual check trigger (header button).
    const listener = () => void runCheck(false);
    window.addEventListener("todd:check-updates", listener);
    return () => window.removeEventListener("todd:check-updates", listener);
  }, []);

  const installAndRelaunch = async () => {
    if (!state.update) return;
    setState((prev) => ({ ...prev, phase: "downloading" }));
    try {
      // Background download + signature verification + silent install.
      await state.update.downloadAndInstall();
      await relaunch();
    } catch (error) {
      setState({
        phase: "error",
        error: error instanceof Error ? error.message : String(error),
      });
    }
  };

  if (!inTauri || state.phase === "hidden") return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="w-full max-w-md rounded-lg border border-border bg-background p-6 shadow-2xl">
        {state.phase === "checking" && (
          <>
            <h2 className="text-lg font-semibold">Checking for updates…</h2>
            <p className="mt-2 text-sm text-muted-foreground">
              Contacting the update server.
            </p>
          </>
        )}

        {state.phase === "upToDate" && (
          <>
            <h2 className="text-lg font-semibold">You're up to date</h2>
            <p className="mt-2 text-sm text-muted-foreground">
              Todd Studio is running the latest version.
            </p>
            <div className="mt-5 flex justify-end">
              <Button variant="outline" onClick={() => setState(IDLE)}>
                Close
              </Button>
            </div>
          </>
        )}

        {state.phase === "available" && (
          <>
            <h2 className="text-lg font-semibold">
              Update available — v{state.version}
            </h2>
            {state.notes ? (
              <div className="mt-2 max-h-40 overflow-y-auto rounded-md border border-border bg-muted/40 p-3 text-xs whitespace-pre-wrap text-muted-foreground">
                {state.notes}
              </div>
            ) : (
              <p className="mt-2 text-sm text-muted-foreground">
                A newer version of Todd Studio is ready.
              </p>
            )}
            <div className="mt-5 flex justify-end gap-2">
              <Button variant="outline" onClick={() => setState(IDLE)}>
                Remind Me Later
              </Button>
              <Button onClick={() => void installAndRelaunch()}>
                Update &amp; Restart Now
              </Button>
            </div>
          </>
        )}

        {state.phase === "downloading" && (
          <>
            <h2 className="text-lg font-semibold">Installing update…</h2>
            <p className="mt-2 text-sm text-muted-foreground">
              Downloading and verifying the signed update. Todd Studio will
              restart automatically when it's done.
            </p>
          </>
        )}

        {state.phase === "error" && (
          <>
            <h2 className="text-lg font-semibold">Update failed</h2>
            <p className="mt-2 break-words text-sm text-destructive">
              {state.error ?? "Unknown error"}
            </p>
            <div className="mt-5 flex justify-end">
              <Button variant="outline" onClick={() => setState(IDLE)}>
                Close
              </Button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
