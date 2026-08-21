import { useEffect, useMemo, useRef, useState } from "react";
import { api, ApiError } from "../lib/api/client";
import type {
  CricketConfigUpdate,
  CricketConfigView,
  CricketMatchConfig,
  MatchSyncState,
} from "../lib/api/types";
import { useControlState } from "../hooks/useControlState";
import { env, cn } from "../lib/utils";
import { getToken } from "../lib/auth/authStore";
import { Button } from "./ui/Button";

const SYNC_BADGE: Record<MatchSyncState, string> = {
  synced: "bg-emerald-500/20 text-emerald-400",
  error: "bg-destructive/20 text-destructive",
  pending: "bg-amber-500/20 text-amber-400",
};

const TRANSPORT_LABEL = {
  push: "push",
  poll: "poll",
  pending: "—",
} as const;

interface SettingsForm {
  pollMs: string;
  token: string;
  matches: CricketMatchConfig[];
}

function formFromConfig(config: CricketConfigView): SettingsForm {
  return {
    pollMs: String(config.poll_ms),
    token: "",
    matches: config.match_configs.map((match) => ({ ...match })),
  };
}

function formattedTime(epochMs: number): string {
  return new Date(epochMs).toLocaleTimeString();
}

/**
 * Cricket Manager sync settings: match ids, API token, poll interval and
 * live sync health. Changes are applied server-side (`PUT
 * /api/v1/cricket/config`) and broadcast to every director panel.
 */
