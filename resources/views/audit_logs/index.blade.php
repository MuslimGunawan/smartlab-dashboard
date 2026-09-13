@extends('layouts.app')

@section('title', 'Riwayat & Audit Log')
@section('page_title', 'Audit Trail & Riwayat Aktivitas')

@section('content')
    <div class="card" style="margin-bottom: 30px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <div>
                <h3 style="font-size: 16px; font-weight: 800; color: var(--gray-900);">Log Audit Aktivitas ASLAB</h3>
                <p style="font-size: 12.5px; color: var(--gray-500); margin-top: 2px;">
                    Mencatat seluruh aksi penting (login, buat lab, pairing, pengiriman perintah) untuk akuntabilitas.
                </p>
            </div>
            <span class="badge badge-online">Audit Aktif</span>
        </div>

        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Waktu</th>
                        <th>Pengguna / Pelaksana</th>
                        <th>Aksi</th>
                        <th>Target</th>
                        <th>Detail Metadata</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($auditLogs as $log)
                        <tr>
                            <td style="font-size: 12px; color: var(--gray-500); white-space: nowrap;">
                                {{ $log->created_at?->translatedFormat('d M Y, H:i:s') }}
                            </td>
                            <td>
                                <strong style="color: var(--gray-800);">{{ $log->user?->name ?? 'Sistem / Agent' }}</strong>
                                <div style="font-size: 11px; color: var(--gray-400);">{{ $log->user?->email ?? '-' }}</div>
                            </td>
                            <td>
                                <code style="font-size: 12px; font-weight: 700; color: var(--unimal-green); background: var(--unimal-green-light); padding: 3px 8px; border-radius: 6px;">
                                    {{ $log->aksi }}
                                </code>
                            </td>
                            <td>
                                <strong>{{ $log->target ?? '-' }}</strong>
                            </td>
                            <td style="font-size: 11.5px; color: var(--gray-600); max-width: 320px;">
                                @if($log->detail)
                                    <code>{{ json_encode($log->detail) }}</code>
                                @else
                                    -
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" style="text-align: center; color: var(--gray-400); padding: 32px;">
                                Belum ada catatan log aktivitas.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div style="margin-top: 20px;">
            {{ $auditLogs->links() }}
        </div>
    </div>
@endsection
