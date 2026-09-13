@extends('layouts.app')

@section('title', 'Pengaturan Sistem & Notifikasi')
@section('page_title', 'Pengaturan Sistem & Notifikasi Alert')

@section('content')
<div style="max-width: 900px; display: flex; flex-direction: column; gap: 24px;">

    <!-- Telegram Alert Settings -->
    <div class="card" style="padding: 24px;">
        <div style="display: flex; align-items: center; gap: 14px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid var(--gray-200);">
            <div style="width: 44px; height: 44px; border-radius: 12px; background: #e0f2fe; color: #0284c7; display: flex; align-items: center; justify-content: center;">
                <svg style="width: 24px; height: 24px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>
            </div>
            <div>
                <h3 style="font-size: 16px; font-weight: 800; color: var(--gray-900);">Integrasi Notifikasi Instan Telegram (PRD #21)</h3>
                <p style="font-size: 13px; color: var(--gray-600);">Kirim pemberitahuan otomatis secara langsung ke bot / grup chat ASLAB saat terjadi kejadian penting di lab.</p>
            </div>
        </div>

        <form action="{{ route('settings.store') }}" method="POST">
            @csrf

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                <div class="form-group">
                    <label class="form-label" for="telegram_bot_token">Telegram Bot Token</label>
                    <input type="text" id="telegram_bot_token" name="telegram_bot_token" class="form-control" placeholder="Contoh: 7123456789:AAHxxxx..." value="{{ old('telegram_bot_token', $telegramBotToken) }}">
                    <div style="font-size: 11.5px; color: var(--gray-500); margin-top: 4px;">Dibuat melalui <code>@BotFather</code> di aplikasi Telegram.</div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="telegram_chat_id">Telegram Chat ID / Group ID</label>
                    <input type="text" id="telegram_chat_id" name="telegram_chat_id" class="form-control" placeholder="Contoh: -100192837465 atau ID user" value="{{ old('telegram_chat_id', $telegramChatId) }}">
                    <div style="font-size: 11.5px; color: var(--gray-500); margin-top: 4px;">ID grup chat tujuan yang sudah dimasukkan bot ASLAB.</div>
                </div>
            </div>

            <div style="margin-top: 8px; margin-bottom: 20px;">
                <label class="form-label">Jenis Notifikasi yang Dikirimkan:</label>
                <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 8px;">
                    <label style="display: flex; align-items: center; gap: 10px; font-size: 13.5px; cursor: pointer;">
                        <input type="checkbox" name="notify_issues_enabled" value="1" {{ $notifyIssues == '1' ? 'checked' : '' }} style="width: 16px; height: 16px; accent-color: var(--unimal-green);">
                        <span><strong>Laporan Kerusakan Meja/PC:</strong> Kirim alert saat mahasiswa melapor masalah via scan QR meja.</span>
                    </label>

                    <label style="display: flex; align-items: center; gap: 10px; font-size: 13.5px; cursor: pointer;">
                        <input type="checkbox" name="notify_violations_enabled" value="1" {{ $notifyViolations == '1' ? 'checked' : '' }} style="width: 16px; height: 16px; accent-color: var(--unimal-green);">
                        <span><strong>Pelanggaran Aplikasi/Game Terlarang:</strong> Kirim alert saat blocklist watcher memutus paksa proses game.</span>
                    </label>

                    <label style="display: flex; align-items: center; gap: 10px; font-size: 13.5px; cursor: pointer;">
                        <input type="checkbox" name="notify_software_enabled" value="1" {{ $notifySoftware == '1' ? 'checked' : '' }} style="width: 16px; height: 16px; accent-color: var(--unimal-green);">
                        <span><strong>Deteksi Software Baru:</strong> Kirim alert saat terdeteksi instalasi software baru di PC lab.</span>
                    </label>
                </div>
            </div>

            <!-- Report Signatures -->
            <div style="padding-top: 20px; border-top: 1px solid var(--gray-200); margin-top: 24px;">
                <h4 style="font-size: 14px; font-weight: 700; color: var(--gray-800); margin-bottom: 12px;">Format Pejabat Penandatangan Laporan Resmi Unimal</h4>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div class="form-group">
                        <label class="form-label" for="lab_head_name">Nama & Gelar Kepala Laboratorium</label>
                        <input type="text" id="lab_head_name" name="lab_head_name" class="form-control" placeholder="Contoh: Dahlan Abdullah, S.T., M.Kom." value="{{ old('lab_head_name', $labHeadName) }}">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="aslab_coordinator_name">Nama Koordinator ASLAB</label>
                        <input type="text" id="aslab_coordinator_name" name="aslab_coordinator_name" class="form-control" placeholder="Contoh: Muslim Gunawan" value="{{ old('aslab_coordinator_name', $aslabCoordinator) }}">
                    </div>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px;">
                <button type="submit" class="btn btn-primary" style="padding: 10px 20px;">Simpan Semua Pengaturan</button>
            </div>
        </form>

        <!-- Test Notification Form -->
        <div style="margin-top: 24px; padding-top: 20px; border-top: 1px dashed var(--gray-200); display: flex; justify-content: space-between; align-items: center;">
            <div>
                <strong style="font-size: 13px; color: var(--gray-800);">Uji Coba Pengiriman Pesan</strong>
                <p style="font-size: 12px; color: var(--gray-500);">Kirim pesan simulasi ke bot Telegram untuk memverifikasi token dan chat ID.</p>
            </div>
            <form action="{{ route('settings.test-telegram') }}" method="POST" style="margin:0;">
                @csrf
                <button type="submit" class="btn btn-secondary" style="font-size: 12.5px; display: inline-flex; align-items: center; gap: 6px;">
                    <svg style="width:16px;height:16px;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/></svg>
                    <span>Kirim Pesan Uji Coba</span>
                </button>
            </form>
        </div>
    </div>

</div>
@endsection
