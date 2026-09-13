<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Computer;
use App\Models\HardwareSpec;
use App\Models\DiskPartition;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AgentHardwareController extends Controller
{
    public function sync(Request $request): JsonResponse
    {
        /** @var Computer $computer */
        $computer = $request->get('current_computer');

        $validated = $request->validate([
            'serial_number' => 'nullable|string|max:255',
            'processor' => 'nullable|string|max:255',
            'ram_gb' => 'nullable|numeric',
            'os_version' => 'nullable|string|max:255',
            'partitions' => 'nullable|array',
            'partitions.*.drive_letter' => 'required|string|max:8',
            'partitions.*.total_gb' => 'required|numeric',
            'partitions.*.free_gb' => 'required|numeric',
        ]);

        // Upsert Hardware Spec
        HardwareSpec::updateOrCreate(
            ['computer_id' => $computer->id],
            [
                'serial_number' => $validated['serial_number'] ?? null,
                'processor' => $validated['processor'] ?? null,
                'ram_gb' => $validated['ram_gb'] ?? null,
                'os_version' => $validated['os_version'] ?? null,
            ]
        );

        // Update Partitions
        if (!empty($validated['partitions'])) {
            DiskPartition::where('computer_id', $computer->id)->delete();
            foreach ($validated['partitions'] as $part) {
                DiskPartition::create([
                    'computer_id' => $computer->id,
                    'drive_letter' => $part['drive_letter'],
                    'total_gb' => $part['total_gb'],
                    'free_gb' => $part['free_gb'],
                ]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Spesifikasi hardware dan partisi berhasil disinkronisasi.',
        ]);
    }
}
