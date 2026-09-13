@extends('layouts.app')

@section('title', 'Semua Komputer')
@section('page_title', 'Inventaris Komputer Terdaftar')

@section('topbar_actions')
    <a href="{{ route('labs.index') }}" class="btn btn-primary btn-sm">
        <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/></svg>
        <span>Lihat Kode Pairing Lab</span>
    </a>
@endsection

@section('content')
    <!-- Filters & Search -->
    <div class="card" style="margin-bottom: 24px; padding: 18px 24px;">
        <form method="GET" action="{{ route('computers.index') }}" style="display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
            <div style="flex: 1; min-width: 200px;">
                <input type="text" id="filterSearch" onkeyup="filterTable()" placeholder="Cari nama PC, hostname, atau IP..." class="form-control" style="padding: 8px 14px;">
            </div>

            <div style="width: 240px;">
                <select name="lab_id" onchange="this.form.submit()" class="form-control" style="padding: 8px 14px;">
                    <option value="">Semua Ruangan Lab</option>
                    @foreach($labs as $l)
                        <option value="{{ $l->id }}" {{ $selectedLabId == $l->id ? 'selected' : '' }}>
                            {{ $l->nama_lab }}
                        </option>
                    @endforeach
                </select>
            </div>

            @if($selectedLabId)
                <a href="{{ route('computers.index') }}" class="btn btn-secondary btn-sm">Reset Filter</a>
            @endif
        </form>
    </div>

    <!-- Computers Table -->
    <div class="card">
        <div style="overflow-x: auto;">
            <table class="data-table" id="computersTable">
                <thead>
                    <tr>
                        <th>Status</th>
                        <th>Nama PC</th>
                        <th>Ruangan Lab</th>
                        <th>IP Address</th>
                        <th>User Aktif</th>
                        <th>Uptime</th>
                        <th>Versi Agent</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($computers as $pc)
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
                            <td>
                                @if($pc->lab)
                                    <a href="{{ route('labs.show', $pc->lab) }}" style="color: var(--unimal-green); text-decoration: none; font-weight: 600;">
                                        {{ $pc->lab->nama_lab }}
                                    </a>
                                @else
                                    <span style="color: var(--gray-400);">(Belum dipindah)</span>
                                @endif
                            </td>
                            <td><code>{{ $pc->ip_terakhir ?? '-' }}</code></td>
                            <td>{{ $pc->active_user ?? '-' }}</td>
                            <td>{{ $pc->uptime_seconds > 0 ? gmdate("H:i:s", $pc->uptime_seconds) : '-' }}</td>
                            <td style="font-size: 12px; color: var(--gray-500);">v{{ $pc->versi_agent ?? '1.0.0' }}</td>
                            <td>
                                <div style="display: flex; gap: 6px;">
                                    <a href="{{ route('computers.show', $pc) }}" class="btn btn-secondary btn-sm">Detail</a>
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
                            <td colspan="8" style="text-align: center; color: var(--gray-400); padding: 40px;">
                                Belum ada komputer yang terdaftar pada filter ini.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection

@section('scripts')
<script>
    function filterTable() {
        const query = document.getElementById('filterSearch').value.toLowerCase();
        const rows = document.querySelectorAll('#computersTable tbody tr');
        rows.forEach(row => {
            const text = row.innerText.toLowerCase();
            row.style.display = text.includes(query) ? '' : 'none';
        });
    }
</script>
@endsection
