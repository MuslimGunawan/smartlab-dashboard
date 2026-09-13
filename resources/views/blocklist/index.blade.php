@extends('layouts.app')

@section('title', 'Daftar Aplikasi Terlarang')
@section('page_title', 'Aplikasi & Game Terlarang')

@section('topbar_actions')
    <button class="btn btn-primary" onclick="openAddModal()">
        <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
        </svg>
        <span>Tambah Aplikasi Terlarang</span>
    </button>
@endsection

@section('content')
<div style="display: flex; flex-direction: column; gap: 24px;">

    <!-- Info Banner -->
    <div style="background: linear-gradient(135deg, rgba(0,147,68,0.08) 0%, rgba(226,163,19,0.08) 100%); border: 1px solid rgba(0,147,68,0.2); border-radius: var(--radius-lg); padding: 18px 24px; display: flex; align-items: center; justify-content: space-between;">
        <div style="display: flex; align-items: center; gap: 16px;">
            <div style="width: 44px; height: 44px; border-radius: 12px; background: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; font-size: 22px;">
                🛑
            </div>
            <div>
                <h3 style="font-size: 15px; font-weight: 700; color: var(--gray-900); margin: 0 0 4px 0;">Otomasi Pengawasan Aplikasi Praktikum</h3>
                <p style="font-size: 13px; color: var(--gray-600); margin: 0;">Setiap aplikasi/game dalam daftar ini akan <strong>otomatis di-force-close</strong> oleh Agent di komputer mahasiswa, disertai <strong>tangkapan layar (screenshot) bukti pelanggaran</strong>.</p>
            </div>
        </div>
        <div>
            <a href="{{ route('violations.index') }}" class="btn btn-secondary btn-sm" style="display: flex; align-items: center; gap: 6px;">
                <svg style="width: 14px; height: 14px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                <span>Lihat Bukti Pelanggaran</span>
            </a>
        </div>
    </div>

    <!-- Quick Presets -->
    <div class="card" style="padding: 16px 20px;">
        <div style="font-size: 12.5px; font-weight: 700; color: var(--gray-600); margin-bottom: 10px;">Shortcut Tambah Cepat Game/Software Populer:</div>
        <div style="display: flex; flex-wrap: wrap; gap: 8px;">
            <button type="button" class="btn btn-secondary btn-sm" onclick="quickAdd('RobloxPlayerBeta.exe', 'Game Roblox Player')">+ Roblox</button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="quickAdd('valorant.exe', 'Game Valorant')">+ Valorant</button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="quickAdd('steam.exe', 'Steam Game Client')">+ Steam</button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="quickAdd('GenshinImpact.exe', 'Game Genshin Impact')">+ Genshin Impact</button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="quickAdd('cheatengine-x86_64.exe', 'Aplikasi Cheat Engine')">+ Cheat Engine</button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="quickAdd('pointblank.exe', 'Game Point Blank')">+ Point Blank</button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="quickAdd('EpicGamesLauncher.exe', 'Epic Games Launcher')">+ Epic Games</button>
        </div>
    </div>

    <!-- Table of Blocklist Apps -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center;">
            <div style="font-size: 15px; font-weight: 700; color: var(--gray-900);">
                Daftar Proses Terlarang ({{ $apps->total() }})
            </div>
            <form action="{{ route('blocklist.index') }}" method="GET" style="margin:0; display:flex; gap:8px;">
                <input type="text" name="q" value="{{ request('q') }}" placeholder="Cari nama proses..." class="form-control" style="width: 220px; padding: 6px 12px; font-size: 13px;">
                <button type="submit" class="btn btn-secondary btn-sm">Cari</button>
            </form>
        </div>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Nama Proses Windows</th>
                    <th>Keterangan / Kategori</th>
                    <th>Status Pengawasan</th>
                    <th>Dibuat Oleh</th>
                    <th>Terakhir Update</th>
                    <th style="text-align: right;">Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($apps as $app)
                    <tr>
                        <td>
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="display:inline-block; width:8px; height:8px; border-radius:50%; background-color: {{ $app->aktif ? 'var(--danger)' : 'var(--gray-400)' }};"></span>
                                <code style="font-size: 13px; font-weight: 700; color: var(--gray-900); background: var(--gray-100); padding: 3px 8px; border-radius: 6px;">{{ $app->process_name }}</code>
                            </div>
                        </td>
                        <td>{{ $app->keterangan ?: 'Tanpa keterangan' }}</td>
                        <td>
                            @if($app->aktif)
                                <span class="badge" style="background:#fee2e2; color:#dc2626;">AKTIF DIBLOKIR</span>
                            @else
                                <span class="badge" style="background:var(--gray-200); color:var(--gray-600);">NONAKTIF</span>
                            @endif
                        </td>
                        <td>{{ $app->creator?->name ?: 'Sistem / Admin' }}</td>
                        <td>{{ $app->updated_at->format('d M Y, H:i') }}</td>
                        <td style="text-align: right;">
                            <div style="display: inline-flex; gap: 8px; align-items: center;">
                                <form action="{{ route('blocklist.toggle', $app) }}" method="POST" style="margin:0;">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="btn btn-secondary btn-sm" title="Ubah Status">
                                        {{ $app->aktif ? 'Nonaktifkan' : 'Aktifkan' }}
                                    </button>
                                </form>
                                <form action="{{ route('blocklist.destroy', $app) }}" method="POST" style="margin:0;" onsubmit="return confirm('Hapus proses {{ $app->process_name }} dari daftar terlarang?')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-danger btn-sm" title="Hapus">Hapus</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px; color: var(--gray-400);">
                            Belum ada proses yang dimasukkan ke daftar terlarang.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        @if($apps->hasPages())
            <div style="padding: 16px 20px; border-top: 1px solid var(--gray-200);">
                {{ $apps->links() }}
            </div>
        @endif
    </div>
