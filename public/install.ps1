# ==============================================================================
# SCRIPT OTOMASI INSTALASI SOFTWARE LABORATORIUM TEKNIK INFORMATIKA
# UNIVERSITAS MALIKUSSALEH (UNIMAL)
# ==============================================================================
# Arsitektur Modular Terorganisir:
#   - Root Orchestrator : install-lab-software.ps1 (Ringkas, Bersih, Cepat)
#   - Modules/ Folder   :
#       * 01-helpers.ps1      (Core Helpers, Download Mirrors, Shortcuts, PATH)
#       * 02-runtimes.ps1     (7-Zip, WinRAR, Chrome, Git, Java JDK, Python, Node.js)
#       * 03-webserver.ps1    (Laragon, XAMPP port 8088 anti-bentrok, Composer/Laravel)
#       * 04-dev-tools.ps1    (NetBeans, Visual Studio 2022 C++, Flutter SDK)
#       * 05-virtual-gis.ps1  (VirtualBox + ExtPack, Google Earth Pro)
#       * 06-orchestrator.ps1 (Run-FullInstallation, Download Only, Menu & Verify)
#   - Apps/ Folder      : Folder khusus penyimpanan seluruh master installer offline
# ==============================================================================

$SCRIPT_CURRENT_VERSION = "3.4.5"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Installer Otomatis 22 Software Lab TI Unimal - v$SCRIPT_CURRENT_VERSION"

# 1. Pastikan status Administrator terdeteksi dengan cerdas (Dual-Mode: Admin & Standard User)
function Test-Administrator {
    try {
        $user = [Security.Principal.WindowsIdentity]::GetCurrent()
        return (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

$script:IsAdmin = Test-Administrator

if (-not $script:IsAdmin) {
    try {
        $spPath = $PSCommandPath
        if (-not $spPath) { $spPath = $MyInvocation.MyCommand.Path }
        if ($spPath -and (Test-Path $spPath)) {
            $p = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -NoExit -File `"{0}`"" -f $spPath) -Verb RunAs -PassThru -ErrorAction Stop
            if ($p -and $p.Id) {
                [System.Environment]::Exit(0)
            }
        }
    } catch {}
}

# 1.1 Konfigurasi Kebijakan Eksekusi PowerShell (Bebas Hambatan)
try {
    Set-ExecutionPolicy RemoteSigned -Scope Process -Force -ErrorAction SilentlyContinue
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -ErrorAction SilentlyContinue
} catch {}

# 2. Deteksi Folder Master Installer Offline (Apps/)
$candidateDirs = @()
if ((Split-Path -Leaf $PSScriptRoot) -ieq "Apps") { $candidateDirs += $PSScriptRoot }
$candidateDirs += (Join-Path $PSScriptRoot "Apps")
$candidateDirs += (Join-Path (Split-Path -Parent $PSScriptRoot) "Apps")
$candidateDirs += (Join-Path (Get-Location).Path "Apps")

$driveLetters = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -match 'Removable|Fixed' -and $_.IsReady } | Select-Object -ExpandProperty RootDirectory
foreach ($d in $driveLetters) {
    $candidateDirs += (Join-Path $d.FullName "Lab_Software\Apps")
    $candidateDirs += (Join-Path $d.FullName "Apps")
}
$candidateDirs += $PSScriptRoot
$candidateDirs += (Split-Path -Parent $PSScriptRoot)

$AppsDir = $null
foreach ($cand in $candidateDirs) {
    if (-not [string]::IsNullOrWhiteSpace($cand) -and (Test-Path $cand)) {
        $hasInstallers = Get-ChildItem -Path $cand -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match "exe|msi" -and $_.Name -notmatch "jalankan|test" } | Select-Object -First 1
        $hasCustomStack = Test-Path (Join-Path $cand "Laragon_Custom_Stack")
        if ($hasInstallers -or $hasCustomStack) {
            $AppsDir = (Get-Item $cand).FullName
            break
        }
    }
}

if (-not $AppsDir) {
    if (Test-Path (Join-Path $PSScriptRoot "Apps")) {
        $AppsDir = (Join-Path $PSScriptRoot "Apps")
    } elseif ((Split-Path -Leaf $PSScriptRoot) -ieq "Apps") {
        $AppsDir = $PSScriptRoot
    } else {
        $AppsDir = (Join-Path $PSScriptRoot "Apps")
    }
}

# 3. Deteksi & Sinkronisasi Modul-Modul Modular (Folder modules/)
$modulesDir = $PSScriptRoot
if ((Split-Path -Leaf $modulesDir) -ine "modules") {
    if (Test-Path (Join-Path $PSScriptRoot "modules")) {
        $modulesDir = Join-Path $PSScriptRoot "modules"
    } elseif (Test-Path (Join-Path (Split-Path -Parent $PSScriptRoot) "modules")) {
        $modulesDir = Join-Path (Split-Path -Parent $PSScriptRoot) "modules"
    }
}
if (-not (Test-Path $modulesDir)) {
    New-Item -ItemType Directory -Path $modulesDir -Force | Out-Null
}

