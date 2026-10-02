<#
==================================================================================
SMARTLAB UNIMAL - INISIALISASI OTOMATIS STRUKTUR SOFTWARE LAB TI
Laboratorium Terpadu Teknik Informatika — Universitas Malikussaleh
==================================================================================
Fungsi:
1. Otomatis membuat struktur folder:
   Lab_Software\
   ├── jalankan-instalasi.bat
   └── Apps\
       └── install-lab-software.ps1
2. Mengunduh launcher batch dan skrip instalasi utama versi terbaru dari GitHub resmi.
3. Menyiapkan sistem siap pakai untuk mode offline / online.
==================================================================================
#>

$SETUP_VERSION = "3.0.1"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Setup Bootstrapper Software Lab TI - UNIMAL [v$SETUP_VERSION]"

Write-Host "`n==============================================================" -ForegroundColor Green
Write-Host "   SETUP INISIALISASI STRUKTUR SOFTWARE LAB TI - UNIMAL       " -ForegroundColor Green
Write-Host "            [ VERSI $SETUP_VERSION - RILIS 02 OKTOBER 2026 ]           " -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Green

# 1. Tentukan Direktori Target
$currentDir = (Get-Location).Path
$targetBase = $null

if ((Split-Path -Leaf $currentDir) -ieq "Lab_Software") {
    $targetBase = $currentDir
} else {
    $targetBase = Join-Path $currentDir "Lab_Software"
    if (-not (Test-Path $targetBase)) {
        New-Item -ItemType Directory -Path $targetBase -Force | Out-Null
    }
}

$appsDir = Join-Path $targetBase "Apps"
if (-not (Test-Path $appsDir)) {
    New-Item -ItemType Directory -Path $appsDir -Force | Out-Null
}

Write-Host "`n[+] Folder Target Disiapkan: $targetBase" -ForegroundColor Cyan
Write-Host "    -> $targetBase" -ForegroundColor Gray
Write-Host "    -> $appsDir" -ForegroundColor Gray

# 2. Unduh Berkas Eksekusi Utama dari GitHub Resmi SmartLab TI (dengan fallback mirror server)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate")
$wc.Headers.Add("Pragma", "no-cache")

$ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$batUrls = @(
    "https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/jalankan-instalasi.bat?v=$ts",
    "https://smartlab.is-best.net/scripts/jalankan-instalasi.bat?v=$ts"
)
$psUrls  = @(
    "https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/install-lab-software.ps1?v=$ts",
    "https://smartlab.is-best.net/scripts/install-lab-software.ps1?v=$ts"
)

$destBat = Join-Path $targetBase "jalankan-instalasi.bat"
$destPs  = Join-Path $appsDir "install-lab-software.ps1"

Write-Host "`n[i] Mengunduh berkas launcher 'jalankan-instalasi.bat'..." -ForegroundColor Yellow
$batSuccess = $false
foreach ($bUrl in $batUrls) {
    try {
        $wc.DownloadFile($bUrl, $destBat)
        Write-Host " [OK] Berhasil mengunduh: $destBat" -ForegroundColor Green
        $batSuccess = $true
        break
    } catch {}
}
if (-not $batSuccess) {
    Write-Host " [!] Gagal mengunduh bat launcher dari semua sumber." -ForegroundColor Red
}

Write-Host "[i] Mengunduh berkas otomasi 'install-lab-software.ps1'..." -ForegroundColor Yellow
$psSuccess = $false
foreach ($pUrl in $psUrls) {
    try {
        $wc.DownloadFile($pUrl, $destPs)
        Write-Host " [OK] Berhasil mengunduh: $destPs" -ForegroundColor Green
        $psSuccess = $true
        break
    } catch {}
}
if (-not $psSuccess) {
    Write-Host " [!] Gagal mengunduh PowerShell script dari semua sumber." -ForegroundColor Red
}
$wc.Dispose()

# 3. Tampilkan Informasi Struktur Berkas
Write-Host "`n==============================================================" -ForegroundColor Green
Write-Host "   STRUKTUR BERKAS BERHASIL DISIAPKAN DENGAN LENGKAP         " -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host @"
$targetBase\
  |-- jalankan-instalasi.bat
  \-- Apps\
        \-- install-lab-software.ps1
"@ -ForegroundColor Cyan

Write-Host "`nInformasi Penting:" -ForegroundColor Yellow
Write-Host " - Struktur folder dan 2 berkas eksekusi utama kini telah siap." -ForegroundColor Gray
Write-Host " - Berkas master installer aplikasi (.exe/.msi) belum ada di dalam folder Apps." -ForegroundColor Gray
Write-Host " - Saat 'jalankan-instalasi.bat' dijalankan pertama kali, skrip otomatis mengunduh" -ForegroundColor Gray
Write-Host "   installer dan menyimpannya di folder Apps (sehingga PC berikutnya tinggal pakai offline)." -ForegroundColor Gray

# 4. Opsi Langsung Menjalankan
Write-Host ""
$launch = Read-Host "Apakah Anda ingin langsung menjalankan instalasi sekarang? (Y/T)"
if ($launch -match "^[yY]") {
    Write-Host "`n[>>>] Menjalankan installer 'jalankan-instalasi.bat'..." -ForegroundColor Green
    Start-Process -FilePath "cmd.exe" -ArgumentList ("/c `"{0}`"" -f $destBat)
} else {
    Write-Host "`n[i] Buka folder '$targetBase' lalu klik 2x 'jalankan-instalasi.bat' kapan saja." -ForegroundColor Cyan
    Start-Process explorer.exe -ArgumentList "`"$targetBase`""
}
