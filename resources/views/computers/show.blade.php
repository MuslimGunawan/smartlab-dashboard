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
        <!-- Left Column: Specs, Storage, Software & Commands -->
        <div style="display: flex; flex-direction: column; gap: 24px;">
            <!-- Main Info Card -->
            <div class="card">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <div style="display: flex; align-items: center; gap: 12px;">
                            <h3 style="font-size: 22px; font-weight: 800; color: var(--gray-900); margin: 0;">{{ $computer->nama_pc }}</h3>
                            @php $isOnline = $computer->isOnline(); @endphp
                            <span class="badge {{ $isOnline ? 'badge-online' : 'badge-offline' }}">
                                {{ $isOnline ? 'Online' : 'Offline' }}
                            </span>
                        </div>
                        <p style="font-size: 13px; color: var(--gray-500); margin: 4px 0 0 0;">
                            Hostname: <strong>{{ $computer->hostname ?? '-' }}</strong> | Lab: <strong>{{ $computer->lab?->nama_lab ?? 'Belum Ditentukan' }}</strong>
                        </p>
                    </div>

                    <!-- Quick Command Actions -->
                    <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                        <button onclick="openBroadcastModal()" class="btn btn-secondary btn-sm" style="color: var(--unimal-green);" title="Kirim Pesan Melayang ke Layar">
                            Pesan Layar
                        </button>
                        <form action="{{ route('computers.cleanup', $computer) }}" method="POST" onsubmit="return confirm('Jalankan pembersihan file sampah (%TEMP% & Recycle Bin) pada {{ $computer->nama_pc }}?');">
                            @csrf
                            <button type="submit" class="btn btn-secondary btn-sm" title="Bersihkan file sementara dan cache">
                                🧹 Bersihkan PC
                            </button>
                        </form>
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
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 14px; padding: 16px; background: var(--gray-50); border-radius: var(--radius-md); border: 1px solid var(--gray-200);">
                    <div>
                        <div style="font-size: 11px; color: var(--gray-400); font-weight: 700; text-transform: uppercase;">Alamat IP</div>
                        <div style="font-size: 13.5px; font-weight: 700; color: var(--gray-800); margin-top: 2px;">
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

            <!-- Hardware Specs & Storage Partitions (Fase 3) -->
            <div class="card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <h4 style="font-size: 16px; font-weight: 800; color: var(--gray-900); margin: 0; display: flex; align-items: center; gap: 8px;">
                        <span>🖥️ Spesifikasi Hardware & Partisi Storage</span>
                    </h4>
                    <span style="font-size: 11.5px; color: var(--gray-400);">Disinkronisasi otomatis via WMI</span>
                </div>

                @if($computer->hardwareSpec)
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; margin-bottom: 20px;">
                        <div style="background: var(--gray-50); padding: 12px 14px; border-radius: 8px; border: 1px solid var(--gray-200);">
                            <div style="font-size: 11px; color: var(--gray-500); font-weight: 700;">PROCESSOR (CPU)</div>
                            <div style="font-size: 13px; font-weight: 700; color: var(--gray-900); margin-top: 2px;">
                                {{ $computer->hardwareSpec->processor ?: 'Tidak diketahui' }}
                            </div>
                        </div>
                        <div style="background: var(--gray-50); padding: 12px 14px; border-radius: 8px; border: 1px solid var(--gray-200);">
                            <div style="font-size: 11px; color: var(--gray-500); font-weight: 700;">TOTAL RAM</div>
                            <div style="font-size: 13px; font-weight: 700; color: var(--gray-900); margin-top: 2px;">
                                {{ $computer->hardwareSpec->ram_gb ? number_format($computer->hardwareSpec->ram_gb, 1) . ' GB' : 'Tidak diketahui' }}
                            </div>
                        </div>
                        <div style="background: var(--gray-50); padding: 12px 14px; border-radius: 8px; border: 1px solid var(--gray-200);">
                            <div style="font-size: 11px; color: var(--gray-500); font-weight: 700;">SISTEM OPERASI</div>
                            <div style="font-size: 13px; font-weight: 700; color: var(--gray-900); margin-top: 2px;">
                                {{ $computer->hardwareSpec->os_version ?: 'Windows 10/11' }}
                            </div>
                        </div>
                        <div style="background: var(--gray-50); padding: 12px 14px; border-radius: 8px; border: 1px solid var(--gray-200);">
                            <div style="font-size: 11px; color: var(--gray-500); font-weight: 700;">SERIAL NUMBER PC</div>
                            <div style="font-size: 13px; font-weight: 700; color: var(--gray-900); margin-top: 2px;">
                                <code>{{ $computer->hardwareSpec->serial_number ?: '-' }}</code>
                            </div>
                        </div>
                    </div>
                @else
                    <div style="padding: 16px; background: var(--gray-50); border-radius: 8px; color: var(--gray-500); font-size: 13px; margin-bottom: 16px;">
                        Data spesifikasi hardware belum diterima dari Agent. Menunggu sinkronisasi pertama kali.
                    </div>
                @endif

                <!-- Partisi Disk -->
                <div style="font-size: 13px; font-weight: 700; color: var(--gray-800); margin-bottom: 10px;">Partisi Hard Drive / SSD:</div>
                @if($computer->diskPartitions && $computer->diskPartitions->count() > 0)
                    <div style="display: flex; flex-direction: column; gap: 12px;">
                        @foreach($computer->diskPartitions as $part)
                            @php
                                $total = $part->total_gb > 0 ? $part->total_gb : 1;
                                $free = $part->free_gb;
                                $used = max(0, $total - $free);
                                $percentUsed = min(100, round(($used / $total) * 100));
                                $color = $percentUsed > 90 ? 'var(--danger)' : ($percentUsed > 80 ? 'var(--unimal-gold)' : 'var(--unimal-green)');
                            @endphp
                            <div style="background: #ffffff; border: 1px solid var(--gray-200); border-radius: 8px; padding: 12px 16px;">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                                    <div style="font-weight: 700; font-size: 14px; color: var(--gray-900);">
                                        Drive {{ $part->drive_letter }}
                                    </div>
                                    <div style="font-size: 12px; color: var(--gray-600);">
                                        <strong>{{ number_format($free, 1) }} GB</strong> sisa dari <strong>{{ number_format($total, 1) }} GB</strong> ({{ $percentUsed }}% terpakai)
                                    </div>
                                </div>
                                <div style="width: 100%; height: 8px; background: var(--gray-200); border-radius: 4px; overflow: hidden;">
                                    <div style="width: {{ $percentUsed }}%; height: 100%; background: {{ $color }}; transition: width 0.3s ease;"></div>
                                </div>
                            </div>
                        @endforeach
                    </div>
                @else
                    <div style="font-size: 12.5px; color: var(--gray-400); font-style: italic;">
                        Belum ada informasi partisi harddisk.
                    </div>
                @endif
            </div>

            <!-- Installed Software (Fase 3) -->
            <div class="card" style="padding: 0; overflow: hidden;">
                <div style="padding: 16px 20px; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                    <div>
                        <h4 style="font-size: 16px; font-weight: 800; color: var(--gray-900); margin: 0;">
                            Software Terinstall ({{ $computer->installedSoftware->count() }})
                        </h4>
                        <span style="font-size: 12px; color: var(--gray-500);">Daftar aplikasi resmi dan pihak ketiga dari Windows Registry</span>
                    </div>
                    <div>
                        <input type="text" id="softwareSearch" onkeyup="filterSoftware()" placeholder="Cari nama software..." class="form-control" style="width: 220px; padding: 6px 12px; font-size: 12.5px;">
                    </div>
                </div>

                <div style="max-height: 400px; overflow-y: auto;">
                    <table class="data-table" id="softwareTable">
                        <thead>
                            <tr>
                                <th>Nama Software</th>
                                <th>Versi</th>
                                <th>Ukuran</th>
                                <th>Tgl Install</th>
                                <th style="text-align: right;">Aksi Remote</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($computer->installedSoftware as $sw)
                                <tr>
                                    <td>
                                        <div style="font-weight: 700; color: var(--gray-900); font-size: 13px;">{{ $sw->nama }}</div>
                                    </td>
                                    <td style="font-size: 12px; color: var(--gray-600);">{{ $sw->versi ?: '-' }}</td>
                                    <td style="font-size: 12px; color: var(--gray-600);">
                                        {{ $sw->ukuran_kb ? number_format($sw->ukuran_kb / 1024, 1) . ' MB' : '-' }}
                                    </td>
                                    <td style="font-size: 12px; color: var(--gray-600);">{{ $sw->tanggal_install ?: '-' }}</td>
                                    <td style="text-align: right;">
                                        @if($sw->uninstall_string)
                                            <form action="{{ route('computers.software.uninstall', [$computer, $sw->id]) }}" method="POST" style="margin: 0;" onsubmit="return confirm('Yakin ingin menjalankan silent uninstall untuk software {{ $sw->nama }} dari PC ini?');">
                                                @csrf
                                                <button type="submit" class="btn btn-secondary btn-sm" style="color: var(--danger); font-weight: 700;" title="Jalankan Silent Uninstall">
                                                    Uninstall
                                                </button>
                                            </form>
                                        @else
                                            <span style="font-size: 11px; color: var(--gray-400);">No Uninstaller</span>
                                        @endif
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="5" style="text-align: center; color: var(--gray-400); padding: 30px;">
                                        Belum ada daftar software yang terdata dari komputer ini.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
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

            <!-- QR Code & Label Meja (Fase 4 - PRD #22) -->
            <div class="card" style="margin-bottom: 24px; text-align: center;">
                <h4 style="font-size: 14px; font-weight: 800; color: var(--gray-900); margin-bottom: 6px;">QR Code & Label Meja</h4>
                <p style="font-size: 11.5px; color: var(--gray-500); margin-bottom: 12px;">Scan untuk lapor kendala/kerusakan perangkat</p>
                
                <div style="background: #ffffff; padding: 12px; border: 1px solid var(--gray-200); border-radius: 12px; display: inline-block; box-shadow: var(--shadow-sm); margin-bottom: 12px;">
                    <img src="https://api.qrserver.com/v1/create-qr-code/?size=160x160&data={{ urlencode(route('report-issue.create', $computer->device_token)) }}" alt="QR Meja {{ $computer->nama_pc }}" style="width: 140px; height: 140px; display: block;">
                </div>

                <div style="display: flex; flex-direction: column; gap: 8px;">
                    <button onclick="openBadgeModal()" class="btn btn-primary btn-sm" style="width: 100%; font-size: 12.5px; display: flex; align-items: center; justify-content: center; gap: 6px;">
                        <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/></svg>
                        <span>Cetak Label Stiker Meja</span>
                    </button>
                    <a href="{{ route('report-issue.create', $computer->device_token) }}" target="_blank" class="btn btn-secondary btn-sm" style="width: 100%; font-size: 12px;">
                        ↗ Buka Form Publik
                    </a>
                </div>
            </div>

            <!-- Device Token Card -->
            <div class="card" style="margin-bottom: 24px; background: var(--gray-50);">
                <h4 style="font-size: 13px; font-weight: 800; color: var(--gray-700); margin-bottom: 8px;">Device Token</h4>
                <div style="font-size: 11px; color: var(--gray-500); margin-bottom: 8px;">Kredensial autentikasi unik Agent PC:</div>
                <code style="display: block; word-break: break-all; font-size: 11.5px; background: #ffffff; padding: 10px; border-radius: 8px; border: 1px solid var(--gray-200); color: var(--gray-700);">
                    {{ substr($computer->device_token, 0, 14) }}...{{ substr($computer->device_token, -10) }}
                </code>
            </div>

            <!-- Delete Danger Zone (Restricted to Senior/Super Admin) -->
            @if(auth()->user()->canDeleteResources())
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
            @endif
        </div>
    </div>
@endsection

@section('scripts')
<!-- Broadcast Modal -->
<div id="broadcastModal" class="modal-backdrop">
    <div class="modal-box">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 style="font-size: 18px; font-weight: 800; color: var(--gray-900); margin: 0;">Kirim Pesan ke Layar PC</h3>
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

<!-- Printable Desk Badge Modal (Fase 4 - PRD #22) -->
<div id="badgeModal" class="modal-backdrop">
    <div class="modal-box" style="max-width: 420px; text-align: center;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h3 style="font-size: 16px; font-weight: 800; color: var(--gray-900); margin: 0;">Preview Label Stiker Meja</h3>
            <button onclick="closeBadgeModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:var(--gray-400);">&times;</button>
        </div>

        <!-- Printable Badge Area -->
        <div id="printableDeskBadge" style="border: 2px solid var(--unimal-green); border-radius: 12px; padding: 18px 16px; background: #ffffff; margin-bottom: 20px;">
            <div style="font-size: 11px; font-weight: 800; color: var(--unimal-green-dark); letter-spacing: 0.5px; text-transform: uppercase;">
                LABORATORIUM TEKNIK INFORMATIKA UNIMAL
            </div>
            <div style="font-size: 18px; font-weight: 800; color: #0f172a; margin: 4px 0 2px;">
                {{ $computer->nama_pc }}
            </div>
            <div style="font-size: 12px; font-weight: 600; color: var(--unimal-gold); margin-bottom: 12px;">
                {{ $computer->lab ? $computer->lab->nama_lab : 'Ruang Lab' }}
            </div>

            <div style="background: #f8fafc; padding: 10px; border-radius: 8px; border: 1px dashed var(--gray-300); display: inline-block; margin-bottom: 10px;">
                <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data={{ urlencode(route('report-issue.create', $computer->device_token)) }}" alt="QR Code" style="width: 130px; height: 130px; display: block;">
            </div>

            <div style="font-size: 11.5px; font-weight: 700; color: #1e293b;">
                Pindai QR ini dengan kamera HP
            </div>
            <div style="font-size: 10.5px; color: #64748b; margin-top: 2px;">
                Untuk melapor kendala mouse, keyboard, monitor, atau PC ke ASLAB
            </div>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 10px;">
            <button type="button" onclick="closeBadgeModal()" class="btn btn-secondary">Tutup</button>
            <button type="button" onclick="printBadge()" class="btn btn-primary" style="display: flex; align-items: center; gap: 6px;">
                <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/></svg>
                <span>Cetak Stiker Meja</span>
            </button>
        </div>
    </div>
</div>

<script>
    function openBadgeModal() {
        document.getElementById('badgeModal').classList.add('active');
    }
    function closeBadgeModal() {
        document.getElementById('badgeModal').classList.remove('active');
    }

    function printBadge() {
        const printContent = document.getElementById('printableDeskBadge').innerHTML;
        const printWindow = window.open('', '_blank', 'width=500,height=600');
        printWindow.document.write('<html><head><title>Cetak Label Meja - {{ $computer->nama_pc }}</title>');
        printWindow.document.write('<style>');
        printWindow.document.write('body { font-family: system-ui, sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }');
        printWindow.document.write('.badge-container { border: 2px solid #009344; border-radius: 12px; padding: 24px; text-align: center; width: 320px; }');
        printWindow.document.write('</style></head><body>');
        printWindow.document.write('<div class="badge-container">' + printContent + '</div>');
        printWindow.document.write('</body></html>');
        printWindow.document.close();
        printWindow.focus();
        setTimeout(() => {
            printWindow.print();
            printWindow.close();
        }, 300);
    }

    function openBroadcastModal() {
        document.getElementById('broadcastModal').classList.add('active');
    }
    function closeBroadcastModal() {
        document.getElementById('broadcastModal').classList.remove('active');
    }

    function filterSoftware() {
        let input = document.getElementById('softwareSearch');
        let filter = input.value.toLowerCase();
        let table = document.getElementById('softwareTable');
        let tr = table.getElementsByTagName('tr');

        for (let i = 1; i < tr.length; i++) {
            let td = tr[i].getElementsByTagName('td')[0];
            if (td) {
                let txtValue = td.textContent || td.innerText;
                if (txtValue.toLowerCase().indexOf(filter) > -1) {
                    tr[i].style.display = "";
                } else {
                    tr[i].style.display = "none";
                }
            }
        }
    }
</script>
@endsection
