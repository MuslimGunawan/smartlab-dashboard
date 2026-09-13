@extends('layouts.app')

@section('title', 'Kiosk Mode')
@section('page_title', 'Kiosk Mode — Pembatasan Akses OS Mahasiswa')

@section('content')
    <div style="background: linear-gradient(135deg, #fefce8 0%, #ffffff 100%); border: 1px solid rgba(226,163,19,0.3); border-radius: var(--radius-md); padding: 18px 22px; margin-bottom: 24px; display: flex; align-items: flex-start; gap: 14px;">
        <div style="width: 36px; height: 36px; border-radius: 10px; background: var(--unimal-gold); color:#fff; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
            <svg style="width:20px;height:20px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
        </div>
        <div>
            <h4 style="font-size: 14.5px; font-weight: 800; color: var(--gray-900); margin-bottom: 4px;">Proteksi Praktikum & Ujian Tanpa GPO Domain</h4>
            <p style="font-size: 12.5px; color: var(--gray-600); line-height: 1.5;">
                Kiosk mode membatasi komponen sensitif Windows (Task Manager, Command Prompt, Registry, dan Control Panel) saat sesi praktikum atau ujian berlangsung. Pembatasan ini <strong>bersifat instan dan dapat dibatalkan (reversible)</strong> kapan saja dari dashboard ini. Akun Administrator ASLAB otomatis dikecualikan agar ASLAB tidak terkunci.
            </p>
        </div>
    </div>

    <!-- Labs Kiosk Grid -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(380px, 1fr)); gap: 24px;">
        @foreach($labs as $lab)
            @php
                $setting = $kioskSettings[$lab->id] ?? null;
                $isTaskmgr = $setting?->disable_taskmgr ?? false;
                $isCmd = $setting?->disable_cmd ?? false;
                $isRegedit = $setting?->disable_regedit ?? false;
                $isCp = $setting?->disable_control_panel ?? false;
                $anyActive = $isTaskmgr || $isCmd || $isRegedit || $isCp;
            @endphp

            <div class="card" style="border-top: 4px solid {{ $anyActive ? 'var(--unimal-gold)' : 'var(--gray-300)' }};">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px;">
                    <div>
                        <h3 style="font-size: 17px; font-weight: 800; color: var(--gray-900);">{{ $lab->nama_lab }}</h3>
                        <p style="font-size: 12px; color: var(--gray-500); margin-top: 2px;">{{ $lab->computers->count() }} Komputer Terdaftar</p>
                    </div>
                    <span class="badge {{ $anyActive ? 'badge-pending' : 'badge-online' }}">
                        {{ $anyActive ? 'Restriksi Aktif' : 'Bebas Restriksi' }}
                    </span>
                </div>

                <form action="{{ route('kiosk.update-lab', $lab) }}" method="POST">
                    @csrf

                    <div style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 20px;">
                        <label style="display: flex; justify-content: space-between; align-items: center; padding: 10px 14px; background: var(--gray-50); border: 1px solid var(--gray-200); border-radius: 8px; cursor: pointer;">
                            <div>
                                <div style="font-size: 13px; font-weight: 700; color: var(--gray-800);">Disable Task Manager</div>
                                <div style="font-size: 11px; color: var(--gray-500);">Mencegah mahasiswa mematikan proses via Ctrl+Alt+Del</div>
                            </div>
                            <input type="checkbox" name="disable_taskmgr" value="1" {{ $isTaskmgr ? 'checked' : '' }} style="width: 18px; height: 18px; accent-color: var(--unimal-green);">
                        </label>

                        <label style="display: flex; justify-content: space-between; align-items: center; padding: 10px 14px; background: var(--gray-50); border: 1px solid var(--gray-200); border-radius: 8px; cursor: pointer;">
                            <div>
                                <div style="font-size: 13px; font-weight: 700; color: var(--gray-800);">Disable Command Prompt (CMD)</div>
                                <div style="font-size: 11px; color: var(--gray-500);">Memblokir akses terminal console & PowerShell</div>
                            </div>
                            <input type="checkbox" name="disable_cmd" value="1" {{ $isCmd ? 'checked' : '' }} style="width: 18px; height: 18px; accent-color: var(--unimal-green);">
                        </label>

                        <label style="display: flex; justify-content: space-between; align-items: center; padding: 10px 14px; background: var(--gray-50); border: 1px solid var(--gray-200); border-radius: 8px; cursor: pointer;">
                            <div>
                                <div style="font-size: 13px; font-weight: 700; color: var(--gray-800);">Disable Registry Editor</div>
                                <div style="font-size: 11px; color: var(--gray-500);">Mencegah modifikasi regedit.exe</div>
                            </div>
                            <input type="checkbox" name="disable_regedit" value="1" {{ $isRegedit ? 'checked' : '' }} style="width: 18px; height: 18px; accent-color: var(--unimal-green);">
                        </label>

                        <label style="display: flex; justify-content: space-between; align-items: center; padding: 10px 14px; background: var(--gray-50); border: 1px solid var(--gray-200); border-radius: 8px; cursor: pointer;">
                            <div>
                                <div style="font-size: 13px; font-weight: 700; color: var(--gray-800);">Disable Control Panel & Settings</div>
                                <div style="font-size: 11px; color: var(--gray-500);">Mencegah perubahan setting jaringan / OS</div>
                            </div>
                            <input type="checkbox" name="disable_control_panel" value="1" {{ $isCp ? 'checked' : '' }} style="width: 18px; height: 18px; accent-color: var(--unimal-green);">
                        </label>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--gray-100); padding-top: 14px;">
                        <button type="button" onclick="setAllKiosk(this.form, true)" class="btn btn-secondary btn-sm" style="font-size: 11px;">Pilih Semua</button>
                        <div style="display: flex; gap: 8px;">
                            <button type="button" onclick="setAllKiosk(this.form, false); this.form.submit();" class="btn btn-secondary btn-sm">Bebaskan</button>
                            <button type="submit" class="btn btn-primary btn-sm">Terapkan Kebijakan</button>
                        </div>
                    </div>
                </form>
            </div>
        @endforeach
    </div>
@endsection

@section('scripts')
<script>
    function setAllKiosk(form, state) {
        form.querySelectorAll('input[type="checkbox"]').forEach(cb => cb.checked = state);
    }
</script>
@endsection
