<?php

namespace App\Http\Controllers\Reseller;

use App\Http\Controllers\Controller;
use App\Models\Reseller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class ResellerAuthController extends Controller
{
    /**
     * Login a reseller and return a Sanctum token + reseller ID.
     * POST /api/v1/reseller/login
     */
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $reseller = Reseller::where('email', $validated['email'])->first();

        if (!$reseller || !Hash::check($validated['password'], $reseller->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid email or password.',
            ], 401);
        }

        if ($reseller->status !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'Your account is ' . $reseller->status . '. Contact support.',
            ], 403);
        }

        // Create Sanctum token
        $token = $reseller->createToken('reseller-auth')->plainTextToken;

        Log::info('ResellerAuthController: Login successful.', [
            'reseller_id' => $reseller->id,
            'email' => $reseller->email,
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'token' => $token,
                'resellerId' => $reseller->id,
                'name' => $reseller->name,
                'businessName' => $reseller->business_name,
                'email' => $reseller->email,
                'purchaseApproved' => (bool) $reseller->purchase_approved,
            ],
        ]);
    }

    /**
     * Return the current reseller's profile.
     * GET /api/v1/reseller/me
     */
    public function me(Request $request): JsonResponse
    {
        $reseller = $request->user();

        if (!$reseller instanceof Reseller) {
            $resellerId = $request->header('X-Reseller-Id');
            if ($resellerId) {
                $reseller = Reseller::find($resellerId);
            }
        }

        if (!$reseller instanceof Reseller) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'resellerId' => $reseller->id,
                'name' => $reseller->name,
                'businessName' => $reseller->business_name,
                'email' => $reseller->email,
                'purchaseApproved' => (bool) $reseller->purchase_approved,
            ],
        ]);
    }
}
