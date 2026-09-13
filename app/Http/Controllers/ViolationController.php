<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Lab;
use App\Models\Violation;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class ViolationController extends Controller
{
    public function index(Request $request): View
    {
        $query = Violation::with(['computer.lab'])->latest('detected_at');

        if ($request->filled('lab_id')) {
            $query->whereHas('computer', function ($q) use ($request) {
                $q->where('lab_id', $request->lab_id);
            });
        }

        if ($request->filled('status')) {
            if ($request->status === 'unresolved') {
                $query->where('resolved', false);
            } elseif ($request->status === 'resolved') {
                $query->where('resolved', true);
            }
        }

        if ($request->filled('q')) {
            $query->where(function ($q) use ($request) {
                $q->where('process_name', 'like', '%' . $request->q . '%')
                  ->orWhereHas('computer', function ($cq) use ($request) {
                      $cq->where('nama_pc', 'like', '%' . $request->q . '%');
                  });
            });
        }

        $violations = $query->paginate(12)->withQueryString();
        $labs = Lab::orderBy('nama_lab')->get();

        $unresolvedCount = Violation::where('resolved', false)->count();

        return view('violations.index', compact('violations', 'labs', 'unresolvedCount'));
    }

    public function resolve(Violation $violation): RedirectResponse
    {
        $violation->update(['resolved' => !$violation->resolved]);

        $status = $violation->resolved ? 'ditandai selesai' : 'dibuka kembali';

        AuditLog::create([
            'user_id' => auth()->id(),
            'aksi' => 'resolve_violation',
            'target' => "Violation #{$violation->id} ({$violation->process_name})",
            'detail' => ['resolved' => $violation->resolved],
        ]);

        return back()->with('success', "Insiden pelanggaran berhasil {$status}.");
    }
}
