import { useEffect, useState } from "react";
import { CharacterPop } from "./CharacterPop";
import { Overlay3D } from "./Overlay3D";

export interface OverlayControllerProps {
  /** Event label driving the pop (SIX / FOUR / OUT / …). */
  event: string | null;
  /** Auto-clear the overlay after this many ms. */
  durationMs?: number;
}

/**
 * Triggers a transparent 3D character pop on match events. Re-mounts the
 * character on each event (`key`), restarting the pop-in animation.
 */
export function OverlayController({
  event,
  durationMs = 2500,
}: OverlayControllerProps) {
  const [active, setActive] = useState<string | null>(null);

  useEffect(() => {
    if (!event) return;
    setActive(event);
    const id = setTimeout(() => setActive(null), durationMs);
    return () => clearTimeout(id);
  }, [event, durationMs]);

  if (!active) return null;

  return (
    <Overlay3D>
      {/* The key restarts the animation on every new event. */}
      <CharacterPop key={active} />
    </Overlay3D>
  );
}
