<?php

namespace App\Services\Cricket;

/**
 * ShotZoneMapper — canonical angle → cricket zone mapping.
 *
 * This is the single source of truth for directional shot names across
 * the whole ecosystem: the scoring payload, the Wagon Wheel analytics,
 * the bowler's Conceded Runs heat map, the Todd Studio popup text and
 * the Flutter / React mini-maps all read the SAME zone names from here.
 *
 * Convention (matches the existing analytics engine + the Flutter
 * ShotDirectionSheet, which the React WagonWheelMap mirrors):
 *   0°   = straight down the ground (towards the bowler's end)
 *   0–180°   = leg side  (mid-wicket, square leg, fine leg, long on)
 *   180–360° = off side  (third man, point, cover)
 */
class ShotZoneMapper
{
    /** Zone centers in degrees — leg side first, then off side. */
    private const ZONES = [
        ['name' => 'Straight', 'center' => 0],
        ['name' => 'Mid-Wicket', 'center' => 45],
        ['name' => 'Square Leg', 'center' => 90],
        ['name' => 'Fine Leg', 'center' => 135],
        ['name' => 'Long On', 'center' => 180],
        ['name' => 'Third Man', 'center' => 225],
        ['name' => 'Point', 'center' => 270],
        ['name' => 'Cover', 'center' => 315],
    ];

    /** Half-width of each zone wedge, in degrees. */
    private const WEDGE = 22.5;

    /**
     * Resolves a shot angle (0–359) to its zone name, or null when the
     * direction is absent. Values are normalized into 0–360 first.
     */
    public static function zone(mixed $degrees): ?string
    {
        if ($degrees === null || $degrees === '') {
            return null;
        }

        $angle = self::normalize((float) $degrees);

        foreach (self::ZONES as $zone) {
            if (self::withinWedge($angle, (float) $zone['center'])) {
                return $zone['name'];
            }
        }

        return 'Straight'; // unreachable safety net
    }

    /**
     * Leg/off side for an angle; null when the direction is absent.
     * 0° and 180° count as leg side (straight and long-on flank it).
     */
    public static function side(mixed $degrees): ?string
    {
        if ($degrees === null || $degrees === '') {
            return null;
        }

        $angle = self::normalize((float) $degrees);

        return $angle <= 180.0 ? 'leg' : 'off';
    }

    /** Full summary used in the snapshot: zone, side + normalized angle. */
    public static function summary(mixed $degrees): ?array
    {
        if ($degrees === null || $degrees === '') {
            return null;
        }

        $angle = self::normalize((float) $degrees);

        return [
            'direction' => $angle,
            'zone' => self::zone($angle),
            'side' => self::side($angle),
        ];
    }

    private static function normalize(float $degrees): float
    {
        $angle = fmod($degrees, 360.0);

        return $angle < 0 ? $angle + 360.0 : $angle;
    }

    private static function withinWedge(float $angle, float $center): bool
    {
        $delta = abs($angle - $center);
        if ($delta > 180.0) {
            $delta = 360.0 - $delta; // wrap across 0°/360°
        }

        return $delta <= self::WEDGE;
    }
}
