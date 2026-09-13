@extends('layouts.app')

@section('title', $computer->nama_pc)
@section('page_title', 'Detail Komputer: ' . $computer->nama_pc)

@section('topbar_actions')
    <a href="{{ route('computers.index') }}" class="btn btn-secondary btn-sm">
        &larr; Kembali ke Daftar
    </a>
@endsection

@section('content')
    <div style="display: grid; grid-template-columns: 1fr 340px; gap: 24px; margin-bottom: 28px;">
        <!-- Left Column: Specs & Settings -->
        <div>
            <!-- Main Info Card -->
            <div class="card" style="margin-bottom: 24px;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;">
                    <div>
                        <div style="display: flex; align-items: center; gap: 12px;">
                            <h3 style="font-size: 22px; font-weight: 800; color: var(--gray-900);">{{ $computer->nama_pc }}</h3>
                            @php $isOnline = $computer->isOnline(); @endphp
                            <span class="badge {{ $isOnline ? 'badge-online' : 'badge-offline' }}">
                                {{ $isOnline ? 'Online' : 'Offline' }}
                            </span>
                        </div>
                        <p style="font-size: 13px; color: var(--gray-500); margin-top: 4px;">
                            Hostname: <strong>{{ $computer->hostname ?? '-' }}</strong> | Lab: <strong>{{ $computer->lab?->nama_lab ?? 'Belum Ditentukan' }}</strong>
                        </p>
                    </div>

                    <!-- Quick Command Actions -->
                    <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                        <button onclick="openBroadcastModal()" class="btn btn-secondary btn-sm" style="color: var(--unimal-green);">
                            Pesan Layar
                        </button>
                        <form action="{{ route('computers.wake', $computer) }}" method="POST">
                            @csrf
                            <button type="submit" class="btn btn-gold btn-sm" title="Kirim Magic Packet Wake-on-LAN">
                                Nyalakan (WOL)
                            </button>
                        </form>
                        <form action="{{ route('computers.commands', $computer) }}" method="POST" onsubmit="return confirm('Kirim restart ke {{ $computer->nama_pc }}?');">
                            @csrf
                            <input type="hidden" name="tipe" value="restart">
                            <input type="hidden" name="grace_seconds" value="60">
                            <button type="submit" class="btn btn-secondary btn-sm">Restart</button>
                        </form>
                        <form action="{{ route('computers.commands', $computer) }}" method="POST" onsubmit="return confirm('Kirim shutdown ke {{ $computer->nama_pc }}?');">
                            @csrf
                            <input type="hidden" name="tipe" value="shutdown">
                            <input type="hidden" name="grace_seconds" value="60">
                            <button type="submit" class="btn btn-danger btn-sm">Shutdown</button>
                        </form>
                    </div>
                </div>

                <!-- Info Grid -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; padding: 18px; background: var(--gray-50); border-radius: var(--radius-md); border: 1px solid var(--gray-200);">
                    <div>
                        <div style="font-size: 11px; color: var(--gray-400); font-weight: 700; text-transform: uppercase;">Alamat IP</div>
                        <div style="font-size: 14px; font-weight: 700; color: var(--gray-800); margin-top: 2px;">
                            <code>{{ $computer->ip_terakhir ?? '-' }}</code>
                        </div>
                    </div>
                    <div>
                        <div style="font-size: 11px; color: var(--gray-400); font-weight: 700; text-transform: uppercase;">MAC Address</div>
                        <div style="font-size: 13px; font-weight: 600; color: var(--gray-800); margin-top: 2px;">
                            {{ $computer->mac_address ?? '-' }}
                        </div>
                    </div>
                    <div>
                        <div style="font-size: 11px; color: var(--gray-400); font-weight: 700; text-transform: uppercase;">User Windows</div>
                        <div style="font-size: 13px; font-weight: 700; color: var(--gray-800); margin-top: 2px;">
                            {{ $computer->active_user ?? '-' }}
                        </div>
                    </div>
                    <div>
                        <div style="font-size: 11px; color: var(--gray-400); font-weight: 700; text-transform: uppercase;">Uptime</div>
                        <div style="font-size: 13px; font-weight: 700; color: var(--gray-800); margin-top: 2px;">
                            {{ $computer->uptime_seconds > 0 ? gmdate("H:i:s", $computer->uptime_seconds) : '-' }}
                        </div>
                    </div>
                    <div>
                        <div style="font-size: 11px; color: var(--gray-400); font-weight: 700; text-transform: uppercase;">Versi Agent</div>
                        <div style="font-size: 13px; font-weight: 700; color: var(--unimal-green); margin-top: 2px;">
                            v{{ $computer->versi_agent ?? '1.0.0' }}
                        </div>
                    </div>
                    <div>
                        <div style="font-size: 11px; color: var(--gray-400); font-weight: 700; text-transform: uppercase;">Terakhir Dilihat</div>
                        <div style="font-size: 12.5px; font-weight: 600; color: var(--gray-800); margin-top: 2px;">
                            {{ $computer->last_seen_at ? $computer->last_seen_at->diffForHumans() : 'Belum pernah' }}
                        </div>
                    </div>
                </div>
            </div>

            <!-- Command History for this PC -->
            <div class="card">
                <h4 style="font-size: 16px; font-weight: 800; color: var(--gray-900); margin-bottom: 16px;">Riwayat Perintah untuk Komputer Ini</h4>
                <div style="overflow-x: auto;">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Waktu</th>
                                <th>Perintah</th>
                                <th>Status</th>
                                <th>Pengirim</th>
                                <th>Keterangan / Hasil</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($computer->commands as $cmd)
                                <tr>
                                    <td style="font-size: 12px; color: var(--gray-500);">{{ $cmd->created_at?->diffForHumans() }}</td>
                                    <td><strong style="text-transform: uppercase;">{{ $cmd->tipe }}</strong></td>
                                    <td><span class="badge badge-{{ $cmd->status }}">{{ ucfirst($cmd->status) }}</span></td>
                                    <td>{{ $cmd->creator?->name ?? 'Sistem' }}</td>
                                    <td style="font-size: 12px; color: var(--gray-600);">
                                        {{ $cmd->result_message ?? ($cmd->status === 'pending' ? 'Menunggu siklus polling heartbeat...' : '-') }}
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="5" style="text-align: center; color: var(--gray-400); padding: 24px;">
                                        Belum ada perintah yang dikirim ke komputer ini.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Right Column: Settings Form & Token -->
        <div>
            <!-- Update Metadata Card -->
            <div class="card" style="margin-bottom: 24px;">
                <h4 style="font-size: 15px; font-weight: 800; color: var(--gray-900); margin-bottom: 14px;">Pengaturan Komputer</h4>
                <form action="{{ route('computers.update', $computer) }}" method="POST">
                    @csrf
                    @method('PUT')

                    <div class="form-group">
                        <label class="form-label">Nama Komputer (Label Lab)</label>
                        <input type="text" name="nama_pc" class="form-control" value="{{ $computer->nama_pc }}" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Ruangan Laboratorium</label>
                        <select name="lab_id" class="form-control">
                            <option value="">-- Tanpa Ruangan --</option>
                            @foreach($labs as $l)
                                <option value="{{ $l->id }}" {{ $computer->lab_id == $l->id ? 'selected' : '' }}>
                                    {{ $l->nama_lab }}
                                </option>
                            @endforeach
                        </select>
                    </div>

                    <button type="submit" class="btn btn-primary btn-sm" style="width: 100%; margin-top: 8px;">Simpan Perubahan</button>
                </form>
            </div>

            <!-- Device Token Card -->
            <div class="card" style="margin-bottom: 24px; background: var(--gray-50);">
                <h4 style="font-size: 13px; font-weight: 800; color: var(--gray-700); margin-bottom: 8px;">Device Token</h4>
                <div style="font-size: 11px; color: var(--gray-500); margin-bottom: 8px;">Kredensial autentikasi unik Agent PC:</div>
                <code style="display: block; word-break: break-all; font-size: 11.5px; background: #ffffff; padding: 10px; border-radius: 8px; border: 1px solid var(--gray-200); color: var(--gray-700);">
                    {{ substr($computer->device_token, 0, 14) }}...{{ substr($computer->device_token, -10) }}
                </code>
            </div>

            <!-- Delete Danger Zone -->
            <div class="card" style="border-color: #fecaca; background: #fffbfb;">
                <h4 style="font-size: 13px; font-weight: 800; color: #b91c1c; margin-bottom: 6px;">Zona Bahaya</h4>
                <p style="font-size: 11.5px; color: var(--gray-600); margin-bottom: 12px;">
                    Menghapus komputer akan mencabut akses token. PC harus dipasangkan ulang lewat kode pairing baru.
                </p>
                <form action="{{ route('computers.destroy', $computer) }}" method="POST" onsubmit="return confirm('PERINGATAN: Apakah Anda yakin ingin menghapus PC {{ $computer->nama_pc }}?');">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="btn btn-danger btn-sm" style="width: 100%;">Hapus Komputer Ini</button>
                </form>
            </div>
        </div>
    </div>
