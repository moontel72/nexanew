<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\CompanySubscription;
use App\Models\Invoice;
use App\Models\SubscriptionPlan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Product::query()->where('company_id', $user->company_id);

        if ($search = $request->query('search')) {
            $search = (string) $search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                    ->orWhere('sku', 'ilike', "%{$search}%");
            });
        }

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        $page = (int) $request->query('page', 1);
        $limit = (int) $request->query('limit', 20);
        $limit = max(1, min(100, $limit));

        $paginator = $query->orderByDesc('created_at')->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'data' => [
                'products' => $paginator->items(),
                'total' => $paginator->total(),
                'page' => $paginator->currentPage(),
                'limit' => $paginator->perPage(),
                'total_pages' => $paginator->lastPage(),
            ],
        ]);
    }

    public function show(Request $request, Product $product)
    {
        $this->assertCompany($request, $product);
        return response()->json(['success' => true, 'data' => $product]);
    }

    public function store(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'sku' => ['required', 'string', 'max:100', 'unique:products,sku'],
            'description' => ['nullable', 'string'],
            'category' => ['nullable', 'string', 'max:100'],
            'product_type' => ['required', 'string', 'max:50'],
            'requires_manufacturing_date' => ['nullable', 'boolean'],
            'requires_expiry_date' => ['nullable', 'boolean'],
            'requires_warranty' => ['nullable', 'boolean'],
            'default_warranty_months' => ['nullable', 'integer', 'min:0'],
            'default_storage_conditions' => ['nullable', 'string'],
            'default_handling_instructions' => ['nullable', 'string'],
            'image_urls' => ['nullable', 'array'],
            'status' => ['nullable', Rule::in(['active', 'inactive', 'archived'])],
            'metadata' => ['nullable', 'array'],
            'unit_price' => 'nullable|numeric|min:0',
            'carton_price' => 'nullable|numeric|min:0',
            'wholesale_price' => 'nullable|numeric|min:0',
            'currency' => 'nullable|string|size:3',
            'discount_type' => 'nullable|string|in:percentage,fixed',
            'discount_value' => 'nullable|numeric|min:0',
            'moq' => 'nullable|integer|min:1',
            'marketplace_enabled' => 'nullable|boolean',
            'bonus_quantity' => 'nullable|integer|min:1',
            'bonus_threshold' => 'nullable|integer|min:1',
            'wallet_credit' => 'nullable|numeric|min:0',
            'promo_code' => 'nullable|string|max:50',
            'promo_discount' => 'nullable|numeric|min:0|max:100',
            'tags' => 'nullable|array',
            'volume_discounts' => 'nullable|array',
        ]);

        // Handle image upload (single file via multipart/form-data)
        $imageUrls = $this->handleImageUpload($request);

        // Merge uploaded image URLs with any manually provided image_urls
        $existingUrls = $data['image_urls'] ?? [];
        $data['image_urls'] = array_merge($existingUrls, $imageUrls);

        // Build metadata, setting image_url for backward compatibility with Flutter marketplace.
        // Only override image_url if a new image was actually uploaded in this request.
        // Otherwise, preserve whatever was sent in metadata (e.g. from Flutter's generic upload flow).
        $existingMeta = $data['metadata'] ?? [];
        if (!empty($data['image_urls'])) {
            $existingMeta['image_url'] = $data['image_urls'][0];
        } elseif (empty($existingMeta['image_url'])) {
            $existingMeta['image_url'] = null;
        }
        $data['metadata'] = $existingMeta;

        $product = Product::query()->create(array_merge(
            ['id' => (string) Str::uuid(), 'company_id' => $user->company_id],
            $data,
            ['status' => $data['status'] ?? 'active']
        ));

        return response()->json(['success' => true, 'data' => $product], 201);
    }

    public function update(Request $request, Product $product)
    {
        $this->assertCompany($request, $product);

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'sku' => ['sometimes', 'string', 'max:100', Rule::unique('products', 'sku')->ignore($product->id, 'id')],
            'description' => ['sometimes', 'nullable', 'string'],
            'category' => ['sometimes', 'nullable', 'string', 'max:100'],
            'product_type' => ['sometimes', 'string', 'max:50'],
            'requires_manufacturing_date' => ['sometimes', 'boolean'],
            'requires_expiry_date' => ['sometimes', 'boolean'],
            'requires_warranty' => ['sometimes', 'boolean'],
            'default_warranty_months' => ['sometimes', 'nullable', 'integer', 'min:0'],
            'default_storage_conditions' => ['sometimes', 'nullable', 'string'],
            'default_handling_instructions' => ['sometimes', 'nullable', 'string'],
            'image_urls' => ['sometimes', 'array'],
            'status' => ['sometimes', Rule::in(['active', 'inactive', 'archived'])],
            'metadata' => ['sometimes', 'array'],
            'unit_price' => 'nullable|numeric|min:0',
            'carton_price' => 'nullable|numeric|min:0',
            'wholesale_price' => 'nullable|numeric|min:0',
            'currency' => 'nullable|string|size:3',
            'discount_type' => 'nullable|string|in:percentage,fixed',
            'discount_value' => 'nullable|numeric|min:0',
            'moq' => 'nullable|integer|min:1',
            'marketplace_enabled' => 'nullable|boolean',
            'bonus_quantity' => 'nullable|integer|min:1',
            'bonus_threshold' => 'nullable|integer|min:1',
            'wallet_credit' => 'nullable|numeric|min:0',
            'promo_code' => 'nullable|string|max:50',
            'promo_discount' => 'nullable|numeric|min:0|max:100',
            'tags' => 'nullable|array',
            'volume_discounts' => 'nullable|array',
        ]);

        // Handle image upload (single file via multipart/form-data)
        $imageUrls = $this->handleImageUpload($request, $product);

        // Merge uploaded image URLs with any manually provided image_urls
        // For update, uploaded images replace the existing image_urls if new ones are provided
        if (!empty($imageUrls)) {
            $existingUrls = $data['image_urls'] ?? ($product->image_urls ?? []);
            $data['image_urls'] = array_merge($existingUrls, $imageUrls);
        }

        // Ensure metadata->image_url is set for backward compatibility.
        // Only override image_url if new images were actually uploaded in this request.
        $metadata = $data['metadata'] ?? ($product->metadata ?? []);
        if (!empty($data['image_urls'])) {
            $metadata['image_url'] = $data['image_urls'][0];
        } elseif (isset($data['metadata']['image_url'])) {
            // Preserve image_url passed from Flutter's generic upload flow
            $metadata['image_url'] = $data['metadata']['image_url'];
        }
        $data['metadata'] = $metadata;

        $product->fill($data)->save();
        return response()->json(['success' => true, 'data' => $product->fresh()]);
    }

    public function destroy(Request $request, Product $product)
    {
        $this->assertCompany($request, $product);
        $product->delete();
        return response()->json(['success' => true]);
    }

    public function types()
    {
        return response()->json(['success' => true, 'data' => [
            'pharmaceutical',
            'food_beverage',
            'textile',
            'electronics',
            'other',
        ]]);
    }

    public function categories(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'pharmaceutical',
                'food_beverage',
                'textile',
                'electronics',
                'medical_devices',
                'cosmetics',
                'agriculture',
                'automotive',
                'construction',
                'other',
            ],
        ]);
    }

    /**
     * Toggle marketplace visibility for a product.
     */
    public function toggleMarketplace(Request $request, string $id): JsonResponse
    {
        $companyId = $request->header('X-Company-Id')
            ?? $request->query('company_id');

        if (!$companyId) {
            return response()->json([
                'success' => false,
                'message' => 'Company ID is required.',
            ], 400);
        }

        $product = Product::where('id', $id)
            ->where('company_id', $companyId)
            ->first();

        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found.',
            ], 404);
        }

        // TODO: Re-enable price validation after testing
        $enabled = $request->boolean('marketplace_enabled', !$product->marketplace_enabled);

        // if ($enabled && !$product->unit_price && !$product->carton_price && !$product->wholesale_price) {
        //     return response()->json([
        //         'success' => false,
        //         'message' => 'Cannot publish to marketplace: product has no price set. Please set at least one price (unit, carton, or wholesale).',
        //     ], 422);
        // }

        $product->marketplace_enabled = $enabled;
        $product->save();

        return response()->json([
            'success' => true,
            'message' => $enabled
                ? 'Product listed on marketplace.'
                : 'Product removed from marketplace.',
            'data' => $product->fresh(),
        ]);
    }

    public function linkCodes(Request $request, Product $product)
    {
        $this->assertCompany($request, $product);

        $data = $request->validate([
            'code_ids' => ['required', 'array', 'min:1', 'max:5000'],
            'code_ids.*' => ['uuid'],
            'product_batch_number' => ['nullable', 'string', 'max:100'],
            'manufacturing_date' => ['nullable', 'date'],
            'expiry_date' => ['nullable', 'date'],
            'warranty_months' => ['nullable', 'integer', 'min:0', 'max:240'],
        ]);

        $user = $request->user();
        $companyId = (string) $user->company_id;
        $now = now();

        $updated = DB::table('base_codes')
            ->where('company_id', $companyId)
            ->where('code_type', 'unit')
            ->whereIn('id', $data['code_ids'])
            ->whereNull('published_at')
            ->update([
                'product_id' => (string) $product->id,
                'product_batch_number' => $data['product_batch_number'] ?? null,
                'manufacturing_date' => $data['manufacturing_date'] ?? null,
                'expiry_date' => $data['expiry_date'] ?? null,
                'warranty_months' => $data['warranty_months'] ?? null,
                'status' => 'linked',
                'linked_at' => $now,
                'updated_at' => $now,
            ]);

        return response()->json([
            'success' => true,
            'data' => [
                'linked_count' => (int) $updated,
            ],
        ]);
    }

    public function codes(Request $request, Product $product)
    {
        $this->assertCompany($request, $product);
        return response()->json(['success' => true, 'data' => []]);
    }

    public function publishCodes(Request $request, Product $product)
    {
        $this->assertCompany($request, $product);

        $data = $request->validate([
            'code_ids' => ['nullable', 'array', 'min:1', 'max:5000'],
            'code_ids.*' => ['uuid'],
            'product_batch_number' => ['nullable', 'string', 'max:100'],
            'manufacturing_date' => ['nullable', 'date'],
            'expiry_date' => ['nullable', 'date'],
            'warranty_months' => ['nullable', 'integer', 'min:0', 'max:240'],
        ]);

        $user = $request->user();
        $companyId = (string) $user->company_id;

        $subscription = CompanySubscription::query()
            ->where('company_id', $companyId)
            ->where('status', 'active')
            ->first();
        if (!$subscription) {
            return response()->json(['message' => 'No active subscription'], 422);
        }

        $plan = SubscriptionPlan::query()->find((string) $subscription->plan_id);
        if (!$plan) {
            return response()->json(['message' => 'Invalid subscription plan'], 422);
        }

        $query = DB::table('base_codes')
            ->where('company_id', $companyId)
            ->where('code_type', 'unit')
            ->where('product_id', (string) $product->id)
            ->whereNull('published_at')
            ->whereIn('status', ['generated', 'linked']);

        if (!empty($data['code_ids'])) {
            $query->whereIn('id', $data['code_ids']);
        }

        $toPublish = (int) $query->count('id');
        if ($toPublish <= 0) {
            return response()->json([
                'success' => true,
                'data' => [
                    'published_count' => 0,
                    'remaining_unit_codes' => max(0, (int) ($plan->monthly_unit_codes ?? 0) - (int) ($subscription->current_unit_codes_used ?? 0)),
                ],
            ]);
        }

        $limit = (int) ($plan->monthly_unit_codes ?? 0);
        $used = (int) ($subscription->current_unit_codes_used ?? 0);
        if ($limit > 0 && ($used + $toPublish) > $limit) {
            return response()->json([
                'message' => 'Unit code publish exceeds subscription limit',
                'data' => [
                    'limit' => $limit,
                    'used' => $used,
                    'requested' => $toPublish,
                    'remaining' => max(0, $limit - $used),
                ],
            ], 422);
        }

        $now = now();

        $invoice = null;

        $usedBefore = $used;

        DB::transaction(function () use ($query, $subscription, $plan, $product, $companyId, $toPublish, $data, $now, $usedBefore, &$invoice) {
            $ids = (clone $query)->pluck('id')->map(fn ($v) => (string) $v)->all();

            $linkQuery = clone $query;
            $linkQuery->whereNull('linked_at')->update([
                'linked_at' => $now,
                'updated_at' => $now,
            ]);

            $query->update([
                'status' => 'published',
                'published_at' => $now,
                'subscription_plan_id' => (string) $plan->id,
                'product_batch_number' => $data['product_batch_number'] ?? DB::raw('product_batch_number'),
                'manufacturing_date' => $data['manufacturing_date'] ?? DB::raw('manufacturing_date'),
                'expiry_date' => $data['expiry_date'] ?? DB::raw('expiry_date'),
                'warranty_months' => $data['warranty_months'] ?? DB::raw('warranty_months'),
                'updated_at' => $now,
            ]);

            $subscription->current_unit_codes_used = (int) ($subscription->current_unit_codes_used ?? 0) + $toPublish;
            $subscription->save();

            $invoice = $this->createPublishInvoice(
                companyId: $companyId,
                subscription: $subscription,
                plan: $plan,
                codeType: 'unit',
                quantity: $toPublish,
                publishedAt: $now,
                context: [
                    'product_id' => (string) $product->id,
                    'product_name' => (string) ($product->name ?? ''),
                    'product_batch_number' => $data['product_batch_number'] ?? null,
                    'code_ids' => $ids,
                    'used_before' => $usedBefore,
                ],
            );

            $this->stampInvoiceIdOnCodes($companyId, 'unit', $ids, (string) $invoice->id, $now);
        });

        $newUsed = (int) ($subscription->current_unit_codes_used ?? 0);
        $remaining = $limit > 0 ? max(0, $limit - $newUsed) : null;

        return response()->json([
            'success' => true,
            'data' => [
                'published_count' => $toPublish,
                'used_unit_codes' => $newUsed,
                'remaining_unit_codes' => $remaining,
                'published_at' => Carbon::parse($now)->toISOString(),
                'invoice' => $invoice ? [
                    'id' => (string) $invoice->id,
                    'invoice_number' => (string) $invoice->invoice_number,
                    'status' => (string) $invoice->status,
                    'total_amount' => (float) $invoice->total_amount,
                    'currency' => (string) ($invoice->currency ?? 'USD'),
                    'issue_date' => optional($invoice->issue_date)->toISOString(),
                    'due_date' => optional($invoice->due_date)->toISOString(),
                ] : null,
            ],
        ]);
    }

    private function createPublishInvoice(
        string $companyId,
        CompanySubscription $subscription,
        SubscriptionPlan $plan,
        string $codeType,
        int $quantity,
        \DateTimeInterface $publishedAt,
        array $context = [],
    ): Invoice {
        $currency = (string) ($plan->currency ?? 'USD');
        $usedBefore = (int) ($context['used_before'] ?? 0);
        $freeQuota = 0;
        $meta = $plan->metadata;
        if (is_array($meta) && isset($meta['free_quota']) && is_array($meta['free_quota'])) {
            $freeQuota = (int) ($meta['free_quota'][$codeType] ?? 0);
        }

        $unitPrice = $this->calculatePublishUnitPrice($plan, $codeType);

        $billableQty = max(0, ($usedBefore + max(0, $quantity)) - $freeQuota) - max(0, $usedBefore - $freeQuota);
        $billableQty = max(0, min((int) $quantity, (int) $billableQty));
        $freeApplied = max(0, (int) $quantity - (int) $billableQty);

        $subtotal = round($unitPrice * max(0, $billableQty), 2);

        $issueDate = Carbon::parse($publishedAt)->toDateString();
        $dueDate = Carbon::parse($publishedAt)->copy()->addDays(7)->toDateString();
        $periodStart = Carbon::parse($publishedAt)->copy()->startOfMonth()->toDateString();
        $periodEnd = Carbon::parse($publishedAt)->copy()->endOfMonth()->toDateString();

        $invoiceNumber = $this->generateUniqueInvoiceNumber();

        $invoiceData = [
            'company_id' => $companyId,
            'subscription_id' => (string) $subscription->id,
            'invoice_number' => $invoiceNumber,
            'period_start' => $periodStart,
            'period_end' => $periodEnd,
            'issue_date' => $issueDate,
            'due_date' => $dueDate,
            'subtotal' => $subtotal,
            'tax_amount' => 0,
            'discount_amount' => 0,
            'total_amount' => $subtotal,
            'currency' => $currency,
            'items' => [
                [
                    'id' => (string) Str::uuid(),
                    'description' => $codeType === 'unit' ? 'Unit codes publish' : ($codeType . ' codes publish'),
                    'quantity' => (float) $billableQty,
                    'unit_price' => $unitPrice,
                    'total' => $subtotal,
                    'currency' => $currency,
                    'code_type' => $codeType,
                    'code_count' => $quantity,
                    'period_start' => $periodStart,
                    'period_end' => $periodEnd,
                    'metadata' => [
                        'source' => 'publish_codes',
                        'used_before' => $usedBefore,
                        'free_quota' => $freeQuota,
                        'free_applied' => $freeApplied,
                        'billable_count' => $billableQty,
                        'rate' => $unitPrice,
                        'monthly_fee' => (float) ($plan->monthly_price ?? 0),
                    ],
                ],
            ],
            'status' => $subtotal > 0 ? 'pending' : 'paid',
            'payment_date' => $subtotal > 0 ? null : $issueDate,
            'payment_method' => $subtotal > 0 ? null : 'system',
            'payment_reference' => $subtotal > 0 ? null : 'FREE',
            'metadata' => array_merge([
                'source' => 'publish_codes',
                'code_type' => $codeType,
                'quantity' => $quantity,
                'billable_count' => $billableQty,
                'free_applied' => $freeApplied,
                'free_quota' => $freeQuota,
                'used_before' => $usedBefore,
                'unit_price' => $unitPrice,
                'monthly_fee' => (float) ($plan->monthly_price ?? 0),
                'published_at' => Carbon::parse($publishedAt)->toISOString(),
                'plan_id_at_publish' => (string) $plan->id,
                'plan_type_at_publish' => (string) ($plan->type ?? ''),
                'plan_monthly_price_at_publish' => (float) ($plan->monthly_price ?? 0),
            ], $context),
        ];

        if (\Illuminate\Support\Facades\Schema::hasColumn('invoices', 'type')) {
            $invoiceData['type'] = 'platform';
        }

        $invoice = new Invoice($invoiceData);

        $invoice->id = (string) Str::uuid();
        $invoice->save();

        return $invoice;
    }

    private function calculatePublishUnitPrice(SubscriptionPlan $plan, string $codeType): float
    {
        $meta = $plan->metadata;
        if (is_array($meta) && isset($meta['publish_rates']) && is_array($meta['publish_rates'])) {
            $explicit = $meta['publish_rates'][$codeType] ?? null;
            if ($explicit !== null && is_numeric($explicit)) {
                return max(0.0, round((float) $explicit, 6));
            }
        }

        $price = (float) ($plan->monthly_price ?? 0);
        if ($price <= 0) {
            return 0.0;
        }

        $quota = match ($codeType) {
            'bundle' => (int) ($plan->monthly_bundle_codes ?? 0),
            'carton' => (int) ($plan->monthly_carton_codes ?? 0),
            'packet' => (int) ($plan->monthly_packet_codes ?? 0),
            default => (int) ($plan->monthly_unit_codes ?? 0),
        };

        if ($quota <= 0) {
            $fallback = (int) ($plan->monthly_unit_codes ?? 0);
            if ($fallback <= 0) {
                return 0.0;
            }
            $quota = $fallback;
        }

        return max(0.0, round($price / $quota, 6));
    }

    private function generateUniqueInvoiceNumber(): string
    {
        $prefix = 'INV-' . now()->format('Ym') . '-';

        for ($i = 0; $i < 10; $i++) {
            $candidate = $prefix . strtoupper(Str::random(8));
            if (!Invoice::query()->where('invoice_number', $candidate)->exists()) {
                return $candidate;
            }
        }

        return $prefix . strtoupper((string) Str::uuid());
    }

    private function stampInvoiceIdOnCodes(string $companyId, string $codeType, array $ids, string $invoiceId, \DateTimeInterface $now): void
    {
        if (empty($ids)) {
            return;
        }

        $driver = DB::getDriverName();
        $jsonExpr = null;
        if ($driver === 'pgsql') {
            $jsonExpr = DB::raw(
                "jsonb_set(" .
                    "case when jsonb_typeof(metadata) = 'object' then metadata else '{}'::jsonb end," .
                    " '{publish_invoice_id}'," .
                    " to_jsonb('{$invoiceId}'::text)," .
                    " true" .
                ")"
            );
        } else {
            $jsonExpr = DB::raw("JSON_SET(COALESCE(metadata, JSON_OBJECT()), '$.publish_invoice_id', '{$invoiceId}')");
        }

        DB::table('base_codes')
            ->where('company_id', $companyId)
            ->where('code_type', $codeType)
            ->whereIn('id', $ids)
            ->update([
                'metadata' => $jsonExpr,
                'updated_at' => $now,
            ]);
    }

    /**
     * Handle single image file upload for products.
     * Deletes the old image if the product already has one and a new image is being uploaded.
     *
     * @param Request $request
     * @param Product|null $product  The existing product (for update) or null (for store)
     * @return array  Array containing the newly uploaded image URL, or empty if no upload
     */
    private function handleImageUpload(Request $request, ?Product $product = null): array
    {
        if (!$request->hasFile('image')) {
            return [];
        }

        $file = $request->file('image');

        // Validate the file (additional safety beyond form validation)
        if (!$file->isValid()) {
            Log::warning('ProductController: Invalid image upload attempt.', [
                'error' => $file->getError(),
                'client_mime' => $file->getClientMimeType(),
            ]);
            return [];
        }

        // If updating an existing product, delete its old primary image from storage
        if ($product && !empty($product->image_urls)) {
            $oldUrl = is_array($product->image_urls) ? ($product->image_urls[0] ?? null) : null;
            if ($oldUrl) {
                $oldPath = $this->extractStoragePath($oldUrl);
                if ($oldPath && Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                    Log::info('ProductController: Deleted old product image.', [
                        'product_id' => $product->id,
                        'old_path' => $oldPath,
                    ]);
                }
            }
        }

        // Store the new image
        $extension = $file->getClientOriginalExtension();
        $filename = sprintf('product_%s_%s.%s',
            $product ? $product->id : Str::uuid(),
            now()->timestamp,
            $extension
        );
        $path = $file->storeAs('products', $filename, 'public');

        if (!$path) {
            Log::error('ProductController: Failed to store product image.', [
                'filename' => $filename,
            ]);
            return [];
        }

        $url = Storage::disk('public')->url($path);

        Log::info('ProductController: Product image uploaded successfully.', [
            'product_id' => $product?->id,
            'path' => $path,
            'url' => $url,
        ]);

        return [$url];
    }

    /**
     * Extract the relative storage path from a full URL.
     */
    private function extractStoragePath(?string $url): ?string
    {
        if (!$url) {
            return null;
        }

        $prefix = '/storage/';
        $pos = strpos($url, $prefix);
        if ($pos !== false) {
            return substr($url, $pos + strlen($prefix));
        }

        $appUrl = config('app.url');
        if ($appUrl && str_starts_with($url, $appUrl)) {
            $relative = substr($url, strlen($appUrl));
            if (str_starts_with($relative, '/storage/')) {
                return substr($relative, strlen('/storage/'));
            }
        }

        return null;
    }

    private function assertCompany(Request $request, Product $product): void
    {
        $user = $request->user();
        if (!$user || (string) $product->company_id !== (string) $user->company_id) {
            abort(404);
        }
    }
}
