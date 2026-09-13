@extends('layouts.app')

@section('title', 'Ringkasan Sistem')
@section('page_title', 'Dashboard Monitoring')

@section('topbar_actions')
    <a href="{{ route('labs.index') }}" class="btn btn-primary btn-sm">
        <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
        <span>Kelola Lab</span>
    </a>
@endsection

@section('content')
    <!-- Stat Grid -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 20px; margin-bottom: 30px;">
        <div class="card" style="display: flex; align-items: center; gap: 16px;">
            <div style="width: 50px; height: 50px; border-radius: 14px; background: var(--unimal-green-light); color: var(--unimal-green); display: flex; align-items: center; justify-content: center;">
                <svg style="width:26px;height:26px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
            </div>
            <div>
                <div style="font-size: 12px; color: var(--gray-500); font-weight: 700; text-transform: uppercase;">Total Komputer</div>
                <div id="statTotalComputers" style="font-size: 26px; font-weight: 800; color: var(--gray-900); margin-top: 2px;">{{ $totalComputers }}</div>
            </div>
        </div>

        <div class="card" style="display: flex; align-items: center; gap: 16px;">
            <div style="width: 50px; height: 50px; border-radius: 14px; background: #dcfce7; color: #16a34a; display: flex; align-items: center; justify-content: center;">
                <svg style="width:26px;height:26px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5.636 18.364a9 9 0 010-12.728m12.728 0a9 9 0 010 12.728m-9.9-2.829a5 5 0 010-7.07m7.072 0a5 5 0 010 7.07M13 12a1 1 0 11-2 0 1 1 0 012 0z"/></svg>
            </div>
            <div>
                <div style="font-size: 12px; color: var(--gray-500); font-weight: 700; text-transform: uppercase;">Online Sekarang</div>
                <div id="statTotalOnline" style="font-size: 26px; font-weight: 800; color: #16a34a; margin-top: 2px;">{{ $totalOnline }}</div>
            </div>
        </div>

        <div class="card" style="display: flex; align-items: center; gap: 16px;">
            <div style="width: 50px; height: 50px; border-radius: 14px; background: var(--unimal-gold-light); color: var(--unimal-gold); display: flex; align-items: center; justify-content: center;">
                <svg style="width:26px;height:26px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>
            </div>
            <div>
                <div style="font-size: 12px; color: var(--gray-500); font-weight: 700; text-transform: uppercase;">Ruangan Lab</div>
                <div style="font-size: 26px; font-weight: 800; color: var(--gray-900); margin-top: 2px;">{{ $labs->count() }}</div>
            </div>
        </div>

        <div class="card" style="display: flex; align-items: center; gap: 16px;">
            <div style="width: 50px; height: 50px; border-radius: 14px; background: #fef3c7; color: #d97706; display: flex; align-items: center; justify-content: center;">
                <svg style="width:26px;height:26px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
            <div>
                <div style="font-size: 12px; color: var(--gray-500); font-weight: 700; text-transform: uppercase;">Antrian Perintah</div>
                <div style="font-size: 26px; font-weight: 800; color: #d97706; margin-top: 2px;">{{ $pendingCommandsCount }}</div>
            </div>
        </div>
    </div>

    <!-- Ruangan Lab Overview -->
    <div style="margin-bottom: 32px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h3 style="font-size: 16px; font-weight: 800; color: var(--gray-900);">Status Per Ruangan Lab</h3>
            <a href="{{ route('labs.index') }}" style="font-size: 13px; font-weight: 700; color: var(--unimal-green); text-decoration: none;">Lihat Semua Lab &rarr;</a>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px;">
            @forelse($labs as $lab)
                <div class="card" style="transition: transform 0.2s, box-shadow 0.2s;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
                        <div>
                            <h4 style="font-size: 15px; font-weight: 800; color: var(--gray-900);">{{ $lab->nama_lab }}</h4>
                            <p style="font-size: 12px; color: var(--gray-500); margin-top: 2px;">{{ $lab->lokasi ?? 'Teknik Informatika' }}</p>
                        </div>
                        <span class="badge {{ $lab->online_computers_count > 0 ? 'badge-online' : 'badge-offline' }}">
                            {{ $lab->online_computers_count }} / {{ $lab->computers_count }} Online
                        </span>
                    </div>

                    <!-- Progress bar -->
                    @php
                        $percentage = $lab->computers_count > 0 ? round(($lab->online_computers_count / $lab->computers_count) * 100) : 0;
                    @endphp
                    <div style="height: 6px; background: var(--gray-100); border-radius: 4px; overflow: hidden; margin: 14px 0;">
                        <div style="width: {{ $percentage }}%; height: 100%; background: var(--unimal-green); border-radius: 4px;"></div>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 16px; padding-top: 14px; border-top: 1px solid var(--gray-100);">
                        <span style="font-size: 12px; color: var(--gray-500);">Keaktifan: <strong>{{ $percentage }}%</strong></span>
                        <a href="{{ route('labs.show', $lab) }}" class="btn btn-secondary btn-sm">Buka Kontrol Lab</a>
                    </div>
                </div>
            @empty
                <div class="card" style="grid-column: 1 / -1; text-align: center; padding: 40px;">
                    <p style="color: var(--gray-500); font-size: 14px;">Belum ada ruangan lab yang dibuat.</p>
                    <a href="{{ route('labs.index') }}" class="btn btn-primary btn-sm" style="margin-top: 12px;">Tambah Lab Pertama</a>
                </div>
            @endforelse
        </div>
    </div>

    <!-- Live Computers Table -->
    <div class="card" style="margin-bottom: 32px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <div>
                <h3 style="font-size: 16px; font-weight: 800; color: var(--gray-900);">Komputer Terkoneksi (Real-time Feed)</h3>
                <p style="font-size: 12px; color: var(--gray-500); margin-top: 2px;">Status diperbarui otomatis setiap 6 detik</p>
            </div>
            <a href="{{ route('computers.index') }}" class="btn btn-secondary btn-sm">Lihat Semua Komputer</a>
        </div>

        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Status</th>
                        <th>Nama PC</th>
                        <th>Lab</th>
                        <th>Alamat IP</th>
                        <th>User Aktif</th>
                        <th>Uptime</th>
                        <th>Aksi Cepat</th>
                    </tr>
                </thead>
                <tbody id="computerTableBody">
                    <tr>
                        <td colspan="7" style="text-align:center; padding: 30px; color: var(--gray-400);">Memuat status komputer...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Recent Commands Log -->
    <div class="card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h3 style="font-size: 16px; font-weight: 800; color: var(--gray-900);">Riwayat Perintah Terakhir</h3>
            <a href="{{ route('audit-logs.index') }}" style="font-size: 13px; font-weight: 700; color: var(--unimal-green); text-decoration: none;">Selengkapnya &rarr;</a>
        </div>

        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Waktu</th>
                        <th>Target</th>
                        <th>Perintah</th>
                        <th>Status</th>
                        <th>Pengirim</th>
                        <th>Keterangan</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($recentCommands as $cmd)
                        <tr>
                            <td style="font-size: 12px; color: var(--gray-500);">{{ $cmd->created_at?->diffForHumans() }}</td>
                            <td>
                                <strong>{{ $cmd->computer?->nama_pc ?? ($cmd->lab ? 'Seluruh ' . $cmd->lab->nama_lab : 'Semua') }}</strong>
                            </td>
                            <td>
                                <span style="font-weight: 700; text-transform: uppercase; font-size: 12px;">{{ $cmd->tipe }}</span>
                            </td>
                            <td>
                                <span class="badge badge-{{ $cmd->status }}">{{ ucfirst($cmd->status) }}</span>
                            </td>
                            <td>{{ $cmd->creator?->name ?? 'Sistem' }}</td>
                            <td style="font-size: 12px; color: var(--gray-500);">{{ $cmd->result_message ?? '-' }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" style="text-align: center; color: var(--gray-400); padding: 24px;">Belum ada perintah yang dikirim.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection

@section('scripts')
<script>
    async function fetchStatusFeed() {
        try {
            const res = await fetch("{{ route('dashboard.status-feed') }}");
            if (!res.ok) return;
            const json = await res.json();
            if (json.success) {
                document.getElementById('statTotalComputers').innerText = json.data.total_computers;
                document.getElementById('statTotalOnline').innerText = json.data.total_online;

                const tbody = document.getElementById('computerTableBody');
                if (!json.data.computers || json.data.computers.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding: 24px; color: var(--gray-400);">Belum ada komputer yang terdaftar. Pasangkan Agent dengan kode pairing lab.</td></tr>';
                    return;
                }

                let html = '';
                json.data.computers.forEach(pc => {
                    const isOnline = pc.status === 'online';
                    html += `
                        <tr>
                            <td>
                                <span class="badge ${isOnline ? 'badge-online' : 'badge-offline'}">
                                    ${isOnline ? 'Online' : 'Offline'}
                                </span>
                            </td>
                            <td>
                                <a href="/computers/${pc.id}" style="font-weight: 700; color: var(--gray-900); text-decoration: none;">
                                    ${pc.nama_pc}
                                </a>
                                <div style="font-size: 11px; color: var(--gray-400);">${pc.hostname || ''}</div>
                            </td>
                            <td>${pc.lab_nama}</td>
                            <td><code>${pc.ip}</code></td>
                            <td>${pc.active_user}</td>
                            <td>${pc.uptime_human}</td>
                            <td>
                                <div style="display: flex; gap: 6px;">
                                    <form action="/computers/${pc.id}/commands" method="POST" onsubmit="return confirm('Kirim perintah restart ke ${pc.nama_pc}?');">
                                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                        <input type="hidden" name="tipe" value="restart">
                                        <input type="hidden" name="grace_seconds" value="60">
                                        <button type="submit" class="btn btn-secondary btn-sm" title="Restart PC (60s)">Restart</button>
                                    </form>
                                    <form action="/computers/${pc.id}/commands" method="POST" onsubmit="return confirm('Kirim perintah shutdown ke ${pc.nama_pc}?');">
                                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                        <input type="hidden" name="tipe" value="shutdown">
                                        <input type="hidden" name="grace_seconds" value="60">
                                        <button type="submit" class="btn btn-danger btn-sm" title="Shutdown PC (60s)">Shutdown</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    `;
                });
                tbody.innerHTML = html;
            }
        } catch (e) {
            console.error('Gagal mengambil status feed:', e);
        }
    }

    // Initial fetch and loop
    fetchStatusFeed();
    setInterval(fetchStatusFeed, 6000);
</script>
@endsection
