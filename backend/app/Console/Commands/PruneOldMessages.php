<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PruneOldMessages extends Command
{
    protected $signature = 'messages:prune {--days=60 : Days to retain messages}';
    protected $description = 'Prune fleet assignment messages older than the retention period';

    public function handle(): int
    {
        $days = (int) $this->option('days');
        $cutoff = now()->subDays($days);

        $deleted = DB::table('fleet_assignment_messages')
            ->where('created_at', '<', $cutoff)
            ->delete();

        Log::info("PruneOldMessages: removed {$deleted} messages older than {$days} days.");
        $this->info("Pruned {$deleted} messages older than {$days} days.");

        return 0;
    }
}
