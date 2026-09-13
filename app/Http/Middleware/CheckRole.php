<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     * @param  string  ...$roles
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return redirect()->route('login');
        }

        // Super admin always has access
        if ($user->isSuperAdmin()) {
            return $next($request);
        }

        // Check if user has any of the accepted roles
        $userRole = $user->role;
        // Legacy role 'aslab' maps to 'aslab_senior'
        if ($userRole === 'aslab') {
            $userRole = 'aslab_senior';
        }

        foreach ($roles as $role) {
            $roleList = explode(',', $role);
            foreach ($roleList as $r) {
                $trimmed = trim($r);
                if ($userRole === $trimmed || ($trimmed === 'aslab' && in_array($userRole, ['aslab_senior', 'aslab_junior']))) {
                    return $next($request);
                }
            }
        }

        if ($request->expectsJson()) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Akun Anda tidak memiliki hak akses untuk tindakan ini.'
            ], 403);
        }

        return back()->with('error', 'Akses ditolak! Tindakan ini membutuhkan hak akses level lebih tinggi.');
    }
}
