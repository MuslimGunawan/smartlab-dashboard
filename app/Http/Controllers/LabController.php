<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Command;
use App\Models\Computer;
use App\Models\Lab;
use App\Models\PairingCode;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Illuminate\View\View;

class LabController extends Controller
{
    public function index(): View
    {
        $labs = Lab::withCount([
            'computers',
            'computers as online_computers_count' => function ($query) {
                $query->where('status', 'online')
                    ->where('last_seen_at', '>=', now()->subSeconds(45));
            },
        ])->latest()->get();

        return view('labs.index', compact('labs'));
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'nama_lab' => ['required', 'string', 'max:128'],
            'lokasi' => ['nullable', 'string', 'max:255'],
            'deskripsi' => ['nullable', 'string'],
        ]);

        $lab = Lab::create($validated);

        // Attach current user as manager
        if (Auth::user()) {
            $lab->users()->syncWithoutDetaching([Auth::id()]);
        }

        AuditLog::log(Auth::id(), 'CREATE_LAB', $lab->nama_lab, ['lab_id' => $lab->id]);

        return redirect()->route('labs.show', $lab)->with('success', "Lab {$lab->nama_lab} berhasil ditambahkan.");
    }

    public function show(Lab $lab): View
    {
        $lab->load(['computers' => function ($q) {
            $q->orderBy('nama_pc', 'asc');
        }]);

        $activePairingCodes = PairingCode::where('lab_id', $lab->id)
            ->where('is_used', false)
            ->where('expired_at', '>', now())
            ->latest()
            ->get();

        $recentCommands = Command::where('lab_id', $lab->id)
            ->orWhereIn('computer_id', $lab->computers->pluck('id'))
            ->latest()
            ->take(10)
            ->get();

        return view('labs.show', compact('lab', 'activePairingCodes', 'recentCommands'));
    }

    public function generatePairingCode(Lab $lab): RedirectResponse
    {
        $code = 'UNM-' . strtoupper(Str::random(6));

        $pairing = PairingCode::create([
            'code' => $code,
            'lab_id' => $lab->id,
            'is_used' => false,
            'expired_at' => now()->addHours(24),
        ]);

        AuditLog::log(
            Auth::id(),
            'GENERATE_PAIRING_CODE',
            "Kode: {$code} untuk Lab {$lab->nama_lab}",
            ['lab_id' => $lab->id, 'code' => $code]
        );

        return back()->with('success', "Kode Pairing baru berhasil dibuat: {$code} (berlaku 24 jam).");
    }

    public function sendCommand(Request $request, Lab $lab): RedirectResponse
    {
        $validated = $request->validate([
            'tipe' => ['required', 'in:shutdown,restart,broadcast,lock'],
            'grace_seconds' => ['nullable', 'integer', 'min:0', 'max:600'],
            'message' => ['nullable', 'string', 'max:255'],
        ]);

        $computers = $lab->computers;
        if ($computers->isEmpty()) {
            return back()->with('error', 'Tidak ada komputer terdaftar di lab ini untuk dikirimi perintah.');
        }

        $graceSeconds = $validated['grace_seconds'] ?? 60;
        $createdCommandsCount = 0;

        foreach ($computers as $pc) {
            Command::create([
                'computer_id' => $pc->id,
                'lab_id' => $lab->id,
                'tipe' => $validated['tipe'],
                'payload' => [
                    'grace_seconds' => (int)$graceSeconds,
                    'message' => $validated['message'] ?? "Perintah massal dari ASLAB untuk Lab {$lab->nama_lab}",
                ],
                'status' => 'pending',
                'created_by' => Auth::id(),
            ]);
            $createdCommandsCount++;
        }

        AuditLog::log(
            Auth::id(),
            'SEND_BULK_COMMAND',
            "Lab {$lab->nama_lab}",
            [
                'tipe' => $validated['tipe'],
                'count' => $createdCommandsCount,
                'grace_seconds' => $graceSeconds,
            ]
        );

        return back()->with('success', "Perintah massal [{$validated['tipe']}] berhasil dikirim ke {$createdCommandsCount} komputer di Lab {$lab->nama_lab}.");
    }
}
