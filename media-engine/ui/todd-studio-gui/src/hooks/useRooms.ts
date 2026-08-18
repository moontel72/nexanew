import { useEffect, useState } from "react";
import { api } from "../lib/api/client";
import type { Room } from "../lib/api/types";

/** Polls the active room list (admin token). */
export function useRooms(token: string, pollMs = 5000) {
  const [rooms, setRooms] = useState<Room[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!token) return;
    let cancelled = false;

    const poll = async () => {
      try {
        const next = await api.listRooms(token);
        if (!cancelled) {
          setRooms(next);
          setError(null);
        }
      } catch (e) {
        if (!cancelled) setError((e as Error).message);
      }
    };

    poll();
    const id = setInterval(poll, pollMs);
    return () => {
      cancelled = true;
      clearInterval(id);
    };
  }, [token, pollMs]);

  return { rooms, error };
}
