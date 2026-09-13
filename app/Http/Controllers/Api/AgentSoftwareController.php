<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Computer;
use App\Models\InstalledSoftware;
use App\Models\SoftwareEvent;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AgentSoftwareController extends Controller
{
    public function sync(Request $request): JsonResponse
    {
        /** @var Computer $computer */
        $computer = $request->get('current_computer');

        $validated = $request->validate([
            'software' => 'required|array',
            'software.*.nama' => 'required|string|max:255',
            'software.*.versi' => 'nullable|string|max:100',
            'software.*.tanggal_install' => 'nullable|string|max:50',
            'software.*.ukuran_kb' => 'nullable|numeric',
            'software.*.uninstall_string' => 'nullable|string',
        ]);

        $incomingList = collect($validated['software']);
        $incomingNames = $incomingList->pluck('nama')->map(fn($n) => trim($n))->filter()->values();

        // Get existing software in DB
        $existing = InstalledSoftware::where('computer_id', $computer->id)->get()->keyBy('nama');

        $now = Carbon::now();
        $newCount = 0;

        foreach ($incomingList as $item) {
            $name = trim($item['nama']);
            if (empty($name)) continue;

            if (!$existing->has($name)) {
                // Newly installed software detected!
                $newCount++;
                $event = SoftwareEvent::create([
                    'computer_id' => $computer->id,
                    'software_name' => $name,
                    'tipe' => 'installed',
                    'detected_at' => $now,
                ]);

                \App\Services\TelegramService::notifySoftwareEvent($event);

                AuditLog::create([
                    'user_id' => null,
                    'aksi' => 'software_installed_detected',
                    'target' => "Computer #{$computer->id} ({$computer->nama_pc})",
                    'detail' => [
                        'software' => $name,
                        'versi' => $item['versi'] ?? null,
                    ],
                ]);

                InstalledSoftware::create([
                    'computer_id' => $computer->id,
                    'nama' => $name,
                    'versi' => $item['versi'] ?? null,
                    'tanggal_install' => $item['tanggal_install'] ?? null,
                    'ukuran_kb' => isset($item['ukuran_kb']) ? (int)$item['ukuran_kb'] : null,
                    'uninstall_string' => $item['uninstall_string'] ?? null,
                    'terdeteksi_pertama_at' => $now,
                    'terakhir_dicek_at' => $now,
                ]);
            } else {
                // Update last seen
                $existingItem = $existing->get($name);
                $existingItem->update([
                    'versi' => $item['versi'] ?? $existingItem->versi,
                    'ukuran_kb' => isset($item['ukuran_kb']) ? (int)$item['ukuran_kb'] : $existingItem->ukuran_kb,
                    'uninstall_string' => $item['uninstall_string'] ?? $existingItem->uninstall_string,
                    'terakhir_dicek_at' => $now,
                ]);
            }
        }

        // Detect uninstalled / removed software
        foreach ($existing as $oldName => $oldItem) {
            if (!$incomingNames->contains($oldName)) {
                SoftwareEvent::create([
                    'computer_id' => $computer->id,
                    'software_name' => $oldName,
                    'tipe' => 'removed',
                    'detected_at' => $now,
                ]);
                $oldItem->delete();
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Sinkronisasi software berhasil.',
            'new_detected' => $newCount,
            'total_active' => $incomingNames->count(),
        ]);
    }
}
