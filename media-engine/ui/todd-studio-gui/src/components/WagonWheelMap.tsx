// WagonWheelMap — live mini ground map for the director panel.
//
// Phase 3: a small wagon-wheel view that mirrors the scorer's shot
// direction in real time. When a ball carries `shot_direction` data,
// the marker + wedge animate to the exact region; hovering anywhere on
// the map resolves the angle under the cursor into the canonical zone
// name automatically (no manual direction entry anywhere).
//
// Pure presentation — reads the push-fed control state; no extra
// network traffic, no component-logic coupling.

import { useMemo, useState } from "react";
import { useControlState } from "../hooks/useControlState";
import type { BallEventDto } from "../lib/api/types";

/** Canonical 8-zone wedge map — must match the Laravel ShotZoneMapper. */
const ZONES: Array<{ name: string; center: number }> = [
  { name: "Straight", center: 0 },
  { name: "Mid-Wicket", center:45 },
  { name: "Square Leg", center: 90 },
  { name: "Fine Leg", center: 135 },
  { name: "Long On", center: 180 },
  { name: "Third Man", center: 225 },
  { name: "Point", center: 270 },
  { name: "Cover", center: 315 },
];

const CX = 100;
const CY = 92;
const RX = 84;
const RY = 62;

function zoneForAngle(angle: number): string {
  const normalized = ((angle % 360) + 360) % 360;
  for (const zone of ZONES) {
    let delta = Math.abs(normalized - zone.center);
    if (delta > 180) delta = 360 - delta;
    if (delta <= 22.5) return zone.name;
  }
  return "Straight";
}

/** Polar point for a cricket angle (0 = straight = up on the map). */
function pointForAngle(angle: number, rx = RX, ry = RY): [number, number] {
  const rad = (angle * Math.PI) / 180;
  return [CX + rx * Math.sin(rad), CY - ry * Math.cos(rad)];
}

/** SVG arc path for a zone wedge between two angles. */
function wedgePath(start: number, end: number): string {
  const [x1, y1] = pointForAngle(start);
  const [x2, y2] = pointForAngle(end);
  return `M ${CX} ${CY} L ${x1.toFixed(2)} ${y1.toFixed(2)} A ${RX} ${RY} 0 0 1 ${x2.toFixed(2)} ${y2.toFixed(2)} Z`;
}

export function WagonWheelMap() {
  const control = useControlState();
  const [cursor, setCursor] = useState<{ x: number; y: number; angle: number } | null>(null);

  const matchId =
    control.cricket?.active_match_id ??
    control.cricket?.match_configs[0]?.match_id ??
    null;
  const score = matchId ? (control.scores[matchId] ?? null) : null;
  const shot: BallEventDto | null = score?.last_event ?? null;

  const marker = useMemo(() => {
    if (!shot || typeof shot.direction !== "number") return null;
    const [x, y] = pointForAngle(shot.direction, RX * 0.82, RY * 0.82);
    return { x, y, angle: shot.direction, zone: shot.zone ?? zoneForAngle(shot.direction) };
  }, [shot]);

  const hoveredZone = cursor ? zoneForAngle(cursor.angle) : null;

  // Mouse-over the map → angle under the cursor → zone fetched
  // automatically (the scorer-facing twin of this map submits it).
  const onMouseMove = (event: React.MouseEvent<SVGSVGElement>) => {
    const rect = event.currentTarget.getBoundingClientRect();
    const x = ((event.clientX - rect.left) / rect.width) * 200;
    const y = ((event.clientY - rect.top) / rect.height) * 200;
    const dx = x - CX;
    const dy = CY - y; // flip: map y grows downward
    const angle = ((Math.atan2(dx, dy) * 180) / Math.PI + 360) % 360;
    setCursor({ x, y, angle });
  };

  const cursorPoint = cursor ? pointForAngle(cursor.angle) : null;

  return (
    <section className="flex flex-col gap-2 rounded-md border border-border bg-muted/40 p-3">
      <header className="flex items-center justify-between text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Wagon Wheel
        <span className="font-mono text-[10px] normal-case">
          {matchId ?? "no match"}
        </span>
      </header>

      <svg
        viewBox="0 0 200 200"
        className="w-full select-none rounded-md border border-border bg-background/60"
        onMouseMove={onMouseMove}
        onMouseLeave={() => setCursor(null)}
      >
        {/* Zone wedges */}
        {ZONES.map((zone) => {
          const start = zone.center - 22.5;
          const end = zone.center + 22.5;
          const active =
            marker?.zone === zone.name || hoveredZone === zone.name;
          return (
            <path
              key={zone.name}
              d={wedgePath(start, end)}
              fill={active ? "hsl(var(--accent) / 0.35)" : "hsl(var(--muted) / 0.25)"}
              stroke="hsl(var(--border))"
              strokeWidth="0.5"
            />
          );
        })}

        {/* Boundary + pitch */}
        <ellipse
          cx={CX}
          cy={CY}
          rx={RX}
          ry={RY}
          fill="none"
          stroke="hsl(var(--muted-foreground) / 0.6)"
          strokeWidth="1.5"
        />
        <rect x={CX - 4} y={CY + RY - 46} width={8} height={46} rx={2} fill="hsl(var(--muted))" />
        <circle cx={CX} cy={CY} r={3} fill="hsl(var(--foreground))" />

        {/* Zone labels (subtle, on the wedge centers) */}
        {ZONES.map((zone) => {
          const [x, y] = pointForAngle(zone.center, RX * 0.62, RY * 0.62);
          return (
            <text
              key={zone.name}
              x={x}
              y={y}
              textAnchor="middle"
              dominantBaseline="middle"
              className="fill-muted-foreground"
              fontSize="6.5"
              opacity="0.75"
            >
              {zone.name}
            </text>
          );
        })}

        {/* Live shot marker (animated when a directional ball arrives) */}
        {marker && (
          <g>
            <line
              x1={CX}
              y1={CY}
              x2={marker.x}
              y2={marker.y}
              stroke="hsl(var(--accent))"
              strokeWidth="2"
            />
            <circle cx={marker.x} cy={marker.y} r="7" className="wagon-marker" />
            <circle cx={marker.x} cy={marker.y} r="3" fill="hsl(var(--accent))" />
          </g>
        )}

        {/* Hover cursor + auto-fetched zone label under the pointer */}
        {cursorPoint && (
          <g pointerEvents="none">
            <circle
              cx={cursorPoint[0]}
              cy={cursorPoint[1]}
              r="4"
              fill="none"
              stroke="hsl(var(--ring))"
              strokeWidth="1"
            />
            <text
              x={cursorPoint[0]}
              y={cursorPoint[1] - 10}
              textAnchor="middle"
              fontSize="8"
              className="fill-foreground"
            >
              {hoveredZone}
            </text>
          </g>
        )}
      </svg>

      <div className="flex items-center justify-between text-[11px] text-muted-foreground">
        <span className="truncate">
          {marker
            ? `Last: ${marker.zone} · ${Math.round(marker.angle)}°`
            : shot
              ? shot.text
              : "Hover the map to read a zone"}
        </span>
        {cursor && (
          <span className="font-mono">{Math.round(cursor.angle)}°</span>
        )}
      </div>
    </section>
  );
}
