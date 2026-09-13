@extends('layouts.app')

@section('title', 'Lapor Masalah & Kerusakan')
@section('page_title', 'Laporan Kendala Perangkat Lab')

@section('content')
<div style="display: flex; flex-direction: column; gap: 24px;">

    <!-- Top Metric Cards -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px;">
        <div class="card" style="display: flex; align-items: center; gap: 16px; padding: 20px;">
            <div style="width: 48px; height: 48px; border-radius: 12px; background: var(--gray-100); display: flex; align-items: center; justify-content: center; color: var(--gray-700);">
                <svg style="width:24px;height:24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
            </div>
            <div>
                <div style="font-size: 12px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Total Pengaduan</div>
                <div style="font-size: 24px; font-weight: 800; color: var(--gray-900);">{{ $totalReports }}</div>
            </div>
        </div>

        <div class="card" style="display: flex; align-items: center; gap: 16px; padding: 20px;">
            <div style="width: 48px; height: 48px; border-radius: 12px; background: #fee2e2; display: flex; align-items: center; justify-content: center; color: #ef4444;">
                <svg style="width:24px;height:24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <div style="font-size: 12px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Menunggu Respon</div>
                <div style="font-size: 24px; font-weight: 800; color: #ef4444;">{{ $pendingReports }}</div>
            </div>
        </div>

        <div class="card" style="display: flex; align-items: center; gap: 16px; padding: 20px;">
            <div style="width: 48px; height: 48px; border-radius: 12px; background: var(--unimal-gold-light); display: flex; align-items: center; justify-content: center; color: var(--unimal-gold);">
                <svg style="width:24px;height:24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <div style="font-size: 12px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Sedang Dikerjakan</div>
                <div style="font-size: 24px; font-weight: 800; color: var(--unimal-gold);">{{ $inProgressReports }}</div>
            </div>
        </div>

        <div class="card" style="display: flex; align-items: center; gap: 16px; padding: 20px;">
            <div style="width: 48px; height: 48px; border-radius: 12px; background: var(--unimal-green-light); display: flex; align-items: center; justify-content: center; color: var(--unimal-green-dark);">
                <svg style="width:24px;height:24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <div style="font-size: 12px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Sudah Diselesaikan</div>
                <div style="font-size: 24px; font-weight: 800; color: var(--unimal-green-dark);">{{ $resolvedReports }}</div>
            </div>
        </div>
    </div>

    <!-- Filter Bar -->
    <div class="card" style="padding: 16px 20px;">
        <form method="GET" action="{{ route('issues.index') }}" style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; justify-content: space-between;">
            <div style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center;">
                <select name="lab_id" class="form-control" style="width: auto; min-width: 170px;" onchange="this.form.submit()">
                    <option value="">Semua Ruangan Lab</option>
                    @foreach($labs as $lab)
                        <option value="{{ $lab->id }}" {{ request('lab_id') == $lab->id ? 'selected' : '' }}>{{ $lab->nama_lab }}</option>
                    @endforeach
                </select>

                <select name="status" class="form-control" style="width: auto; min-width: 150px;" onchange="this.form.submit()">
                    <option value="">Semua Status</option>
                    <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>⏳ Menunggu (Pending)</option>
                    <option value="in_progress" {{ request('status') == 'in_progress' ? 'selected' : '' }}>🛠️ Sedang Dikerjakan</option>
                    <option value="resolved" {{ request('status') == 'resolved' ? 'selected' : '' }}>✅ Selesai (Resolved)</option>
                </select>

                <select name="category" class="form-control" style="width: auto; min-width: 160px;" onchange="this.form.submit()">
                    <option value="">Semua Kategori</option>
                    <option value="mouse" {{ request('category') == 'mouse' ? 'selected' : '' }}>🖱️ Mouse</option>
                    <option value="keyboard" {{ request('category') == 'keyboard' ? 'selected' : '' }}>⌨️ Keyboard</option>
                    <option value="monitor" {{ request('category') == 'monitor' ? 'selected' : '' }}>🖥️ Monitor</option>
                    <option value="pc_hang" {{ request('category') == 'pc_hang' ? 'selected' : '' }}>⚡ PC Hang</option>
                    <option value="network" {{ request('category') == 'network' ? 'selected' : '' }}>🌐 Internet/LAN</option>
                    <option value="software" {{ request('category') == 'software' ? 'selected' : '' }}>📦 Software</option>
                    <option value="other" {{ request('category') == 'other' ? 'selected' : '' }}>🔧 Lainnya</option>
                </select>
            </div>

            @if(request()->hasAny(['lab_id', 'status', 'category']))
                <a href="{{ route('issues.index') }}" class="btn btn-secondary" style="font-size: 13px;">Reset Filter</a>
            @endif
        </form>
    </div>

    <!-- Table of Issues -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 20px; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center;">
            <h3 style="font-size: 16px; font-weight: 700; color: var(--gray-900);">Daftar Pengaduan Masalah Perangkat</h3>
            <span style="font-size: 13px; color: var(--gray-500);">Menampilkan {{ $issues->total() }} laporan</span>
        </div>

        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 70px;">Tiket</th>
                        <th>Waktu & Tanggal</th>
                        <th>Perangkat & Lab</th>
                        <th>Pelapor</th>
                        <th>Kategori</th>
                        <th style="min-width: 250px;">Deskripsi Kendala</th>
                        <th>Status</th>
                        <th style="width: 140px; text-align: center;">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($issues as $issue)
                        <tr>
                            <td>
                                <span style="font-weight: 800; font-size: 12px; color: var(--gray-700);">#{{ str_pad($issue->id, 4, '0', STR_PAD_LEFT) }}</span>
                            </td>
                            <td>
                                <div style="font-weight: 600; color: var(--gray-800);">{{ $issue->created_at->translatedFormat('d M Y') }}</div>
                                <div style="font-size: 11.5px; color: var(--gray-500);">{{ $issue->created_at->format('H:i') }} WIB</div>
                            </td>
                            <td>
                                @if($issue->computer)
                                    <a href="{{ route('computers.show', $issue->computer_id) }}" style="font-weight: 700; color: var(--unimal-green); text-decoration: none;">
                                        {{ $issue->computer->nama_pc }}
                                    </a>
                                    <div style="font-size: 11.5px; color: var(--gray-500);">{{ $issue->lab ? $issue->lab->nama_lab : ($issue->computer->lab ? $issue->computer->lab->nama_lab : '-') }}</div>
                                @else
                                    <span style="color: var(--gray-400); font-style: italic;">PC Dihapus</span>
                                @endif
                            </td>
                            <td>
                                <div style="font-weight: 700; color: var(--gray-900);">{{ $issue->reporter_name }}</div>
                                <div style="font-size: 11.5px; color: var(--gray-500);">{{ $issue->reporter_nim ?: 'Mahasiswa' }}</div>
                                @if($issue->reporter_contact)
                                    <a href="https://wa.me/{{ preg_replace('/[^0-9]/', '', $issue->reporter_contact) }}" target="_blank" style="font-size: 11.5px; color: #16a34a; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; margin-top: 2px;">
                                        <span>💬 {{ $issue->reporter_contact }}</span>
                                    </a>
                                @endif
                            </td>
                            <td>
                                <span style="display: inline-block; padding: 4px 8px; border-radius: 6px; font-size: 11.5px; font-weight: 700; background: var(--gray-100); color: var(--gray-700);">
                                    {{ $issue->category_label }}
                                </span>
                            </td>
                            <td>
                                <div style="font-size: 13px; color: var(--gray-800); line-height: 1.4;">
                                    {{ $issue->description }}
                                </div>
                                @if($issue->resolution_notes)
                                    <div style="margin-top: 6px; padding: 6px 10px; background: var(--unimal-green-light); border-left: 3px solid var(--unimal-green); border-radius: 4px; font-size: 12px; color: var(--unimal-green-dark);">
                                        <strong>Catatan ASLAB:</strong> {{ $issue->resolution_notes }}
                                        @if($issue->resolver)
                                            <span style="font-size: 11px; opacity: 0.8;">(oleh {{ $issue->resolver->name }})</span>
                                        @endif
                                    </div>
                                @endif
                            </td>
                            <td>
                                @if($issue->status === 'pending')
                                    <span style="display: inline-block; padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: 800; background: #fee2e2; color: #b91c1c;">
                                        ⏳ PENDING
                                    </span>
                                @elseif($issue->status === 'in_progress')
                                    <span style="display: inline-block; padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: 800; background: var(--unimal-gold-light); color: var(--unimal-gold);">
                                        🛠️ PROSES
                                    </span>
                                @else
                                    <span style="display: inline-block; padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: 800; background: var(--unimal-green-light); color: var(--unimal-green-dark);">
                                        ✅ SELESAI
                                    </span>
                                @endif
                            </td>
                            <td style="text-align: center;">
                                <div style="display: flex; gap: 6px; justify-content: center;">
                                    <button onclick="openResolveModal({{ $issue->id }}, '{{ $issue->status }}', '{{ addslashes($issue->resolution_notes ?? '') }}', '{{ addslashes($issue->computer ? $issue->computer->nama_pc : 'PC') }}')" class="btn btn-secondary" style="padding: 6px 10px; font-size: 12px;" title="Update Tindakan">
                                        Tindak
                                    </button>

                                    @if(auth()->user()->isSenior())
                                        <form action="{{ route('issues.destroy', $issue->id) }}" method="POST" onsubmit="return confirm('Hapus riwayat laporan ini?')" style="margin:0;">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-secondary" style="padding: 6px 8px; color: var(--danger);" title="Hapus Laporan">
                                                <svg style="width:14px;height:14px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                                            </button>
                                        </form>
                                    @endif
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 48px 16px; color: var(--gray-500);">
                                <div style="font-size: 36px; margin-bottom: 8px;">🎉</div>
                                <div style="font-size: 15px; font-weight: 700; color: var(--gray-800);">Tidak ada laporan kerusakan</div>
                                <p style="font-size: 13px; margin-top: 4px;">Semua perangkat komputer lab berfungsi normal tanpa kendala dari praktikan.</p>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($issues->hasPages())
            <div style="padding: 16px 20px; border-top: 1px solid var(--gray-200);">
                {{ $issues->links() }}
            </div>
        @endif
    </div>

