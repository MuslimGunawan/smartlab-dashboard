<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Computer;
use App\Models\KioskSetting;
use App\Models\Schedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AgentConfigController extends Controller
{
    public function getConfig(Request $request): JsonResponse
    {
        /** @var Computer $computer */
        $computer = $request->get('current_computer');

        $schedules = [];
        if ($computer->lab_id) {
            $schedules = Schedule::where('lab_id', $computer->lab_id)
                ->where('aktif', true)
                ->get(['id', 'tipe', 'waktu', 'hari']);
        }

        $kioskSetting = null;
        if ($computer->lab_id) {
            $kioskSetting = KioskSetting::where('lab_id', $computer->lab_id)->first();
        }

        $githubRepo = config('app.github_repo', env('GITHUB_REPO', 'MuslimGunawan/smartlab-agent'));

        $blocklist = \App\Models\BlocklistApp::where('aktif', true)
            ->pluck('process_name')
            ->values()
            ->all();

        return response()->json([
            'success' => true,
            'data' => [
                'computer_id' => $computer->id,
                'lab_id' => $computer->lab_id,
                'lab_nama' => $computer->lab?->nama_lab,
                'schedules' => $schedules,
                'blocklist' => $blocklist,
                'kiosk_settings' => [
                    'disable_taskmgr' => $kioskSetting?->disable_taskmgr ?? false,
                    'disable_cmd' => $kioskSetting?->disable_cmd ?? false,
                    'disable_regedit' => $kioskSetting?->disable_regedit ?? false,
                    'disable_control_panel' => $kioskSetting?->disable_control_panel ?? false,
                ],
                'github_repo' => $githubRepo,
                'heartbeat_interval_seconds' => 15,
                'server_time' => now()->toIso8601String(),
                'server_time_human' => now()->translatedFormat('l, d F Y H:i:s'),
            ],
            'message' => 'Konfigurasi agent berhasil diambil.',
        ]);
    }
}