@endsection

@section('scripts')
<!-- Broadcast Modal -->
<div id="broadcastModal" class="modal-backdrop">
    <div class="modal-box">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 style="font-size: 18px; font-weight: 800; color: var(--gray-900);">Kirim Pesan ke Layar PC</h3>
            <button type="button" onclick="closeBroadcastModal()" style="background:none; border:none; font-size:20px; color:var(--gray-400); cursor:pointer;">&times;</button>
        </div>

        <form action="{{ route('computers.commands', $computer) }}" method="POST">
            @csrf
            <input type="hidden" name="tipe" value="broadcast">

            <div class="form-group">
                <label class="form-label">Isi Pesan Notifikasi Layar *</label>
                <textarea name="message" class="form-control" rows="3" placeholder="Contoh: Harap segera mengumpulkan tugas praktikum ke asisten lab." required></textarea>
            </div>

            <div class="form-group">
                <label class="form-label">Durasi Tampil di Layar (detik)</label>
                <input type="number" name="grace_seconds" class="form-control" value="15" min="5" max="300" required>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
                <button type="button" onclick="closeBroadcastModal()" class="btn btn-secondary">Batal</button>
                <button type="submit" class="btn btn-primary">Siarkan ke Layar PC</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openBroadcastModal() {
        document.getElementById('broadcastModal').classList.add('active');
    }
    function closeBroadcastModal() {
        document.getElementById('broadcastModal').classList.remove('active');
    }
</script>
@endsection
