<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * NEXATRACE — CRICKET: Store image URLs as root-relative paths.
     *
     * Converts host-pinned absolute URLs persisted by Storage::url() at
     * upload time (e.g. "http://135.181.46.27/storage/teams/abc.jpg" or
     * "https://cricket.traceodd.com/storage/players/xyz.jpg") into
     * root-relative paths ("/storage/teams/abc.jpg") that every client
     * resolves against its own origin.
     *
     * SAFETY:
     *  - Only rows starting with "http" AND containing "/storage/" are
     *    touched. Pasted external URLs (no "/storage/") are left intact.
     *  - Original values are backed up in cricket_image_url_backups;
     *    down() restores them, making this migration reversible.
     */
    public function up(): void
    {
        Schema::create('cricket_image_url_backups', function (Blueprint $table) {
            $table->id();
            $table->string('entity_type', 20); // 'team' | 'player'
            $table->uuid('entity_id');
            $table->string('old_url', 500);
            $table->timestamps();
        });

        $this->stripHost('cricket_teams', 'logo_url', 'team');
        $this->stripHost('cricket_players', 'photo_url', 'player');
    }

    public function down(): void
    {
        $this->restore('cricket_teams', 'logo_url', 'team');
        $this->restore('cricket_players', 'photo_url', 'player');

        Schema::dropIfExists('cricket_image_url_backups');
    }

    /**
     * Rewrite "{scheme}://{host}/storage/..." to "/storage/..." for the
     * given table/column, backing up each original value first.
     */
    private function stripHost(string $table, string $column, string $entityType): void
    {
        $rows = DB::table($table)
            ->where($column, 'like', 'http%')
            ->whereRaw("position('/storage/' in {$column}) > 0")
            ->select('id', $column)
            ->get();

        foreach ($rows as $row) {
            DB::table('cricket_image_url_backups')->insert([
                'entity_type' => $entityType,
                'entity_id' => $row->id,
                'old_url' => $row->{$column},
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $relative = substr(
                $row->{$column},
                strpos($row->{$column}, '/storage/'),
            );

            DB::table($table)
                ->where('id', $row->id)
                ->update([$column => $relative]);
        }
    }

    /**
     * Restore original absolute URLs from the backup table.
     */
    private function restore(string $table, string $column, string $entityType): void
    {
        $backups = DB::table('cricket_image_url_backups')
            ->where('entity_type', $entityType)
            ->get();

        foreach ($backups as $backup) {
            DB::table($table)
                ->where('id', $backup->entity_id)
                ->update([$column => $backup->old_url]);
        }
    }
};
