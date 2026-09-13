<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\BlocklistApp;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class BlocklistController extends Controller
{
    public function index(Request $request): View
    {
        $query = BlocklistApp::with('creator')->latest();

        if ($request->filled('q')) {
            $query->where('process_name', 'like', '%' . $request->q . '%')
                  ->orWhere('keterangan', 'like', '%' . $request->q . '%');
        }

        $apps = $query->paginate(15)->withQueryString();

        return view('blocklist.index', compact('apps'));
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'process_name' => 'required|string|max:255|unique:blocklist_apps,process_name',
            'keterangan' => 'nullable|string|max:255',
            'aktif' => 'nullable|boolean',
        ]);

        // Clean process name: ensure ends with .exe if omitted
        $proc = trim($validated['process_name']);
        if (!str_ends_with(strtolower($proc), '.exe')) {
            $proc .= '.exe';
        }

        $app = BlocklistApp::create([
            'process_name' => $proc,
            'keterangan' => $validated['keterangan'] ?? null,
            'dibuat_oleh' => auth()->id(),
            'aktif' => $request->has('aktif') ? true : false,
        ]);

        AuditLog::create([
            'user_id' => auth()->id(),
            'aksi' => 'create_blocklist_app',
            'target' => $app->process_name,
            'detail' => ['keterangan' => $app->keterangan],
        ]);

        return redirect()->route('blocklist.index')->with('success', "Proses '{$app->process_name}' berhasil ditambahkan ke daftar aplikasi terlarang.");
    }

    public function toggle(BlocklistApp $blocklist): RedirectResponse
    {
        $blocklist->update(['aktif' => !$blocklist->aktif]);

        $status = $blocklist->aktif ? 'diaktifkan' : 'dinonaktifkan';

        AuditLog::create([
            'user_id' => auth()->id(),
            'aksi' => 'toggle_blocklist_app',
            'target' => $blocklist->process_name,
            'detail' => ['status_baru' => $blocklist->aktif],
        ]);

        return redirect()->route('blocklist.index')->with('success', "Blokir untuk '{$blocklist->process_name}' berhasil {$status}.");
    }

    public function destroy(BlocklistApp $blocklist): RedirectResponse
    {
        $name = $blocklist->process_name;
        $blocklist->delete();

        AuditLog::create([
            'user_id' => auth()->id(),
            'aksi' => 'delete_blocklist_app',
            'target' => $name,
            'detail' => null,
        ]);

        return redirect()->route('blocklist.index')->with('success', "Proses '{$name}' dihapus dari daftar terlarang.");
    }
}
