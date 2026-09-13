# SmartLab Dashboard (Unimal) 🏛️💻

> **Web Dashboard Terpusat & REST API Manajemen Laboratorium Komputer Universitas Malikussaleh (Unimal)**

![Laravel](https://img.shields.io/badge/Laravel-12-FF2D20?logo=laravel&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-8.2+-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-9.0+-4479A1?logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/Status-Production%20Ready-009344)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## 🌟 Ringkasan Sistem

**SmartLab Dashboard** adalah sistem kendali dan otomasi terpusat berbasis web untuk Asisten Laboratorium (ASLAB), Dosen, dan Kepala Laboratorium di Universitas Malikussaleh. Sistem ini mengontrol seluruh PC praktikum, memantau kesehatan hardware dan partisi drive, menegakkan aturan pemakaian aplikasi/game, mencatat insiden pelanggaran, serta menyediakan helpdesk pengaduan kerusakan meja berbasis scan QR Code.

### Fitur Lengkap Sistem (Fase 1 – 4):

1. 📊 **Monitoring Real-Time & Live Status Feed**: Grid interaktif status PC lab (online/offline, IP, MAC, user login, uptime jam) dengan polling live update tanpa perlu refresh browser.
2. 🔑 **Zero-Config Pairing**: Pembuatan kode pairing 6-digit (misal `UNM-REK01`) per lab untuk menghubungkan komputer lab baru secara instan.
3. ⚡ **Kontrol Jarak Jauh (Remote Commands)**:
   - Shutdown & Restart massal per-lab atau per-PC dengan hitung mundur grace period.
   - Siarkan pesan darurat / banner melayang (`broadcast`) ke layar mahasiswa.
   - Penguncian layar seketika (`lock workstation`) saat ujian/praktikum selesai.
   - **Wake-on-LAN (WOL)**: Mengirimkan Magic Packet UDP untuk menyalakan PC yang mati dari jarak jauh.
   - **Remote Disk Cleanup**: Membersihkan file sementara `%TEMP%` dan Recycle Bin secara remote.
   - **Remote Silent Uninstall**: Mencopot software terlarang langsung dari browser tanpa perlu datang ke meja PC.
4. 🚫 **Pengawasan Aplikasi Terlarang (Blocklist Watcher)**:
   - Otomatis mematikan paksa proses game terlarang (Valorant, Steam, Genshin, Cheat Engine, dsb).
   - Mengambil screenshot layar secara silent saat pelanggaran terjadi dan mengunggahnya ke dashboard.
   - Notifikasi instan ke grup Telegram ASLAB.
5. 🔍 **Inventarisasi Hardware & Software Lengkap**:
   - Spesifikasi detail CPU, RAM, OS, dan partisi disk dengan progress bar persentase visual.
   - Daftar 100+ software Windows terpasang di setiap PC.
   - Deteksi otomatis instalasi software baru secara real-time.
6. 🛠️ **Helpdesk Kerusakan Meja & Generator QR Code (PRD #22)**:
   - Generator QR Code per meja pada halaman detail PC.
   - Modal cetak stiker label meja berlogo Unimal siap tempel di meja praktikum.
   - Form publik responsif bagi mahasiswa untuk melapor kerusakan hardware (mouse, keyboard, monitor, pc hang, jaringan).
   - Dashboard Issue Tracker bagi ASLAB untuk memantau dan menindaklanjuti perbaikan teknis.
7. 📑 **Laporan Bulanan & Analitik Kesehatan Lab (PRD #19)**:
   - Rekapitulasi bulanan per lab: PC aktif, rata-rata uptime, insiden pelanggaran, peringatan storage (> 80% penuh), dan log software baru.
   - **Cetak Laporan / PDF**: Format cetak resmi ber-KOP Surat Universitas Malikussaleh - Fakultas Teknik dengan kolom tanda tangan Kepala Lab & Koordinator ASLAB.
   - **Export CSV / Excel**: Unduhan data rekapitulasi ke format spreadsheet.
8. 🛡️ **Multi-Role RBAC & Manajemen Pengguna (PRD #20)**:
   - `super_admin`: Kepala Lab / Dosen (Akses penuh seluruh lab, kelola akun pengguna, hapus PC/Lab).
   - `aslab_senior`: Koordinator Lab (Kelola lab & PC, kirim perintah, jadwal otomatis, Kiosk, Blocklist, dan laporan).
   - `aslab_junior`: Asisten Praktikum (Monitoring PC, kirim broadcast/lock, tindak lanjut laporan kerusakan praktikan).
9. 📱 **Integrasi Notifikasi Telegram Bot (PRD #21)**:
   - Pengiriman alert instan ke grup chat ASLAB saat ada laporan kerusakan meja baru, insiden game terlarang, atau software baru terinstall.

---

## 🚀 Panduan Instalasi & Menjalankan

### Persyaratan
- PHP >= 8.2 (ekstensi: `pdo_mysql`, `mbstring`, `openssl`, `curl`)
- Composer
- MySQL >= 8.0 / MariaDB

### Langkah Pemasangan:
```bash
# 1. Clone repository
git clone https://github.com/MuslimGunawan/smartlab-dashboard.git
cd smartlab-dashboard

# 2. Install dependensi
composer install

# 3. Buat file .env dan generate key
cp .env.example .env
php artisan key:generate

# 4. Sesuaikan konfigurasi database pada .env
# DB_DATABASE=labcontrol_unimal
# DB_USERNAME=root
# DB_PASSWORD=

# 5. Jalankan migrasi dan seeder data resmi
php artisan migrate --seed

# 6. Buat symbolic link storage untuk upload screenshot
php artisan storage:link

# 7. Jalankan server lokal
php artisan serve --port=8000
```

### Akun Bawaan (Default Credentials):
- **Super Admin (Kepala Lab)**: `admin@unimal.ac.id` / `password123`
- **ASLAB Senior (Koordinator)**: `aslab@unimal.ac.id` / `password123`
- **ASLAB Junior (Asisten)**: `junior@unimal.ac.id` / `password123`

---

## 🔌 API Endpoint Agent Klien (`/api/v1/agent`)

| Method | Endpoint | Deskripsi |
|---|---|---|
| `POST` | `/api/v1/agent/register` | Mendaftarkan PC baru menggunakan Kode Pairing 6-digit |
| `POST` | `/api/v1/agent/heartbeat` | Polling heartbeat tiap 15 detik & pengambilan perintah pending |
| `POST` | `/api/v1/agent/commands/{id}/ack` | Mengirim konfirmasi status hasil eksekusi perintah |
| `GET`  | `/api/v1/agent/config` | Sinkronisasi jadwal otomatis, blocklist aplikasi, dan kiosk mode |
| `POST` | `/api/v1/agent/hardware` | Sinkronisasi spesifikasi hardware CPU, RAM, OS, dan partisi drive |
| `POST` | `/api/v1/agent/software` | Sinkronisasi daftar software dan deteksi software baru terpasang |
| `POST` | `/api/v1/agent/violations` | Pelaporan insiden proses terlarang beserta unggahan screenshot JPEG |

---

## 🤝 Hak Cipta & Pengembang
- **Pengembang**: Muslim Gunawan ([@MuslimGunawan](https://github.com/MuslimGunawan))
- **Institusi**: Laboratorium Teknik Informatika, Universitas Malikussaleh (Unimal)
