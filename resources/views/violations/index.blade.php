@extends('layouts.app')

@section('title', 'Insiden Pelanggaran Aplikasi')
@section('page_title', 'Insiden Pelanggaran Mahasiswa')

@section('topbar_actions')
    @if($unresolvedCount > 0)
        <span class="badge" style="background:#fee2e2; color:#dc2626; padding: 6px 12px; font-size:12px;">
            ⚠️ {{ $unresolvedCount }} Pelanggaran Belum Ditangani
        </span>
    @endif
@endsection

@section('content')
<div style="display: flex; flex-direction: column; gap: 24px;">

    <!-- Filter Bar -->
    <div class="card" style="padding: 18px 24px;">
        <form action="{{ route('violations.index') }}" method="GET" style="margin: 0; display: flex; flex-wrap: wrap; gap: 14px; align-items: flex-end;">
            <div style="flex: 1; min-width: 200px;">
                <label class="form-label" style="margin-bottom: 4px;">Cari PC atau Nama Proses</label>
                <input type="text" name="q" value="{{ request('q') }}" placeholder="Contoh: PC-01 atau roblox..." class="form-control">
            </div>

            <div style="width: 220px;">
                <label class="form-label" style="margin-bottom: 4px;">Ruangan Laboratorium</label>
                <select name="lab_id" class="form-control">
                    <option value="">-- Semua Laboratorium --</option>
                    @foreach($labs as $lab)
                        <option value="{{ $lab->id }}" {{ request('lab_id') == $lab->id ? 'selected' : '' }}>
                            {{ $lab->nama_lab }}
                        </option>
                    @endforeach
                </select>
            </div>

            <div style="width: 180px;">
                <label class="form-label" style="margin-bottom: 4px;">Status Penanganan</label>
                <select name="status" class="form-control">
                    <option value="">Semua Status</option>
                    <option value="unresolved" {{ request('status') == 'unresolved' ? 'selected' : '' }}>Belum Selesai</option>
                    <option value="resolved" {{ request('status') == 'resolved' ? 'selected' : '' }}>Sudah Selesai</option>
                </select>
            </div>

            <div style="display: flex; gap: 8px;">
                <button type="submit" class="btn btn-primary" style="height: 42px;">Filter</button>
                <a href="{{ route('violations.index') }}" class="btn btn-secondary" style="height: 42px;">Reset</a>
            </div>
        </form>
    </div>

    <!-- Violations Grid -->
    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 20px;">
        @forelse($violations as $item)
            <div class="card" style="padding: 0; overflow: hidden; display: flex; flex-direction: column; border-top: 4px solid {{ $item->resolved ? 'var(--unimal-green)' : 'var(--danger)' }};">
                <!-- Screenshot Area -->
                <div style="position: relative; background: #0f172a; height: 180px; display: flex; align-items: center; justify-content: center; cursor: pointer;" onclick="openImageModal('{{ $item->screenshot_path ? asset($item->screenshot_path) : '' }}', '{{ $item->process_name }} - {{ $item->computer?->nama_pc }}')">
                    @if($item->screenshot_path)
                        <img src="{{ asset($item->screenshot_path) }}" alt="Screenshot Pelanggaran" style="width: 100%; height: 100%; object-fit: cover;">
                        <div style="position: absolute; inset: 0; background: rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: center; opacity: 0; transition: opacity 0.2s;" onmouseenter="this.style.opacity='1'" onmouseleave="this.style.opacity='0'">
                            <span style="color: #ffffff; background: rgba(0,0,0,0.7); padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 600;">🔍 Klik Perbesar Screenshot</span>
                        </div>
                    @else
                        <div style="color: var(--gray-400); font-size: 13px; text-align: center; padding: 20px;">
                            <svg style="width: 36px; height: 36px; margin: 0 auto 8px; stroke-width: 1.5;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                            <span>Screenshot tidak tersedia</span>
                        </div>
                    @endif

                    <div style="position: absolute; top: 12px; right: 12px;">
                        @if($item->resolved)
                            <span class="badge" style="background:#dcfce7; color:#166534;">SELESAI</span>
                        @else
                            <span class="badge" style="background:#fee2e2; color:#dc2626; box-shadow: 0 2px 6px rgba(220,38,38,0.3);">PERLU TINDAKAN</span>
                        @endif
                    </div>
                </div>

                <!-- Info Details -->
                <div style="padding: 18px; flex: 1; display: flex; flex-direction: column; justify-content: space-between;">
                    <div>
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
                            <div>
                                <h4 style="font-size: 15px; font-weight: 700; color: var(--gray-900); margin: 0;">
                                    <a href="{{ route('computers.show', $item->computer) }}" style="color: inherit; text-decoration: none;">
                                        {{ $item->computer?->nama_pc ?: 'PC #' . $item->computer_id }}
                                    </a>
                                </h4>
                                <span style="font-size: 12px; color: var(--unimal-green); font-weight: 600;">
                                    {{ $item->computer?->lab?->nama_lab ?: 'Lab Belum Ditentukan' }}
                                </span>
                            </div>
                            <span style="font-size: 11.5px; color: var(--gray-400);">
                                {{ $item->detected_at->format('d/m H:i') }} WIB
                            </span>
                        </div>

                        <div style="background: var(--gray-50); border: 1px solid var(--gray-200); border-radius: 8px; padding: 10px 12px; margin: 12px 0;">
                            <div style="font-size: 11px; font-weight: 700; color: var(--gray-500); text-transform: uppercase;">Proses yang Diblokir:</div>
                            <code style="font-size: 13.5px; font-weight: 700; color: #dc2626; display: block; margin-top: 2px;">
                                {{ $item->process_name }}
                            </code>
                        </div>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 14px; padding-top: 12px; border-top: 1px solid var(--gray-100);">
                        <form action="{{ route('violations.resolve', $item) }}" method="POST" style="margin: 0; width: 100%;">
                            @csrf
                            @method('PATCH')
                            <button type="submit" class="btn {{ $item->resolved ? 'btn-secondary' : 'btn-primary' }} btn-sm" style="width: 100%;">
                                {{ $item->resolved ? 'Buka Kembali Insiden' : 'Tandai Telah Ditindaklanjuti' }}
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        @empty
            <div style="grid-column: 1 / -1;" class="card">
                <div style="text-align: center; padding: 60px 20px; color: var(--gray-400);">
                    <div style="font-size: 40px; margin-bottom: 12px;">🛡️</div>
                    <h3 style="font-size: 16px; font-weight: 700; color: var(--gray-700); margin: 0 0 6px 0;">Tidak Ada Insiden Pelanggaran</h3>
                    <p style="font-size: 13px; color: var(--gray-500); margin: 0;">Semua PC laboratorium tertib atau belum ada proses dari blocklist yang terdeteksi dibuka oleh mahasiswa.</p>
                </div>
            </div>
        @endforelse
    </div>

    @if($violations->hasPages())
        <div style="margin-top: 16px;">
            {{ $violations->links() }}
        </div>
    @endif
