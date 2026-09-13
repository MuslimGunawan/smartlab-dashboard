<?php

namespace App\Services;

use App\Models\IssueReport;
use App\Models\Setting;
use App\Models\SoftwareEvent;
use App\Models\Violation;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class TelegramService
{
    /**
     * Send general formatted message to Telegram channel/group
     */
    public static function sendMessage(string $text, ?string $botToken = null, ?string $chatId = null): bool
    {
        $token = $botToken ?: Setting::get('telegram_bot_token');
        $chat = $chatId ?: Setting::get('telegram_chat_id');

        if (empty($token) || empty($chat)) {
            return false; // Telegram not configured
        }

        try {
            $response = Http::timeout(5)->post("https://api.telegram.org/bot{$token}/sendMessage", [
                'chat_id' => $chat,
                'text' => $text,
                'parse_mode' => 'HTML',
                'disable_web_page_preview' => true,
            ]);

            return $response->successful();
        } catch (\Throwable $e) {
            Log::warning('Telegram Notification Error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send Alert when student submits hardware issue
     */
    public static function notifyIssueReport(IssueReport $issue): bool
    {
        if (Setting::get('notify_issues_enabled', '1') !== '1') {
            return false;
        }

        $pcName = $issue->computer ? $issue->computer->nama_pc : 'PC Tidak Terdaftar';
        $labName = $issue->lab ? $issue->lab->nama_lab : ($issue->computer && $issue->computer->lab ? $issue->computer->lab->nama_lab : '-');
        $time = now()->translatedFormat('d M Y H:i');

        $msg = "🛠 <b>[LAPOR KERUSAKAN BARU]</b>\n"
             . "━━━━━━━━━━━━━━━━━━━\n"
             . "📍 <b>Lokasi:</b> {$labName} — {$pcName}\n"
             . "👤 <b>Pelapor:</b> {$issue->reporter_name} (" . ($issue->reporter_nim ?: 'Mahasiswa') . ")\n"
             . "📞 <b>Kontak:</b> " . ($issue->reporter_contact ?: '-') . "\n"
             . "⚠️ <b>Kategori:</b> {$issue->category_label}\n"
             . "📝 <b>Kendala:</b> {$issue->description}\n"
             . "🕒 <b>Waktu:</b> {$time} WIB\n"
             . "━━━━━━━━━━━━━━━━━━━\n"
             . "⚡ <i>Segera cek dashboard SmartLab untuk penanganan teknis!</i>";

        return self::sendMessage($msg);
    }

    /**
     * Send Alert when blocklist violation occurs
     */
    public static function notifyViolation(Violation $violation): bool
    {
        if (Setting::get('notify_violations_enabled', '1') !== '1') {
            return false;
        }

        $pcName = $violation->computer ? $violation->computer->nama_pc : 'PC Lab';
        $labName = $violation->computer && $violation->computer->lab ? $violation->computer->lab->nama_lab : '-';
        $user = $violation->computer ? $violation->computer->active_user : 'Unknown';

        $msg = "🚨 <b>[PELANGGARAN TERDETEKSI]</b>\n"
             . "━━━━━━━━━━━━━━━━━━━\n"
             . "🚫 <b>Aplikasi:</b> <code>{$violation->process_name}</code>\n"
             . "📍 <b>PC:</b> {$pcName} ({$labName})\n"
             . "👤 <b>User Aktif:</b> {$user}\n"
             . "⚡ <b>Tindakan:</b> Force Kill Otomatis + Screenshot diambil\n"
             . "🕒 <b>Waktu:</b> {$violation->detected_at->translatedFormat('d M Y H:i:s')} WIB\n"
             . "━━━━━━━━━━━━━━━━━━━";

        return self::sendMessage($msg);
    }

    /**
     * Send Alert when new software is installed
     */
    public static function notifySoftwareEvent(SoftwareEvent $event): bool
    {
        if (Setting::get('notify_software_enabled', '1') !== '1') {
            return false;
        }

        $pcName = $event->computer ? $event->computer->nama_pc : 'PC Lab';
        $labName = $event->computer && $event->computer->lab ? $event->computer->lab->nama_lab : '-';

        $msg = "📦 <b>[SOFTWARE BARU TERPASANG]</b>\n"
             . "━━━━━━━━━━━━━━━━━━━\n"
             . "🆕 <b>Software:</b> <b>{$event->software_name}</b>\n"
             . "📍 <b>Lokasi:</b> {$pcName} ({$labName})\n"
             . "🕒 <b>Waktu:</b> {$event->detected_at->translatedFormat('d M Y H:i')} WIB\n"
             . "━━━━━━━━━━━━━━━━━━━\n"
             . "<i>Silakan verifikasi legalitas & izin instalasi melalui dashboard.</i>";

        return self::sendMessage($msg);
    }
}
