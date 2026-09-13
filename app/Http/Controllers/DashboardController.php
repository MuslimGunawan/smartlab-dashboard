<?php

namespace App\Http\Controllers;

use App\Models\Command;
use App\Models\Computer;
use App\Models\Lab;
use Illuminate\Http\JsonResponse;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function index(): View
    {
        $labs = Lab::withCount([
            'computers',
            'computers as online_computers_count' => function ($query) {
                $query->where('status', 'online')
                    ->where('last_seen_at', '>=', now()->subSeconds(45));
            },
        ])->get();

        $totalComputers = Computer::count();
        $totalOnline = Computer::where('status', 'online')
            ->where('last_seen_at', '>=', now()->subSeconds(45))
            ->count();

        $pendingCommandsCount = Command::where('status', 'pending')->count();

        $recentCommands = Command::with(['computer', 'lab', 'creator'])
            ->latest()
            ->take(8)
            ->get();

        return view('dashboard.index', compact(
            'labs',
            'totalComputers',
            'totalOnline',
            'pendingCommandsCount',
            'recentCommands'
        ));
    }

    public function statusFeed(): JsonResponse
    {
        $computers = Computer::with('lab:id,nama_lab')
            ->select('id', 'lab_id', 'nama_pc', 'hostname', 'ip_terakhir', 'status', 'active_user', 'uptime_seconds', 'last_seen_at')
            ->get()
            ->map(function ($pc) {
                $isOnline = $pc->isOnline();
                return [
                    'id' => $pc->id,
                    'nama_pc' => $pc->nama_pc,
                    'hostname' => $pc->hostname,
                    'lab_id' => $pc->lab_id,
                    'lab_nama' => $pc->lab?->nama_lab ?? 'Tanpa Lab',
                    'ip' => $pc->ip_terakhir ?? '-',
                    'active_user' => $pc->active_user ?? '-',
                    'uptime_human' => $pc->uptime_seconds > 0 ? gmdate("H:i:s", $pc->uptime_seconds) : '-',
                    'status' => $isOnline ? 'online' : 'offline',
                    'last_seen' => $pc->last_seen_at ? $pc->last_seen_at->diffForHumans() : 'Belum pernah',
                ];
            });

        $totalOnline = $computers->where('status', 'online')->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_computers' => $computers->count(),
                'total_online' => $totalOnline,
                'computers' => $computers,
                'server_time' => now()->translatedFormat('d M Y, H:i:s'),
            ],
        ]);
    }
}
