<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Command;
use App\Models\Computer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AgentHeartbeatController extends Controller
{
    public function heartbeat(Request $request): JsonResponse
    {
        /** @var Computer $computer */
        $computer = $request->get('current_computer');

        $validated = $request->validate([
            'status' => ['nullable', 'string', 'max:32'],
            'ip' => ['nullable', 'string', 'max:64'],
            'active_user' => ['nullable', 'string', 'max:64'],
            'uptime_seconds' => ['nullable', 'integer'],
            'agent_version' => ['nullable', 'string', 'max:32'],
            'config_version' => ['nullable', 'integer'],
        ]);

        $ip = $validated['ip'] ?? $request->ip();

        $computer->update([
            'status' => 'online',
            'ip_terakhir' => $ip,
            'active_user' => $validated['active_user'] ?? $computer->active_user,
            'uptime_seconds' => $validated['uptime_seconds'] ?? $computer->uptime_seconds,
            'versi_agent' => $validated['agent_version'] ?? $computer->versi_agent,
            'last_seen_at' => now(),
        ]);

        // Get pending commands for this computer
        $pendingCommands = Command::where('computer_id', $computer->id)
            ->where('status', 'pending')
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($cmd) {
                return [
                    'id' => $cmd->id,
                    'type' => $cmd->tipe,
                    'payload' => $cmd->payload ?? (object)[],
                    'created_at' => $cmd->created_at?->toISOString(),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'computer_id' => $computer->id,
                'nama_pc' => $computer->nama_pc,
                'pending_commands' => $pendingCommands,
                'config_version_server' => 1,
                'config_changed' => false,
                'server_time' => now()->toISOString(),
            ],
            'message' => 'Heartbeat diterima.',
        ]);
    }
}
