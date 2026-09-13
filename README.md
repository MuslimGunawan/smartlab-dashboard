# SmartLab Dashboard (Unimal) 🏛️💻

> **Web Dashboard & REST API Manajemen Laboratorium Komputer Universitas Malikussaleh (Unimal)**

![Laravel](https://img.shields.io/badge/Laravel-12-FF2D20?logo=laravel&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-8.2+-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-9.0+-4479A1?logo=mysql&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/TailwindCSS-Custom%20Design-38B2AC?logo=tailwindcss&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## 🌟 Ringkasan Sistem

**SmartLab Dashboard** adalah platform pusat kendali berbasis web untuk Asisten Laboratorium (ASLAB) dan Admin di Universitas Malikussaleh. Sistem ini memungkinkan pemantauan kesehatan komputer klien secara real-time, pengiriman perintah kendali (Shutdown, Restart, Broadcast, Kiosk Mode, Wake-on-LAN), manajemen jadwal praktikum, inventarisasi, dan pelaporan log audit komprehensif.

### Fitur Utama

- 📊 **Monitoring Real-Time**: Grid visual interaktif komputer lab dengan status online/offline, utilisasi RAM & CPU, dan filter dinamis per Lab.
- 🔑 **Zero-Config Pairing**: Pembuatan kode OTP 6-digit dengan kedaluwarsa 15 menit untuk pairing otomatis agent komputer baru.
- ⚡ **Kontrol Remote Massal & Parsial**:
  - Shutdown & Restart serempak satu lab atau per unit komputer dengan grace period countdown.
  - Pembatalan shutdown darurat (`abort_shutdown`).
  - Broadcast pengumuman instan ke layar praktikan.
  - Toggle Kiosk Mode (kunci Task Manager, CMD, Regedit, Control Panel saat ujian/praktikum).
  - **Wake-on-LAN (WOL)**: Mengirimkan magic packet UDP ke kartu jaringan (MAC address) untuk menyalakan PC dari jarak jauh.
- 📅 **Otomasi Jadwal Praktikum**: Penjadwalan power on/off dan aktivasi Kiosk mode berdasarkan jam kuliah/praktikum.
- 🛡️ **Role-Based Access Control (RBAC)**: Pemisahan hak akses antara Super Admin dan ASLAB.
- 📋 **Audit Trail**: Pencatatan riwayat setiap aksi admin, perintah, dan status eksekusi.

---

## 🏗️ Struktur Basis Data

Terdiri dari 16 tabel relasional terpadu:
- `users`, `sessions`, `password_reset_tokens`
- `labs`, `computers`, `pairing_codes`
- `commands`, `schedules`, `kiosk_policies`
- `audit_logs`, `hardware_specs`, `software_inventories`
- `blacklists`, `violations`, `maintenance_records`, `system_settings`

---

## 🚀 Panduan Instalasi & Menjalankan

### Persyaratan
- PHP >= 8.2 (dengan ekstensi `pdo_mysql`, `mbstring`, `openssl`)
- Composer
- MySQL >= 8.0 / MariaDB

### Langkah Instalasi
```bash
# Clone repository
git clone https://github.com/MuslimGunawan/smartlab-dashboard.git
cd smartlab-dashboard

# Install dependensi PHP
composer install

# Salin konfigurasi environment
cp .env.example .env

# Generate Application Key
php artisan key:generate

# Konfigurasi database di file .env:
# DB_DATABASE=labcontrol_unimal
# DB_USERNAME=root
# DB_PASSWORD=

# Jalankan migrasi dan seeder
php artisan migrate --seed

# Jalankan development server
php artisan serve --port=8000
```

### Akun Bawaan (Default Credentials)
- **Super Admin**: `admin@unimal.ac.id` / `password123`
- **ASLAB**: `aslab@unimal.ac.id` / `password123`

---

## 🔌 API Endpoint Agent Klien (`/api/v1/agent`)

| Method | Endpoint | Deskripsi | Autentikasi |
|---|---|---|---|
| `POST` | `/api/v1/agent/register` | Mendaftarkan agent baru dengan kode OTP 6-digit | None |
| `POST` | `/api/v1/agent/heartbeat` | Mengirimkan metrik status & polling perintah baru | Bearer Token |
| `POST` | `/api/v1/agent/commands/ack` | Mengirim konfirmasi status eksekusi perintah | Bearer Token |
| `GET`  | `/api/v1/agent/config` | Sinkronisasi jadwal lokal dan repo auto-update | Bearer Token |

---

## 🤝 Kontributor & Hak Cipta
- **Pengembang**: Muslim Gunawan ([@MuslimGunawan](https://github.com/MuslimGunawan))
- **Institusi**: Laboratorium Komputer, Universitas Malikussaleh (Unimal)
