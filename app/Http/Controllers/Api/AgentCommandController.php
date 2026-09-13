<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Command;
use App\Models\Computer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AgentCommandController extends Controller
{
    public function ack(Request $request, int $id): JsonResponse
    {
        /** @var Computer $computer */
        $computer = $request->get('current_computer');

        $validated = $request->validate([
            'status' => ['required', 'string', 'in:executed,failed'],
            'result_message' => ['nullable', 'string', 'max:1000'],
        ]);

        $command = Command::where('id', $id)
            ->where('computer_id', $computer->id)
            ->first();

        if (!$command) {
            return response()->json([
                'success' => false,
                'data' => null,
                'message' => 'Command tidak ditemukan atau bukan ditujukan untuk perangkat ini.',
            ], 404);
        }

        $command->update([
            'status' => $validated['status'],
            'result_message' => $validated['result_message'] ?? null,
            'executed_at' => now(),
        ]);

        AuditLog::log(
            null,
            'COMMAND_ACK',
            "Command #{$command->id} ({$command->tipe})",
            [
                'computer_id' => $computer->id,
                'nama_pc' => $computer->nama_pc,
                'status' => $validated['status'],
                'result_message' => $validated['result_message'] ?? null,
            ]
        );

        return response()->json([
            'success' => true,
            'data' => [
                'command_id' => $command->id,
                'status' => $command->status,
                'executed_at' => $command->executed_at?->toISOString(),
            ],
            'message' => 'Status command berhasil diperbarui.',
        ]);
    }
}
