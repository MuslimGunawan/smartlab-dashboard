<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Computer;
use App\Models\DiskPartition;
use App\Models\IssueReport;
use App\Models\Lab;
use App\Models\SoftwareEvent;
use App\Models\Violation;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    /**
     * Tampilkan Halaman Laporan Bulanan & Analitik Lab
     */
    public function monthly(Request $request)
    {
        $selectedMonth = (int) $request->input('month', now()->month);
        $selectedYear = (int) $request->input('year', now()->year);
        $selectedLabId = $request->input('lab_id');

        $startDate = Carbon::createFromDate($selectedYear, $selectedMonth, 1)->startOfMonth();
        $endDate = $startDate->copy()->endOfMonth();

        // Query Labs
        $labs = Lab::withCount('computers')->orderBy('nama_lab')->get();

        // Base Computers Query
        $computersQuery = Computer::with(['lab', 'hardwareSpec', 'diskPartitions']);
        if ($selectedLabId) {
            $computersQuery->where('lab_id', $selectedLabId);
        }
        $computers = $computersQuery->get();

        // 1. Metrik Komputer
        $totalPc = $computers->count();
        $onlinePc = $computers->filter(fn($c) => $c->isOnline())->count();
        $avgUptimeHours = $totalPc > 0 ? round($computers->avg('uptime_seconds') / 3600, 1) : 0;

        // 2. Insiden Pelanggaran (Bulan terpilih)
        $violationsQuery = Violation::with(['computer.lab'])
            ->whereBetween('detected_at', [$startDate, $endDate]);

        if ($selectedLabId) {
            $violationsQuery->whereHas('computer', fn($q) => $q->where('lab_id', $selectedLabId));
        }
        $violations = $violationsQuery->latest('detected_at')->get();
        $totalViolations = $violations->count();
        $topViolations = $violations->groupBy('process_name')
            ->map(fn($group) => $group->count())
            ->sortDesc()
            ->take(5);

        // 3. Storage Warning (Disks with > 80% used)
        $warningDisks = DiskPartition::with(['computer.lab'])
            ->where('total_gb', '>', 0)
            ->whereRaw('((total_gb - free_gb) / total_gb) >= 0.8')
            ->when($selectedLabId, function ($q) use ($selectedLabId) {
                $q->whereHas('computer', fn($c) => $c->where('lab_id', $selectedLabId));
            })
            ->get();

        // 4. Software Baru Terinstall (Bulan terpilih)
        $softwareEventsQuery = SoftwareEvent::with(['computer.lab'])
            ->whereBetween('detected_at', [$startDate, $endDate])
            ->where('tipe', 'installed');

        if ($selectedLabId) {
            $softwareEventsQuery->whereHas('computer', fn($q) => $q->where('lab_id', $selectedLabId));
        }
        $newSoftwareList = $softwareEventsQuery->latest('detected_at')->take(20)->get();

        // 5. Aksi ASLAB / Audit Logs (Bulan terpilih)
        $auditLogsQuery = AuditLog::with('user')
            ->whereBetween('created_at', [$startDate, $endDate]);
        $auditLogs = $auditLogsQuery->latest()->take(30)->get();
        $totalCommandsSent = AuditLog::whereBetween('created_at', [$startDate, $endDate])
            ->whereIn('aksi', ['send_command_single', 'send_command_lab', 'wake_on_lan', 'cleanup_computer'])
            ->count();

        // 6. Rekap Masalah Mahasiswa (Bulan terpilih)
        $issueReportsQuery = IssueReport::with(['computer.lab', 'resolver'])
            ->whereBetween('created_at', [$startDate, $endDate]);

        if ($selectedLabId) {
            $issueReportsQuery->where('lab_id', $selectedLabId);
        }
        $issueReports = $issueReportsQuery->latest()->get();
        $totalIssues = $issueReports->count();
        $resolvedIssues = $issueReports->where('status', 'resolved')->count();

        $selectedLab = $selectedLabId ? Lab::find($selectedLabId) : null;

        return view('reports.monthly', compact(
            'selectedMonth',
            'selectedYear',
            'selectedLabId',
            'selectedLab',
            'startDate',
            'labs',
            'computers',
            'totalPc',
            'onlinePc',
            'avgUptimeHours',
            'violations',
            'totalViolations',
            'topViolations',
            'warningDisks',
            'newSoftwareList',
            'auditLogs',
            'totalCommandsSent',
            'issueReports',
            'totalIssues',
            'resolvedIssues'
        ));
    }

    /**
     * Export Laporan ke Format CSV / Excel
     */
    public function exportCsv(Request $request): StreamedResponse
    {
        $selectedMonth = (int) $request->input('month', now()->month);
        $selectedYear = (int) $request->input('year', now()->year);
        $selectedLabId = $request->input('lab_id');

        $startDate = Carbon::createFromDate($selectedYear, $selectedMonth, 1)->startOfMonth();
        $endDate = $startDate->copy()->endOfMonth();

        $labName = 'Semua-Lab';
        if ($selectedLabId) {
            $lab = Lab::find($selectedLabId);
            if ($lab) {
                $labName = str_replace(' ', '-', $lab->nama_lab);
            }
        }

        $filename = "Laporan_SmartLab_{$labName}_{$selectedYear}_{$selectedMonth}.csv";

        return response()->streamDownload(function () use ($startDate, $endDate, $selectedLabId) {
            $handle = fopen('php://output', 'w');
            // Add UTF-8 BOM for Excel compatibility
            fputs($handle, "\xEF\xBB\xBF");

            // Header Section
            fputcsv($handle, ['LAPORAN BULANAN SISTEM MANAJEMEN LABORATORIUM (SMARTLAB UNIMAL)']);
            fputcsv($handle, ['UNIVERSITAS MALIKUSSALEH - FAKULTAS TEKNIK']);
            fputcsv($handle, ['Periode', $startDate->translatedFormat('F Y')]);
            fputcsv($handle, ['Tanggal Generate', now()->translatedFormat('d F Y H:i') . ' WIB']);
            fputcsv($handle, []);

            // 1. Data Komputer
            fputcsv($handle, ['--- 1. REKAPITULASI INVENTARIS KOMPUTER ---']);
            fputcsv($handle, ['No', 'Nama PC', 'Ruang Lab', 'IP Address', 'MAC Address', 'Status', 'Uptime (Jam)', 'OS', 'Processor', 'RAM (GB)']);

            $computers = Computer::with(['lab', 'hardwareSpec'])
                ->when($selectedLabId, fn($q) => $q->where('lab_id', $selectedLabId))
                ->get();

            $no = 1;
            foreach ($computers as $pc) {
                fputcsv($handle, [
                    $no++,
                    $pc->nama_pc,
                    $pc->lab ? $pc->lab->nama_lab : '-',
                    $pc->ip_terakhir ?: '-',
                    $pc->mac_address ?: '-',
                    $pc->status,
                    round($pc->uptime_seconds / 3600, 1),
                    $pc->hardwareSpec ? $pc->hardwareSpec->os_version : '-',
                    $pc->hardwareSpec ? $pc->hardwareSpec->processor : '-',
                    $pc->hardwareSpec ? $pc->hardwareSpec->ram_gb : '-',
                ]);
            }
            fputcsv($handle, []);

            // 2. Insiden Pelanggaran
            fputcsv($handle, ['--- 2. DAFTAR INSIDEN PELANGGARAN SOFTWARE TERLARANG ---']);
            fputcsv($handle, ['No', 'Waktu Deteksi', 'PC', 'Lab', 'Aplikasi Terlarang', 'Tindakan', 'Status Selesai']);

            $violations = Violation::with('computer.lab')
                ->whereBetween('detected_at', [$startDate, $endDate])
                ->when($selectedLabId, fn($q) => $q->whereHas('computer', fn($c) => $c->where('lab_id', $selectedLabId)))
                ->latest('detected_at')
                ->get();

            $vNo = 1;
            foreach ($violations as $v) {
                fputcsv($handle, [
                    $vNo++,
                    $v->detected_at ? $v->detected_at->format('Y-m-d H:i:s') : '-',
                    $v->computer ? $v->computer->nama_pc : '-',
                    $v->computer && $v->computer->lab ? $v->computer->lab->nama_lab : '-',
                    $v->process_name,
                    'Force-Close + Screenshot',
                    $v->resolved ? 'Resolved' : 'Pending',
                ]);
            }
            fputcsv($handle, []);

            // 3. Laporan Kerusakan Mahasiswa
            fputcsv($handle, ['--- 3. DAFTAR LAPORAN KERUSAKAN DARI MAHASISWA ---']);
            fputcsv($handle, ['No', 'Tanggal', 'PC', 'Lab', 'Pelapor', 'NIM', 'Kategori', 'Deskripsi', 'Status', 'Catatan Perbaikan']);

            $issues = IssueReport::with(['computer.lab'])
                ->whereBetween('created_at', [$startDate, $endDate])
                ->when($selectedLabId, fn($q) => $q->where('lab_id', $selectedLabId))
                ->latest()
                ->get();

            $iNo = 1;
            foreach ($issues as $issue) {
                fputcsv($handle, [
                    $iNo++,
                    $issue->created_at->format('Y-m-d H:i'),
                    $issue->computer ? $issue->computer->nama_pc : '-',
                    $issue->lab ? $issue->lab->nama_lab : '-',
                    $issue->reporter_name,
                    $issue->reporter_nim ?: '-',
                    $issue->category_label,
                    $issue->description,
                    strtoupper($issue->status),
                    $issue->resolution_notes ?: '-',
                ]);
            }

            fclose($handle);
        }, $filename, [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => "attachment; filename=\"{$filename}\"",
        ]);
    }
}
