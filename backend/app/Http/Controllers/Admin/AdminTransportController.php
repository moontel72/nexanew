<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class AdminTransportController extends Controller
{
    public function walletStats()
    {
        $totalWallets = 0;
        $totalBalance = 0.0;
        $transactions24h = 0;
        $suspicious24h = 0;

        if (Schema::hasTable('wallets')) {
            $totalWallets = (int) DB::table('wallets')->count();
            $totalBalance = (float) DB::table('wallets')->sum('balance');
        }

        if (Schema::hasTable('wallet_transactions')) {
            $since = now()->subDay();
            $transactions24h = (int) DB::table('wallet_transactions')
                ->where('created_at', '>=', $since)
                ->count();

            $suspicious24h = (int) DB::table('wallet_transactions')
                ->where('created_at', '>=', $since)
                ->whereIn('type', ['penalty', 'failed', 'fraud'])
                ->count();
        }

        return response()->json([
            'success' => true,
            'data' => [
                'total_wallets' => $totalWallets,
                'total_balance' => $totalBalance,
                'transactions_24h' => $transactions24h,
                'suspicious_24h' => $suspicious24h,
            ],
        ]);
    }

    public function marketplaceStats()
    {
        $totalLoads = 0;
        $openLoads = 0;
        $totalBids = 0;
        $activeTrips = 0;

        if (Schema::hasTable('loads')) {
            $totalLoads = (int) DB::table('loads')->count();
            $openLoads = (int) DB::table('loads')->whereIn('status', ['posted', 'open'])->count();
        }

        if (Schema::hasTable('bids')) {
            $totalBids = (int) DB::table('bids')->count();
        }

        if (Schema::hasTable('trips')) {
            $activeTrips = (int) DB::table('trips')->whereIn('status', ['active', 'in_progress'])->count();
        }

        return response()->json([
            'success' => true,
            'data' => [
                'total_loads' => $totalLoads,
                'open_loads' => $openLoads,
                'total_bids' => $totalBids,
                'active_trips' => $activeTrips,
            ],
        ]);
    }

    public function driversStats()
    {
        $totalDrivers = 0;
        $activeDrivers = 0;
        $activeTrips = 0;
        $earningsThisMonth = 0.0;

        if (Schema::hasTable('transport_drivers')) {
            $totalDrivers = (int) DB::table('transport_drivers')->count();
            $activeDrivers = (int) DB::table('transport_drivers')
                ->whereIn('status', ['active', 'verified'])
                ->count();
        }

        if (Schema::hasTable('trips')) {
            $activeTrips = (int) DB::table('trips')->whereIn('status', ['active', 'in_progress'])->count();
        }

        if (Schema::hasTable('wallet_transactions')) {
            $start = now()->startOfMonth();
            $earningsThisMonth = (float) DB::table('wallet_transactions')
                ->where('created_at', '>=', $start)
                ->whereIn('type', ['trip_payment', 'commission'])
                ->sum('amount');
        }

        return response()->json([
            'success' => true,
            'data' => [
                'total_drivers' => $totalDrivers,
                'active_drivers' => $activeDrivers,
                'active_trips' => $activeTrips,
                'earnings_this_month' => $earningsThisMonth,
            ],
        ]);
    }
}