export function SettingsPanel() {
  const control = useControlState();

  const [form, setForm] = useState<SettingsForm>(() => ({
    pollMs: "",
    token: "",
    matches: [],
  }));
  const [dirty, setDirty] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);
  const hydratedRef = useRef(false);

  const config: CricketConfigView | null = control.cricket;

  // Hydrate the form from the control-plane state; fall back to a one-off
  // REST fetch when the feed has not delivered a config yet.
  useEffect(() => {
    if (config) {
      if (!dirty) setForm(formFromConfig(config));
      hydratedRef.current = true;
      return;
    }
    if (hydratedRef.current || !getToken()) return;
    let cancelled = false;
    api
      .getCricketConfig(getToken())
      .then((fetched) => {
        if (!cancelled) {
          setForm(formFromConfig(fetched));
          hydratedRef.current = true;
        }
      })
      .catch(() => {
        // The control feed will deliver the config once connected.
      });
    return () => {
      cancelled = true;
    };
  }, [config, dirty]);

  const syncByMatch = useMemo(() => {
    const map = new Map<string, CricketConfigView["sync"][number]>();
    config?.sync.forEach((status) => map.set(status.match_id, status));
    return map;
  }, [config]);

  const setField = (patch: Partial<SettingsForm>) => {
    setForm((current) => ({ ...current, ...patch }));
    setDirty(true);
    setSaved(false);
  };

  const setMatch = (index: number, patch: Partial<CricketMatchConfig>) => {
    setForm((current) => ({
      ...current,
      matches: current.matches.map((match, i) => (i === index ? { ...match, ...patch } : match)),
    }));
    setDirty(true);
    setSaved(false);
  };

  const addMatchRow = () => {
    setForm((current) => ({
      ...current,
      matches: [...current.matches, { match_id: "", label: "" }],
    }));
    setDirty(true);
    setSaved(false);
  };

  const removeMatchRow = (index: number) => {
    setForm((current) => ({
      ...current,
      matches: current.matches.filter((_, i) => i !== index),
    }));
    setDirty(true);
    setSaved(false);
  };

  const handleSave = () => {
    setBusy(true);
    setError(null);
    setSaved(false);

    const matches = form.matches
      .map((match) => ({ ...match, match_id: match.match_id.trim() }))
      .filter((match) => match.match_id.length > 0);

    const pollMs = Number(form.pollMs);
    if (!Number.isInteger(pollMs) || pollMs < 500) {
      setError("Poll interval must be an integer ≥ 500 ms");
      setBusy(false);
      return;
    }

    // Only send the token when the director typed one; a blank field must
    // keep the stored server-side value instead of wiping it.
    const payload: CricketConfigUpdate = {
      match_configs: matches,
      poll_ms: pollMs,
    };
    const token = form.token.trim();
    if (token) payload.api_token = token;

    api
      .updateCricketConfig(payload, getToken())
      .then(() => {
        setSaved(true);
        setDirty(false);
        // Keep the token field empty after a successful save; the
        // configured value is never echoed back by the API.
        setForm((current) => ({ ...current, token: "" }));
      })
      .catch((saveError: Error) => {
        setError(saveError instanceof ApiError ? saveError.message : saveError.message);
      })
      .finally(() => setBusy(false));
  };

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Cricket Manager
      </header>

      <div className="flex flex-col gap-1 text-xs">
        <span className="text-muted-foreground">Manager API</span>
        <span className="truncate font-mono">{config?.base_url ?? env.cricketManagerUrl}</span>
      </div>

      {/* Unified realtime state: push-first, poll as watchdog fallback. */}
      <div className="flex flex-col gap-1 text-xs">
        <div className="flex items-center justify-between">
          <span className="text-muted-foreground">Realtime transport</span>
          <span
            className={cn(
              "rounded px-1.5 py-0.5 text-[10px] font-semibold",
              config?.push_connected
                ? "bg-emerald-500/20 text-emerald-400"
                : "bg-amber-500/20 text-amber-400",
            )}
          >
            {config?.push_connected ? "push live" : "poll fallback"}
          </span>
        </div>
        <div className="flex items-center justify-between">
          <span className="text-muted-foreground">Active match (manager)</span>
          <span className="max-w-[55%] truncate font-mono">
            {config?.active_match_id ?? "—"}
          </span>
        </div>
        <p className="text-[10px] text-muted-foreground">
          Selecting a match in the Cricket Manager switches this studio
          automatically — no manual match ids or polling required.
        </p>
      </div>

      {/* Match list */}
      <div className="flex flex-col gap-2">
        <div className="flex items-center justify-between">
          <span className="text-xs text-muted-foreground">Matches</span>
          <Button variant="outline" className="px-2 py-1 text-xs" onClick={addMatchRow}>
            + Match
          </Button>
        </div>

        {form.matches.length === 0 && (
          <div className="text-xs text-muted-foreground">
            No matches synced — the scoreboard lower-third stays empty.
          </div>
        )}

        {form.matches.map((match, index) => {
          const status = syncByMatch.get(match.match_id);
          return (
            <div key={index} className="flex flex-col gap-1 rounded-md border border-border bg-background/60 p-2">
              <div className="flex items-center justify-between gap-2">
                <input
                  className="min-w-0 flex-1 rounded-md border border-input bg-background px-2 py-1 font-mono text-xs"
                  placeholder="match id"
                  value={match.match_id}
                  onChange={(event) => setMatch(index, { match_id: event.target.value })}
                />
                <Button
                  variant="destructive"
                  className="px-2 py-1 text-xs"
                  onClick={() => removeMatchRow(index)}
                >
                  ✕
                </Button>
              </div>
              <div className="flex items-center gap-2">
                <input
                  className="min-w-0 flex-1 rounded-md border border-input bg-background px-2 py-1 text-xs"
                  placeholder="label (shown in settings)"
                  value={match.label}
                  onChange={(event) => setMatch(index, { label: event.target.value })}
                />
                {status ? (
                  <span
                    className={cn("shrink-0 rounded px-1.5 py-0.5 text-[10px] font-semibold", SYNC_BADGE[status.state])}
                    title={
                      status.state === "error"
                        ? `last error: ${status.last_error ?? "unknown"}`
                        : status.last_ok_at_ms
                          ? `last synced ${formattedTime(status.last_ok_at_ms)} via ${status.transport}`
                          : undefined
                    }
                  >
                    {status.state}
                    {status.transport !== "pending" ? ` · ${TRANSPORT_LABEL[status.transport]}` : ""}
                  </span>
                ) : (
                  <span className="shrink-0 rounded bg-muted px-1.5 py-0.5 text-[10px] text-muted-foreground">
                    new
                  </span>
                )}
              </div>
            </div>
          );
        })}
      </div>

      {/* Poll interval + API token */}
      <div className="grid grid-cols-2 gap-2">
        <label className="flex flex-col gap-1 text-xs text-muted-foreground">
          Poll interval (ms)
          <input
            className="rounded-md border border-input bg-background px-2 py-1 font-mono text-xs text-foreground"
            inputMode="numeric"
            value={form.pollMs}
            onChange={(event) => setField({ pollMs: event.target.value })}
          />
        </label>
        <label className="flex flex-col gap-1 text-xs text-muted-foreground">
          API token
          <input
            className="rounded-md border border-input bg-background px-2 py-1 font-mono text-xs text-foreground"
            type="password"
            placeholder={config?.api_token_set ? "configured — leave blank to keep" : "not set"}
            value={form.token}
            onChange={(event) => setField({ token: event.target.value })}
          />
          <span className="text-[10px] text-muted-foreground">
            Optional — only used by the fallback poll when the live feed is
            a private endpoint.
          </span>
        </label>
      </div>

      <Button onClick={handleSave} disabled={busy || !dirty}>
        {busy ? "Saving…" : "Save Sync Config"}
      </Button>

      {saved && (
        <div className="rounded-md bg-accent/10 p-2 text-xs text-accent">
          Sync configuration saved — the engine applies it on the next poll round.
        </div>
      )}
      {error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">{error}</div>
      )}
    </section>
  );
}
