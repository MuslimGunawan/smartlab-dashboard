<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Computer;
use App\Models\IssueReport;
use App\Models\Lab;
use App\Services\TelegramService;
use Illuminate\Http\Request;

class IssueReportController extends Controller
{
    /**
     * Public Form: Mahasiswa scan QR code meja / buka link dari PC
     */
    public function create(string $token)
    {
        $computer = Computer::with('lab')->where('device_token', $token)->firstOrFail();
        return view('issues.public_report', compact('computer'));
    }

    /**
     * Public Store: Mahasiswa submit formulir kerusakan
     */
    public function store(Request $request, string $token)
    {
        $computer = Computer::with('lab')->where('device_token', $token)->firstOrFail();

        $validated = $request->validate([
            'reporter_name' => 'required|string|max:120',
            'reporter_nim' => 'nullable|string|max:32',
            'reporter_contact' => 'nullable|string|max:64',
            'category' => 'required|string|in:mouse,keyboard,monitor,pc_hang,network,software,other',
            'description' => 'required|string|min:5|max:2000',
        ], [
            'reporter_name.required' => 'Nama pelapor wajib diisi.',
            'category.required' => 'Pilih kategori kendala.',
            'description.required' => 'Mohon jelaskan kendala atau kerusakan yang dialami.',
            'description.min' => 'Deskripsi kendala minimal 5 karakter.',
        ]);

        $issue = IssueReport::create([
            'computer_id' => $computer->id,
            'lab_id' => $computer->lab_id,
            'reporter_name' => $validated['reporter_name'],
            'reporter_nim' => $validated['reporter_nim'] ?? null,
            'reporter_contact' => $validated['reporter_contact'] ?? null,
            'category' => $validated['category'],
            'description' => $validated['description'],
            'status' => 'pending',
        ]);

        // Send instant notification to ASLAB group if configured
        TelegramService::notifyIssueReport($issue);

        return redirect()->route('report-issue.success', ['token' => $token, 'ticket' => $issue->id]);
    }

    /**
     * Public Success Page
     */
    public function success(string $token, Request $request)
    {
        $computer = Computer::with('lab')->where('device_token', $token)->firstOrFail();
        $ticketId = $request->query('ticket');
        $issue = $ticketId ? IssueReport::find($ticketId) : null;

        return view('issues.public_success', compact('computer', 'issue'));
    }

    /**
     * Dashboard: Daftar Laporan Kerusakan untuk ASLAB
     */
    public function index(Request $request)
    {
        $query = IssueReport::with(['computer', 'lab', 'resolver'])->latest();

        if ($request->filled('lab_id')) {
            $query->where('lab_id', $request->lab_id);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        $issues = $query->paginate(15)->withQueryString();
        $labs = Lab::orderBy('nama_lab')->get();

        // Quick Metrics
        $totalReports = IssueReport::count();
        $pendingReports = IssueReport::where('status', 'pending')->count();
        $inProgressReports = IssueReport::where('status', 'in_progress')->count();
        $resolvedReports = IssueReport::where('status', 'resolved')->count();

        return view('issues.index', compact(
            'issues',
            'labs',
            'totalReports',
            'pendingReports',
            'inProgressReports',
            'resolvedReports'
        ));
    }

    /**
     * Dashboard: Update status penanganan (In Progress / Resolved)
     */
    public function updateStatus(Request $request, IssueReport $issue)
    {
        $validated = $request->validate([
            'status' => 'required|in:pending,in_progress,resolved',
            'resolution_notes' => 'nullable|string|max:1000',
        ]);

        $updates = [
            'status' => $validated['status'],
            'resolution_notes' => $validated['resolution_notes'] ?? $issue->resolution_notes,
        ];

        if ($validated['status'] === 'resolved') {
            $updates['resolved_by'] = auth()->id();
            $updates['resolved_at'] = now();
        } elseif ($validated['status'] === 'in_progress' && !$issue->resolved_by) {
            $updates['resolved_by'] = auth()->id();
        }

        $issue->update($updates);

        AuditLog::log(
            auth()->id(),
            'update_issue_status',
            'Issue #' . $issue->id,
            [
                'status' => $validated['status'],
                'computer' => $issue->computer ? $issue->computer->nama_pc : null,
                'notes' => $validated['resolution_notes'] ?? null,
            ]
        );

        return back()->with('success', 'Status laporan #' . $issue->id . ' berhasil diperbarui menjadi ' . strtoupper($validated['status']) . '!');
    }

    /**
     * Dashboard: Hapus laporan (Senior / Super Admin only)
     */
    public function destroy(IssueReport $issue)
    {
        if (!auth()->user()->isSenior()) {
            return back()->with('error', 'Hanya ASLAB Senior atau Super Admin yang dapat menghapus riwayat laporan.');
        }

        $id = $issue->id;
        $issue->delete();

        AuditLog::log(auth()->id(), 'delete_issue', 'Issue #' . $id, []);

        return back()->with('success', 'Laporan #' . $id . ' berhasil dihapus dari sistem.');
    }
}
