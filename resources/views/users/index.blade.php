@extends('layouts.app')

@section('title', 'Kelola Pengguna & Asisten')
@section('page_title', 'Manajemen Pengguna & ASLAB')

@section('topbar_actions')
<button onclick="openCreateUserModal()" class="btn btn-primary" style="display: flex; align-items: center; gap: 8px;">
    <svg style="width: 18px; height: 18px;" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
    </svg>
    <span>Tambah Pengguna</span>
</button>
@endsection

@section('content')
<div style="display: flex; flex-direction: column; gap: 24px;">

    <!-- Info Box -->
    <div style="background: linear-gradient(135deg, var(--unimal-green-light) 0%, #f0fdf4 100%); border: 1px solid rgba(0, 147, 68, 0.2); border-radius: var(--radius-lg); padding: 20px; display: flex; align-items: flex-start; gap: 16px;">
        <div style="width: 40px; height: 40px; border-radius: 10px; background: var(--unimal-green); color: #ffffff; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
            <svg style="width: 22px; height: 22px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
        </div>
        <div>
            <h4 style="font-size: 15px; font-weight: 800; color: var(--unimal-green-dark); margin-bottom: 4px;">Hierarki Peran & Izin Akses (RBAC)</h4>
            <p style="font-size: 13px; color: var(--gray-600); line-height: 1.5;">
                <strong>Super Admin (Kalab):</strong> Memiliki kontrol penuh, manajemen akun, dan otorisasi seluruh lab.<br>
                <strong>ASLAB Senior:</strong> Mengelola lab dan PC, eksekusi perintah remote, konfigurasi Kiosk & Blocklist, serta laporan bulanan.<br>
                <strong>ASLAB Junior:</strong> Monitoring PC, broadcast pesan, lock sesi, dan penanganan pengaduan kerusakan praktikan.
            </p>
        </div>
    </div>

    <!-- User Table -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 20px; border-bottom: 1px solid var(--gray-200); display: flex; justify-content: space-between; align-items: center;">
            <h3 style="font-size: 16px; font-weight: 700; color: var(--gray-900);">Daftar Akun Pengguna</h3>
            <span style="font-size: 13px; color: var(--gray-500);">Total {{ $users->total() }} akun</span>
        </div>

        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 50px;">No</th>
                        <th>Nama Pengguna</th>
                        <th>Email Login</th>
                        <th>Peran (Role)</th>
                        <th>Ruangan Lab Tanggung Jawab</th>
                        <th>Terdaftar</th>
                        <th style="width: 140px; text-align: center;">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($users as $idx => $user)
                        <tr>
                            <td>{{ $users->firstItem() + $idx }}</td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <div style="width: 34px; height: 34px; border-radius: 50%; background: var(--unimal-gold-light); color: var(--unimal-gold); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px;">
                                        {{ substr($user->name, 0, 1) }}
                                    </div>
                                    <div>
                                        <strong style="color: var(--gray-900);">{{ $user->name }}</strong>
                                        @if($user->id === auth()->id())
                                            <span style="font-size: 11px; background: var(--unimal-green-light); color: var(--unimal-green-dark); padding: 2px 6px; border-radius: 4px; font-weight: 700; margin-left: 4px;">Akun Anda</span>
                                        @endif
                                    </div>
                                </div>
                            </td>
                            <td>{{ $user->email }}</td>
                            <td>
                                @if($user->role === 'super_admin')
                                    <span style="display: inline-block; padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: 800; background: #fee2e2; color: #b91c1c;">
                                        👑 Super Admin
                                    </span>
                                @elseif($user->role === 'aslab_senior')
                                    <span style="display: inline-block; padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: 800; background: var(--unimal-green-light); color: var(--unimal-green-dark);">
                                        ⭐ ASLAB Senior
                                    </span>
                                @elseif($user->role === 'aslab_junior')
                                    <span style="display: inline-block; padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: 800; background: var(--unimal-gold-light); color: var(--unimal-gold);">
                                        🌱 ASLAB Junior
                                    </span>
                                @else
                                    <span style="display: inline-block; padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: 800; background: var(--gray-100); color: var(--gray-700);">
                                        {{ $user->role }}
                                    </span>
                                @endif
                            </td>
                            <td>
                                @if($user->isSuperAdmin())
                                    <span style="color: var(--gray-500); font-style: italic;">Seluruh Ruangan (Full Akses)</span>
                                @elseif($user->labs->count() > 0)
                                    <div style="display: flex; flex-wrap: wrap; gap: 4px;">
                                        @foreach($user->labs as $lab)
                                            <span style="background: var(--gray-100); color: var(--gray-700); padding: 2px 8px; border-radius: 6px; font-size: 11.5px;">
                                                {{ $lab->nama_lab }}
                                            </span>
                                        @endforeach
                                    </div>
                                @else
                                    <span style="color: var(--gray-400); font-style: italic;">Belum Ditugaskan</span>
                                @endif
                            </td>
                            <td>{{ $user->created_at ? $user->created_at->translatedFormat('d M Y') : '-' }}</td>
                            <td style="text-align: center;">
                                <div style="display: flex; gap: 6px; justify-content: center;">
                                    <button onclick="openEditUserModal({{ $user->id }}, '{{ addslashes($user->name) }}', '{{ addslashes($user->email) }}', '{{ $user->role }}', {{ json_encode($user->labs->pluck('id')) }})" class="btn btn-secondary" style="padding: 6px 10px; font-size: 12px;">
                                        Edit
                                    </button>

                                    @if($user->id !== auth()->id())
                                        <form action="{{ route('users.destroy', $user->id) }}" method="POST" onsubmit="return confirm('Hapus pengguna {{ addslashes($user->name) }}?')" style="margin:0;">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-secondary" style="padding: 6px 8px; color: var(--danger);" title="Hapus Akun">
                                                <svg style="width: 14px; height: 14px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                                            </button>
                                        </form>
                                    @endif
                                </div>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        @if($users->hasPages())
            <div style="padding: 16px 20px; border-top: 1px solid var(--gray-200);">
                {{ $users->links() }}
            </div>
        @endif
    </div>

