@extends('layouts.app')

@section('title', 'Laporan Bulanan Laboratorium')
@section('page_title', 'Laporan Bulanan & Analitik Lab')

@section('styles')
<style>
    /* Print Specific Styles */
    @media print {
        body {
            background: #ffffff !important;
            color: #000000 !important;
        }
        aside.sidebar, header.topbar, .no-print, .alert {
            display: none !important;
        }
        main.main-content {
            margin-left: 0 !important;
            padding: 0 !important;
            width: 100% !important;
        }
        .content-body {
            padding: 0 !important;
        }
        .card {
            border: 1px solid #ddd !important;
            box-shadow: none !important;
            break-inside: avoid;
            margin-bottom: 20px !important;
        }
        .print-header {
            display: block !important;
            text-align: center;
            border-bottom: 3px double #000;
            padding-bottom: 12px;
            margin-bottom: 24px;
        }
        .signature-section {
            display: flex !important;
            justify-content: space-between;
            margin-top: 48px;
            page-break-inside: avoid;
        }
    }

    .print-header {
        display: none;
    }

    .signature-section {
        display: none;
    }
</style>
@endsection

@section('topbar_actions')
<div class="no-print" style="display: flex; gap: 10px;">
    <a href="{{ route('reports.monthly.export-csv', ['month' => $selectedMonth, 'year' => $selectedYear, 'lab_id' => $selectedLabId]) }}" class="btn btn-secondary" style="font-size: 13px; display: inline-flex; align-items: center; gap: 6px;">
        <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
        <span>Export CSV</span>
    </a>
    <button onclick="window.print()" class="btn btn-primary" style="font-size: 13px; display: inline-flex; align-items: center; gap: 6px;">
        <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/></svg>
        <span>Cetak Laporan / PDF</span>
    </button>
</div>
@endsection

