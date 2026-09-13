<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Command;
use App\Models\Computer;
use App\Models\Lab;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class ComputerController extends Controller
{
    public function index(Request $request): View
    {
        $selectedLabId = $request->query('lab_id');

        $query = Computer::with('lab');

        if ($selectedLabId) {
            $query->where('lab_id', $selectedLabId);
        }

        $computers = $query->orderBy('status', 'desc')
            ->orderBy('nama_pc', 'asc')
            ->get();

        $labs = Lab::orderBy('nama_lab')->get();

        return view('computers.index', compact('computers', 'labs', 'selectedLabId'));
    }

    public function show(Computer $computer): View
    {
        $computer->load([
            'lab',
            'hardwareSpec',
            'diskPartitions',
            'installedSoftware' => function ($q) {
                $q->orderBy('nama', 'asc');
            },
            'commands' => function ($q) {
                $q->latest()->take(20);
            },
        ]);

        $labs = Lab::orderBy('nama_lab')->get();

        return view('computers.show', compact('computer', 'labs'));
    }

    public function update(Request $request, Computer $computer): RedirectResponse
    {
        $validated = $request->validate([
            'nama_pc' => ['required', 'string', 'max:128'],
            'lab_id' => ['nullable', 'exists:labs,id'],
        ]);

        $computer->update($validated);

        AuditLog::log(
            Auth::id(),
            'UPDATE_COMPUTER',
            $computer->nama_pc,
            ['computer_id' => $computer->id, 'changes' => $validated]
        );

        return back()->with('success', "Data komputer {$computer->nama_pc} berhasil diperbarui.");
    }

    public function destroy(Computer $computer): RedirectResponse
    {
        $name = $computer->nama_pc;
        $id = $computer->id;

        $computer->delete();

        AuditLog::log(
            Auth::id(),
            'DELETE_COMPUTER',
            $name,
            ['computer_id' => $id]
        );

        return redirect()->route('computers.index')->with('success', "Komputer {$name} telah dihapus dari sistem.");
    }

    public function sendCommand(Request $request, Computer $computer): RedirectResponse
    {
        $validated = $request->validate([
            'tipe' => ['required', 'in:shutdown,restart,broadcast,lock'],
            'grace_seconds' => ['nullable', 'integer', 'min:0', 'max:600'],
            'message' => ['nullable', 'string', 'max:255'],
        ]);

        $graceSeconds = $validated['grace_seconds'] ?? 60;

        $command = Command::create([
            'computer_id' => $computer->id,
            'lab_id' => $computer->lab_id,
            'tipe' => $validated['tipe'],
            'payload' => [
                'grace_seconds' => (int)$graceSeconds,
                'message' => $validated['message'] ?? "Perintah {$validated['tipe']} dari ASLAB.",
            ],
            'status' => 'pending',
            'created_by' => Auth::id(),
        ]);

        AuditLog::log(
            Auth::id(),
            'SEND_COMMAND',
            "{$computer->nama_pc} (#{$command->id} - {$validated['tipe']})",
            [
                'command_id' => $command->id,
                'computer_id' => $computer->id,
                'tipe' => $validated['tipe'],
                'grace_seconds' => $graceSeconds,
            ]
        );

        return back()->with('success', "Perintah [{$validated['tipe']}] berhasil dikirim ke {$computer->nama_pc}. Akan dieksekusi saat siklus heartbeat berikutnya.");
    }

    public function wake(Computer $computer): RedirectResponse
    {
        if (!$computer->mac_address) {
            return back()->with('error', "Komputer {$computer->nama_pc} tidak memiliki data MAC Address.");
        }

        $success = \App\Services\WakeOnLanService::wake($computer->mac_address);

        AuditLog::log(
            Auth::id(),
            'WAKE_ON_LAN',
            "{$computer->nama_pc} ({$computer->mac_address})",
            ['success' => $success]
        );

        if ($success) {
            return back()->with('success', "Magic Packet Wake-on-LAN berhasil dikirim ke {$computer->nama_pc} ({$computer->mac_address}).");
        }

        return back()->with('error', "Gagal mengirim paket Wake-on-LAN. Pastikan format MAC Address valid.");
    }

    public function uninstallSoftware(Request $request, Computer $computer, $softwareId): RedirectResponse
    {
        $software = \App\Models\InstalledSoftware::where('computer_id', $computer->id)->findOrFail($softwareId);

        \App\Models\SoftwareAction::create([
            'computer_id' => $computer->id,
            'software_name' => $software->nama,
            'aksi' => 'uninstall',
            'status' => 'pending',
            'dikirim_oleh' => Auth::id(),
        ]);

        $command = Command::create([
            'computer_id' => $computer->id,
            'lab_id' => $computer->lab_id,
            'tipe' => 'uninstall_software',
            'payload' => [
                'software_id' => $software->id,
                'software_name' => $software->nama,
                'uninstall_string' => $software->uninstall_string,
            ],
            'status' => 'pending',
            'created_by' => Auth::id(),
        ]);

        AuditLog::log(
            Auth::id(),
            'UNINSTALL_SOFTWARE',
            "{$computer->nama_pc} ({$software->nama})",
            ['command_id' => $command->id, 'software' => $software->nama]
        );

        return back()->with('success', "Perintah uninstall software '{$software->nama}' berhasil dikirim ke {$computer->nama_pc}.");
    }

    public function cleanup(Request $request, Computer $computer): RedirectResponse
    {
        $command = Command::create([
            'computer_id' => $computer->id,
            'lab_id' => $computer->lab_id,
            'tipe' => 'cleanup',
            'payload' => [
                'clean_temp' => true,
                'clean_recycle_bin' => true,
            ],
            'status' => 'pending',
            'created_by' => Auth::id(),
        ]);

        AuditLog::log(
            Auth::id(),
            'CLEANUP_SYSTEM',
            $computer->nama_pc,
            ['command_id' => $command->id]
        );

        return back()->with('success', "Perintah pembersihan sampah sistem (%TEMP% & Recycle Bin) dikirim ke {$computer->nama_pc}.");
    }
}
