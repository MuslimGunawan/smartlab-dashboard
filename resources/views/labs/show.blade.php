@extends('layouts.app')

@section('title', $lab->nama_lab)
@section('page_title', $lab->nama_lab)

@section('topbar_actions')
    <div style="display: flex; gap: 8px;">
        <form action="{{ route('labs.pairing-code', $lab) }}" method="POST">
            @csrf
            <button type="submit" class="btn btn-gold btn-sm">
                <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/></svg>
                <span>Generate Kode Pairing</span>
            </button>
        </form>
        <button onclick="openBulkCommandModal('broadcast')" class="btn btn-secondary btn-sm" style="color: var(--unimal-green);">
            <span>Broadcast Layar</span>
        </button>
        <button onclick="openBulkCommandModal('restart')" class="btn btn-secondary btn-sm">
            <span>Restart Lab</span>
        </button>
        <button onclick="openBulkCommandModal('shutdown')" class="btn btn-danger btn-sm">
            <span>Shutdown Lab</span>
        </button>
    </div>
@endsection

@section('content')
    <!-- Lab Summary & Active Pairing Codes -->
    <div style="display: grid; grid-template-columns: 1fr 340px; gap: 24px; margin-bottom: 28px;">
        <!-- Left: Lab Info -->
        <div class="card">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
                <div>
                    <h3 style="font-size: 20px; font-weight: 800; color: var(--gray-900);">{{ $lab->nama_lab }}</h3>
                    <p style="font-size: 13.5px; color: var(--gray-500); margin-top: 4px;">{{ $lab->lokasi ?? 'Lokasi belum disetel' }}</p>
                </div>
                <span class="badge {{ $lab->computers->where('status', 'online')->count() > 0 ? 'badge-online' : 'badge-offline' }}">
                    {{ $lab->computers->where('status', 'online')->count() }} / {{ $lab->computers->count() }} Online
                </span>
            </div>

            @if($lab->deskripsi)
                <p style="font-size: 13px; color: var(--gray-600); line-height: 1.6; margin-top: 8px;">
                    {{ $lab->deskripsi }}
                </p>
            @endif

            <div style="display: flex; gap: 16px; margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--gray-100); font-size: 12.5px; color: var(--gray-500);">
                <div>Total Komputer: <strong style="color:var(--gray-900)">{{ $lab->computers->count() }}</strong></div>
                <div>ID Lab: <strong style="color:var(--gray-900)">#{{ $lab->id }}</strong></div>
            </div>
        </div>

        <!-- Right: Active Pairing Codes -->
        <div class="card" style="background: linear-gradient(135deg, #ffffff 0%, #fefce8 100%);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
                <h4 style="font-size: 14px; font-weight: 800; color: var(--gray-900);">Kode Pairing Aktif</h4>
                <span style="font-size: 11px; color: var(--unimal-gold); font-weight: 700;">Untuk Desktop Agent</span>
            </div>

            @forelse($activePairingCodes as $code)
                <div style="background: #ffffff; border: 1px solid var(--gray-200); border-radius: 10px; padding: 12px; margin-bottom: 10px; display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <code style="font-size: 16px; font-weight: 800; color: var(--unimal-green); letter-spacing: 1px;">{{ $code->code }}</code>
                        <div style="font-size: 11px; color: var(--gray-400); margin-top: 2px;">
                            Berlaku s/d {{ $code->expired_at->format('d M H:i') }}
                        </div>
                    </div>
                    <button type="button" onclick="navigator.clipboard.writeText('{{ $code->code }}'); alert('Kode pairing {{ $code->code }} disalin!');" class="btn btn-secondary btn-sm" style="padding: 4px 8px; font-size: 11px;">
                        Salin
                    </button>
                </div>
            @empty
                <div style="text-align: center; padding: 16px 0; color: var(--gray-500); font-size: 12.5px;">
                    <p>Tidak ada kode pairing aktif.</p>
                    <form action="{{ route('labs.pairing-code', $lab) }}" method="POST" style="margin-top: 10px;">
                        @csrf
                        <button type="submit" class="btn btn-gold btn-sm">Buat Kode Pairing</button>
                    </form>
                </div>
            @endforelse
            <div style="font-size: 11px; color: var(--gray-500); margin-top: 8px;">
                * Masukkan kode ini pada aplikasi Agent di PC lab agar otomatis terdaftar di lab ini.
            </div>
        </div>
    </div>

    <!-- Computers in this Lab -->
    <div class="card" style="margin-bottom: 28px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 style="font-size: 16px; font-weight: 800; color: var(--gray-900);">Daftar Komputer di Lab Ini</h3>
            <span style="font-size: 12px; color: var(--gray-500);">Total: {{ $lab->computers->count() }} unit</span>
        </div>

        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Status</th>
                        <th>Nama PC</th>
                        <th>Alamat IP</th>
                        <th>MAC Address</th>
                        <th>User Aktif</th>
                        <th>Uptime</th>
                        <th>Terakhir Dilihat</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($lab->computers as $pc)
                        @php $isOnline = $pc->isOnline(); @endphp
                        <tr>
                            <td>
                                <span class="badge {{ $isOnline ? 'badge-online' : 'badge-offline' }}">
                                    {{ $isOnline ? 'Online' : 'Offline' }}
                                </span>
                            </td>
                            <td>
                                <a href="{{ route('computers.show', $pc) }}" style="font-weight: 700; color: var(--gray-900); text-decoration: none;">
                                    {{ $pc->nama_pc }}
                                </a>
                                <div style="font-size: 11px; color: var(--gray-400);">{{ $pc->hostname }}</div>
                            </td>
                            <td><code>{{ $pc->ip_terakhir ?? '-' }}</code></td>
                            <td style="font-size: 12px; color: var(--gray-500);">{{ $pc->mac_address ?? '-' }}</td>
                            <td>{{ $pc->active_user ?? '-' }}</td>
                            <td>{{ $pc->uptime_seconds > 0 ? gmdate("H:i:s", $pc->uptime_seconds) : '-' }}</td>
                            <td style="font-size: 12px; color: var(--gray-500);">
                                {{ $pc->last_seen_at ? $pc->last_seen_at->diffForHumans() : 'Belum pernah' }}
                            </td>
                            <td>
                                <div style="display: flex; gap: 6px;">
                                    <form action="{{ route('computers.commands', $pc) }}" method="POST" onsubmit="return confirm('Kirim restart ke {{ $pc->nama_pc }}?');">
                                        @csrf
                                        <input type="hidden" name="tipe" value="restart">
                                        <input type="hidden" name="grace_seconds" value="60">
                                        <button type="submit" class="btn btn-secondary btn-sm" title="Restart (60s)">Restart</button>
                                    </form>
                                    <form action="{{ route('computers.commands', $pc) }}" method="POST" onsubmit="return confirm('Kirim shutdown ke {{ $pc->nama_pc }}?');">
                                        @csrf
                                        <input type="hidden" name="tipe" value="shutdown">
                                        <input type="hidden" name="grace_seconds" value="60">
                                        <button type="submit" class="btn btn-danger btn-sm" title="Shutdown (60s)">Shutdown</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" style="text-align: center; color: var(--gray-400); padding: 32px;">
                                Belum ada PC yang terdaftar di lab ini. Gunakan Kode Pairing di atas pada Agent desktop.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Bulk Command Modal -->
    <div id="bulkCommandModal" class="modal-backdrop">
        <div class="modal-box">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 id="bulkModalTitle" style="font-size: 18px; font-weight: 800; color: var(--gray-900);">Kirim Perintah Massal</h3>
                <button type="button" onclick="closeBulkModal()" style="background:none; border:none; font-size:20px; color:var(--gray-400); cursor:pointer;">&times;</button>
            </div>

            <form action="{{ route('labs.commands', $lab) }}" method="POST">
                @csrf
                <input type="hidden" id="bulkTipe" name="tipe" value="shutdown">

                <div class="form-group">
                    <label class="form-label">Grace Period / Waktu Tunggu Countdown (detik)</label>
                    <input type="number" name="grace_seconds" class="form-control" value="60" min="0" max="600" required>
                    <div style="font-size: 11.5px; color: var(--gray-500); margin-top: 4px;">
                        Memberikan waktu bagi mahasiswa/user untuk menyimpan file sebelum PC mati/restart.
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Pesan Pemberitahuan Layar</label>
                    <input type="text" name="message" class="form-control" value="Lab akan ditutup. Harap simpan pekerjaan Anda." required>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
                    <button type="button" onclick="closeBulkModal()" class="btn btn-secondary">Batal</button>
                    <button type="submit" id="bulkSubmitBtn" class="btn btn-danger">Kirim Sekarang</button>
                </div>
            </form>
        </div>
    </div>
@endsection

@section('scripts')
<script>
    function openBulkCommandModal(tipe) {
        document.getElementById('bulkTipe').value = tipe;
        let title = 'Kirim Perintah Massal';
        const submitBtn = document.getElementById('bulkSubmitBtn');

        if (tipe === 'shutdown') {
            title = 'Shutdown Seluruh Komputer Lab';
            submitBtn.className = 'btn btn-danger';
            submitBtn.innerText = 'Eksekusi Shutdown Massal';
        } else if (tipe === 'restart') {
            title = 'Restart Seluruh Komputer Lab';
            submitBtn.className = 'btn btn-primary';
            submitBtn.innerText = 'Eksekusi Restart Massal';
        } else if (tipe === 'broadcast') {
            title = 'Siarkan Pesan Layar ke Seluruh Lab';
            submitBtn.className = 'btn btn-primary';
            submitBtn.innerText = 'Kirim Pesan Sekarang';
        }

        document.getElementById('bulkModalTitle').innerText = title;
        document.getElementById('bulkCommandModal').classList.add('active');
    }

    function closeBulkModal() {
        document.getElementById('bulkCommandModal').classList.remove('active');
    }
</script>
@endsection