# 3.1 Pemuatan & Auto-Download Modul dari Cloud SmartLab / GitHub jika belum ada di lokal
$moduleFiles = @(
    "01-helpers.ps1",
    "02-runtimes.ps1",
    "03-webserver.ps1",
    "04-dev-tools.ps1",
    "05-virtual-gis.ps1",
    "06-orchestrator.ps1"
)

$baseModuleUrls = @(
    "https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/modules/",
    "https://smartlab.is-best.net/scripts/modules/"
)

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$wc = New-Object System.Net.WebClient

foreach ($modName in $moduleFiles) {
    $localModPath = Join-Path $modulesDir $modName
    if (-not (Test-Path $localModPath) -or ((Get-Item $localModPath).Length -lt 200)) {
        Write-Host "   [i] Mempersiapkan modul: $modName dari server Cloud..." -ForegroundColor DarkCyan
        foreach ($bUrl in $baseModuleUrls) {
            try {
                $targetUrl = $bUrl + $modName
                $wc.DownloadFile($targetUrl, $localModPath)
                if (Test-Path $localModPath) { break }
            } catch {}
        }
    }

    if (Test-Path $localModPath) {
        try {
            . $localModPath
        } catch {
            Write-Host "   [!] Peringatan saat memuat modul $modName : $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   [!] Modul $modName tidak ditemukan di $modulesDir." -ForegroundColor Red
    }
}
$wc.Dispose()

# 4. Tampilkan Banner SmartLab
if (Get-Command Show-SmartLabBanner -ErrorAction SilentlyContinue) {
    Show-SmartLabBanner
}

# 5. Cek Pembaruan Script Otomatis dari Cloud SmartLab
function Check-ScriptSelfUpdate {
    $scriptFile = $PSCommandPath
    if (-not $scriptFile) { $scriptFile = $MyInvocation.MyCommand.Path }
    if (-not $scriptFile -or (-not (Test-Path $scriptFile))) { return }

    Write-Host "[*] Memeriksa status versi script ke server Cloud SmartLab..." -ForegroundColor Cyan
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        $updateUrls = @(
            "https://raw.githubusercontent.com/MuslimGunawan/smartlab-dashboard/main/public/scripts/install-lab-software.ps1?v=$ts",
            "https://smartlab.is-best.net/scripts/install-lab-software.ps1?v=$ts"
        )
        $remoteContent = $null
        foreach ($url in $updateUrls) {
            try {
                $cleanHost = ($url -split '/')[2]
                Write-Host "    -> Menghubungi server mirror ($cleanHost)..." -ForegroundColor DarkGray
                $req = [System.Net.HttpWebRequest]::Create($url)
                $req.Timeout = 5000
                $req.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate")
                $req.Headers.Add("Pragma", "no-cache")
                $resp = $req.GetResponse()
                $stream = $resp.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
                $remoteContent = $reader.ReadToEnd()
                $reader.Close()
                $resp.Close()
                if (-not [string]::IsNullOrWhiteSpace($remoteContent) -and $remoteContent -match '\$SCRIPT_CURRENT_VERSION\s*=\s*"([^"]+)"') {
                    break
                }
            } catch {}
        }

        if (-not [string]::IsNullOrWhiteSpace($remoteContent) -and $remoteContent -match '\$SCRIPT_CURRENT_VERSION\s*=\s*"([^"]+)"') {
            $remoteVer = $matches[1]
            try {
                $vRemote = [version]$remoteVer
                $vCurrent = [version]$SCRIPT_CURRENT_VERSION
            } catch {
                $vRemote = $null
                $vCurrent = $null
            }

            $isNewer = $false
            if ($vRemote -and $vCurrent) {
                if ($vRemote -gt $vCurrent) { $isNewer = $true }
            } elseif ($remoteVer -ne $SCRIPT_CURRENT_VERSION) {
                $isNewer = $true
            }

            if ($isNewer) {
                Write-Host "`n==============================================================================" -ForegroundColor Yellow
                Write-Host "   PEMBARUAN SKRIP TERSEDIA! [ v$SCRIPT_CURRENT_VERSION  ==>  v$remoteVer ]" -ForegroundColor Yellow
                Write-Host "==============================================================================" -ForegroundColor Yellow
                Write-Host " [*] Mengunduh pembaruan lengkap dari Cloud..." -ForegroundColor Cyan
                Start-Sleep -Milliseconds 600

                [System.IO.File]::WriteAllText($scriptFile, $remoteContent, [System.Text.Encoding]::UTF8)
                Write-Host " [*] Memverifikasi integritas berkas lokal..." -ForegroundColor Cyan
                Start-Sleep -Milliseconds 600

                $verifiedContent = [System.IO.File]::ReadAllText($scriptFile, [System.Text.Encoding]::UTF8)
                if ($verifiedContent -match '\$SCRIPT_CURRENT_VERSION\s*=\s*"([^"]+)"' -and $matches[1] -eq $remoteVer) {
                    Write-Host " [OK] Skrip berhasil diperbarui ke Versi $remoteVer secara sempurna!" -ForegroundColor Green
                    Write-Host " [*] Melakukan restart skrip otomatis dalam 2 detik..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                    if ($script:IsAdmin) {
                        Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -NoExit -File `"{0}`"" -f $scriptFile) -Verb RunAs
                    } else {
                        Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -NoExit -File `"{0}`"" -f $scriptFile)
                    }
                    [System.Environment]::Exit(0)
                }
            } else {
                Write-Host " [OK] Terverifikasi: Skrip sudah menggunakan versi terbaru (v$SCRIPT_CURRENT_VERSION).`n" -ForegroundColor Green
            }
        }
    } catch {}
}

