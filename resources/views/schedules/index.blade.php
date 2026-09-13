@extends('layouts.app')

@section('title', 'Jadwal Otomatis')
@section('page_title', 'Penjadwalan Otomatis Lab (Client-Side Scheduler)')

@section('topbar_actions')
    <button onclick="openCreateScheduleModal()" class="btn btn-primary btn-sm">
        <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
        <span>Tambah Jadwal Baru</span>
    </button>
@endsection

@section('content')
    <!-- Info banner explaining client-side scheduler -->
    <div style="background: linear-gradient(135deg, #e6f7ee 0%, #fefce8 100%); border: 1px solid rgba(0,147,68,0.2); border-radius: var(--radius-md); padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: flex-start; gap: 14px;">
        <div style="width: 36px; height: 36px; border-radius: 10px; background: var(--unimal-green); color:#fff; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
            <svg style="width:20px;height:20px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
        </div>
        <div>
            <h4 style="font-size: 14px; font-weight: 800; color: var(--gray-900); margin-bottom: 3px;">Arsitektur Penjadwalan Otomatis Cerdas</h4>
            <p style="font-size: 12.5px; color: var(--gray-600); line-height: 1.5;">
                Jadwal yang Anda buat di sini disimpan di database dan disinkronkan ke setiap Agent PC lab. <strong>Agent mengevaluasi waktu secara lokal di masing-masing komputer</strong> tanpa ketergantungan cron job server. Ini memastikan PC lab tetap mati otomatis tepat waktu walau koneksi internet kampus sedang terputus.
            </p>
        </div>
    </div>

    <!-- Schedules Table -->
    <div class="card">
        <div style="overflow-x: auto;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Status</th>
                        <th>Ruangan Lab</th>
                        <th>Jenis Perintah</th>
                        <th>Waktu Eksekusi</th>
                        <th>Hari Aktif</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($schedules as $sched)
                        <tr>
                            <td>
                                <form action="{{ route('schedules.toggle', $sched) }}" method="POST">
                                    @csrf
                                    <button type="submit" class="badge {{ $sched->aktif ? 'badge-online' : 'badge-offline' }}" style="border:none; cursor:pointer;" title="Klik untuk mengubah status aktif">
                                        {{ $sched->aktif ? 'AKTIF' : 'NONAKTIF' }}
                                    </button>
                                </form>
                            </td>
                            <td>
                                <strong>{{ $sched->lab?->nama_lab ?? 'Semua Lab' }}</strong>
                            </td>
                            <td>
                                <span style="font-weight: 800; font-size: 12px; text-transform: uppercase; color: {{ $sched->tipe === 'shutdown' ? 'var(--danger)' : 'var(--unimal-green)' }};">
                                    {{ $sched->tipe }}
                                </span>
                            </td>
                            <td>
                                <span style="font-size: 15px; font-weight: 800; color: var(--gray-900); background: var(--gray-100); padding: 4px 10px; border-radius: 8px;">
                                    {{ substr($sched->waktu, 0, 5) }} WIB
                                </span>
                            </td>
                            <td>
                                <div style="display: flex; gap: 4px; flex-wrap: wrap;">
                                    @foreach(['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'] as $h)
                                        @php $isActive = in_array($h, $sched->hari ?? []); @endphp
                                        <span style="font-size: 11px; font-weight: 700; padding: 2px 7px; border-radius: 6px; {{ $isActive ? 'background: var(--unimal-green-light); color: var(--unimal-green-dark);' : 'background: var(--gray-100); color: var(--gray-400);' }}">
                                            {{ ucfirst(substr($h, 0, 3)) }}
                                        </span>
                                    @endforeach
                                </div>
                            </td>
                            <td>
                                <form action="{{ route('schedules.destroy', $sched) }}" method="POST" onsubmit="return confirm('Apakah Anda yakin ingin menghapus jadwal ini?');">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-secondary btn-sm" style="color: var(--danger);">Hapus</button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" style="text-align: center; color: var(--gray-400); padding: 40px;">
                                Belum ada jadwal otomatis yang dibuat. Klik tombol di atas untuk menambahkan jadwal (misal: PC mati tiap jam 22:00).
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Create Schedule Modal -->
    <div id="createScheduleModal" class="modal-backdrop">
        <div class="modal-box" style="max-width: 520px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 style="font-size: 18px; font-weight: 800; color: var(--gray-900);">Buat Jadwal Otomatis Baru</h3>
                <button type="button" onclick="closeCreateScheduleModal()" style="background:none; border:none; font-size:20px; color:var(--gray-400); cursor:pointer;">&times;</button>
            </div>

            <form action="{{ route('schedules.store') }}" method="POST">
                @csrf
                <div class="form-group">
                    <label class="form-label">Ruangan Laboratorium *</label>
                    <select name="lab_id" class="form-control" required>
                        @foreach($labs as $lab)
                            <option value="{{ $lab->id }}">{{ $lab->nama_lab }}</option>
                        @endforeach
                    </select>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                    <div class="form-group">
                        <label class="form-label">Jenis Tindakan *</label>
                        <select name="tipe" class="form-control" required>
                            <option value="shutdown">Shutdown (Matikan PC)</option>
                            <option value="restart">Restart PC</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Jam Eksekusi (HH:MM) *</label>
                        <input type="time" name="waktu" class="form-control" value="22:00" required>
                    </div>
                </div>

                <div class="form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                        <label class="form-label" style="margin: 0;">Hari Pelaksanaan *</label>
                        <div style="display: flex; gap: 8px; font-size: 11px;">
                            <a href="javascript:void(0)" onclick="checkDays(true)" style="color: var(--unimal-green); text-decoration:none; font-weight:700;">Semua</a>
                            <a href="javascript:void(0)" onclick="checkWorkdays()" style="color: var(--unimal-green); text-decoration:none; font-weight:700;">Hari Kerja</a>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px;">
                        @foreach(['senin' => 'Senin', 'selasa' => 'Selasa', 'rabu' => 'Rabu', 'kamis' => 'Kamis', 'jumat' => 'Jumat', 'sabtu' => 'Sabtu', 'minggu' => 'Minggu'] as $val => $label)
                            <label style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; background: var(--gray-50); padding: 8px; border-radius: 8px; border: 1px solid var(--gray-200); cursor: pointer;">
                                <input type="checkbox" name="hari[]" value="{{ $val }}" class="day-check" {{ in_array($val, ['senin','selasa','rabu','kamis','jumat']) ? 'checked' : '' }}>
                                <span>{{ $label }}</span>
                            </label>
                        @endforeach
                    </div>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
                    <button type="button" onclick="closeCreateScheduleModal()" class="btn btn-secondary">Batal</button>
                    <button type="submit" class="btn btn-primary">Simpan Jadwal</button>
                </div>
            </form>
        </div>
    </div>
@endsection

@section('scripts')
<script>
    function openCreateScheduleModal() {
        document.getElementById('createScheduleModal').classList.add('active');
    }
    function closeCreateScheduleModal() {
        document.getElementById('createScheduleModal').classList.remove('active');
    }
    function checkDays(checked) {
        document.querySelectorAll('.day-check').forEach(cb => cb.checked = checked);
    }
    function checkWorkdays() {
        const workdays = ['senin', 'selasa', 'rabu', 'kamis', 'jumat'];
        document.querySelectorAll('.day-check').forEach(cb => {
            cb.checked = workdays.includes(cb.value);
        });
    }
</script>
@endsection
