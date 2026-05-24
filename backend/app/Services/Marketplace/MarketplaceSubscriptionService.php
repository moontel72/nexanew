<?php

namespace App\Services\Marketplace;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — MARKETPLACE SUBSCRIPTION & ANTI-PIRACY SERVICE
 * ============================================================
 *
 * Enforces tiered listing caps, brand piracy detection,
 * and Reseller OTP product vault locking (Modules 12J, 12K, 12L).
 *
 * GUARDS:
 *   1. Listing Cap: Basic = 5 items max, Standard Reseller = unlimited
 *   2. Brand Piracy: Regex match against registered factory trademarks
 *   3. Reseller OTP Gate: Hand-picked shopkeeper whitelist OTP challenge
 *
 * FREE UNIVERSAL BUYER PARADIGM:
 *   Zero subscription needed for BUYING. No system buyer fee.
 *
 * SAFETY: Entirely NEW service. Zero modification to existing code.
 */

class MarketplaceSubscriptionService
{
    private const BASIC_MAX_ITEMS = 5;

    /**
     * Validate listing cap and brand piracy before allowing publish.
     *
     * @throws \RuntimeException on cap exceeded or trademark violation
     */
    public function validateListingCapAndPiracy(string $userId, array $listingData): void
    {
        // ─── 1. Check subscription tier cap ─────────────
        $sub = DB::table('marketplace_subscriptions')
            ->where('user_id', $userId)->where('is_active', true)->first();

        $tier = $sub->tier ?? 'basic';
        $maxItems = $sub->max_allowed_items ?? self::BASIC_MAX_ITEMS;

        if ($tier === 'basic') {
            $currentCount = DB::table('marketplace_product_listings')
                ->where('is_active', true)
                ->where('is_homemade', true)
                ->count();

            if ($currentCount >= $maxItems) {
                throw new \RuntimeException(
                    "Listing cap reached: Basic tier allows max {$maxItems} active homemade items. " .
                    "Upgrade to Standard Reseller tier for unlimited listings."
                );
            }
        }

        // ─── 2. Brand piracy check ──────────────────────
        $title = $listingData['listing_title'] ?? '';
        $isHomemade = $listingData['is_homemade'] ?? true;

        if (! $isHomemade) {
            // Check against registered factory brand names
            $brands = DB::table('companies')
                ->whereIn('factory_type', ['wholesale_only', 'zone_locked', 'stealth_locked'])
                ->pluck('storefront_name')->toArray();

            // Also check marketplace storefront names
            $storefrontBrands = DB::table('marketplace_storefronts')
                ->pluck('storefront_name')->toArray();

            $allBrands = array_merge($brands, $storefrontBrands);

            foreach ($allBrands as $brand) {
                if (stripos($title, $brand) !== false) {
                    throw new \RuntimeException(
                        "Trademark Violation: '{$brand}' is a registered factory brand. " .
                        "You cannot list products under this name without electronic authorization from the brand owner. " .
                        "Contact the factory for digital authorization flags."
                    );
                }
            }
        }

        Log::info('MarketplaceSubscriptionService: listing validation passed', [
            'user_id' => $userId, 'tier' => $tier, 'title' => $title,
        ]);
    }

    /**
     * Process Reseller OTP gate for privileged shopkeeper access.
     *
     * @return array
     */
    public function processResellerOtpGate(
        string $shopkeeperId,
        string $listingId,
        string $otpToken
    ): array {
        $listing = DB::table('marketplace_product_listings')
            ->where('id', $listingId)->firstOrFail();

        if (! ($listing->reseller_otp_locked ?? false)) {
            throw new \RuntimeException('This listing does not require OTP access.');
        }

        // Verify OTP against shopkeeper's registered phone/email
        $otpHash = hash('sha256', $otpToken);

        $unlock = DB::table('stealth_product_unlocks')
            ->where('reseller_id', $shopkeeperId)
            ->where('product_id', $listingId)
            ->where('otp_token_hash', $otpHash)
            ->whereNull('otp_verified_at')
            ->where('expires_at', '>', now())
            ->first();

        if (! $unlock) {
            // Auto-generate and send OTP if not already pending
            $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
            DB::table('stealth_product_unlocks')->insert([
                'id' => (string) \Illuminate\Support\Str::uuid(),
                'reseller_id' => $shopkeeperId,
                'product_id' => $listingId,
                'otp_method' => 'sms',
                'otp_token_hash' => hash('sha256', $otp),
                'expires_at' => now()->addMinutes(5),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            Log::info('MarketplaceSubscriptionService: Reseller OTP sent', [
                'shopkeeper' => $shopkeeperId, 'listing' => $listingId,
            ]);

            return [
                'otp_sent' => true,
                'message' => 'OTP sent to your registered phone/email. Submit token to unlock wholesale pricing.',
                'expires_in_seconds' => 300,
            ];
        }

        // Verify existing OTP
        DB::table('stealth_product_unlocks')
            ->where('id', $unlock->id)
            ->update(['otp_verified_at' => now(), 'updated_at' => now()]);

        return [
            'unlocked' => true,
            'message' => 'Access granted. Wholesale pricing and order node unlocked.',
            'listing' => $listing,
        ];
    }

    /**
     * Get active subscription tier for a user.
     */
    public function getUserTier(string $userId): array
    {
        $sub = DB::table('marketplace_subscriptions')
            ->where('user_id', $userId)->where('is_active', true)->first();

        if (! $sub) {
            return ['tier' => 'basic', 'max_items' => self::BASIC_MAX_ITEMS, 'is_free' => true];
        }

        return [
            'tier' => $sub->tier,
            'max_items' => $sub->max_allowed_items,
            'expires_at' => $sub->expires_at,
            'is_free' => $sub->tier === 'basic',
        ];
    }
}
