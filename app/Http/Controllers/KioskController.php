<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Command;
use App\Models\Computer;
use App\Models\KioskSetting;
use App\Models\Lab;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class KioskController extends Controller
{
    public function index(): View
    {
        $labs = Lab::with(['computers', 'schedules'])->get();

        $kioskSettings = KioskSetting::all()->keyBy('lab_id');

        return view('kiosk.index', compact('labs', 'kioskSettings'));
    }

    public function updateLab(Request $request, Lab $lab): RedirectResponse
    {
        $validated = $request->validate([
            'disable_taskmgr' => ['nullable', 'boolean'],
            'disable_cmd' => ['nullable', 'boolean'],
            'disable_regedit' => ['nullable', 'boolean'],
            'disable_control_panel' => ['nullable', 'boolean'],
        ]);

        $disableTaskmgr = $request->boolean('disable_taskmgr');
        $disableCmd = $request->boolean('disable_cmd');
        $disableRegedit = $request->boolean('disable_regedit');
        $disableCp = $request->boolean('disable_control_panel');

        $setting = KioskSetting::updateOrCreate(
            ['lab_id' => $lab->id, 'computer_id' => null],
            [
                'disable_taskmgr' => $disableTaskmgr,
                'disable_cmd' => $disableCmd,
                'disable_regedit' => $disableRegedit,
                'disable_control_panel' => $disableCp,
            ]
        );

        // Dispatch kiosk_toggle command to all computers in this lab
        $computers = $lab->computers;
        $count = 0;

        foreach ($computers as $pc) {
            Command::create([
                'computer_id' => $pc->id,
                'lab_id' => $lab->id,
                'tipe' => 'kiosk_toggle',
                'payload' => [
                    'disable_taskmgr' => $disableTaskmgr,
                    'disable_cmd' => $disableCmd,
                    'disable_regedit' => $disableRegedit,
                    'disable_control_panel' => $disableCp,
                ],
                'status' => 'pending',
                'created_by' => Auth::id(),
            ]);
            $count++;
        }

        AuditLog::log(
            Auth::id(),
            'UPDATE_LAB_KIOSK',
            "Lab {$lab->nama_lab}",
            [
                'lab_id' => $lab->id,
                'computers_count' => $count,
                'settings' => $setting->toArray(),
            ]
        );

        return back()->with('success', "Kebijakan Kiosk Mode untuk {$lab->nama_lab} berhasil diperbarui dan disiarkan ke {$count} komputer.");
    }
}