</div>

<!-- Modal Update Status Penanganan -->
<div id="resolveModal" class="modal-backdrop">
    <div class="modal-box">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 style="font-size: 16px; font-weight: 700;" id="modalTitle">Penanganan Laporan Kerusakan</h3>
            <button onclick="closeResolveModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:var(--gray-400);">&times;</button>
        </div>

        <form id="resolveForm" method="POST" action="">
            @csrf
            @method('PATCH')

            <div class="form-group">
                <label class="form-label" for="update_status">Status Penanganan</label>
                <select id="update_status" name="status" class="form-control" required>
                    <option value="pending">⏳ Menunggu (Pending)</option>
                    <option value="in_progress">🛠️ Sedang Dikerjakan (In Progress)</option>
                    <option value="resolved">✅ Selesai / Berhasil Diperbaiki (Resolved)</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label" for="resolution_notes">Catatan Tindakan / Perbaikan ASLAB</label>
                <textarea id="resolution_notes" name="resolution_notes" class="form-control" placeholder="Contoh: Kabel mouse diganti baru dari gudang lab, tes klik normal..."></textarea>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
                <button type="button" onclick="closeResolveModal()" class="btn btn-secondary">Batal</button>
                <button type="submit" class="btn btn-primary">Simpan Status Tindakan</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openResolveModal(issueId, currentStatus, notes, pcName) {
        document.getElementById('modalTitle').innerText = 'Penanganan Kendala ' + pcName + ' (#' + issueId + ')';
        document.getElementById('update_status').value = currentStatus;
        document.getElementById('resolution_notes').value = notes;
        document.getElementById('resolveForm').action = '/issues/' + issueId;
        document.getElementById('resolveModal').classList.add('active');
    }

    function closeResolveModal() {
        document.getElementById('resolveModal').classList.remove('active');
    }
</script>
@endsection