</div>

<!-- Modal Tambah Pengguna -->
<div id="createUserModal" class="modal-backdrop">
    <div class="modal-box" style="max-width: 520px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 style="font-size: 16px; font-weight: 700;">Tambah Pengguna / ASLAB Baru</h3>
            <button onclick="closeCreateUserModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:var(--gray-400);">&times;</button>
        </div>

        <form action="{{ route('users.store') }}" method="POST">
            @csrf

            <div class="form-group">
                <label class="form-label" for="new_name">Nama Lengkap</label>
                <input type="text" id="new_name" name="name" class="form-control" placeholder="Contoh: Muhammad Ilham" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="new_email">Alamat Email</label>
                <input type="email" id="new_email" name="email" class="form-control" placeholder="aslab@unimal.ac.id" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="new_password">Password Awal</label>
                <input type="password" id="new_password" name="password" class="form-control" placeholder="Minimal 6 karakter" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="new_role">Peran Akun</label>
                <select id="new_role" name="role" class="form-control" required>
                    <option value="aslab_junior">ASLAB Junior (Monitoring & Helpdesk)</option>
                    <option value="aslab_senior" selected>ASLAB Senior (Kontrol Penuh Lab & PC)</option>
                    <option value="super_admin">Super Admin (Kepala Lab / Dosen)</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">Tugaskan Ruangan Lab</label>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; max-height: 140px; overflow-y: auto; padding: 8px; border: 1px solid var(--gray-200); border-radius: var(--radius-md);">
                    @foreach($labs as $lab)
                        <label style="display: flex; align-items: center; gap: 8px; font-size: 13px; cursor: pointer;">
                            <input type="checkbox" name="labs[]" value="{{ $lab->id }}">
                            <span>{{ $lab->nama_lab }}</span>
                        </label>
                    @endforeach
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
                <button type="button" onclick="closeCreateUserModal()" class="btn btn-secondary">Batal</button>
                <button type="submit" class="btn btn-primary">Simpan Pengguna</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Edit Pengguna -->
<div id="editUserModal" class="modal-backdrop">
    <div class="modal-box" style="max-width: 520px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 style="font-size: 16px; font-weight: 700;">Edit Data Pengguna</h3>
            <button onclick="closeEditUserModal()" style="background:none; border:none; font-size:20px; cursor:pointer; color:var(--gray-400);">&times;</button>
        </div>

        <form id="editUserForm" method="POST" action="">
            @csrf
            @method('PUT')

            <div class="form-group">
                <label class="form-label" for="edit_name">Nama Lengkap</label>
                <input type="text" id="edit_name" name="name" class="form-control" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="edit_email">Alamat Email</label>
                <input type="email" id="edit_email" name="email" class="form-control" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="edit_password">Ganti Password (Kosongkan jika tidak diubah)</label>
                <input type="password" id="edit_password" name="password" class="form-control" placeholder="Kosongkan jika tetap">
            </div>

            <div class="form-group">
                <label class="form-label" for="edit_role">Peran Akun</label>
                <select id="edit_role" name="role" class="form-control" required>
                    <option value="aslab_junior">ASLAB Junior</option>
                    <option value="aslab_senior">ASLAB Senior</option>
                    <option value="super_admin">Super Admin</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">Tugaskan Ruangan Lab</label>
                <div id="editLabsContainer" style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; max-height: 140px; overflow-y: auto; padding: 8px; border: 1px solid var(--gray-200); border-radius: var(--radius-md);">
                    @foreach($labs as $lab)
                        <label style="display: flex; align-items: center; gap: 8px; font-size: 13px; cursor: pointer;">
                            <input type="checkbox" name="labs[]" value="{{ $lab->id }}" id="edit_lab_{{ $lab->id }}">
                            <span>{{ $lab->nama_lab }}</span>
                        </label>
                    @endforeach
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
                <button type="button" onclick="closeEditUserModal()" class="btn btn-secondary">Batal</button>
                <button type="submit" class="btn btn-primary">Simpan Perubahan</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openCreateUserModal() {
        document.getElementById('createUserModal').classList.add('active');
    }
    function closeCreateUserModal() {
        document.getElementById('createUserModal').classList.remove('active');
    }

    function openEditUserModal(id, name, email, role, assignedLabIds) {
        document.getElementById('editUserForm').action = '/users/' + id;
        document.getElementById('edit_name').value = name;
        document.getElementById('edit_email').value = email;
        document.getElementById('edit_password').value = '';
        document.getElementById('edit_role').value = role;

        // Reset and check labs
        const checkboxes = document.querySelectorAll('#editLabsContainer input[type="checkbox"]');
        checkboxes.forEach(cb => {
            cb.checked = assignedLabIds.includes(parseInt(cb.value));
        });

        document.getElementById('editUserModal').classList.add('active');
    }

    function closeEditUserModal() {
        document.getElementById('editUserModal').classList.remove('active');
    }
</script>
@endsection
