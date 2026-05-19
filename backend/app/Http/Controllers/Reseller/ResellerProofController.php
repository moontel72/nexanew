<?php

namespace App\Http\Controllers\Reseller;

use App\Http\Controllers\Controller;
use App\Models\Reseller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class ResellerProofController extends Controller
{
    /**
     * Upload business proof document for purchase approval.
     */
    public function uploadProof(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'proof_file' => 'required|file|mimes:jpg,jpeg,png,pdf|max:10240',
                'document_title' => 'required|string|max:255',
            ]);

            $reseller = $request->user();

            // If not authenticated via Sanctum, fall back to header-based lookup
            if (!$reseller || !$reseller instanceof Reseller) {
                $resellerId = $request->header('X-Reseller-Id');
                if ($resellerId) {
                    $reseller = Reseller::find($resellerId);
                }
            }

            if (!$reseller || !$reseller instanceof Reseller) {
                Log::warning('ResellerProofController: Authenticated user is not a reseller.', [
                    'user_id' => $reseller->id ?? 'unknown',
                    'class' => get_class($reseller),
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Only resellers can upload proof documents.',
                ], 403);
            }

            // Delete old proof file if it exists
            if ($reseller->business_proof_url) {
                $oldPath = $this->extractStoragePath($reseller->business_proof_url);
                if ($oldPath && Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                    Log::info('ResellerProofController: Deleted old proof file.', [
                        'reseller_id' => $reseller->id,
                        'old_path' => $oldPath,
                    ]);
                }
            }

            // Store the new file
            $file = $validated['proof_file'];
            $extension = $file->getClientOriginalExtension();
            $filename = sprintf('reseller_%s_%s.%s', $reseller->id, now()->timestamp, $extension);
            $path = $file->storeAs('reseller_proofs', $filename, 'public');

            if (!$path) {
                Log::error('ResellerProofController: Failed to store proof file.', [
                    'reseller_id' => $reseller->id,
                    'filename' => $filename,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to upload file. Please try again.',
                ], 500);
            }

            $url = Storage::disk('public')->url($path);

            // Update reseller record
            $reseller->update([
                'business_proof_url' => $url,
                'business_proof_title' => $validated['document_title'],
                'business_proof_uploaded_at' => now(),
                'purchase_approved' => false, // Reset approval on new upload
            ]);

            Log::info('ResellerProofController: Proof uploaded successfully.', [
                'reseller_id' => $reseller->id,
                'path' => $path,
                'title' => $validated['document_title'],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Business proof uploaded successfully. Awaiting approval.',
                'data' => [
                    'business_proof_url' => $url,
                    'business_proof_title' => $validated['document_title'],
                    'business_proof_uploaded_at' => $reseller->business_proof_uploaded_at?->toISOString(),
                    'purchase_approved' => false,
                ],
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed.',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Throwable $e) {
            Log::error('ResellerProofController: Unexpected error during proof upload.', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
            ], 500);
        }
    }

    /**
     * Check the current purchase approval status for the authenticated reseller.
     */
    public function checkStatus(Request $request): JsonResponse
    {
        try {
            $reseller = $request->user();

            // If not authenticated via Sanctum, fall back to header-based lookup
            if (!$reseller || !$reseller instanceof Reseller) {
                $resellerId = $request->header('X-Reseller-Id');
                if ($resellerId) {
                    $reseller = Reseller::find($resellerId);
                }
            }

            if (!$reseller || !$reseller instanceof Reseller) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized.',
                ], 403);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'purchase_approved' => (bool) $reseller->purchase_approved,
                    'business_proof_url' => $reseller->business_proof_url,
                    'business_proof_title' => $reseller->business_proof_title,
                    'business_proof_uploaded_at' => $reseller->business_proof_uploaded_at?->toISOString(),
                ],
            ]);
        } catch (\Throwable $e) {
            Log::error('ResellerProofController: Error checking proof status.', [
                'error' => $e->getMessage(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred.',
            ], 500);
        }
    }

    /**
     * Extract the relative storage path from a full URL.
     */
    private function extractStoragePath(?string $url): ?string
    {
        if (!$url) {
            return null;
        }

        // Try to match the pattern: /storage/...
        $prefix = '/storage/';
        $pos = strpos($url, $prefix);
        if ($pos !== false) {
            return substr($url, $pos + strlen($prefix));
        }

        // Fallback: try to extract from the full app URL
        $appUrl = config('app.url');
        if ($appUrl && str_starts_with($url, $appUrl)) {
            $relative = substr($url, strlen($appUrl));
            if (str_starts_with($relative, '/storage/')) {
                return substr($relative, strlen('/storage/'));
            }
        }

        return null;
    }
}
