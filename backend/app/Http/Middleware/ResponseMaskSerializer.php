<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Symfony\Component\HttpFoundation\Response;

/**
 * Wave 3 — ResponseMaskSerializer (Section 10.10, Step 12)
 *
 * Defect F-4 Fix: Applies the 5-tier mask level to outbound JSON
 * responses after the controller executes.
 *
 * Mask Levels (Section 10.4.1):
 *   - full:      Pass through unchanged
 *   - view:      Pass through unchanged (read-only enforced upstream)
 *   - aggregate: Strip all row identifiers, return only counts/sums
 *   - redacted:  Recursively mask PII fields in every row
 *   - hidden:    Throw 404 — data must not be visible
 *
 * PII fields that are redacted:
 *   phone, phone_number, cnic, cnic_old, cnic_new, email, driver_name,
 *   passenger_name, address, license_number, passport, identity_token
 *
 * Redaction pattern: first 4 chars preserved, middle chars replaced
 * with ***, last 4 chars preserved (e.g., 03001234567 → 0300***4567).
 */
class ResponseMaskSerializer
{
    /**
     * Fields considered PII — these are redacted at mask_level=redacted.
     */
    private const PII_FIELDS = [
        'phone', 'phone_number', 'mobile', 'telephone',
        'email', 'email_address',
        'cnic', 'cnic_old', 'cnic_new', 'national_id',
        'passport', 'passport_number',
        'driver_name', 'passenger_name', 'account_name', 'display_name',
        'address', 'home_address', 'billing_address',
        'license_number', 'driving_license', 'license_plate',
        'identity_token', 'claim_value',
        'password', 'password_hash',
    ];

    /**
     * Handle an incoming request.
     *
     * This is a post-middleware that intercepts the response after
     * the controller has executed and applies the mask level.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $maskLevel = $request->attributes->get('mask_level');
        if (!$maskLevel || $maskLevel === 'full') {
            return $response;
        }

        // Handle 'hidden' — return 404
        if ($maskLevel === 'hidden') {
            return response()->json([
                'status'  => 'error',
                'message' => 'Not found.',
            ], 404);
        }

        // Only process JSON responses
        if (!$this->isJsonResponse($response)) {
            return $response;
        }

        $content = $response->getContent();
        $data = json_decode($content, true);

        if ($data === null) {
            return $response;
        }

        $masked = $this->applyMask($data, $maskLevel);

        // Handle 'aggregate' — return only aggregate values
        if ($maskLevel === 'aggregate') {
            $masked = $this->aggregateOnly($data);
        }

        // Handle 'redacted' — recursively mask PII
        if ($maskLevel === 'redacted') {
            $masked = $this->redactPii($data);
        }

        // 'view' passes through unchanged

        $response->setContent(json_encode($masked, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        return $response;
    }

    /**
     * Strip row-level identifiers, return only aggregate counts/sums.
     *
     * For collections: return ['total_records' => N, 'aggregates' => {...}]
     * For single objects: return only non-PII summary fields
     */
    private function aggregateOnly(array $data): array
    {
        // If the response has a 'data' key that's a list, aggregate it
        if (isset($data['data']) && is_array($data['data'])) {
            $items = $data['data'];

            // Check if it's a list (sequential keys)
            if (array_keys($items) === range(0, count($items) - 1)) {
                $aggregates = $this->computeAggregates($items);
                return [
                    'status'      => $data['status'] ?? 'success',
                    'mask_level'  => 'aggregate',
                    'total_records' => count($items),
                    'aggregates'  => $aggregates,
                ];
            }
        }

        // For single-object responses, strip identifiers
        return $this->stripIdentifiers($data);
    }

    /**
     * Compute aggregate values from a list of items.
     */
    private function computeAggregates(array $items): array
    {
        $aggregates = [];
        $numericFields = [];

        // Discover numeric fields
        foreach ($items as $item) {
            if (!is_array($item)) continue;
            foreach ($item as $key => $value) {
                if (is_numeric($value)) {
                    $numericFields[$key] = true;
                }
            }
        }

        foreach (array_keys($numericFields) as $field) {
            $values = array_column($items, $field);
            $values = array_filter($values, 'is_numeric');
            if (!empty($values)) {
                $aggregates['sum_' . $field] = array_sum($values);
                $aggregates['avg_' . $field] = array_sum($values) / count($values);
                $aggregates['count_' . $field] = count($values);
            }
        }

        return $aggregates;
    }

    /**
     * Recursively redact PII fields from the data structure.
     */
    private function redactPii(array $data): array
    {
        return $this->recursiveMask($data);
    }

    private function recursiveMask(mixed $data): mixed
    {
        if (is_array($data)) {
            $result = [];
            foreach ($data as $key => $value) {
                // Check if this key is a PII field
                if (is_string($key) && $this->isPiiField($key)) {
                    $result[$key] = $this->maskValue($value);
                } elseif (is_array($value)) {
                    $result[$key] = $this->recursiveMask($value);
                } else {
                    $result[$key] = $value;
                }
            }
            return $result;
        }

        return $data;
    }

    /**
     * Check if a field name matches a PII pattern.
     */
    private function isPiiField(string $key): bool
    {
        $normalized = strtolower(preg_replace('/[^a-z_]/', '', $key));

        foreach (self::PII_FIELDS as $piiField) {
            if ($normalized === $piiField || str_contains($normalized, $piiField)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Apply redaction mask to a single value.
     *
     * Pattern:
     *   - Long strings (>8 chars): first 4 + *** + last 4 (03001234567 → 0300***4567)
     *   - Medium strings (5-8 chars): first 2 + *** + last 2
     *   - Short strings (≤4 chars): full mask (****)
     *   - Non-strings: return null
     */
    private function maskValue(mixed $value): mixed
    {
        if ($value === null || $value === '') {
            return null;
        }

        $str = (string) $value;
        $len = strlen($str);

        if ($len > 8) {
            return substr($str, 0, 4) . '***' . substr($str, -4);
        }
        if ($len > 4) {
            return substr($str, 0, 2) . '***' . substr($str, -2);
        }
        return '****';
    }

    /**
     * Strip row identifiers (id, uuid, foreign keys) from data.
     */
    private function stripIdentifiers(array $data): array
    {
        $idFields = ['id', 'uuid', '_id', 'identity_token', 'claim_id'];

        $result = [];
        foreach ($data as $key => $value) {
            $normalized = strtolower($key);
            $isId = false;
            foreach ($idFields as $idField) {
                if ($normalized === $idField || str_ends_with($normalized, $idField)) {
                    $isId = true;
                    break;
                }
            }
            if (!$isId) {
                $result[$key] = is_array($value) ? $this->stripIdentifiers($value) : $value;
            }
        }
        return $result;
    }

    private function applyMask(array $data, string $level): array
    {
        return match ($level) {
            'aggregate' => $this->aggregateOnly($data),
            'redacted'  => $this->redactPii($data),
            'view'      => $data,
            default     => $data,
        };
    }

    private function isJsonResponse(Response $response): bool
    {
        if ($response instanceof JsonResponse) {
            return true;
        }
        $contentType = $response->headers->get('Content-Type', '');
        return str_contains($contentType, 'application/json');
    }
}
