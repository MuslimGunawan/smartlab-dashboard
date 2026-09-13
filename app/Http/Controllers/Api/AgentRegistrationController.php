<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Computer;
use App\Models\PairingCode;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AgentRegistrationController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'pairing_code' => ['required', 'string'],
            'hostname' => ['required', 'string', 'max:128'],
            'mac_address' => ['nullable', 'string', 'max:64'],
            'nama_pc' => ['nullable', 'string', 'max:128'],
        ]);

        $pairing = PairingCode::where('code', trim($validated['pairing_code']))
            ->where('is_used', false)
            ->where('expired_at', '>', now())
            ->first();

        if (!$pairing) {
            return response()->json([
                'success' => false,
                'data' => null,
                'message' => 'Kode pairing tidak valid atau sudah kadaluwarsa. Silakan generate kode baru dari dashboard ASLAB.',
            ], 422);
        }

        // Generate strong secure device token
        $deviceToken = 'unm_' . bin2hex(random_bytes(32));

        $computerName = $validated['nama_pc'] ?? ('PC-' . strtoupper($validated['hostname']));

        $computer = Computer::create([
            'lab_id' => $pairing->lab_id,
            'nama_pc' => $computerName,
            'hostname' => $validated['hostname'],
            'mac_address' => $validated['mac_address'] ?? null,
            'device_token' => $deviceToken,
            'ip_terakhir' => $request->ip(),
            'status' => 'online',
            'last_seen_at' => now(),
        ]);

        // Mark pairing code used and attach to computer
        $pairing->update([
            'is_used' => true,
            'computer_id' => $computer->id,
        ]);

        AuditLog::log(
            null,
            'AGENT_REGISTERED',
            $computer->nama_pc,
            [
                'computer_id' => $computer->id,
                'lab_id' => $pairing->lab_id,
                'hostname' => $computer->hostname,
                'ip' => $request->ip(),
            ]
        );

        return response()->json([
            'success' => true,
            'data' => [
                'device_token' => $deviceToken,
                'computer_id' => $computer->id,
                'nama_pc' => $computer->nama_pc,
                'lab_id' => $computer->lab_id,
                'lab_nama' => $pairing->lab?->nama_lab,
            ],
            'message' => 'Pairing berhasil. Komputer telah terhubung ke sistem LabControl Unimal.',
        ]);
    }
}