</div>

<!-- Modal Zoom Screenshot -->
<div id="imageModal" class="modal-backdrop" onclick="closeImageModal()">
    <div class="modal-box" style="max-width: 900px; padding: 16px; background: #000000; border-radius: var(--radius-lg);" onclick="event.stopPropagation()">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; color: #ffffff;">
            <h4 id="modalTitle" style="font-size: 14px; font-weight: 600; margin: 0;">Screenshot Pelanggaran</h4>
            <button type="button" onclick="closeImageModal()" style="background:none; border:none; font-size:24px; color:#ffffff; cursor:pointer;">&times;</button>
        </div>
        <div style="max-height: 80vh; overflow: auto; text-align: center;">
            <img id="modalImg" src="" alt="Bukti Pelanggaran" style="max-width: 100%; height: auto; border-radius: 6px; box-shadow: 0 4px 20px rgba(0,0,0,0.5);">
        </div>
    </div>
</div>

<script>
    function openImageModal(imgSrc, title) {
        if (!imgSrc) return;
        document.getElementById('modalImg').src = imgSrc;
        document.getElementById('modalTitle').innerText = title;
        document.getElementById('imageModal').classList.add('active');
    }

    function closeImageModal() {
        document.getElementById('imageModal').classList.remove('active');
    }
</script>
@endsection
