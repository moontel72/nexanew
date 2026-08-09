<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Cricket Module — Vertical & Feature Registry Seeder
 *
 * Registers the 5th sub-admin vertical (cricket_ops) and all cricket
 * feature codes into the existing feature_registry system.
 *
 * This is ADDITIVE only — inserts new rows into:
 *   - sub_admin_verticals
 *   - feature_registry
 *
 * Uses upsert() for idempotent re-runs. Zero deletion of existing data.
 */
class CricketFeatureRegistrySeeder extends Seeder
{
    public function run(): void
    {
        $this->seedCricketVertical();
        $this->seedCricketFeatures();
    }

    private function seedCricketVertical(): void
    {
        DB::table('sub_admin_verticals')->upsert(
            [
                'id'                           => (string) Str::uuid(),
                'code'                         => 'cricket_ops',
                'display_name'                 => 'Sub-Admin 5 — Cricket Tournament Operations',
                'default_feature_bundle_codes' => json_encode([
                    'cricket.tournaments.*',
                    'cricket.managers.*',
                    'cricket.scores.*',
                    'cricket.streams.*',
                    'cricket.sponsors.*',
                ]),
                'created_at'                   => now(),
                'updated_at'                   => now(),
            ],
            ['code'],
            ['display_name', 'default_feature_bundle_codes', 'updated_at']
        );

        $this->command?->info('  Cricket vertical registered: cricket_ops');
    }

    private function seedCricketFeatures(): void
    {
        $cricketVerticalId = DB::table('sub_admin_verticals')
            ->where('code', 'cricket_ops')
            ->value('id');

        $now = now();

        $features = [
            [
                'code'                => 'cricket.tournaments.manage',
                'module_name'         => 'Cricket Tournament Management',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'CRUD cricket tournaments and configure tournament settings',
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.tournaments.activate',
                'module_name'         => 'Cricket Tournament Activation',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'Activate/deactivate tournaments (sleep mode toggle)',
                'is_destructive'      => true,
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.managers.provision',
                'module_name'         => 'Cricket Manager Provisioning',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'Create, suspend, and manage Cricket Manager accounts',
                'severity'            => 'elevated',
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.teams.manage',
                'module_name'         => 'Cricket Team Management',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'CRUD teams and player rosters within a tournament',
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.matches.schedule',
                'module_name'         => 'Cricket Match Scheduling',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'Schedule matches, assign teams, configure match parameters',
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.matches.manage',
                'module_name'         => 'Cricket Match Management',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'Toss, start/end matches, assign Cricket Managers to matches',
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.scores.update',
                'module_name'         => 'Cricket Live Score Update',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'Update live scores ball-by-ball via Cricket Manager panel',
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.scores.undo',
                'module_name'         => 'Cricket Score Undo',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'Undo the last ball in the current innings',
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.streams.manage',
                'module_name'         => 'Cricket Stream Management',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'Configure multi-camera RTMP streams and HLS CDN endpoints',
                'severity'            => 'elevated',
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.streams.activate',
                'module_name'         => 'Cricket Stream Activation',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'Activate/deactivate individual camera streams during a match',
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.sponsors.manage',
                'module_name'         => 'Cricket Sponsor Management',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'Manage sponsor accounts and assign sponsors to matches',
                'is_active'           => true,
            ],
            [
                'code'                => 'cricket.voice.score',
                'module_name'         => 'Cricket Voice-to-Score AI',
                'vertical_default_id' => $cricketVerticalId,
                'description'         => 'DeepSeek V4 Pro voice-to-score parsing for live match scoring',
                'is_active'           => true,
            ],
        ];

        foreach ($features as $f) {
            DB::table('feature_registry')->upsert(
                array_merge($f, ['created_at' => $now, 'updated_at' => $now]),
                ['code'],
                ['module_name', 'description', 'severity', 'is_destructive', 'vertical_default_id', 'is_active', 'updated_at']
            );
        }

        $count = DB::table('feature_registry')->where('code', 'like', 'cricket.%')->count();
        $this->command?->info("  Cricket features seeded: {$count} feature codes registered.");
    }
}
