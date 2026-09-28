<?php

namespace App\Console\Commands;

use App\Models\Product;
use App\Services\Marketplace\MarketplaceListingService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

/**
 * Backfills marketplace listings for factory products.
 *
 * The factory UI's publish action only flipped `products.marketplace_enabled`, so
 * `marketplace_product_listings` and `marketplace_storefronts` stayed empty and the
 * marketplace had nothing to show. The publish step is now wired (item #9 of
 * MASTER-TASK-LIST.md); this command applies it to products that were published
 * before the fix — and is the idempotent tool for any future re-sync.
 *
 * Default: every active product whose `marketplace_enabled` is already true.
 * `--all` : every active product (and it flips `marketplace_enabled` on).
 *
 * Idempotent: re-running updates the existing listing instead of duplicating it.
 *
 *   php artisan marketplace:publish-products              # dry check of the queue
 *   php artisan marketplace:publish-products --all        # publish the 6 existing products
 *   php artisan marketplace:publish-products --company=<uuid>
 */
class PublishMarketplaceListings extends Command
{
    protected $signature = 'marketplace:publish-products
                            {--company= : Only publish products of this company id}
                            {--all : Publish every active product, not only marketplace_enabled ones}
                            {--dry-run : Report what would be published without writing anything}';

    protected $description = 'Create/refresh marketplace storefronts and product listings from factory products';

    public function handle(MarketplaceListingService $marketplace): int
    {
        $query = Product::query()
            ->where('status', 'active')
            ->with('company');

        if ($company = $this->option('company')) {
            $query->where('company_id', $company);
        }

        if (! $this->option('all')) {
            $query->where('marketplace_enabled', true);
        }

        $products = $query->orderBy('created_at')->get();

        if ($products->isEmpty()) {
            $this->info('No products matched — nothing to publish.');

            return self::SUCCESS;
        }

        $dryRun = (bool) $this->option('dry-run');
        $published = 0;
        $failed = 0;

        foreach ($products as $product) {
            $label = sprintf('%s (%s)', $product->name, $product->id);

            if ($dryRun) {
                $this->line('  would publish  '.$label);

                continue;
            }

            try {
                // `--all` publishes products that were never toggled on, so keep the
                // product flag consistent with the listing we are about to create.
                if (! $product->marketplace_enabled) {
                    $product->marketplace_enabled = true;
                    $product->save();
                }

                $listing = $marketplace->publishProduct($product);

                if ($listing) {
                    $published++;
                    $this->info('  published  '.$label.'  ->  '.$listing->id);
                } else {
                    $failed++;
                    $this->warn('  SKIPPED  '.$label.' — product has no company');
                }
            } catch (\Throwable $e) {
                $failed++;
                $this->error('  FAILED  '.$label.' — '.$e->getMessage());

                Log::error('marketplace:publish-products failed for a product.', [
                    'product_id' => $product->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        if ($dryRun) {
            $this->info(sprintf('%d product(s) would be published.', $products->count()));

            return self::SUCCESS;
        }

        $this->info(sprintf('Published %d listing(s); %d failed.', $published, $failed));

        return $failed > 0 ? self::FAILURE : self::SUCCESS;
    }
}