Check-ScriptSelfUpdate

# 6. MENU UTAMA INTERAKTIF
$running = $true

while ($running) {
    Clear-Host
    if (Get-Command Show-SmartLabBanner -ErrorAction SilentlyContinue) { Show-SmartLabBanner }
    Write-Host "Pilihan Tindakan:" -ForegroundColor Yellow
    Write-Host " [1] Jalankan Otomasi Lengkap Lab (Instalasi & Standarisasi 22 Software)"
    Write-Host " [2] Instalasi Kustom / Pilihan Software (Smart Bundle: QGIS+Earth, VBox+ExtPack, dll)"
    Write-Host " [3] Unduh Seluruh Master Installer Offline ke Flashdisk (Download Saja / Cache Master)"
    Write-Host " [4] Verifikasi Status & Peta Port Software Lab"
    Write-Host " [5] Rapikan & Bersihkan Shortcut Desktop Lab (Hapus duplikat & icon CLI)"
    Write-Host " [6] Keluar`n"

    $choice = Read-Host "Masukkan pilihan Anda (1/2/3/4/5/6)"

    switch ($choice) {
        "1" {
            if (-not $script:IsAdmin) {
                Write-Host "`n[!] INFORMASI HAK AKSES SISTEM:" -ForegroundColor Yellow
                Write-Host "    Sesi ini berjalan sebagai Pengguna Standar (Non-Administrator)." -ForegroundColor Yellow
                Write-Host "    Beberapa software tingkat sistem (seperti driver VirtualBox, Laragon ke C:\, XAMPP)" -ForegroundColor Gray
                Write-Host "    mungkin memerlukan konfirmasi Administrator saat proses instalasi berlangsung." -ForegroundColor Gray
                Write-Host "    Skrip akan memasang semua software yang mendukung user-space dan mengonfigurasi User PATH." -ForegroundColor Gray
                $konfirmasi = Read-Host "    Lanjutkan proses instalasi sekarang? (Y/T, default: Y)"
                if ($konfirmasi -match "^[Tt]") {
                    continue
                }
            }
            if (Get-Command Run-FullInstallation -ErrorAction SilentlyContinue) {
                Run-FullInstallation
            }
            Wait-EnterOnly -PromptMessage "[Tekan tombol ENTER untuk kembali ke Menu Utama...]"
        }
        "2" {
            if (Get-Command Run-CustomInstallation -ErrorAction SilentlyContinue) {
                Run-CustomInstallation
            }
            Wait-EnterOnly -PromptMessage "[Tekan tombol ENTER untuk kembali ke Menu Utama...]"
        }
        "3" {
            if (Get-Command Start-DownloadOnlyMaster -ErrorAction SilentlyContinue) {
                Start-DownloadOnlyMaster
            }
            Wait-EnterOnly -PromptMessage "[Tekan tombol ENTER untuk kembali ke Menu Utama...]"
        }
        "4" {
            Clear-Host
            if (Get-Command Show-SmartLabBanner -ErrorAction SilentlyContinue) { Show-SmartLabBanner }
            if (Get-Command Test-LabSoftwareStatus -ErrorAction SilentlyContinue) {
                Test-LabSoftwareStatus
            }
            Wait-EnterOnly -PromptMessage "[Tekan tombol ENTER untuk kembali ke Menu Utama...]"
        }
        "5" {
            Clear-Host
            if (Get-Command Show-SmartLabBanner -ErrorAction SilentlyContinue) { Show-SmartLabBanner }
            if (Get-Command Clean-LabDesktopIcons -ErrorAction SilentlyContinue) {
                Clean-LabDesktopIcons
            }
            Wait-EnterOnly -PromptMessage "[Tekan tombol ENTER untuk kembali ke Menu Utama...]"
        }
        "6" {
            Write-Host "Keluar dari skrip otomasi SmartLab. Terima kasih." -ForegroundColor Green
            Wait-EnterOnly -PromptMessage "[Tekan tombol ENTER untuk menutup jendela ini...]"
            $running = $false
            [System.Environment]::Exit(0)
        }
        default {
            Write-Host "Pilihan tidak valid. Silakan ketik angka 1, 2, 3, 4, 5, atau 6." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
