<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class FileController extends Controller
{
    /**
     * Upload a file and return its public URL.
     * POST /api/v1/files/upload
     */
    public function upload(Request $request): JsonResponse
    {
        $request->validate([
            'file' => 'required|file|max:20480|mimes:jpg,jpeg,png,gif,webp,pdf',
        ]);

        try {
            $file = $request->file('file');
            $ext = $file->getClientOriginalExtension();
            $filename = sprintf('%s_%s.%s', Str::random(12), time(), $ext);
            $path = $file->storeAs('uploads', $filename, 'public');

            if (!$path) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to store file.',
                ], 500);
            }

            $url = Storage::disk('public')->url($path);

            Log::info('FileController: File uploaded.', [
                'path' => $path,
                'url' => $url,
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'url' => $url,
                    'path' => $path,
                    'filename' => $filename,
                ],
            ], 201);
        } catch (\Throwable $e) {
            Log::error('FileController: Upload failed.', [
                'error' => $e->getMessage(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Upload failed. Please try again.',
            ], 500);
        }
    }

    /**
     * Delete a file by path.
     * DELETE /api/v1/files/delete
     */
    public function delete(Request $request): JsonResponse
    {
        $request->validate([
            'path' => 'required|string',
        ]);

        $path = $request->input('path');

        // Extract storage path from full URL if needed
        if (str_starts_with($path, 'http')) {
            $parsed = parse_url($path);
            $urlPath = $parsed['path'] ?? '';
            // Remove /storage/ prefix
            $path = preg_replace('#^/storage/#', '', $urlPath);
        }

        if (Storage::disk('public')->exists($path)) {
            Storage::disk('public')->delete($path);
            return response()->json(['success' => true, 'message' => 'File deleted.']);
        }

        return response()->json(['success' => false, 'message' => 'File not found.'], 404);
    }
}
