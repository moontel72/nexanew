<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SiteContentBlock;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

/**
 * Dynamic site content (CMS-lite) for the landing site (traceodd.com) and
 * the documentation site (docs.traceodd.com).
 *
 * Public sites read blocks at runtime via GET /api/v1/public/content/{slug};
 * Super Admins create/update them here. Screenshots are uploaded through
 * uploadImage() and referenced by relative /storage/… URLs so they resolve
 * same-origin on every host that aliases the Laravel storage directory.
 */
class SiteContentController extends Controller
{
    /** GET /api/v1/public/content/{slug} — public read (landing + docs). */
    public function show(string $slug): JsonResponse
    {
        $block = SiteContentBlock::where('slug', $slug)->first();

        if (!$block) {
            return response()->json([
                'success' => false,
                'message' => 'Content not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'slug' => $block->slug,
                'title' => $block->title,
                'payload' => $block->payload,
                'updated_at' => $block->updated_at?->toIso8601String(),
            ],
        ]);
    }

    /** GET /api/v1/admin/content — list all blocks (admin only). */
    public function index(): JsonResponse
    {
        $blocks = SiteContentBlock::query()
            ->orderBy('slug')
            ->get(['slug', 'title', 'updated_at']);

        return response()->json([
            'success' => true,
            'data' => $blocks,
        ]);
    }

    /** PUT /api/v1/admin/content/{slug} — create/update a block (admin only). */
    public function upsert(Request $request, string $slug): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'nullable|string|max:255',
            'payload' => 'nullable|array',
        ]);

        $block = SiteContentBlock::updateOrCreate(
            ['slug' => $slug],
            [
                'title' => $validated['title'] ?? null,
                'payload' => $validated['payload'] ?? null,
                'updated_by' => $request->user()?->id,
            ],
        );

        return response()->json([
            'success' => true,
            'message' => 'Content saved.',
            'data' => [
                'slug' => $block->slug,
                'title' => $block->title,
                'updated_at' => $block->updated_at?->toIso8601String(),
            ],
        ]);
    }

    /** DELETE /api/v1/admin/content/{slug} (admin only). */
    public function destroy(string $slug): JsonResponse
    {
        $deleted = SiteContentBlock::where('slug', $slug)->delete();

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Content not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Content deleted.',
        ]);
    }

    /** POST /api/v1/admin/content/upload-image — screenshot upload (admin only). */
    public function uploadImage(Request $request): JsonResponse
    {
        $request->validate([
            'image' => 'required|file|max:5120|mimes:jpg,jpeg,png,webp',
        ]);

        try {
            $file = $request->file('image');
            $ext = strtolower((string) $file->getClientOriginalExtension());
            $filename = sprintf('%s_%s.%s', Str::random(12), time(), $ext);
            $path = $file->storeAs('site-content', $filename, 'public');

            return response()->json([
                'success' => true,
                'data' => [
                    // Relative URL — resolves same-origin on any host that
                    // aliases the Laravel public storage directory.
                    'url' => '/storage/' . $path,
                    'absolute_url' => Storage::disk('public')->url($path),
                    'path' => $path,
                ],
            ], 201);
        } catch (\Throwable $e) {
            Log::error('SiteContentController: screenshot upload failed.', [
                'error' => $e->getMessage(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Upload failed. Please try again.',
            ], 500);
        }
    }
}
