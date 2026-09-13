<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Setting;
use App\Services\TelegramService;
use Illuminate\Http\Request;

class SettingController extends Controller
{
    /**
     * Tampilkan Halaman Pengaturan
     */
    public function index()
    {
        $telegramBotToken = Setting::get('telegram_bot_token', '');
        $telegramChatId = Setting::get('telegram_chat_id', '');
        $notifyIssues = Setting::get('notify_issues_enabled', '1');
        $notifyViolations = Setting::get('notify_violations_enabled', '1');
        $notifySoftware = Setting::get('notify_software_enabled', '1');
        $labHeadName = Setting::get('lab_head_name', 'Dosen Pembina Lab, S.T., M.T.');
        $aslabCoordinator = Setting::get('aslab_coordinator_name', 'Koordinator ASLAB');

        return view('settings.index', compact(
            'telegramBotToken',
            'telegramChatId',
            'notifyIssues',
            'notifyViolations',
            'notifySoftware',
            'labHeadName',
            'aslabCoordinator'
        ));
    }

    /**
     * Simpan Pengaturan
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'telegram_bot_token' => 'nullable|string|max:255',
            'telegram_chat_id' => 'nullable|string|max:120',
            'notify_issues_enabled' => 'nullable|boolean',
            'notify_violations_enabled' => 'nullable|boolean',
            'notify_software_enabled' => 'nullable|boolean',
            'lab_head_name' => 'nullable|string|max:120',
            'aslab_coordinator_name' => 'nullable|string|max:120',
        ]);

        Setting::set('telegram_bot_token', $validated['telegram_bot_token'] ?? '', 'telegram');
        Setting::set('telegram_chat_id', $validated['telegram_chat_id'] ?? '', 'telegram');
        Setting::set('notify_issues_enabled', $request->has('notify_issues_enabled') ? '1' : '0', 'notification');
        Setting::set('notify_violations_enabled', $request->has('notify_violations_enabled') ? '1' : '0', 'notification');
        Setting::set('notify_software_enabled', $request->has('notify_software_enabled') ? '1' : '0', 'notification');
        Setting::set('lab_head_name', $validated['lab_head_name'] ?? '', 'report');
        Setting::set('aslab_coordinator_name', $validated['aslab_coordinator_name'] ?? '', 'report');

        AuditLog::log(auth()->id(), 'update_settings', 'System Settings', []);

        return back()->with('success', 'Pengaturan sistem berhasil disimpan!');
    }

    /**
     * Test Kirim Notifikasi Telegram
     */
    public function testTelegram(Request $request)
    {
        $token = $request->input('telegram_bot_token') ?: Setting::get('telegram_bot_token');
        $chatId = $request->input('telegram_chat_id') ?: Setting::get('telegram_chat_id');

        if (empty($token) || empty($chatId)) {
            return back()->with('error', 'Token Bot dan Chat ID Telegram wajib diisi untuk melakukan pengujian!');
        }

        $time = now()->translatedFormat('d F Y, H:i:s');
        $text = "🟢 <b>[UJI COBA KONEKSI TELEGRAM]</b>\n"
              . "━━━━━━━━━━━━━━━━━━━\n"
              . "Sistem: <b>SmartLab TI Unimal</b>\n"
              . "Status: <b>Koneksi Berhasil!</b>\n"
              . "Waktu: {$time} WIB\n"
              . "Pengirim: " . auth()->user()->name . "\n"
              . "━━━━━━━━━━━━━━━━━━━\n"
              . "<i>Notifikasi instan untuk laporan kerusakan & pelanggaran siap aktif.</i>";

        $success = TelegramService::sendMessage($text, $token, $chatId);

        if ($success) {
            return back()->with('success', 'Pesan uji coba berhasil terkirim ke Telegram! Periksa grup/chat Anda.');
        } else {
            return back()->with('error', 'Gagal mengirim pesan ke Telegram. Pastikan Bot Token dan Chat ID valid, dan Bot sudah di-start / dimasukkan ke grup.');
        }
    }
}
