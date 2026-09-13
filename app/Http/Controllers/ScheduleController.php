<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Lab;
use App\Models\Schedule;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class ScheduleController extends Controller
{
    public function index(): View
    {
        $schedules = Schedule::with('lab')->latest()->get();
        $labs = Lab::orderBy('nama_lab')->get();

        return view('schedules.index', compact('schedules', 'labs'));
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'lab_id' => ['required', 'exists:labs,id'],
            'tipe' => ['required', 'in:shutdown,restart'],
            'waktu' => ['required', 'date_format:H:i'],
            'hari' => ['required', 'array', 'min:1'],
            'hari.*' => ['in:senin,selasa,rabu,kamis,jumat,sabtu,minggu'],
        ]);

        $schedule = Schedule::create([
            'lab_id' => $validated['lab_id'],
            'tipe' => $validated['tipe'],
            'waktu' => $validated['waktu'],
            'hari' => $validated['hari'],
            'aktif' => true,
        ]);

        AuditLog::log(
            Auth::id(),
            'CREATE_SCHEDULE',
            "Lab #{$validated['lab_id']} - {$validated['tipe']} @ {$validated['waktu']}",
            ['schedule_id' => $schedule->id, 'hari' => $validated['hari']]
        );

        return back()->with('success', "Jadwal otomatis {$validated['tipe']} jam {$validated['waktu']} berhasil ditambahkan.");
    }

    public function toggle(Schedule $schedule): RedirectResponse
    {
        $schedule->aktif = !$schedule->aktif;
        $schedule->save();

        $statusText = $schedule->aktif ? 'diaktifkan' : 'dinonaktifkan';

        AuditLog::log(
            Auth::id(),
            'TOGGLE_SCHEDULE',
            "Jadwal #{$schedule->id} ({$schedule->tipe})",
            ['aktif' => $schedule->aktif]
        );

        return back()->with('success', "Jadwal berhasil {$statusText}.");
    }

    public function destroy(Schedule $schedule): RedirectResponse
    {
        $id = $schedule->id;
        $schedule->delete();

        AuditLog::log(Auth::id(), 'DELETE_SCHEDULE', "Jadwal #{$id}");

        return back()->with('success', 'Jadwal otomatis berhasil dihapus.');
    }
}
