<?php

namespace App\Http\Controllers\Transport;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class FraudController extends Controller
{
    public function stats()
    {
        $pending = 0;
        $confirmed = 0;
        $penaltiesApplied = 0;

        if (Schema::hasTable('fraud_reports')) {
            $pending = (int) DB::table('fraud_reports')->whereIn('status', ['pending', 'open'])->count();
            $confirmed = (int) DB::table('fraud_reports')->whereIn('status', ['confirmed', 'resolved'])->count();
        }

        if (Schema::hasTable('wallet_transactions')) {
            $penaltiesApplied = (int) DB::table('wallet_transactions')
                ->where('type', 'penalty')
                ->count();
        }

        return response()->json([
            'success' => true,
            'data' => [
                'pending_reports' => $pending,
                'confirmed_reports' => $confirmed,
                'penalties_applied' => $penaltiesApplied,
            ],
        ]);
    }
}