</div>

<!-- Modal Tambah Blocklist -->
<div id="addModal" class="modal-backdrop">
    <div class="modal-box">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 style="font-size: 16px; font-weight: 700; color: var(--gray-900); margin: 0;">Tambah Proses Terlarang</h3>
            <button type="button" onclick="closeAddModal()" style="background:none; border:none; font-size:20px; color:var(--gray-400); cursor:pointer;">&times;</button>
        </div>

        <form action="{{ route('blocklist.store') }}" method="POST">
            @csrf
            <div class="form-group">
                <label class="form-label">Nama File Proses (.exe)</label>
                <input type="text" id="procInput" name="process_name" class="form-control" placeholder="Contoh: RobloxPlayerBeta.exe" required autofocus>
                <span style="font-size: 11.5px; color: var(--gray-500); margin-top: 4px; display: block;">Masukkan nama executable file yang muncul di Windows Task Manager.</span>
            </div>

            <div class="form-group">
                <label class="form-label">Keterangan / Alasan Blokir</label>
                <input type="text" id="descInput" name="keterangan" class="form-control" placeholder="Contoh: Game online mahasiswa di luar materi praktikum">
            </div>

            <div class="form-group" style="display: flex; align-items: center; gap: 8px;">
                <input type="checkbox" id="aktif" name="aktif" value="1" checked style="width: 16px; height: 16px; accent-color: var(--unimal-green);">
                <label for="aktif" style="font-size: 13px; font-weight: 600; color: var(--gray-700); cursor: pointer; margin: 0;">Aktifkan proteksi blokir langsung di semua PC lab</label>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
                <button type="button" class="btn btn-secondary" onclick="closeAddModal()">Batal</button>
                <button type="submit" class="btn btn-primary">Simpan ke Blocklist</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openAddModal() {
        document.getElementById('addModal').classList.add('active');
        document.getElementById('procInput').focus();
    }

    function closeAddModal() {
        document.getElementById('addModal').classList.remove('active');
    }

    function quickAdd(procName, desc) {
        document.getElementById('procInput').value = procName;
        document.getElementById('descInput').value = desc;
        openAddModal();
    }
</script>
@endsection
