<?php

namespace App\Http\Controllers\Factory\Codes;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\File;

class CodeExportsController extends Controller
{
    public function download(Request $request, string $companyId, string $file)
    {
        $safeFile = basename($file);
        if ($safeFile !== $file) {
            abort(404);
        }

        if (!preg_match('/^[A-Za-z0-9._-]+$/', $safeFile)) {
            abort(404);
        }

        $baseDir = storage_path('app/public/exports/' . $companyId);
        $absPath = $baseDir . DIRECTORY_SEPARATOR . $safeFile;

        if (!File::exists($absPath)) {
            abort(404);
        }

        // Build a clean display filename from the stored filename.
        // Stored:  ITF-14_Packet_Batch_Hero_2026-05-06_143025.csv
        // Display: ITF-14_Packet_Batch_Hero_2026-05-06.csv
        $ext = pathinfo($safeFile, PATHINFO_EXTENSION);
        $nameWithoutExt = pathinfo($safeFile, PATHINFO_FILENAME);
        $cleanName = preg_replace('/_\d{6}$/', '', $nameWithoutExt);
        $displayName = $cleanName . '.' . $ext;

        $headers = [
            'Content-Disposition' => 'attachment; filename="' . $displayName . '"',
        ];

        return response()->download($absPath, $displayName, $headers);
    }
}