@section('content')
<div style="display: flex; flex-direction: column; gap: 24px;">

    <!-- Filter Bar (Screen only) -->
    <div class="card no-print" style="padding: 16px 20px;">
        <form method="GET" action="{{ route('reports.monthly') }}" style="display: flex; flex-wrap: wrap; gap: 14px; align-items: center; justify-content: space-between;">
            <div style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center;">
                <div>
                    <label style="font-size: 11px; font-weight: 700; color: var(--gray-500); text-transform: uppercase; display: block; margin-bottom: 4px;">Bulan</label>
                    <select name="month" class="form-control" style="width: auto; min-width: 140px;" onchange="this.form.submit()">
                        @for($m = 1; $m <= 12; $m++)
                            <option value="{{ $m }}" {{ $selectedMonth == $m ? 'selected' : '' }}>
                                {{ \Carbon\Carbon::create(2026, $m, 1)->translatedFormat('F') }}
                            </option>
                        @endfor
                    </select>
                </div>

                <div>
                    <label style="font-size: 11px; font-weight: 700; color: var(--gray-500); text-transform: uppercase; display: block; margin-bottom: 4px;">Tahun</label>
                    <select name="year" class="form-control" style="width: auto; min-width: 100px;" onchange="this.form.submit()">
                        @for($y = now()->year - 2; $y <= now()->year + 1; $y++)
                            <option value="{{ $y }}" {{ $selectedYear == $y ? 'selected' : '' }}>{{ $y }}</option>
                        @endfor
                    </select>
                </div>

                <div>
                    <label style="font-size: 11px; font-weight: 700; color: var(--gray-500); text-transform: uppercase; display: block; margin-bottom: 4px;">Ruangan Lab</label>
                    <select name="lab_id" class="form-control" style="width: auto; min-width: 180px;" onchange="this.form.submit()">
                        <option value="">Semua Laboratorium</option>
                        @foreach($labs as $lab)
                            <option value="{{ $lab->id }}" {{ $selectedLabId == $lab->id ? 'selected' : '' }}>{{ $lab->nama_lab }} ({{ $lab->computers_count }} PC)</option>
                        @endforeach
                    </select>
                </div>
            </div>

            <div style="font-size: 13px; color: var(--gray-600);">
                Periode Laporan: <strong style="color: var(--unimal-green-dark);">{{ $startDate->translatedFormat('F Y') }}</strong>
            </div>
        </form>
    </div>

    <!-- Official Unimal Letterhead (Shown in Print / Export) -->
    <div class="print-header">
        <div style="font-size: 13px; font-weight: 800; letter-spacing: 1px;">KEMENTERIAN PENDIDIKAN TINGGI, SAINS, DAN TEKNOLOGI</div>
        <div style="font-size: 16px; font-weight: 800; letter-spacing: 0.5px;">UNIVERSITAS MALIKUSSALEH — FAKULTAS TEKNIK</div>
        <div style="font-size: 15px; font-weight: 800; color: #007033;">LABORATORIUM TEKNIK INFORMATIKA</div>
        <div style="font-size: 11px; color: #555; margin-top: 2px;">Jl. Cot Teungku Nie, Reuleuet, Kec. Muara Batu, Kab. Aceh Utara, Aceh 24355</div>
        <div style="font-size: 14px; font-weight: 800; margin-top: 14px; text-decoration: underline;">LAPORAN OPERASIONAL & KINERJA LABORATORIUM KOMPUTER</div>
        <div style="font-size: 12px; font-weight: 600; margin-top: 4px;">Periode: {{ $startDate->translatedFormat('F Y') }} • Ruangan: {{ $selectedLab ? $selectedLab->nama_lab : 'Seluruh Laboratorium' }}</div>
    </div>

    <!-- Executive Summary Cards -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px;">
        <div class="card" style="padding: 16px;">
            <div style="font-size: 11.5px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Total Unit PC</div>
            <div style="font-size: 24px; font-weight: 800; color: var(--gray-900); margin-top: 4px;">{{ $totalPc }} Unit</div>
            <div style="font-size: 11.5px; color: var(--unimal-green); font-weight: 600; margin-top: 4px;">{{ $onlinePc }} aktif saat ini</div>
        </div>

        <div class="card" style="padding: 16px;">
            <div style="font-size: 11.5px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Rata-rata Uptime</div>
            <div style="font-size: 24px; font-weight: 800; color: var(--gray-900); margin-top: 4px;">{{ $avgUptimeHours }} Jam</div>
            <div style="font-size: 11.5px; color: var(--gray-500); margin-top: 4px;">Jam operasional PC</div>
        </div>

        <div class="card" style="padding: 16px;">
            <div style="font-size: 11.5px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Insiden Terdeteksi</div>
            <div style="font-size: 24px; font-weight: 800; color: {{ $totalViolations > 0 ? '#ef4444' : 'var(--unimal-green)' }}; margin-top: 4px;">{{ $totalViolations }}</div>
            <div style="font-size: 11.5px; color: var(--gray-500); margin-top: 4px;">Aplikasi terlarang/game</div>
        </div>

        <div class="card" style="padding: 16px;">
            <div style="font-size: 11.5px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Storage Peringatan</div>
            <div style="font-size: 24px; font-weight: 800; color: {{ $warningDisks->count() > 0 ? 'var(--unimal-gold)' : 'var(--unimal-green)' }}; margin-top: 4px;">{{ $warningDisks->count() }} Partisi</div>
            <div style="font-size: 11.5px; color: var(--gray-500); margin-top: 4px;">Kapasitas > 80% penuh</div>
        </div>

        <div class="card" style="padding: 16px;">
            <div style="font-size: 11.5px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Perintah Remote</div>
            <div style="font-size: 24px; font-weight: 800; color: var(--gray-900); margin-top: 4px;">{{ $totalCommandsSent }}</div>
            <div style="font-size: 11.5px; color: var(--gray-500); margin-top: 4px;">Eksekusi ASLAB</div>
        </div>

        <div class="card" style="padding: 16px;">
            <div style="font-size: 11.5px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Kendala Meja</div>
            <div style="font-size: 24px; font-weight: 800; color: var(--gray-900); margin-top: 4px;">{{ $resolvedIssues }}/{{ $totalIssues }}</div>
            <div style="font-size: 11.5px; color: var(--unimal-green); font-weight: 600; margin-top: 4px;">Selesai diperbaiki</div>
        </div>
    </div>

    <!-- Section 1: Rekapitulasi Inventaris PC -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--gray-200); background: var(--gray-50);">
            <h3 style="font-size: 15px; font-weight: 800; color: var(--gray-900);">1. Rekapitulasi Inventaris & Kesehatan Perangkat</h3>
        </div>
        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 50px;">No</th>
                        <th>Nama PC</th>
                        <th>Ruangan Lab</th>
                        <th>Spesifikasi Pokok (CPU / RAM)</th>
                        <th>Sistem Operasi</th>
                        <th>Penyimpanan (Used / Total)</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($computers as $idx => $pc)
                        <tr>
                            <td>{{ $idx + 1 }}</td>
                            <td>
                                <strong style="color: var(--gray-900);">{{ $pc->nama_pc }}</strong>
                                <div style="font-size: 11px; color: var(--gray-500);">IP: {{ $pc->ip_terakhir ?: '-' }}</div>
                            </td>
                            <td>{{ $pc->lab ? $pc->lab->nama_lab : 'Unassigned' }}</td>
                            <td>
                                @if($pc->hardwareSpec)
                                    <div>{{ $pc->hardwareSpec->processor ?: 'Generic CPU' }}</div>
                                    <div style="font-size: 11px; color: var(--gray-500);">RAM: {{ $pc->hardwareSpec->ram_gb ? $pc->hardwareSpec->ram_gb . ' GB' : '-' }}</div>
                                @else
                                    <span style="color: var(--gray-400); font-style: italic;">Belum sync</span>
                                @endif
                            </td>
                            <td>{{ $pc->hardwareSpec ? $pc->hardwareSpec->os_version : '-' }}</td>
                            <td>
                                @if($pc->diskPartitions->count() > 0)
                                    @foreach($pc->diskPartitions as $disk)
                                        <div style="font-size: 12px;">
                                            <strong>{{ $disk->drive_letter }}:</strong> {{ $disk->used_gb }} / {{ $disk->total_gb }} GB ({{ $disk->used_percentage }}%)
                                        </div>
                                    @endforeach
                                @else
                                    <span style="color: var(--gray-400);">-</span>
                                @endif
                            </td>
                            <td>
                                @if($pc->isOnline())
                                    <span style="color: var(--unimal-green); font-weight: 700; font-size: 12px;">● Online</span>
                                @else
                                    <span style="color: var(--gray-400); font-size: 12px;">○ Offline</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 24px; color: var(--gray-500);">Tidak ada perangkat terdaftar</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Section 2: Insiden & Pelanggaran Software -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--gray-200); background: var(--gray-50); display: flex; justify-content: space-between; align-items: center;">
            <h3 style="font-size: 15px; font-weight: 800; color: var(--gray-900);">2. Rekapitulasi Pelanggaran Game & Aplikasi Terlarang</h3>
            <span style="font-size: 12.5px; font-weight: 700; color: var(--danger);">Total: {{ $totalViolations }} Insiden</span>
        </div>
        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 50px;">No</th>
                        <th>Waktu Kejadian</th>
                        <th>Perangkat (PC)</th>
                        <th>Ruang Lab</th>
                        <th>Aplikasi / Game Terdeteksi</th>
                        <th>Tindakan Sistem</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($violations as $vIdx => $violation)
                        <tr>
                            <td>{{ $vIdx + 1 }}</td>
                            <td>{{ $violation->detected_at ? $violation->detected_at->translatedFormat('d M Y, H:i') : '-' }} WIB</td>
                            <td><strong>{{ $violation->computer ? $violation->computer->nama_pc : 'PC Lab' }}</strong></td>
                            <td>{{ $violation->computer && $violation->computer->lab ? $violation->computer->lab->nama_lab : '-' }}</td>
                            <td>
                                <span style="font-family: monospace; font-weight: 700; color: #b91c1c; background: #fee2e2; padding: 2px 6px; border-radius: 4px;">
                                    {{ $violation->process_name }}
                                </span>
                            </td>
                            <td>Force-Kill + Screenshot</td>
                            <td>
                                @if($violation->resolved)
                                    <span style="color: var(--unimal-green); font-weight: 700; font-size: 12px;">Telah Ditinjau</span>
                                @else
                                    <span style="color: var(--danger); font-weight: 700; font-size: 12px;">Perlu Perhatian</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 20px; color: var(--unimal-green); font-weight: 600;">
                                ✓ Tidak ada insiden pelanggaran aplikasi terlarang selama bulan {{ $startDate->translatedFormat('F Y') }}.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Section 3: Peringatan Kapasitas Storage -->
    @if($warningDisks->count() > 0)
        <div class="card" style="padding: 0; overflow: hidden; border-left: 4px solid var(--unimal-gold);">
            <div style="padding: 16px 20px; border-bottom: 1px solid var(--gray-200); background: var(--unimal-gold-light);">
                <h3 style="font-size: 15px; font-weight: 800; color: #92400e;">3. Peringatan Kapasitas Penyimpanan (> 80% Penuh)</h3>
            </div>
            <div style="overflow-x: auto;">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Perangkat</th>
                            <th>Ruang Lab</th>
                            <th>Partisi</th>
                            <th>Total Kapasitas</th>
                            <th>Sisa Bebas</th>
                            <th>Persentase Terpakai</th>
                            <th>Rekomendasi Tindakan</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($warningDisks as $disk)
                            <tr>
                                <td><strong>{{ $disk->computer ? $disk->computer->nama_pc : '-' }}</strong></td>
                                <td>{{ $disk->computer && $disk->computer->lab ? $disk->computer->lab->nama_lab : '-' }}</td>
                                <td>Drive {{ $disk->drive_letter }}:</td>
                                <td>{{ $disk->total_gb }} GB</td>
                                <td style="color: #b91c1c; font-weight: 700;">{{ $disk->free_gb }} GB</td>
                                <td>
                                    <span style="font-weight: 800; color: #b91c1c;">{{ $disk->used_percentage }}%</span>
                                </td>
                                <td>
                                    <span style="font-size: 12px; color: var(--gray-600);">Jalankan Remote Cleanup Temp / Cache dari dashboard</span>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    @endif

    <!-- Section 4: Software Baru Terdeteksi Terpasang -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--gray-200); background: var(--gray-50);">
            <h3 style="font-size: 15px; font-weight: 800; color: var(--gray-900);">4. Riwayat Instalasi Software Baru (Audit Lisensi)</h3>
        </div>
        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 50px;">No</th>
                        <th>Waktu Terdeteksi</th>
                        <th>Perangkat (PC)</th>
                        <th>Ruang Lab</th>
                        <th>Nama Software Baru</th>
                        <th>Keterangan</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($newSoftwareList as $sIdx => $software)
                        <tr>
                            <td>{{ $sIdx + 1 }}</td>
                            <td>{{ $software->detected_at ? $software->detected_at->translatedFormat('d M Y, H:i') : '-' }} WIB</td>
                            <td><strong>{{ $software->computer ? $software->computer->nama_pc : 'PC Lab' }}</strong></td>
                            <td>{{ $software->computer && $software->computer->lab ? $software->computer->lab->nama_lab : '-' }}</td>
                            <td><strong style="color: var(--unimal-green-dark);">{{ $software->software_name }}</strong></td>
                            <td><span style="font-size: 11.5px; color: var(--gray-500);">Terpasang baru di sistem</span></td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 20px; color: var(--gray-500);">
                                Tidak ada software baru yang diinstal secara lokal pada periode ini.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Section 5: Rekap Kerusakan Meja & Penanganan -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--gray-200); background: var(--gray-50); display: flex; justify-content: space-between; align-items: center;">
            <h3 style="font-size: 15px; font-weight: 800; color: var(--gray-900);">5. Rekapitulasi Penanganan Kendala Meja / Hardware</h3>
            <span style="font-size: 12.5px; font-weight: 700; color: var(--unimal-green-dark);">{{ $resolvedIssues }} dari {{ $totalIssues }} Masalah Selesai</span>
        </div>
        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 50px;">Tiket</th>
                        <th>Tanggal</th>
                        <th>Perangkat</th>
                        <th>Pelapor</th>
                        <th>Kategori</th>
                        <th>Kendala</th>
                        <th>Status & Catatan Perbaikan</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($issueReports as $issue)
                        <tr>
                            <td>#{{ str_pad($issue->id, 4, '0', STR_PAD_LEFT) }}</td>
                            <td>{{ $issue->created_at->format('d/m/Y') }}</td>
                            <td><strong>{{ $issue->computer ? $issue->computer->nama_pc : '-' }}</strong></td>
                            <td>{{ $issue->reporter_name }}</td>
                            <td>{{ $issue->category_label }}</td>
                            <td>{{ $issue->description }}</td>
                            <td>
                                @if($issue->status === 'resolved')
                                    <div style="color: var(--unimal-green); font-weight: 700; font-size: 12px;">✓ SELESAI</div>
                                    <div style="font-size: 11px; color: var(--gray-600);">{{ $issue->resolution_notes ?: '-' }}</div>
                                @elseif($issue->status === 'in_progress')
                                    <div style="color: var(--unimal-gold); font-weight: 700; font-size: 12px;">🛠️ DALAM PENANGANAN</div>
                                @else
                                    <div style="color: #ef4444; font-weight: 700; font-size: 12px;">⏳ MENUNGGU</div>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 20px; color: var(--gray-500);">Tidak ada laporan kerusakan pada bulan ini.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Official Signature Block (Shown in Print) -->
    <div class="signature-section">
        <div style="text-align: center; width: 260px;">
            <div style="font-size: 12.5px;">Mengetahui,</div>
            <div style="font-size: 13px; font-weight: 700; margin-bottom: 70px;">Kepala Laboratorium TI Unimal</div>
            <div style="font-size: 13.5px; font-weight: 800; text-decoration: underline;">{{ \App\Models\Setting::get('lab_head_name', 'Dosen Pembina Lab, S.T., M.T.') }}</div>
            <div style="font-size: 11.5px; color: #555;">NIP. 19850101 201012 1 001</div>
        </div>

        <div style="text-align: center; width: 260px;">
            <div style="font-size: 12.5px;">Reuleuet, {{ now()->translatedFormat('d F Y') }}</div>
            <div style="font-size: 13px; font-weight: 700; margin-bottom: 70px;">Koordinator ASLAB TI</div>
            <div style="font-size: 13.5px; font-weight: 800; text-decoration: underline;">{{ \App\Models\Setting::get('aslab_coordinator_name', auth()->user()->name) }}</div>
            <div style="font-size: 11.5px; color: #555;">Koordinator Operasional</div>
        </div>
    </div>

</div>
@endsection
