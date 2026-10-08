<#
==================================================================================
SMARTLAB UNIMAL - INISIALISASI OTOMATIS STRUKTUR SOFTWARE LAB TI
Laboratorium Terpadu Teknik Informatika - Universitas Malikussaleh
==================================================================================
Fungsi:
1. Otomatis membuat struktur folder rapi:
   Lab_Software\
   +-- jalankan-instalasi.bat  (Satu-satunya launcher di tampilan depan)
   +-- modules\                 (Folder skrip modular & orchestrator)
   +-- Apps\                    (Folder master installer offline)
2. Mengunduh launcher batch dan seluruh modul versi terbaru dari GitHub resmi.
3. Siap digunakan langsung di komputer lab, VM, maupun offline.
==================================================================================
#>

$SETUP_VERSION = "3.4.7"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Setup Bootstrapper Software Lab TI - UNIMAL [v$SETUP_VERSION]"

Write-Host "`n==============================================================" -ForegroundColor Green
Write-Host "   SETUP INISIALISASI STRUKTUR SOFTWARE LAB TI - UNIMAL       " -ForegroundColor Green
Write-Host "            [ VERSI $SETUP_VERSION - MODULAR SYSTEM ]                 " -ForegroundColor Yellow
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

$modulesDir = Join-Path $targetBase "modules"
if (-not (Test-Path $modulesDir)) {
    New-Item -ItemType Directory -Path $modulesDir -Force | Out-Null
}

$appsDir = Join-Path $targetBase "Apps"
if (-not (Test-Path $appsDir)) {
    New-Item -ItemType Directory -Path $appsDir -Force | Out-Null
}

# Bersihkan file ps1 lama di root atau Apps jika ada
if (Test-Path (Join-Path $targetBase "install-lab-software.ps1")) {
    Remove-Item (Join-Path $targetBase "install-lab-software.ps1") -Force -ErrorAction SilentlyContinue
}
if (Test-Path (Join-Path $appsDir "install-lab-software.ps1")) {
    Remove-Item (Join-Path $appsDir "install-lab-software.ps1") -Force -ErrorAction SilentlyContinue
}

Write-Host "`n[+] Folder Target Disiapkan: $targetBase" -ForegroundColor Cyan
Write-Host "    -> Root    : $targetBase (khusus launcher)" -ForegroundColor Gray
Write-Host "    -> Modules : $modulesDir" -ForegroundColor Gray
Write-Host "    -> Apps    : $appsDir" -ForegroundColor Gray

# 2. Unduh Berkas Eksekusi Utama dari GitHub Resmi SmartLab TI
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate")
$wc.Headers.Add("Pragma", "no-cache")

$ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$destBat = Join-Path $targetBase "jalankan-instalasi.bat"
$batUrl = "https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/jalankan-instalasi.bat"

Write-Host "`n[i] Mengunduh berkas launcher 'jalankan-instalasi.bat'..." -ForegroundColor Yellow
try {
    $wc.DownloadFile($batUrl, $destBat)
    Write-Host " [OK] Berhasil mengunduh: $destBat" -ForegroundColor Green
} catch {
    Write-Host " [!] Gagal mengunduh launcher bat: $($_.Exception.Message)" -ForegroundColor Red
}
$wc.Dispose()

$moduleList = @(
    "install-lab-software.ps1",
    "01-helpers.ps1",
    "02-runtimes.ps1",
    "03-webserver.ps1",
    "04-dev-tools.ps1",
    "05-virtual-gis.ps1",
    "06-orchestrator.ps1"
)

Write-Host "`n[i] Mengunduh seluruh modul instalasi SmartLab TI ke $modulesDir..." -ForegroundColor Yellow
foreach ($mod in $moduleList) {
    $destMod = Join-Path $modulesDir $mod
    $modUrl = "https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/modules/$mod"
    try {
        $modWc = New-Object System.Net.WebClient
        $modWc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $modWc.DownloadFile($modUrl, $destMod)
        $modWc.Dispose()
        Write-Host " [OK] Modul siap: $mod" -ForegroundColor Green
    } catch {
        Write-Host " [!] Gagal mengunduh modul $mod : $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 3. Tampilkan Informasi Struktur Berkas
Write-Host "`n==============================================================" -ForegroundColor Green
Write-Host "   STRUKTUR BERKAS BERHASIL DISIAPKAN DENGAN LENGKAP         " -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host @"
$targetBase\
  |-- jalankan-instalasi.bat  (Satu-satunya file launcher)
  |-- modules\                (7 Modul Script Lengkap)
  \-- Apps\                   (Folder Master Installer Offline)
"@ -ForegroundColor Cyan

Write-Host "`nInformasi Penting:" -ForegroundColor Yellow
Write-Host " - Tampilan luar rapi: Hanya 'jalankan-instalasi.bat' yang terlihat di root." -ForegroundColor Gray
Write-Host " - Seluruh logika instalasi tersimpan rapi dan terorganisir di dalam 'modules/'." -ForegroundColor Gray
Write-Host " - Saat 'jalankan-instalasi.bat' dijalankan, installer otomatis mendownload master ke Apps/" -ForegroundColor Gray

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
