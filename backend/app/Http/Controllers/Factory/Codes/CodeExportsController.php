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

        return response()->download($absPath, $safeFile);
    }
}

