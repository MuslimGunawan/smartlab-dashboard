@extends('layouts.app')

@section('title', 'Ruangan Lab')
@section('page_title', 'Daftar Ruangan Laboratorium')

@section('topbar_actions')
    <button onclick="openCreateLabModal()" class="btn btn-primary btn-sm">
        <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
        <span>Tambah Lab Baru</span>
    </button>
@endsection

@section('content')
    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 24px;">
        @forelse($labs as $lab)
            <div class="card" style="display: flex; flex-direction: column; justify-content: space-between;">
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
                        <span class="badge {{ $lab->online_computers_count > 0 ? 'badge-online' : 'badge-offline' }}">
                            {{ $lab->online_computers_count }} / {{ $lab->computers_count }} Komputer Aktif
                        </span>
                    </div>

                    <h3 style="font-size: 17px; font-weight: 800; color: var(--gray-900); margin-bottom: 6px;">{{ $lab->nama_lab }}</h3>
                    <p style="font-size: 13px; color: var(--gray-500); margin-bottom: 14px;">
                        <svg style="width:14px;height:14px;vertical-align:-2px;color:var(--gray-400);margin-right:4px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                        {{ $lab->lokasi ?? 'Lokasi belum ditentukan' }}
                    </p>
                    
                    @if($lab->deskripsi)
                        <p style="font-size: 12.5px; color: var(--gray-600); line-height: 1.5; margin-bottom: 18px;">
                            {{ Str::limit($lab->deskripsi, 100) }}
                        </p>
                    @endif
                </div>

                <div style="border-top: 1px solid var(--gray-100); padding-top: 16px; margin-top: 12px; display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-size: 12px; color: var(--gray-400);">ID Lab: #{{ $lab->id }}</span>
                    <a href="{{ route('labs.show', $lab) }}" class="btn btn-primary btn-sm">
                        <span>Kelola Lab & Komputer &rarr;</span>
                    </a>
                </div>
            </div>
        @empty
            <div class="card" style="grid-column: 1 / -1; text-align: center; padding: 48px;">
                <h4 style="font-size: 16px; font-weight: 700; color: var(--gray-800); margin-bottom: 8px;">Belum Ada Ruangan Lab</h4>
                <p style="color: var(--gray-500); font-size: 13.5px; margin-bottom: 20px;">Silakan buat ruangan lab terlebih dahulu agar komputer dapat dipasangkan (paired).</p>
                <button onclick="openCreateLabModal()" class="btn btn-primary">Tambah Ruangan Pertama</button>
            </div>
        @endforelse
    </div>

    <!-- Create Lab Modal -->
    <div id="createLabModal" class="modal-backdrop">
        <div class="modal-box">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 style="font-size: 18px; font-weight: 800; color: var(--gray-900);">Tambah Ruangan Lab</h3>
                <button type="button" onclick="closeCreateLabModal()" style="background:none; border:none; font-size:20px; color:var(--gray-400); cursor:pointer;">&times;</button>
            </div>

            <form action="{{ route('labs.store') }}" method="POST">
                @csrf
                <div class="form-group">
                    <label class="form-label">Nama Laboratorium *</label>
                    <input type="text" name="nama_lab" class="form-control" placeholder="Contoh: Lab Komputer Pemrograman & RPL" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Lokasi Ruangan</label>
                    <input type="text" name="lokasi" class="form-control" placeholder="Contoh: Gedung TI Lt. 2, Ruang 204">
                </div>

                <div class="form-group">
                    <label class="form-label">Deskripsi / Catatan Lab</label>
                    <textarea name="deskripsi" class="form-control" rows="3" placeholder="Informasi singkat seputar lab..."></textarea>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
                    <button type="button" onclick="closeCreateLabModal()" class="btn btn-secondary">Batal</button>
                    <button type="submit" class="btn btn-primary">Simpan Lab</button>
                </div>
            </form>
        </div>
    </div>
@endsection

@section('scripts')
<script>
    function openCreateLabModal() {
        document.getElementById('createLabModal').classList.add('active');
    }
    function closeCreateLabModal() {
        document.getElementById('createLabModal').classList.remove('active');
    }
</script>
@endsection
