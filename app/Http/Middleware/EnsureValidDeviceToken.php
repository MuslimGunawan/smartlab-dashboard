<?php

namespace App\Http\Middleware;

use App\Models\Computer;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureValidDeviceToken
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $authHeader = $request->header('Authorization');
        if (!$authHeader || !str_starts_with($authHeader, 'Bearer ')) {
            return response()->json([
                'success' => false,
                'data' => null,
                'message' => 'Authorization header missing or invalid. Format: Bearer <device_token>',
            ], 401);
        }

        $token = substr($authHeader, 7);
        $computer = Computer::where('device_token', $token)->first();

        if (!$computer) {
            return response()->json([
                'success' => false,
                'data' => null,
                'message' => 'Device token tidak valid atau komputer tidak terdaftar.',
            ], 401);
        }

        // Attach computer to request
        $request->merge(['current_computer' => $computer]);
        $request->setUserResolver(fn () => null);

        return $next($request);
    }
}
