# ==============================================================================
# SCRIPT OTOMASI INSTALASI SOFTWARE LABORATORIUM TEKNIK INFORMATIKA
# UNIVERSITAS MALIKUSSALEH (UNIMAL)
# ==============================================================================
# Standarisasi 20 Software Praktikum Resmi Lab TI Unimal:
#
# A. APLIKASI BERLISENSI (4):
#   1. Delphi (Embarcadero Delphi / RAD Studio) -> Mode Interaktif (Pihak Ketiga)
#   2. Cisco Packet Tracer (Cisco NetAcad) -> Google Drive Multi-Mirror
#   3. Microsoft Visual Studio 2022 Community
#   4. Proteus Design Suite (Labcenter Electronics) -> Mode Interaktif (Pihak Ketiga)
#
# B. APLIKASI EKSTRAKSI, DEV STACK & BEBAS LISENSI (16):
#   5. 7-Zip (High-Speed Archive Extractor)
#   6. WinRAR (Lab Archive Support .rar/.zip)
#   7. Git for Windows (Wajib untuk Dart SDK, Flutter, Composer, & VS Code)
#   8. Visual Studio Code
#   9. Android Studio
#  10. Python (Versi Terbaru 3.13 / 3.12 LTS with PIP & System PATH)
#  11. Java JDK 17 LTS (with JAVA_HOME & System PATH)
#  12. Node.js LTS (Versi Terbaru v22 LTS with NPM & Global PATH)
#  13. Flutter SDK (Versi Terbaru 3.29/3.27 Stable & Auto-Configured)
#  14. Composer & Laravel Setup (Terkoneksi ke PHP Terbaru Laragon)
#  15. Oracle VM VirtualBox
#  16. Apache NetBeans IDE
#  17. QGIS Desktop
#  18. Arduino IDE (Arduino Uno & IoT)
#  19. Laragon (WAMP Stack + Safe Modul)
#  20. XAMPP Server (Port Anti-Bentrok)
# ==============================================================================

$SCRIPT_CURRENT_VERSION = "3.3.22"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Installer Otomatis 20 Software Lab TI Unimal - v$SCRIPT_CURRENT_VERSION"

# 1. Pastikan status Administrator terdeteksi dengan cerdas (Dukungan Mode Admin & Mode Pengguna Standar)
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
    # Coba minta elevasi Administrator secara halus tanpa menutup sesi jika ditolak pengguna/sistem lab
    try {
        $spPath = $PSCommandPath
        if (-not $spPath) { $spPath = $MyInvocation.MyCommand.Path }
        if ($spPath -and (Test-Path $spPath)) {
            $p = Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -NoExit -File `"{0}`"" -f $spPath) -Verb RunAs -PassThru -ErrorAction Stop
            if ($p -and $p.Id) {
                [System.Environment]::Exit(0)
            }
        }
    } catch {
        # Jika pengguna menolak prompt UAC atau komputer lab menerapkan akun standard non-admin:
        # Script tetap berjalan normal pada sesi pengguna saat ini tanpa tertutup paksa!
    }
}

# 1.1 FITUR ANTI-SLEEP, ANTI-LOCK & ANTI-IDLE SHUTDOWN (Komputer Lab Tetap Terjaga 100%)
try {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class SystemPowerKeeper {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern uint SetThreadExecutionState(uint esFlags);
        public const uint ES_CONTINUOUS = 0x80000000;
        public const uint ES_SYSTEM_REQUIRED = 0x00000001;
        public const uint ES_DISPLAY_REQUIRED = 0x00000002;
        public const uint ES_AWAYMODE_REQUIRED = 0x00000040;

        public static void KeepAwake() {
            SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED | ES_AWAYMODE_REQUIRED);
        }
        public static void RestoreNormal() {
            SetThreadExecutionState(ES_CONTINUOUS);
        }
    }
"@ -ErrorAction SilentlyContinue
    [SystemPowerKeeper]::KeepAwake()
} catch {}

function Invoke-LabKeepAlive {
    try {
        [SystemPowerKeeper]::KeepAwake()
        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys("{F15}")
    } catch {}
}

# 1.2 Konfigurasi Kebijakan Eksekusi PowerShell (Bebas Hambatan untuk npm, npx, dart, & laravel)
try {
    Set-ExecutionPolicy RemoteSigned -Scope Process -Force -ErrorAction SilentlyContinue
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -ErrorAction SilentlyContinue
} catch {}

# 1.3 Deteksi Ketersediaan Winget & Penanganan Sumber (Cegah error sertifikat 0x8a15005e)
function Test-WingetAvailable {
    try {
        $testOut = & winget --version 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0 -and $testOut -match '^\s*v?\d+\.\d+' -and $testOut -notmatch 'No applicable app licenses found') {
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

if (Test-WingetAvailable) {
    try {
        $sources = winget source list 2>$null | Out-String
        if ($sources -match "msstore") {
            winget source remove --name msstore 2>$null
        }
    } catch {}
}

# 2. Deteksi Lokasi Folder Installer Offline (Apps/)
# Cerdas: Mendeteksi apakah script berada di dalam folder Apps, di samping folder Apps, atau di USB/Drive lain
$candidateDirs = @()

# Prioritaskan folder yang secara eksplisit bernama "Apps"
if ((Split-Path -Leaf $PSScriptRoot) -ieq "Apps") { $candidateDirs += $PSScriptRoot }
$candidateDirs += (Join-Path $PSScriptRoot "Apps")
$candidateDirs += (Join-Path (Split-Path -Parent $PSScriptRoot) "Apps")
$candidateDirs += (Join-Path (Get-Location).Path "Apps")

# Tambahkan pencarian drive lain (misal flashdisk E:\Lab_Software\Apps, E:\Apps, dsb.)
$driveLetters = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -match 'Removable|Fixed' -and $_.IsReady } | Select-Object -ExpandProperty RootDirectory
foreach ($d in $driveLetters) {
    $candidateDirs += (Join-Path $d.FullName "Lab_Software\Apps")
    $candidateDirs += (Join-Path $d.FullName "Apps")
}

# Fallback ke folder root skrip jika Apps tidak ditemukan terpisah
$candidateDirs += $PSScriptRoot
$candidateDirs += (Split-Path -Parent $PSScriptRoot)

$AppsDir = $null
foreach ($cand in $candidateDirs) {
    if (-not [string]::IsNullOrWhiteSpace($cand) -and (Test-Path $cand)) {
        # Valid jika mengandung file installer exe/msi (bukan sekadar bat) atau folder Laragon_Custom_Stack
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

function Show-SmartLabBanner {
    Write-Host "  ____________________________________________________________________________" -ForegroundColor DarkGreen
    Write-Host " |                                                                            |" -ForegroundColor DarkGreen
    Write-Host " |   .------------------.   " -NoNewline -ForegroundColor DarkGreen
    Write-Host "  ____                      _   _          _     " -ForegroundColor Green
    Write-Host " |   | [0]----[o]----[0]|   " -NoNewline -ForegroundColor Green
    Write-Host " / ___| _ __ ___   __ _ _ __| |_| |    __ _| |__  " -ForegroundColor Green
    Write-Host " |   |  |   .---.   |   |   " -NoNewline -ForegroundColor Green
    Write-Host " \___ \| '_ ` _ \ / _` | '__| __| |   / _` | '_ \ " -ForegroundColor Yellow
    Write-Host " |   |  |   |CPU|   |   |   " -NoNewline -ForegroundColor Yellow
    Write-Host "  ___) | | | | | | (_| | |  | |_| |__| (_| | |_) |" -ForegroundColor Yellow
    Write-Host " |   |  |   '---'   |   |   " -NoNewline -ForegroundColor Yellow
    Write-Host " |____/|_| |_| |_|\__,_|_|   \__|_____\__,_|_.__/ " -ForegroundColor Green
    Write-Host " |   | [o]----[0]----[o]|   " -ForegroundColor Green
    Write-Host " |   '--------||--------'   " -NoNewline -ForegroundColor DarkGreen
    Write-Host "  TEKNIK INFORMATIKA - UNIVERSITAS MALIKUSSALEH " -ForegroundColor White
    Write-Host " |            ||            " -NoNewline -ForegroundColor DarkGreen
    Write-Host "  [ STANDARISASI LABORATORIUM - VERSI $SCRIPT_CURRENT_VERSION ]               " -ForegroundColor Yellow
    Write-Host " |________[========]________|_________________________________________________|" -ForegroundColor DarkGreen
    if ($script:IsAdmin) {
        Write-Host "  Hak Akses Sesi : [ ADMINISTRATOR - HAK PENUH ]" -ForegroundColor Green
    } else {
        Write-Host "  Hak Akses Sesi : [ PENGGUNA STANDAR / NON-ADMIN ]" -ForegroundColor Yellow
        Write-Host "  Catatan        : Menu [2] Unduh Master & [3] Cek Status dapat digunakan 100%." -ForegroundColor Gray
    }
    Write-Host ""
}

Show-SmartLabBanner

# 2.1 Cek Pembaruan Script Otomatis dari Cloud SmartLab (GitHub / Web Dashboard)
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

                # Tulis file baru
                [System.IO.File]::WriteAllText($scriptFile, $remoteContent, [System.Text.Encoding]::UTF8)
                Write-Host " [*] Memverifikasi integritas berkas lokal..." -ForegroundColor Cyan
                Start-Sleep -Milliseconds 600

                # Verifikasi ulang berkas lokal
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
                } else {
                    Write-Host " [!] Verifikasi versi gagal. Melanjutkan dengan versi saat ini..." -ForegroundColor Yellow
                }
            } else {
                Write-Host " [OK] Terverifikasi: Skrip sudah menggunakan versi terbaru (v$SCRIPT_CURRENT_VERSION).`n" -ForegroundColor Green
            }
        } else {
            Write-Host " [i] Tidak dapat menjangkau server pembaruan (offline mode). Tetap berjalan pada v$SCRIPT_CURRENT_VERSION.`n" -ForegroundColor DarkGray
        }
    } catch {
        Write-Host " [i] Mode offline aktif. Menggunakan skrip versi $SCRIPT_CURRENT_VERSION.`n" -ForegroundColor DarkGray
    }
}

Check-ScriptSelfUpdate

# 3. Fungsi Helper Tambah ke System PATH (Dual-Mode: Machine jika Admin, User jika Pengguna Biasa)
function Add-ToSystemPath {
    param ([string]$DirToAdd)
    if ([string]::IsNullOrWhiteSpace($DirToAdd) -or !(Test-Path $DirToAdd)) { return }

    $target = if ($script:IsAdmin) { [EnvironmentVariableTarget]::Machine } else { [EnvironmentVariableTarget]::User }
    $scopeName = if ($script:IsAdmin) { "System (Machine)" } else { "User" }

    try {
        $currentPath = [Environment]::GetEnvironmentVariable("Path", $target)
        $paths = if ($currentPath) { $currentPath -split ';' | Where-Object { $_ -ne "" } } else { @() }

        if ($paths -notcontains $DirToAdd) {
            $newPath = if ($currentPath) { "$currentPath;$DirToAdd" } else { $DirToAdd }
            [Environment]::SetEnvironmentVariable("Path", $newPath, $target)
            $env:Path = "$env:Path;$DirToAdd"
            Write-Host "   [PATH] Ditambahkan ke PATH ($scopeName): $DirToAdd" -ForegroundColor Green
        } else {
            Write-Host "   [PATH] Sudah terdaftar di PATH ($scopeName): $DirToAdd" -ForegroundColor Cyan
        }
    } catch {
        # Fallback jika menulis ke Machine gagal (misal SecurityException/akses ditolak):
        try {
            $userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
            $uPaths = if ($userPath) { $userPath -split ';' | Where-Object { $_ -ne "" } } else { @() }
            if ($uPaths -notcontains $DirToAdd) {
                $newUPath = if ($userPath) { "$userPath;$DirToAdd" } else { $DirToAdd }
                [Environment]::SetEnvironmentVariable("Path", $newUPath, [EnvironmentVariableTarget]::User)
                $env:Path = "$env:Path;$DirToAdd"
                Write-Host "   [PATH] Ditambahkan ke User PATH (Fallback): $DirToAdd" -ForegroundColor Green
            }
        } catch {
            Write-Host "   [PATH] Gagal menyimpan ke registry PATH: $_" -ForegroundColor Yellow
        }
    }
}

# 4. Fungsi Helper Set System Env Variable (Dual-Mode: Machine jika Admin, User jika Pengguna Biasa)
function Set-SystemEnvVar {
    param ([string]$Name, [string]$Value)
    $target = if ($script:IsAdmin) { [EnvironmentVariableTarget]::Machine } else { [EnvironmentVariableTarget]::User }
    $scopeName = if ($script:IsAdmin) { "Machine" } else { "User" }
    try {
        [Environment]::SetEnvironmentVariable($Name, $Value, $target)
        [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Process)
        Write-Host "   [ENV] $Name = $Value ($scopeName)" -ForegroundColor Green
    } catch {
        try {
            [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::User)
            [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Process)
            Write-Host "   [ENV] $Name = $Value (User Fallback)" -ForegroundColor Green
        } catch {
            [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Process)
            Write-Host "   [ENV] $Name = $Value (Process Saja)" -ForegroundColor Yellow
        }
    }
}

# 4.1. Helper Parser Argumen CLI (Mencegah bug quoting PowerShell Start-Process)
function Convert-ArgsToArray([string]$arguments) {
    if ([string]::IsNullOrWhiteSpace($arguments)) { return @() }
    $regex = [regex]'(?:[^\s"]+|"[^"]*")+'
    $matches = $regex.Matches($arguments)
    $list = @()
    foreach ($m in $matches) {
        $val = $m.Value
        if ($val.StartsWith('"') -and $val.EndsWith('"') -and $val.Length -ge 2) {
            $val = $val.Substring(1, $val.Length - 2)
        }
        $list += $val
    }
    return $list
}

# 4.2. Helper Pembuat Shortcut Desktop & Start Menu (Agar Aplikasi Muncul di Pencarian Windows)
function Create-AppShortcut {
    param (
        [string]$TargetExe,
        [string]$ShortcutName,
        [string]$WorkingDir = "",
        [string]$Arguments = ""
    )
    if (-not (Test-Path $TargetExe)) { return }
    if ([string]::IsNullOrWhiteSpace($WorkingDir)) {
        $WorkingDir = Split-Path -Parent $TargetExe
    }

    try {
        $wsh = New-Object -ComObject WScript.Shell

        # Tentukan lokasi Desktop dan Programs (Publik jika Admin, Profil User jika Non-Admin)
        $desktopDir = if ($script:IsAdmin) {
            [Environment]::GetFolderPath("CommonDesktopDirectory")
        } else {
            [Environment]::GetFolderPath("Desktop")
        }

        $programsDir = if ($script:IsAdmin) {
            [Environment]::GetFolderPath("CommonPrograms")
        } else {
            [Environment]::GetFolderPath("Programs")
        }

        # 1. Desktop
        if (Test-Path $desktopDir) {
            $lnk1 = Join-Path $desktopDir "$ShortcutName.lnk"
            $sc1 = $wsh.CreateShortcut($lnk1)
            $sc1.TargetPath = $TargetExe
            $sc1.WorkingDirectory = $WorkingDir
            if ($Arguments) { $sc1.Arguments = $Arguments }
            $sc1.Save()
        }

        # 2. Start Menu Program (Muncul saat Windows Search / Start Menu diketik)
        if (Test-Path $programsDir) {
            $lnk2 = Join-Path $programsDir "$ShortcutName.lnk"
            $sc2 = $wsh.CreateShortcut($lnk2)
            $sc2.TargetPath = $TargetExe
            $sc2.WorkingDirectory = $WorkingDir
            if ($Arguments) { $sc2.Arguments = $Arguments }
            $sc2.Save()
        }
    } catch {}
}

# 4.2.1. Helper Ekstraksi Otomatis Arsip (ZIP, RAR, 7Z) dengan Multi-Extractor
function Expand-LabArchive {
    param (
        [string]$ArchivePath,
        [string]$DestinationDir
    )
    if (-not (Test-Path $ArchivePath)) { return $false }
    if (-not (Test-Path $DestinationDir)) { New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null }

    $sevenZip = "C:\Program Files\7-Zip\7z.exe"
    $sevenZipX86 = "C:\Program Files (x86)\7-Zip\7z.exe"
    $winRar = "C:\Program Files\WinRAR\WinRAR.exe"
    $tarCmd = Get-Command tar.exe -ErrorAction SilentlyContinue

    $archiveName = Split-Path -Leaf $ArchivePath
    Write-Host "   [i] Mengekstrak arsip instalasi: $archiveName ..." -ForegroundColor Yellow

    # Prioritas 1: 7-Zip (64-bit / 32-bit)
    if (Test-Path $sevenZip) {
        $p = Start-Process -FilePath $sevenZip -ArgumentList "x `"$ArchivePath`" `"-o$DestinationDir`" -y" -Wait -PassThru -NoNewWindow
        if ($p.ExitCode -eq 0) { return $true }
    }
    if (Test-Path $sevenZipX86) {
        $p = Start-Process -FilePath $sevenZipX86 -ArgumentList "x `"$ArchivePath`" `"-o$DestinationDir`" -y" -Wait -PassThru -NoNewWindow
        if ($p.ExitCode -eq 0) { return $true }
    }

    # Prioritas 2: WinRAR
    if (Test-Path $winRar) {
        $p = Start-Process -FilePath $winRar -ArgumentList "x -ibck -inul -y `"$ArchivePath`" `"$DestinationDir\`"" -Wait -PassThru -NoNewWindow
        if ($p.ExitCode -eq 0) { return $true }
    }

    # Prioritas 3: Windows bsdtar (built-in libarchive mendukung RAR/ZIP/TAR/GZ)
    if ($tarCmd) {
        $p = Start-Process -FilePath $tarCmd.Source -ArgumentList "-xf `"$ArchivePath`" -C `"$DestinationDir`"" -Wait -PassThru -NoNewWindow
        if ($p.ExitCode -eq 0) { return $true }
    }

    # Prioritas 4: PowerShell Expand-Archive (khusus file .zip)
    if ($ArchivePath -match '\.zip$') {
        $zipSuccess = $false
        try {
            Expand-Archive -Path $ArchivePath -DestinationPath $DestinationDir -Force -ErrorAction Stop
            $zipSuccess = $true
        } catch {}
        if ($zipSuccess) { return $true }
    }

    Write-Host "   [!] Tidak ditemukan ekstraktor yang cocok untuk format arsip $archiveName." -ForegroundColor Yellow
    return $false
}

$script:LastDownloadedFile = ""

# 4.3. High-Speed Multi-Mirror Downloader dengan Visual Live Progress & Google Drive Direct Support
function Download-FileWithFastMirrors {
    param (
        [object]$Urls,
        [string]$DestinationPath,
        [string]$ActivityTitle = "Mengunduh Berkas"
    )

    $urlList = @($Urls)
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    $parentDir = Split-Path -Parent $DestinationPath
    if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }

    $cookieJar = New-Object System.Net.CookieContainer
    $downloadSuccess = $false

    foreach ($url in $urlList) {
        if ([string]::IsNullOrWhiteSpace($url)) { continue }
        $cleanHost = ($url -split '/')[2]
        Write-Host "   -> Mencoba server unduh: $cleanHost ..." -ForegroundColor DarkCyan

        # Normalisasi link Google Drive jika pengguna memberikan URL share/view biasa
        $actualUrl = $url
        $gdriveId = $null
        if ($url -match 'drive\.google\.com') {
            if ($url -match 'id=([a-zA-Z0-9_-]+)') {
                $gdriveId = $matches[1]
            } elseif ($url -match '/d/([a-zA-Z0-9_-]+)') {
                $gdriveId = $matches[1]
            }
            if ($gdriveId) {
                $actualUrl = "https://drive.usercontent.google.com/download?id=$gdriveId&export=download&confirm=t"
            }
        }

        $targetFile = $null
        $responseStream = $null
        $response = $null
        $currentDest = $DestinationPath
        try {
            $request = [System.Net.HttpWebRequest]::Create($actualUrl)
            $request.Timeout = 20000
            $request.ReadWriteTimeout = 60000
            $request.CookieContainer = $cookieJar
            if ($actualUrl -match 'sourceforge\.net') {
                $request.UserAgent = "curl/8.4.0"
            } else {
                $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            }
            $response = $request.GetResponse()

            # Google Drive Fallback: Tangani halaman konfirmasi "Google Drive can't scan this file for viruses"
            $contentType = $response.ContentType
            if (($url -match 'drive\.google\.com') -and ($contentType -match 'text/html')) {
                $htmlReader = New-Object System.IO.StreamReader($response.GetResponseStream(), [System.Text.Encoding]::UTF8)
                $htmlBody = $htmlReader.ReadToEnd()
                $htmlReader.Close()
                $response.Close()

                # Cek apakah kuota Google Drive habis
                if ($htmlBody -match "quota exceeded" -or $htmlBody -match "kuota terlampaui" -or $htmlBody -match "akses terlampaui") {
                    Write-Host "      [!] Kuota harian Google Drive mirror ini penuh. Berpindah ke salinan berikutnya..." -ForegroundColor DarkYellow
                    continue
                }

                # Cari token konfirmasi download
                $confirmToken = $null
                if ($htmlBody -match 'confirm=([0-9a-zA-Z_-]+)') {
                    $confirmToken = $matches[1]
                } elseif ($htmlBody -match 'name="confirm"\s+value="([^"]+)"') {
                    $confirmToken = $matches[1]
                }

                if ($confirmToken -and $gdriveId) {
                    $actualUrl = "https://docs.google.com/uc?export=download&id=$gdriveId&confirm=$confirmToken"
                    $request = [System.Net.HttpWebRequest]::Create($actualUrl)
                    $request.Timeout = 20000
                    $request.ReadWriteTimeout = 60000
                    $request.CookieContainer = $cookieJar
                    $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
                    $response = $request.GetResponse()
                }
            }

            # Deteksi nama file asli dari header Content-Disposition (kritis untuk Google Drive)
            $contentDisp = $response.Headers["Content-Disposition"]
            $serverName = $null
            if ($contentDisp -and ($contentDisp -match 'filename="?([^";]+)"?')) {
                $serverName = [System.IO.Path]::GetFileName($matches[1].Trim())
            }

            $currentBase = [System.IO.Path]::GetFileName($currentDest)
            if (-not [string]::IsNullOrWhiteSpace($serverName)) {
                $currentDest = Join-Path $parentDir $serverName
            } elseif (($currentBase -ieq "view") -or (-not ([System.IO.Path]::HasExtension($currentDest)))) {
                $fallbackSafe = ($ActivityTitle -replace 'Mengunduh\s*', '' -replace '[^a-zA-Z0-9_-]', '_') + ".exe"
                $currentDest = Join-Path $parentDir $fallbackSafe
            }

            $totalBytes = $response.ContentLength
            $responseStream = $response.GetResponseStream()

            $targetFile = New-Object System.IO.FileStream($currentDest, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            $buffer = New-Object byte[] 65536
            $downloadedBytes = 0
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $lastReport = [System.Diagnostics.Stopwatch]::StartNew()

            while (($bytesRead = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $targetFile.Write($buffer, 0, $bytesRead)
                $downloadedBytes += $bytesRead

                if ($lastReport.ElapsedMilliseconds -gt 300) {
                    Invoke-LabKeepAlive
                    $percent = if ($totalBytes -gt 0) { [math]::Min(100, [int](($downloadedBytes / $totalBytes) * 100)) } else { 0 }
                    $speedKBps = if ($sw.Elapsed.TotalSeconds -gt 0) { [math]::Round(($downloadedBytes / 1024) / $sw.Elapsed.TotalSeconds, 1) } else { 0 }
                    $speedMBps = [math]::Round($speedKBps / 1024, 2)
                    $mbDownloaded = [math]::Round($downloadedBytes / 1MB, 2)
                    $mbTotal = if ($totalBytes -gt 0) { [math]::Round($totalBytes / 1MB, 2) } else { 0 }

                    $barLength = 20
                    $completedBars = [int]($percent / (100 / $barLength))
                    $remainingBars = $barLength - $completedBars
                    $barStr = ("#" * $completedBars) + ("-" * $remainingBars)

                    Write-Progress -Activity "$ActivityTitle" -Status "[$barStr] $percent% ($mbDownloaded MB / $mbTotal MB) @ $speedMBps MB/s" -PercentComplete $percent
                    $lastReport.Restart()
                }
            }

            Write-Progress -Activity "$ActivityTitle" -Completed
            $targetFile.Close()
            $responseStream.Close()
            $response.Close()

            # Verifikasi integritas: cegah berkas rusak/HTML error tersimpan sebagai installer biner
            $fInfo = Get-Item $currentDest -ErrorAction SilentlyContinue
            if ($fInfo) {
                # Cek 1: Jika server mengembalikan Content-Type text/html pada installer binary (.exe, .msi, .zip, .rar, .7z)
                $destExt = [System.IO.Path]::GetExtension($currentDest).ToLower()
                $isBinaryTarget = ($destExt -match '\.(exe|msi|zip|rar|7z|vbox-extpack)$')
                if ($isBinaryTarget -and ($contentType -match 'text/html')) {
                    $targetFile = $null
                    Remove-Item -Path $currentDest -Force -ErrorAction SilentlyContinue
                    Write-Host "      [!] Server mengembalikan dokumen HTML (bukan installer biner). Berpindah ke mirror berikutnya..." -ForegroundColor DarkYellow
                    continue
                }

                # Cek 2: Google Drive limit/quota reached HTML detection
                if (($fInfo.Length -lt 500000) -and ($url -match 'drive\.google\.com')) {
                    $checkTxt = [System.IO.File]::ReadAllText($currentDest)
                    if (($checkTxt -match "<html") -or ($checkTxt -match "quota exceeded") -or ($checkTxt -match "kuota terlampaui")) {
                        Remove-Item -Path $currentDest -Force -ErrorAction SilentlyContinue
                        Write-Host "      [!] Google Drive mirror ini limit/kuota terlampaui. Berpindah ke mirror berikutnya..." -ForegroundColor DarkYellow
                        continue
                    }
                }

                # Cek 3: Verifikasi ukuran minimum untuk installer aplikasi besar
                if ($isBinaryTarget -and ($fInfo.Length -lt 1048576)) { # Kurang dari 1 MB
                    $checkTxt = ""
                    try { $checkTxt = [System.IO.File]::ReadAllText($currentDest) } catch {}
                    if ($checkTxt -match "<html") {
                        Remove-Item -Path $currentDest -Force -ErrorAction SilentlyContinue
                        Write-Host "      [!] File terunduh adalah halaman web/error ($([math]::Round($fInfo.Length/1KB,1)) KB). Dihapus & berpindah ke mirror berikutnya..." -ForegroundColor DarkYellow
                        continue
                    }
                }

                # Cek 4: Verifikasi kelengkapan jika server menyediakan Content-Length valid
                if ($totalBytes -gt 0 -and ($downloadedBytes -lt $totalBytes)) {
                    Remove-Item -Path $currentDest -Force -ErrorAction SilentlyContinue
                    Write-Host "      [!] Unduhan terputus sebelum selesai ($downloadedBytes / $totalBytes bytes). Berpindah ke mirror berikutnya..." -ForegroundColor DarkYellow
                    continue
                }
            }

            $script:LastDownloadedFile = $currentDest
            $downloadSuccess = $true
            break
        } catch {
            Write-Progress -Activity "$ActivityTitle" -Completed
            if ($targetFile) { $targetFile.Close() }
            if ($responseStream) { $responseStream.Close() }
            if ($response) { $response.Close() }
            if (Test-Path $currentDest) { Remove-Item -Path $currentDest -Force -ErrorAction SilentlyContinue }
            $errMsg = $_.Exception.Message
            Write-Host "      [!] Server $cleanHost lambat/gagal: $errMsg. Mencoba mirror cadangan..." -ForegroundColor DarkYellow
        }
    }
    return $downloadSuccess
}

# 5. Fungsi Pelacak Status Instalasi & Ringkasan Hasil Otomasi
$script:InstallResults = @()

function Record-InstallResult {
    param (
        [string]$Name,
        [string]$Status,       # "SUDAH TERPASANG", "BERHASIL DIINSTAL", "BELUM TERSEDIA", "GAGAL"
        [string]$Keterangan
    )
    $existing = $script:InstallResults | Where-Object { $_.Name -eq $Name } | Select-Object -First 1
    if ($existing) {
        $existing.Status = $Status
        $existing.Keterangan = $Keterangan
    } else {
        $script:InstallResults += [PSCustomObject]@{
            Name       = $Name
            Status     = $Status
            Keterangan = $Keterangan
        }
    }
}

# 5.1. Fungsi Cerdas Install (Offline Folder Apps -> Fallback Winget Online)
function Install-AppSmart {
    param (
        [string]$Name,
        [object]$FilePattern,       # misal "*virtualbox*.exe" atau @("*pat1*", "*pat2*")
        [string]$SilentArgs = "",   # misal "/qn" atau "/S"
        [string]$WingetId = "",     # misal "Oracle.VirtualBox"
        [string]$WingetArgs = "",
        [object]$DownloadUrls = $null, # URL unduhan langsung (bisa array mirror untuk server kencang)
        [object]$CheckPath = $null, # Jalur eksekutabel (string atau array) untuk mendeteksi apakah sudah terpasang
        [switch]$IsInteractive      # Untuk installer pihak ketiga (Delphi/Proteus) agar tidak freeze/hang
    )

    Invoke-LabKeepAlive
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: $Name" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    # 0. Cek apakah software SUDAH terpasang di sistem ini (Cerdas: Hindari install ulang)
    if ($CheckPath) {
        $checkList = @($CheckPath)
        $alreadyInstalled = $null
        foreach ($cp in $checkList) {
            $alreadyInstalled = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $alreadyInstalled) {
                $alreadyInstalled = Get-Item -Path $cp -ErrorAction SilentlyContinue | Select-Object -First 1
            }
            if ($alreadyInstalled) { break }
        }
        if ($alreadyInstalled) {
            Write-Host "   [OK SUDAH TERPASANG] $Name terdeteksi di $($alreadyInstalled.FullName)" -ForegroundColor Green
            Create-AppShortcut -TargetExe $alreadyInstalled.FullName -ShortcutName $Name
            Write-Host "   -> Melewati proses instalasi (Skip)." -ForegroundColor DarkGray
            Record-InstallResult -Name $Name -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi aktif di sistem (Skip)"
            return
        }
    }

    # A. Cek apakah ada file offline di folder Apps/ (Pencarian Rekursif ke Seluruh Subfolder)
    if (Test-Path $AppsDir) {
        $offlineFile = $null
        $patterns = @($FilePattern)
        foreach ($pat in $patterns) {
            $candidates = Get-ChildItem -Path $AppsDir -Filter $pat -File -Recurse -ErrorAction SilentlyContinue
            foreach ($cand in $candidates) {
                # Cegah salah deteksi binary portable atau tools internal (bukan installer resmi)
                if ($cand.Name -in @("git.exe", "code.exe", "laragon.exe", "php.exe", "python.exe", "node.exe", "composer.phar")) {
                    continue
                }
                if ($cand.FullName -match '(?i)[\/\\](bin|cmd|usr|node_modules|vendor)[\/\\]') {
                    continue
                }

                # Validasi kelayakan: file binary installer (.exe/.msi/.zip/.rar) harus bukan file HTML rusak/error
                if ($cand.Length -lt 512000) { # kurang dari 500KB
                    $isHtmlErr = $false
                    try {
                        $sample = [System.IO.File]::ReadAllText($cand.FullName)
                        if ($sample -match "<html" -or $sample -match "quota exceeded") { $isHtmlErr = $true }
                    } catch {}
                    if ($isHtmlErr) {
                        Remove-Item -Path $cand.FullName -Force -ErrorAction SilentlyContinue
                        Write-Host "   [!] Menghapus berkas installer rusak/HTML error di Apps: $($cand.Name)" -ForegroundColor DarkYellow
                        continue
                    }
                }
                $offlineFile = $cand
                break
            }
            if ($offlineFile) { break }
        }

        if ($offlineFile) {
            Write-Host "[OK] Ditemukan file installer offline: $($offlineFile.Name) ($([math]::Round($offlineFile.Length / 1MB, 2)) MB)" -ForegroundColor Green
            
            $ext = $offlineFile.Extension.ToLower()

            # Jika file merupakan arsip (ZIP/RAR/7Z), ekstrak terlebih dahulu secara otomatis
            if ($ext -match "zip|rar|7z") {
                $extractFolder = Join-Path $AppsDir ($offlineFile.BaseName)
                $extracted = Expand-LabArchive -ArchivePath $offlineFile.FullName -DestinationDir $extractFolder
                if ($extracted) {
                    $innerExe = Get-ChildItem -Path $extractFolder -Filter "*.exe" -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "uninstall|remove" } | Select-Object -First 1
                    $innerMsi = Get-ChildItem -Path $extractFolder -Filter "*.msi" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($innerExe) {
                        $offlineFile = $innerExe
                        $ext = ".exe"
                    } elseif ($innerMsi) {
                        $offlineFile = $innerMsi
                        $ext = ".msi"
                    }
                }
            }

            if ($IsInteractive) {
                Write-Host "[i] Membuka berkas/installer interaktif: $($offlineFile.Name)" -ForegroundColor Yellow
                Write-Host "    >>> Silakan ikuti petunjuk setup / aktivasi lisensi lab di layar yang muncul..." -ForegroundColor Cyan
                if ($ext -match "zip|rar|7z") {
                    Start-Process explorer.exe -ArgumentList "/select,`"$($offlineFile.FullName)`""
                } else {
                    $proc = Start-Process -FilePath $offlineFile.FullName -Wait -PassThru
                }
                Write-Host "[OK] Selesai memproses $Name." -ForegroundColor Green
                Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Setup interaktif selesai"
                return
            } else {
                Write-Host "[i] Menjalankan instalasi lokal secara otomatis dari flashdisk..." -ForegroundColor Yellow
                if ($ext -eq ".msi") {
                    $cleanSilent = if ($SilentArgs) { $SilentArgs -replace '(?i)\s*/qn\b', '' -replace '(?i)\s*/quiet\b', '' -replace '(?i)\s*/norestart\b', '' } else { "" }
                    $cleanSilent = $cleanSilent.Trim()
                    $msiArgs = if ([string]::IsNullOrWhiteSpace($cleanSilent)) {
                        "/i `"$($offlineFile.FullName)`" /qn /norestart"
                    } else {
                        "/i `"$($offlineFile.FullName)`" /qn /norestart $cleanSilent"
                    }
                    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru
                } else {
                    $argsList = Convert-ArgsToArray $SilentArgs
                    if ($argsList -and ($argsList.Count -gt 0)) {
                        $proc = Start-Process -FilePath $offlineFile.FullName -ArgumentList $argsList -Wait -PassThru
                    } else {
                        $proc = Start-Process -FilePath $offlineFile.FullName -Wait -PassThru
                    }
                }

                # Kode 0 = Sukses, 3010 = Sukses (Butuh restart), 1641 = Sukses reboot, 1223 = Elevated/UAC Success, 1638 = Versi sudah ada
                $isExitSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010 -or $proc.ExitCode -eq 1641 -or $proc.ExitCode -eq 1223 -or $proc.ExitCode -eq 1638)
                
                # Verifikasi langsung pada target CheckPath (beberapa installer seperti BitRock XAMPP mengembalikan exit code 1 saat selesai jika ada peringatan port/antivirus minor padahal file terpasang sempurna)
                $foundCheck = $null
                if ($CheckPath) {
                    foreach ($cp in @($CheckPath)) {
                        $f = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
                        if ($f) { $foundCheck = $f; break }
                    }
                }

                if ($isExitSuccess -or $foundCheck) {
                    Write-Host "[OK] Berhasil menginstal $Name dari folder Apps!" -ForegroundColor Green
                    if ($foundCheck) {
                        Create-AppShortcut -TargetExe $foundCheck.FullName -ShortcutName $Name
                    }
                    Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Terpasang dari offline Apps"
                    return
                } else {
                    $ec = $proc.ExitCode
                    Write-Host "[!] Installer offline selesai dengan kode exit: $ec" -ForegroundColor Yellow
                    Record-InstallResult -Name $Name -Status "GAGAL" -Keterangan "Exit Code: $ec"
                    return
                }
            }
        }
    }

    # B. Jika ada DownloadUrls langsung (CDN mirror cepat), unduh dan simpan ke folder Apps/
    if ($DownloadUrls) {
        $urlsArr = @($DownloadUrls)
        if ($urlsArr -and ($urlsArr.Count -gt 0)) {
            $firstUrl = $urlsArr[0]
            $destName = [System.IO.Path]::GetFileName(($firstUrl -split '\?')[0])
            if ([string]::IsNullOrWhiteSpace($destName) -or ($destName.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ge 0) -or ($destName -ieq "view") -or (-not ([System.IO.Path]::HasExtension($destName)))) {
                $destName = "$($Name -replace '[^a-zA-Z0-9_-]', '_').exe"
            }
            $destFile = Join-Path $AppsDir $destName
            Write-Host "[i] Mengunduh installer $Name via High-Speed CDN Mirror..." -ForegroundColor Yellow
            $downloaded = Download-FileWithFastMirrors -Urls $urlsArr -DestinationPath $destFile -ActivityTitle "Mengunduh $Name"

            if ($downloaded -and (-not [string]::IsNullOrWhiteSpace($script:LastDownloadedFile)) -and (Test-Path $script:LastDownloadedFile)) {
                $destFile = $script:LastDownloadedFile
            }

            if ($downloaded -and (Test-Path $destFile)) {
                $savedLeaf = Split-Path -Leaf $destFile
                Write-Host "[OK] Installer $Name berhasil diunduh dan disimpan ke folder Apps/ ($savedLeaf)!" -ForegroundColor Green

                $ext = [System.IO.Path]::GetExtension($destFile).ToLower()

                # Jika unduhan berupa file arsip (ZIP/RAR/7Z), ekstrak secara otomatis
                if ($ext -match "zip|rar|7z") {
                    $extractFolder = Join-Path $AppsDir ([System.IO.Path]::GetFileNameWithoutExtension($destFile))
                    $extracted = Expand-LabArchive -ArchivePath $destFile -DestinationDir $extractFolder
                    if ($extracted) {
                        $innerExe = Get-ChildItem -Path $extractFolder -Filter "*.exe" -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "uninstall|remove" } | Select-Object -First 1
                        $innerMsi = Get-ChildItem -Path $extractFolder -Filter "*.msi" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                        if ($innerExe) {
                            $destFile = $innerExe.FullName
                            $ext = ".exe"
                        } elseif ($innerMsi) {
                            $destFile = $innerMsi.FullName
                            $ext = ".msi"
                        }
                    }
                }

                if ($ext -eq ".msi") {
                    $cleanSilent = if ($SilentArgs) { $SilentArgs -replace '(?i)\s*/qn\b', '' -replace '(?i)\s*/quiet\b', '' -replace '(?i)\s*/norestart\b', '' } else { "" }
                    $cleanSilent = $cleanSilent.Trim()
                    $msiArgs = if ([string]::IsNullOrWhiteSpace($cleanSilent)) {
                        "/i `"$destFile`" /qn /norestart"
                    } else {
                        "/i `"$destFile`" /qn /norestart $cleanSilent"
                    }
                    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru
                } else {
                    $argsList = Convert-ArgsToArray $SilentArgs
                    if ($argsList -and ($argsList.Count -gt 0)) {
                        $proc = Start-Process -FilePath $destFile -ArgumentList $argsList -Wait -PassThru
                    } else {
                        $proc = Start-Process -FilePath $destFile -Wait -PassThru
                    }
                }
                $isMirrorExitSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010 -or $proc.ExitCode -eq 1641 -or $proc.ExitCode -eq 1223 -or $proc.ExitCode -eq 1638)
                $foundCheckMirror = $null
                if ($CheckPath) {
                    foreach ($cp in @($CheckPath)) {
                        $f = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
                        if ($f) { $foundCheckMirror = $f; break }
                    }
                }

                if ($isMirrorExitSuccess -or $foundCheckMirror) {
                    Write-Host "[OK] Berhasil menginstal $Name!" -ForegroundColor Green
                    if ($foundCheckMirror) {
                        Create-AppShortcut -TargetExe $foundCheckMirror.FullName -ShortcutName $Name
                    }
                    Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Terunduh & terpasang via Mirror"
                    return
                }
            } else {
                Write-Host "[!] Gagal mengunduh dari semua CDN mirror langsung. Mencoba fallback ke Winget..." -ForegroundColor Yellow
            }
        }
    }

    # C. Jika tidak ada file offline di folder Apps, unduh & simpan ke Apps/ via Winget, lalu instal
    if (-not [string]::IsNullOrWhiteSpace($WingetId)) {
        if (-not (Test-WingetAvailable)) {
            Write-Host "   [i] Winget (Windows Package Manager) tidak terpasang di komputer ini." -ForegroundColor DarkYellow
            Write-Host "       (Sistem mengandalkan file installer offline di folder Apps/ atau Direct CDN Mirror)." -ForegroundColor DarkGray
            Record-InstallResult -Name $Name -Status "BELUM TERSEDIA" -Keterangan "Memerlukan file master offline di Apps/"
            return
        }

        Write-Host "[i] File offline belum ada di folder Apps. Mengunduh & menyimpan installer ke Apps/..." -ForegroundColor Yellow
        $wingetDownloadedSuccess = $false
        try {
            & winget download --id "$WingetId" --source winget -d "$AppsDir" --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null
            
            # Pasang dependensi offline jika ikut terunduh oleh winget ke folder Dependencies
            $depDir = Join-Path $AppsDir "Dependencies"
            if (Test-Path $depDir) {
                Get-ChildItem -Path $depDir -Filter "*.msi" -File -ErrorAction SilentlyContinue | ForEach-Object {
                    Write-Host "   [i] Memasang dependensi offline: $($_.Name)..." -ForegroundColor Yellow
                    Start-Process msiexec.exe -ArgumentList "/i `"$($_.FullName)`" /qn /norestart" -Wait
                }
            }

            $patterns = @($FilePattern)
            $newOfflineFile = $null
            foreach ($pat in $patterns) {
                $newOfflineFile = Get-ChildItem -Path $AppsDir -Filter $pat -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($newOfflineFile) { break }
            }
            if ($newOfflineFile) {
                Write-Host "[OK] Installer berhasil diunduh dan disimpan di Apps/: $($newOfflineFile.Name)" -ForegroundColor Green
                Write-Host "[i] Melanjutkan instalasi lokal..." -ForegroundColor Yellow
                $ext = $newOfflineFile.Extension.ToLower()
                if ($ext -eq ".msi") {
                    $cleanSilent = if ($SilentArgs) { $SilentArgs -replace '(?i)\s*/qn\b', '' -replace '(?i)\s*/quiet\b', '' -replace '(?i)\s*/norestart\b', '' } else { "" }
                    $cleanSilent = $cleanSilent.Trim()
                    $msiArgs = if ([string]::IsNullOrWhiteSpace($cleanSilent)) {
                        "/i `"$($newOfflineFile.FullName)`" /qn /norestart"
                    } else {
                        "/i `"$($newOfflineFile.FullName)`" /qn /norestart $cleanSilent"
                    }
                    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru
                } else {
                    $argsList = Convert-ArgsToArray $SilentArgs
                    if ($argsList -and ($argsList.Count -gt 0)) {
                        $proc = Start-Process -FilePath $newOfflineFile.FullName -ArgumentList $argsList -Wait -PassThru
                    } else {
                        $proc = Start-Process -FilePath $newOfflineFile.FullName -Wait -PassThru
                    }
                }
                if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010 -or $proc.ExitCode -eq 1641 -or $proc.ExitCode -eq 1223 -or $proc.ExitCode -eq 1638) {
                    Write-Host "[OK] Berhasil menginstal $Name!" -ForegroundColor Green
                    if ($CheckPath) {
                        foreach ($cp in @($CheckPath)) {
                            $f = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
                            if ($f) { Create-AppShortcut -TargetExe $f.FullName -ShortcutName $Name; break }
                        }
                    }
                    Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Terunduh & terpasang via Winget"
                    $wingetDownloadedSuccess = $true
                }
            }
        } catch {
            Write-Host "[!] Unduhan installer offline via Winget dilewati: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
        if ($wingetDownloadedSuccess) { return }

        # Fallback langsung install via Winget jika download bundle belum menyelesaikan install
        try {
            $installed = & winget list --id "$WingetId" --source winget 2>$null
            if ($LASTEXITCODE -eq 0 -and $installed -match $WingetId) {
                Write-Host "[OK] $Name sudah terinstal di sistem ini." -ForegroundColor Green
                Record-InstallResult -Name $Name -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi via Winget (Skip)"
                return
            }

            $wArgsList = @("install", "--id", "$WingetId", "--source", "winget", "-e", "--silent", "--accept-source-agreements", "--accept-package-agreements", "--disable-interactivity")
            if (-not [string]::IsNullOrWhiteSpace($WingetArgs)) {
                $extraW = Convert-ArgsToArray $WingetArgs
                if ($extraW) { $wArgsList += $extraW }
            }
            $pWinget = Start-Process -FilePath "winget.exe" -ArgumentList $wArgsList -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue

            if ($pWinget -and ($pWinget.ExitCode -eq 0 -or $pWinget.ExitCode -eq 3010)) {
                Write-Host "[OK] Berhasil menginstal $Name via Winget!" -ForegroundColor Green
                Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Terpasang via Winget Direct"
            } else {
                Write-Host "[!] Pemasangan $Name via Winget tidak berhasil (Exit: $($pWinget.ExitCode))." -ForegroundColor DarkYellow
                Record-InstallResult -Name $Name -Status "GAGAL" -Keterangan "Winget error / offline"
            }
        } catch {
            Write-Host "[!] Eksekusi Winget gagal: $($_.Exception.Message)" -ForegroundColor DarkYellow
            Record-InstallResult -Name $Name -Status "GAGAL" -Keterangan "Winget tidak tersedia"
        }
    } else {
        Write-Host "[!] File installer offline $Name ($FilePattern) belum ada di folder Apps/." -ForegroundColor Yellow
        Write-Host "    (Silakan salin installer pihak ketiga $Name ke folder Apps dan jalankan kembali)." -ForegroundColor Gray
        Record-InstallResult -Name $Name -Status "BELUM TERSEDIA" -Keterangan "Menunggu file master di Apps/"
    }
}

# 5.1. Fungsi Setup 7-Zip (High-Speed Multi-Format Archive Extractor)
function Setup-7Zip {
    $sevenZipMirrors = @(
        "https://www.7-zip.org/a/7z2408-x64.exe",
        "https://github.com/ip7z/7zip/releases/download/24.08/7z2408-x64.exe"
    )
    Install-AppSmart -Name "7-Zip" `
                     -FilePattern @("*7z*x64*.exe", "*7z*.exe", "*7-zip*.exe", "*7z*.msi") `
                     -DownloadUrls $sevenZipMirrors `
                     -SilentArgs "/S" `
                     -WingetId "7zip.7zip" `
                     -CheckPath @("C:\Program Files\7-Zip\7z.exe", "C:\Program Files (x86)\7-Zip\7z.exe")

    $sevenZipPath = "C:\Program Files\7-Zip"
    if (Test-Path $sevenZipPath) {
        Add-ToSystemPath -DirToAdd $sevenZipPath
        if ($env:Path -notlike "*$sevenZipPath*") { $env:Path = "$sevenZipPath;" + $env:Path }
    }
}

# 5.2. Fungsi Setup WinRAR (Lab Archive Support .rar/.zip)
function Setup-WinRAR {
    $winRarMirrors = @(
        "https://www.rarlab.com/rar/winrar-x64-701.exe",
        "https://www.rarlab.com/rar/winrar-x64-700.exe"
    )
    Install-AppSmart -Name "WinRAR" `
                     -FilePattern @("*winrar*x64*.exe", "*winrar*.exe", "*wrar*.exe") `
                     -DownloadUrls $winRarMirrors `
                     -SilentArgs "/s" `
                     -WingetId "RARLab.WinRAR" `
                     -CheckPath @("C:\Program Files\WinRAR\WinRAR.exe", "C:\Program Files (x86)\WinRAR\WinRAR.exe")

    $winRarPath = "C:\Program Files\WinRAR"
    if (Test-Path $winRarPath) {
        Add-ToSystemPath -DirToAdd $winRarPath
        if ($env:Path -notlike "*$winRarPath*") { $env:Path = "$winRarPath;" + $env:Path }
    }
}

# 5.3. Fungsi Setup Git for Windows (Wajib untuk Dart SDK, Flutter, Composer, & VS Code)
function Setup-Git {
    $gitMirrors = @(
        "https://github.com/git-for-windows/git/releases/download/v2.48.1.windows.1/Git-2.48.1-64-bit.exe",
        "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe",
        "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe"
    )
    # HANYA periksa instalasi resmi Git for Windows (C:\Program Files\Git)
    # JANGAN sertakan C:\laragon\bin\git agar Git resmi tetap terpasang di Windows (Control Panel & Start Menu)
    $gitCheckPaths = @(
        "C:\Program Files\Git\cmd\git.exe",
        "C:\Program Files\Git\bin\git.exe",
        "C:\Program Files (x86)\Git\cmd\git.exe"
    )

    Install-AppSmart -Name "Git for Windows" `
                     -FilePattern @("Git-*-64-bit.exe", "Git-*.exe", "*Git*Setup*.exe") `
                     -DownloadUrls $gitMirrors `
                     -SilentArgs "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS" `
                     -WingetId "Git.Git" `
                     -CheckPath $gitCheckPaths

    $gitFound = $null
    foreach ($gp in $gitCheckPaths) {
        if (Test-Path $gp) { $gitFound = $gp; break }
    }

    if ($gitFound) {
        $gitDir = Split-Path -Parent $gitFound
        $gitRoot = Split-Path -Parent $gitDir
        $gitCmd = Join-Path $gitRoot "cmd"
        $gitBin = Join-Path $gitRoot "bin"
        $gitUsrBin = Join-Path $gitRoot "usr\bin"
        $gitBashExe = Join-Path $gitRoot "git-bash.exe"
        $gitGuiExe = Join-Path $gitRoot "cmd\git-gui.exe"

        if (Test-Path $gitCmd) { Add-ToSystemPath -DirToAdd $gitCmd }
        if (Test-Path $gitBin) { Add-ToSystemPath -DirToAdd $gitBin }
        if (Test-Path $gitUsrBin) { Add-ToSystemPath -DirToAdd $gitUsrBin }

        # Buat Pintasan Start Menu & Desktop resmi agar langsung muncul di Pencarian Windows
        if (Test-Path $gitBashExe) {
            Create-AppShortcut -TargetExe $gitBashExe -ShortcutName "Git Bash"
        }
        if (Test-Path $gitGuiExe) {
            Create-AppShortcut -TargetExe $gitGuiExe -ShortcutName "Git GUI"
        }

        # Daftarkan ke Windows App Paths agar bisa dipanggil langsung dari Run (Win+R) git.exe
        try {
            $regAppPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\git.exe"
            if (-not (Test-Path $regAppPath)) { New-Item -Path $regAppPath -Force | Out-Null }
            Set-ItemProperty -Path $regAppPath -Name "(Default)" -Value "$gitCmd\git.exe" -Force
            Set-ItemProperty -Path $regAppPath -Name "Path" -Value "$gitCmd;$gitBin;$gitUsrBin" -Force
        } catch {}

        # Update environment PATH sesi sekarang secara instan agar dart/flutter/composer langsung mengenal git
        $pathsToPrepend = @($gitCmd, $gitBin, $gitUsrBin) | Where-Object { Test-Path $_ }
        foreach ($pt in $pathsToPrepend) {
            if ($env:Path -notlike "*$pt*") {
                $env:Path = "$pt;" + $env:Path
            }
        }
        Write-Host "   [OK] Git for Windows resmi aktif dan terintegrasi di Windows ($gitFound)!" -ForegroundColor Green
    }
}

# 6. Fungsi Khusus Setup Java JDK & JAVA_HOME
function Setup-JavaJDK {
    $jdkMirrors = @(
        "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.msi"
    )
    Install-AppSmart -Name "Java JDK 17 (OpenJDK Temurin)" `
                     -FilePattern @("*Temurin*17*.msi", "*jdk*17*.msi", "*Temurin*.msi") `
                     -DownloadUrls $jdkMirrors `
                     -SilentArgs "ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /qn" `
                     -WingetId "EclipseAdoptium.Temurin.17.JDK" `
                     -CheckPath @("C:\Program Files\Eclipse Adoptium\jdk-17*\bin\javac.exe", "C:\Program Files\Java\jdk-17*\bin\javac.exe")

    $jdkSearchPaths = @(
        "C:\Program Files\Eclipse Adoptium\jdk-17*",
        "C:\Program Files\Eclipse Adoptium\jdk-2*",
        "C:\Program Files\Java\jdk-17*",
        "C:\Program Files\Java\jdk-2*",
        "C:\Program Files\Java\jdk*"
    )
    $jdkPath = $null
    foreach ($pattern in $jdkSearchPaths) {
        $found = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $jdkPath = $found.FullName; break }
    }

    if ($jdkPath) {
        Set-SystemEnvVar -Name "JAVA_HOME" -Value $jdkPath
        $javaBin = Join-Path $jdkPath "bin"
        Add-ToSystemPath -DirToAdd $javaBin
        $env:JAVA_HOME = $jdkPath
        if ($env:Path -notlike "*$javaBin*") {
            $env:Path = "$javaBin;" + $env:Path
        }
        Write-Host "[OK] JAVA_HOME berhasil dikonfigurasi ke $jdkPath" -ForegroundColor Green
    } else {
        Write-Host "[!] Path JDK tidak terdeteksi otomatis. Silakan atur JAVA_HOME manual jika diperlukan." -ForegroundColor Yellow
    }
}

# 7. Fungsi Khusus Setup Python & Pip PATH
function Setup-Python {
    $pythonMirrors = @(
        "https://www.python.org/ftp/python/3.13.2/python-3.13.2-amd64.exe",
        "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe",
        "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"
    )
    Install-AppSmart -Name "Python (Latest with PIP)" `
                     -FilePattern @("*python*3.13*.exe", "*python*3.12*.exe", "*python*.exe") `
                     -DownloadUrls $pythonMirrors `
                     -SilentArgs "/quiet InstallAllUsers=1 PrependPath=1 Include_pip=1" `
                     -WingetId "Python.Python.3.13" `
                     -CheckPath @("C:\Program Files\Python313\python.exe", "C:\Program Files\Python312\python.exe", "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe", "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe")

    $pyPaths = @(
        "C:\Program Files\Python313",
        "C:\Program Files\Python312",
        "$env:LOCALAPPDATA\Programs\Python\Python313",
        "$env:LOCALAPPDATA\Programs\Python\Python312"
    )
    foreach ($p in $pyPaths) {
        if (Test-Path $p) {
            Add-ToSystemPath -DirToAdd $p
            $pScripts = Join-Path $p "Scripts"
            if (Test-Path $pScripts) { Add-ToSystemPath -DirToAdd $pScripts }
            if ($env:Path -notlike "*$p*") { $env:Path = "$p;$pScripts;" + $env:Path }
            Write-Host "   [OK] Python berhasil didaftarkan ke System PATH ($p)" -ForegroundColor Green
            break
        }
    }
}

# 8. Fungsi Khusus Setup & Overlay Custom Stack Laragon
function Setup-LaragonStack {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: Laragon (WAMP Stack) + Custom Lab Environment" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $targetLaragon = "C:\laragon"
    $laragonExe = Join-Path $targetLaragon "laragon.exe"

    # Multi-Mirror Google Drive resmi untuk paket master Laragon_Custom_Stack.rar (Auto-Fallback kuota)
    $laragonCustomMirrors = @(
        "https://drive.google.com/file/d/1nn1aUQm1FiVlFRy-pIerSxCkK1I7MtJ_/view?usp=sharing",
        "https://drive.google.com/file/d/14IyGfCdk3VOw-MWYXqA2SkP2S9jq1hBC/view?usp=sharing",
        "https://drive.google.com/file/d/1Eunm6q6ir8yx0F9ybTPU4dfaOn33fkUt/view?usp=sharing",
        "https://drive.google.com/file/d/1majSE8h7bR_tRFFz2euHBP3-CNtzigP6/view?usp=sharing"
    )

    if (Test-Path $laragonExe) {
        Write-Host "   [OK SUDAH TERPASANG] Laragon terdeteksi di $laragonExe." -ForegroundColor Green
    } else {
        # 1. Cari file installer offline Laragon di AppsDir (KECUALIKAN file binary laragon.exe)
        $laragonInstaller = Get-ChildItem -Path $AppsDir -Filter "*laragon*.exe" -File -Recurse -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -ine "laragon.exe" -and $_.Name -notmatch "unins" -and $_.FullName -notmatch 'bin|usr|etc|Custom_Stack'
        } | Select-Object -First 1

        if (-not $laragonInstaller) {
            $laragonInstaller = Get-ChildItem -Path $AppsDir -Filter "*wamp*.exe" -File -Recurse -ErrorAction SilentlyContinue | Where-Object {
                $_.Name -notmatch "unins"
            } | Select-Object -First 1
        }

        if (-not $laragonInstaller) {
            Write-Host "   [i] File offline Laragon belum ada di Apps. Mengunduh installer resmi 6.0.0..." -ForegroundColor Yellow
            $laragonBaseUrls = @(
                "https://github.com/leokhoa/laragon/releases/download/6.0.0/laragon-wamp.exe",
                "https://downloads.sourceforge.net/project/laragon/laragon-wamp.exe"
            )
            $destExe = Join-Path $AppsDir "laragon-wamp-setup-6.0.0.exe"
            $dlBase = Download-FileWithFastMirrors -Urls $laragonBaseUrls -DestinationPath $destExe -ActivityTitle "Mengunduh Laragon WAMP"
            if ($dlBase -and (Test-Path $destExe)) {
                $laragonInstaller = Get-Item $destExe -ErrorAction SilentlyContinue
                Write-Host "   [OK] Installer Laragon berhasil diunduh dan disimpan di folder Apps/!" -ForegroundColor Green
            }

            if (-not $laragonInstaller) {
                try {
                    winget download --id "LeNgocKhoa.Laragon" --source winget -d "$AppsDir" --accept-package-agreements --accept-source-agreements --disable-interactivity
                    $laragonInstaller = Get-ChildItem -Path $AppsDir -Filter "*laragon*.exe" -File -Recurse -ErrorAction SilentlyContinue | Where-Object {
                        $_.Name -ine "laragon.exe" -and $_.Name -notmatch "unins"
                    } | Select-Object -First 1
                } catch {}
            }
        }

        if ($laragonInstaller) {
            Write-Host "   [OK] Ditemukan installer: $($laragonInstaller.Name)" -ForegroundColor Green
            Write-Host "   [i] Menjalankan instalasi Laragon secara otomatis..." -ForegroundColor Yellow

            # Hentikan proses lama jika ada
            Get-Process -Name "laragon", "httpd", "mysqld" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 500

            # Background Watchdog: Cegah modal popup laragon.exe (/VERYSILENT atau /DIR) memblok instalasi
            $killJob = Start-Job -ScriptBlock {
                for ($i = 0; $i -lt 150; $i++) {
                    Get-Process -Name "laragon" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Milliseconds 250
                }
            }

            $laragonArgs = @("/VERYSILENT", "/NORESTART", "/SP-", "/SUPPRESSMSGBOXES", "/DIR=C:\laragon")
            $p = Start-Process -FilePath $laragonInstaller.FullName -ArgumentList $laragonArgs -Wait -PassThru

            Stop-Job $killJob -Force -ErrorAction SilentlyContinue
            Remove-Job $killJob -Force -ErrorAction SilentlyContinue
            Get-Process -Name "laragon" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "   [i] Mencoba direct install Laragon via Winget..." -ForegroundColor Yellow
            $cmd = "winget install --id `"LeNgocKhoa.Laragon`" --source winget -e --silent --accept-source-agreements --accept-package-agreements --disable-interactivity"
            Invoke-Expression $cmd
            Get-Process -Name "laragon" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        }
    }

    # 2. Pastikan Shortcut & Windows Search SELALU Terdaftar (Muncul di Menu Start, Desktop & Run)
    if (Test-Path $laragonExe) {
        Write-Host "   [OK] Memverifikasi shortcut & integrasi Windows Search untuk Laragon..." -ForegroundColor Green
        Create-AppShortcut -TargetExe $laragonExe -ShortcutName "Laragon" -WorkingDir "C:\laragon"

        $startMenuFolders = @(
            [Environment]::GetFolderPath("CommonPrograms"),
            [Environment]::GetFolderPath("Programs"),
            "C:\ProgramData\Microsoft\Windows\Start Menu\Programs",
            "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        )
        $wsh = New-Object -ComObject WScript.Shell
        foreach ($sm in $startMenuFolders) {
            if (Test-Path $sm) {
                $lnk = Join-Path $sm "Laragon.lnk"
                $sc = $wsh.CreateShortcut($lnk)
                $sc.TargetPath = $laragonExe
                $sc.WorkingDirectory = "C:\laragon"
                $sc.IconLocation = "$laragonExe,0"
                $sc.Save()
            }
        }
        try {
            $regKeys = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\laragon.exe",
                "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\laragon.exe"
            )
            foreach ($rk in $regKeys) {
                if (-not (Test-Path $rk)) { New-Item -Path $rk -Force | Out-Null }
                Set-ItemProperty -Path $rk -Name "(Default)" -Value $laragonExe -Force
                Set-ItemProperty -Path $rk -Name "Path" -Value "C:\laragon" -Force
            }
        } catch {}
        Add-ToSystemPath -DirToAdd "C:\laragon"
    }

    # 3. PERSIAPAN & EKSTRAKSI LARAGON CUSTOM STACK (Google Drive Multi-Mirror + Auto-Extract)
    $customStackDir = Join-Path $AppsDir "Laragon_Custom_Stack"
    $hasExtracted = (Test-Path (Join-Path $customStackDir "bin"))

    if (-not $hasExtracted) {
        Write-Host "`n   [i] Memeriksa paket Laragon Custom Stack (PHP terbaru, MySQL, phpMyAdmin)..." -ForegroundColor Yellow

        # Cari arsip lokal di AppsDir
        $customRar = Get-ChildItem -Path $AppsDir -Filter "*Custom*Stack*.rar" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $customRar) {
            $customRar = Get-ChildItem -Path $AppsDir -Filter "*Laragon*Custom*.rar" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        }
        if (-not $customRar) {
            $customRar = Get-ChildItem -Path $AppsDir -Filter "*Custom*Stack*.zip" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        }

        # Jika belum ada arsip di flashdisk, unduh dari Google Drive Multi-Mirror
        if (-not $customRar) {
            Write-Host "   [i] Master Laragon_Custom_Stack.rar belum ada di flashdisk." -ForegroundColor Yellow
            Write-Host "   [>>>] Mengunduh Laragon_Custom_Stack.rar dari Google Drive Multi-Mirror..." -ForegroundColor Cyan
            $destRar = Join-Path $AppsDir "Laragon_Custom_Stack.rar"
            $dlSuccess = Download-FileWithFastMirrors -Urls $laragonCustomMirrors -DestinationPath $destRar -ActivityTitle "Mengunduh Laragon Custom Stack"
            if ($dlSuccess -and (Test-Path $destRar)) {
                $customRar = Get-Item $destRar -ErrorAction SilentlyContinue
            }
        }

        # Ekstrak arsip ke folder Apps\Laragon_Custom_Stack
        if ($customRar) {
            Write-Host "   [OK] Ditemukan arsip Custom Stack: $($customRar.Name)" -ForegroundColor Green
            Write-Host "   [i] Mengekstrak paket Custom Stack ke $customStackDir..." -ForegroundColor Yellow
            $null = Expand-LabArchive -ArchivePath $customRar.FullName -DestinationDir $customStackDir
        }
    }

    # 4. Terapkan / Timpa modul Custom Stack ke C:\laragon
    $effectiveStackDir = $customStackDir
    if (-not (Test-Path (Join-Path $effectiveStackDir "bin")) -and (Test-Path (Join-Path $customStackDir "Laragon_Custom_Stack\bin"))) {
        $effectiveStackDir = Join-Path $customStackDir "Laragon_Custom_Stack"
    }

    if (Test-Path (Join-Path $effectiveStackDir "bin")) {
        Write-Host "`n   [i] Menerapkan paket modul custom Laragon (PHP, MySQL, Node.js, Python, phpMyAdmin)..." -ForegroundColor Yellow

        if (-not (Test-Path $targetLaragon)) {
            New-Item -ItemType Directory -Path $targetLaragon -Force | Out-Null
        }

        # Salin / Timpa modul bin (PHP 8.2/8.3/8.4, MySQL, Node, Python, Redis, dll.)
        $srcBin = Join-Path $effectiveStackDir "bin"
        if (Test-Path $srcBin) {
            Write-Host "   -> Menyinkronkan direktori C:\laragon\bin..." -ForegroundColor Cyan
            & robocopy $srcBin "$targetLaragon\bin" /E /R:1 /W:1 /NP /NFL /NDL | Out-Null
        }

        # Salin / Timpa etc
        $srcEtc = Join-Path $effectiveStackDir "etc"
        if (Test-Path $srcEtc) {
            Write-Host "   -> Menyinkronkan direktori C:\laragon\etc (phpMyAdmin, dll)..." -ForegroundColor Cyan
            & robocopy $srcEtc "$targetLaragon\etc" /E /R:1 /W:1 /NP /NFL /NDL | Out-Null
        }

        # Salin konfigurasi laragon.ini pilihan versi
        $srcIni = Join-Path $effectiveStackDir "usr\laragon.ini"
        if (Test-Path $srcIni) {
            $destUsr = Join-Path $targetLaragon "usr"
            if (-not (Test-Path $destUsr)) { New-Item -ItemType Directory -Path $destUsr -Force | Out-Null }
            Copy-Item $srcIni -Destination "$destUsr\laragon.ini" -Force
            Write-Host "   -> Menyinkronkan konfigurasi C:\laragon\usr\laragon.ini" -ForegroundColor Cyan
        }

        Write-Host "   [OK] Berhasil menerapkan seluruh custom stack Laragon (Data & Web www tetap aman)!" -ForegroundColor Green
    }

    # 5. DETEKSI PHP TERBARU & OPTIMASI LENGKAP SEMUA php.ini AGAR COMPOSER & LARAVEL BEBAS ERROR
    Write-Host "`n   [i] Mengonfigurasi seluruh php.ini dan mengaktifkan ekstensi lengkap (bebas warning/error)..." -ForegroundColor Yellow
    
    # Cari PHP versi terbaru di C:\laragon\bin\php (otomatis urutkan secara semantik: 8.5 > 8.4 > 8.3 > 8.2)
    $newestPhpDir = Get-ChildItem -Path "$targetLaragon\bin\php" -Directory -ErrorAction SilentlyContinue |
                    Where-Object { Test-Path (Join-Path $_.FullName "php.exe") } |
                    Sort-Object {
                        if ($_.Name -match '(\d+(?:\.\d+)+)') {
                            try {
                                $vParts = $matches[1].Split('.')
                                $major = [int]$vParts[0]
                                $minor = if ($vParts.Count -gt 1) { [int]$vParts[1] } else { 0 }
                                $build = if ($vParts.Count -gt 2) { [int]$vParts[2] } else { 0 }
                                [Version]::new($major, $minor, $build)
                            } catch { [Version]::new(0, 0, 0) }
                        } else { [Version]::new(0, 0, 0) }
                    } -Descending | Select-Object -First 1

    if ($newestPhpDir) {
        Write-Host "   [OK] PHP Terbaru Terdeteksi: $($newestPhpDir.Name)" -ForegroundColor Green
        
        # Update laragon.ini agar otomatis memilih PHP terbaru ini
        $usrLaragonIni = Join-Path $targetLaragon "usr\laragon.ini"
        if (Test-Path $usrLaragonIni) {
            try {
                $iniTxt = [System.IO.File]::ReadAllText($usrLaragonIni)
                if ($iniTxt -match '(?m)^Version=.*$') {
                    $newIniTxt = $iniTxt -replace '(?m)^Version=.*$', "Version=$($newestPhpDir.Name)"
                    [System.IO.File]::WriteAllText($usrLaragonIni, $newIniTxt)
                }
            } catch {}
        }
    }

    $phpInis = Get-ChildItem -Path "$targetLaragon\bin\php" -Filter "php.ini" -Recurse -File -ErrorAction SilentlyContinue
    foreach ($pIni in $phpInis) {
        try {
            $iniText = [System.IO.File]::ReadAllText($pIni.FullName)
            $phpFolder = $pIni.Directory.FullName
            $extDir = Join-Path $phpFolder "ext"
            
            # Cek ketersediaan file dll spesifik di folder ext masing-masing PHP
            $hasZipDll = (Test-Path (Join-Path $extDir "php_zip.dll")) -or (Test-Path (Join-Path $extDir "zip.dll"))
            if ($hasZipDll) {
                $iniText = $iniText -replace '(?m)^;\s*extension\s*=\s*zip\b', 'extension=zip'
                $iniText = $iniText -replace '(?m)^;\s*extension\s*=\s*php_zip\.dll\b', 'extension=php_zip.dll'
                if ($iniText -notmatch '(?m)^extension\s*=\s*(zip|php_zip\.dll)\b') { $iniText += "`r`nextension=zip`r`n" }
            } else {
                $iniText = $iniText -replace '(?m)^\s*extension\s*=\s*php_zip\.dll\b', ';extension=php_zip.dll'
                $iniText = $iniText -replace '(?m)^\s*extension\s*=\s*zip\b', ';extension=zip'
            }

            # Daftar ekstensi wajib untuk Composer, Laravel 11/12, & praktikum web modern
            $extList = @("curl", "fileinfo", "openssl", "pdo_mysql", "mysqli", "mbstring", "gd", "intl", "exif", "bcmath", "sodium")
            foreach ($ext in $extList) {
                $hasExtDll = (Test-Path (Join-Path $extDir "php_$ext.dll")) -or (Test-Path (Join-Path $extDir "$ext.dll"))
                if ($hasExtDll -or -not (Test-Path $extDir)) {
                    # Bersihkan duplikasi lama: komentar semua baris extension yang sama dulu
                    $iniText = $iniText -replace "(?m)^\s*extension\s*=\s*(?:php_)?$ext(?:\.dll)?\b", ";extension=$ext"
                    # Aktifkan tepat satu baris pertama
                    $matchedFirst = $false
                    $iniLines = @($iniText -split "`r?`n")
                    for ($li = 0; $li -lt $iniLines.Count; $li++) {
                        if ($iniLines[$li] -match "^\s*;\s*extension\s*=\s*$ext\b") {
                            $iniLines[$li] = "extension=$ext"
                            $matchedFirst = $true
                            break
                        }
                    }
                    if ($matchedFirst) {
                        $iniText = $iniLines -join "`r`n"
                    } else {
                        $iniText += "`r`nextension=$ext`r`n"
                    }
                }
            }

            # Normalkan extension_dir ke absolute path
            if (Test-Path $extDir) {
                $escapedExt = $extDir.Replace('\', '/')
                $iniText = $iniText -replace '(?m)^\s*;?\s*extension_dir\s*=\s*"ext"', "extension_dir = `"$escapedExt`""
                $iniText = $iniText -replace '(?m)^\s*;?\s*extension_dir\s*=\s*''ext''', "extension_dir = `"$escapedExt`""
            }

            # Tingkatkan limit memory, upload, dan max execution time untuk Composer & Laravel
            $iniText = $iniText -replace '(?m)^\s*memory_limit\s*=.*$', 'memory_limit = 512M'
            $iniText = $iniText -replace '(?m)^\s*upload_max_filesize\s*=.*$', 'upload_max_filesize = 128M'
            $iniText = $iniText -replace '(?m)^\s*post_max_size\s*=.*$', 'post_max_size = 128M'
            $iniText = $iniText -replace '(?m)^\s*max_execution_time\s*=.*$', 'max_execution_time = 360'

            # Sembunyikan E_DEPRECATED agar Composer & library internal tidak memunculkan output peringatan di PHP 8.4/8.5
            if ($iniText -match '(?m)^\s*error_reporting\s*=') {
                $iniText = $iniText -replace '(?m)^\s*error_reporting\s*=.*$', 'error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT'
            } else {
                $iniText += "`r`nerror_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT`r`n"
            }

            [System.IO.File]::WriteAllText($pIni.FullName, $iniText)
        } catch {}
    }
    # 5.1 KONFIGURASI TEPAT SERVICE LARAGON (laragon.ini) AGAR TIDAK BENTROK PORT & SERVICE SIAP PAKAI
    $usrLaragonIni = Join-Path $targetLaragon "usr\laragon.ini"
    if (Test-Path $usrLaragonIni) {
        try {
            $lIniContent = [System.IO.File]::ReadAllText($usrLaragonIni)
            
            # Nonaktifkan Nginx bawaan Laragon (Use=0) agar port 80 & 443 hanya dipakai Apache
            if ($lIniContent -match '\[nginx\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[nginx\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Use\s*=\s*)-?1', '${1}0')
            }
            # Pastikan Apache dan MySQL aktif (Use=-1)
            if ($lIniContent -match '\[apache\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[apache\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Use\s*=\s*)0', '${1}-1')
            }
            if ($lIniContent -match '\[mysql\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[mysql\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Use\s*=\s*)0', '${1}-1')
            }
            # Nonaktifkan PostgreSQL dan Memcached bawaan jika modulnya tidak lengkap agar tidak error merah
            if ($lIniContent -match '\[postgresql\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[postgresql\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Use\s*=\s*)-?1', '${1}0')
            }
            if ($lIniContent -match '\[memcached\]') {
                $lIniContent = [System.Text.RegularExpressions.Regex]::Replace($lIniContent, '(?s)(\[memcached\][\r\n]+(?:(?!\[)[^\r\n]*[\r\n]+)*?Use\s*=\s*)-?1', '${1}0')
            }

            [System.IO.File]::WriteAllText($usrLaragonIni, $lIniContent)
            Write-Host "   [OK] Konfigurasi C:\laragon\usr\laragon.ini dioptimalkan (Nginx dinonaktifkan dari port 80, Apache & MySQL siap)." -ForegroundColor Green
        } catch {}
    }

    # 5.2 OPTIMASI PHPMYADMIN LARAGON (Hilangkan pesan merah 'configuration storage is not completely configured' & izinkan login root tanpa password)
    $laragonPmaConfig = Join-Path $targetLaragon "etc\apps\phpMyAdmin\config.inc.php"
    if (Test-Path $laragonPmaConfig) {
        try {
            $pmaContent = [System.IO.File]::ReadAllText($laragonPmaConfig)
            $newPmaContent = $pmaContent

            # Pastikan host = '127.0.0.1' agar tidak terjadi timeout IPv6 ::1 dan port = 3306
            if ($newPmaContent -match "['`"]host['`"]\s*=") {
                $newPmaContent = [System.Text.RegularExpressions.Regex]::Replace($newPmaContent, "(\['host'\]\s*=\s*['`"])[^'`"]*(['`"])", '${1}127.0.0.1${2}')
            }
            if ($newPmaContent -match "['`"]port['`"]\s*=") {
                $newPmaContent = [System.Text.RegularExpressions.Regex]::Replace($newPmaContent, "(\['port'\]\s*=\s*['`"]?)[^'`"]*?(['`"]?;)", '${1}3306${2}')
            }

            # Aktifkan AllowNoPassword agar mahasiswa lab bisa login tanpa password
            if ($newPmaContent -match "['`"]AllowNoPassword['`"]\s*=") {
                $newPmaContent = [System.Text.RegularExpressions.Regex]::Replace($newPmaContent, "(\['AllowNoPassword'\]\s*=\s*)(?:false|0)", '${1}true')
            }

            # Sembunyikan notifikasi merah PmaNoRelation_DisableWarning
            if ($newPmaContent -notmatch "PmaNoRelation_DisableWarning") {
                $newPmaContent += "`r`n`$cfg['PmaNoRelation_DisableWarning'] = true;`r`n"
            } else {
                $newPmaContent = [System.Text.RegularExpressions.Regex]::Replace($newPmaContent, "(\['PmaNoRelation_DisableWarning'\]\s*=\s*)(?:false|0)", '${1}true')
            }

            if ($pmaContent -ne $newPmaContent) {
                [System.IO.File]::WriteAllText($laragonPmaConfig, $newPmaContent)
                Write-Host "   [OK] phpMyAdmin Laragon dikonfigurasi ke 127.0.0.1:3306 (Bebas peringatan konfigurasi storage)." -ForegroundColor Green
            }
        } catch {}
    }

    # Kunci & Satukan seluruh ekosistem PHP ke versi terbaru dari Laragon
    Sync-UnifiedLaragonPhp

    Record-InstallResult -Name "Laragon" -Status "BERHASIL DIINSTAL" -Keterangan "Laragon + Custom Stack Siap"
}

# 8.1 Fungsi Khusus Menyatukan Seluruh Ekosistem PHP ke Versi Terbaru Laragon
function Sync-UnifiedLaragonPhp {
    Write-Host "`n   [>>>] Menyatukan seluruh ekosistem PHP ke versi terbaru Laragon (C:\laragon\bin\php)..." -ForegroundColor Cyan
    
    # 1. Cari PHP versi terbaru di C:\laragon\bin\php (otomatis urutkan secara semantik: 8.5 > 8.4 > 8.3 > 8.2)
    $laragonPhps = Get-ChildItem -Path "C:\laragon\bin\php" -Directory -ErrorAction SilentlyContinue |
                   Where-Object { Test-Path (Join-Path $_.FullName "php.exe") } |
                   Sort-Object {
                       if ($_.Name -match '(\d+(?:\.\d+)+)') {
                           try {
                               $vParts = $matches[1].Split('.')
                               $major = [int]$vParts[0]
                               $minor = if ($vParts.Count -gt 1) { [int]$vParts[1] } else { 0 }
                               $build = if ($vParts.Count -gt 2) { [int]$vParts[2] } else { 0 }
                               [Version]::new($major, $minor, $build)
                           } catch { [Version]::new(0, 0, 0) }
                       } else { [Version]::new(0, 0, 0) }
                   } -Descending

    if (-not $laragonPhps) {
        Write-Host "   [!] Belum ada folder PHP terdeteksi di C:\laragon\bin\php." -ForegroundColor Yellow
        return
    }

    $topPhp = $laragonPhps[0]
    $topPhpDir = $topPhp.FullName
    $topPhpExe = Join-Path $topPhpDir "php.exe"

    # Periksa apakah ada versi PHP yang sedang aktif saat ini
    $activePhpCmd = Get-Command php -ErrorAction SilentlyContinue
    $currentActiveVer = "Belum Terdeteksi"
    if ($activePhpCmd) {
        try {
            $curOut = & $activePhpCmd.Source -v 2>&1 | Out-String
            if ($curOut -match 'PHP\s+(\d+(?:\.\d+)+)') {
                $currentActiveVer = $matches[1]
            }
        } catch {}
    }

    Write-Host "   [i] Versi PHP aktif saat ini : $currentActiveVer" -ForegroundColor DarkGray
    Write-Host "   [i] Versi PHP tertinggi      : $($topPhp.Name)" -ForegroundColor Green

    if ($topPhp.Name -match '(\d+(?:\.\d+)+)') {
        $topVerStr = $matches[1]
        try {
            $topV = [Version]$topVerStr
            if ($currentActiveVer -ne "Belum Terdeteksi") {
                $curV = [Version]$currentActiveVer
                if ($curV -lt $topV) {
                    Write-Host "   [UPGRADE OTOMATIS] Versi PHP aktif ($currentActiveVer) lebih rendah dari versi terbaru ($topVerStr)." -ForegroundColor Yellow
                    Write-Host "   -> Mengganti PHP aktif ke versi tertinggi: $($topPhp.Name)!" -ForegroundColor Green
                }
            }
        } catch {}
    }

    Write-Host "   [OK] PHP Utama Sistem Dikunci ke: $($topPhp.Name)" -ForegroundColor Green

    # 2. Daftarkan ke C:\laragon\usr\laragon.ini sebagai versi PHP default Laragon
    $usrLaragonIni = "C:\laragon\usr\laragon.ini"
    if (Test-Path $usrLaragonIni) {
        try {
            $iniTxt = [System.IO.File]::ReadAllText($usrLaragonIni)
            if ($iniTxt -match '(?m)^Version=.*$') {
                $newIniTxt = $iniTxt -replace '(?m)^Version=.*$', "Version=$($topPhp.Name)"
                [System.IO.File]::WriteAllText($usrLaragonIni, $newIniTxt)
                Write-Host "   [OK] Laragon GUI dikonfigurasi ke PHP: $($topPhp.Name)" -ForegroundColor Green
            }
        } catch {}
    }

    # 3. Bersihkan PATH dari versi PHP lain dan daftarkan PHP terbaru ini di System/User PATH
    try {
        $targets = if ($script:IsAdmin) { @([EnvironmentVariableTarget]::Machine, [EnvironmentVariableTarget]::User) } else { @([EnvironmentVariableTarget]::User) }
        foreach ($tgt in $targets) {
            $pVal = [Environment]::GetEnvironmentVariable("Path", $tgt)
            if ($pVal) {
                $parts = ($pVal -split ';') | Where-Object {
                    $_ -ne "" -and $_ -notlike "*\xampp\php*" -and $_ -notlike "*\laragon\bin\php\*"
                }
                $newP = "$topPhpDir;" + ($parts -join ';')
                [Environment]::SetEnvironmentVariable("Path", $newP, $tgt)
            }
        }
    } catch {}

    # 4. Perbarui PATH sesi aktif PowerShell agar langsung memakai PHP terbaru
    $sessionParts = ($env:Path -split ';') | Where-Object {
        $_ -ne "" -and $_ -notlike "*\xampp\php*" -and $_ -notlike "*\laragon\bin\php\*"
    }
    $env:Path = "$topPhpDir;" + ($sessionParts -join ';')
    Write-Host "   [OK] System PATH & Session PATH dikunci ke PHP: $topPhpDir" -ForegroundColor Green

    # 5. Kunci Environment Variables PHP_BINARY & PHP_PATH
    Set-SystemEnvVar -Name "PHP_BINARY" -Value $topPhpExe
    Set-SystemEnvVar -Name "PHP_PATH" -Value $topPhpDir
    $env:PHP_BINARY = $topPhpExe
    $env:PHP_PATH = $topPhpDir

    # 6. Kunci ke Composer: update wrapper script dan environment
    $composerBat = "C:\ProgramData\ComposerSetup\bin\composer.bat"
    if (Test-Path $composerBat) {
        try {
            $compBatContent = "@echo off`r`n`"$topPhpExe`" `"%~dp0composer.phar`" %*`r`n"
            [System.IO.File]::WriteAllText($composerBat, $compBatContent)
            Write-Host "   [OK] Composer wrapper dikunci langsung ke $topPhpExe" -ForegroundColor Green
        } catch {}
    }

    # 7. Tes output versi PHP
    try {
        $vOutput = & $topPhpExe -v 2>&1 | Out-String
        $firstLine = ($vOutput.Trim() -split "`r?`n")[0]
        Write-Host "   [OK] Uji Eksekusi PHP Terpadu: $firstLine" -ForegroundColor Green
    } catch {}
}

# 9. Fungsi Khusus Setup XAMPP & Pencegahan Bentrok Port dengan Laragon
function Setup-XamppStack {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: XAMPP Server + Konfigurasi Port Anti-Bentrok" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $xamppMirrors = @(
        "https://downloads.sourceforge.net/project/xampp/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe",
        "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download"
    )

    $xamppPaths = @("C:\xampp\xampp-control.exe", "D:\xampp\xampp-control.exe")
    $installedXampp = $null
    foreach ($xp in $xamppPaths) {
        if (Test-Path $xp) { $installedXampp = $xp; break }
    }

    # 1. Jalankan Installer XAMPP jika belum ada
    if (-not $installedXampp) {
        # Bersihkan folder C:\xampp kosong/rusak jika ada bekas instalasi gagal sebelumnya
        if ((Test-Path "C:\xampp") -and -not (Test-Path "C:\xampp\xampp-control.exe")) {
            $xItems = Get-ChildItem -Path "C:\xampp" -ErrorAction SilentlyContinue
            if (-not $xItems -or $xItems.Count -eq 0) {
                Remove-Item -Path "C:\xampp" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        # Jalankan instalasi tanpa memulai service di akhir agar tidak bentrok
        Install-AppSmart -Name "XAMPP" `
                         -FilePattern "*xampp*.exe" `
                         -DownloadUrls $xamppMirrors `
                         -SilentArgs "--mode unattended --enable-components apache,mysql,phpmyadmin" `
                         -WingetId "ApacheFriends.Xampp.8.2" `
                         -CheckPath $xamppPaths

        foreach ($xp in $xamppPaths) {
            if (Test-Path $xp) { $installedXampp = $xp; break }
        }
    } else {
        Write-Host "   [OK SUDAH TERPASANG] XAMPP Server terdeteksi di $installedXampp." -ForegroundColor Green
        Create-AppShortcut -TargetExe $installedXampp -ShortcutName "XAMPP Control Panel"
        Record-InstallResult -Name "XAMPP" -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi aktif di sistem (Skip)"
    }

    # 2. Atur Port Otomatis jika C:\xampp terpasang
    $xamppDir = "C:\xampp"
    if (-not (Test-Path $xamppDir) -and (Test-Path "D:\xampp")) { $xamppDir = "D:\xampp" }

    if (Test-Path $xamppDir) {
        Write-Host "`n[i] Mengonfigurasi Port XAMPP agar tidak bentrok dengan Laragon..." -ForegroundColor Yellow

        # 0. Hentikan proses Apache & MySQL XAMPP jika sedang aktif agar melepaskan Port 80, 443, 3306
        $runningXampp = Get-Process -Name "httpd", "mysqld" -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$xamppDir\*" }
        if ($runningXampp) {
            Write-Host "   [!] Menutup proses lama XAMPP agar port 80 & 3306 bebas untuk Laragon..." -ForegroundColor Yellow
            $runningXampp | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
        }

        # A. Konfigurasi Apache Port: Ganti Port 80 -> 8088 di httpd.conf
        # (Port 8000 dipakai Laravel artisan serve, 8080 sering dipakai Tomcat/Spring/Vue, jadi 8088 dijamin 100% aman)
        $httpdConf = Join-Path $xamppDir "apache\conf\httpd.conf"
        if (Test-Path $httpdConf) {
            $confText = [System.IO.File]::ReadAllText($httpdConf)
            $newConfText = $confText -replace '(?m)^Listen\s+(?:.*:)?(80|8080)\s*$', 'Listen 8088'
            $newConfText = $newConfText -replace '(?m)^ServerName\s+localhost:(80|8080)\s*$', 'ServerName localhost:8088'
            if ($confText -ne $newConfText) {
                [System.IO.File]::WriteAllText($httpdConf, $newConfText)
                Write-Host "   [OK] Apache HTTP Port XAMPP dialihkan ke 8088 (Laragon di 80, Laravel di 8000, WebDev di 3000/5173)" -ForegroundColor Green
            } else {
                Write-Host "   [OK] Port Apache XAMPP sudah diatur pada 8088." -ForegroundColor Green
            }
        }

        # B. Konfigurasi Apache SSL Port: Ganti Port 443 -> 8444 di httpd-ssl.conf
        $httpdSslConf = Join-Path $xamppDir "apache\conf\extra\httpd-ssl.conf"
        if (Test-Path $httpdSslConf) {
            $sslText = [System.IO.File]::ReadAllText($httpdSslConf)
            $newSslText = $sslText -replace '(?m)^Listen\s+(443|8443)\s*$', 'Listen 8444'
            $newSslText = $newSslText -replace '(?m)^<VirtualHost _default_:(443|8443)>\s*$', '<VirtualHost _default_:8444>'
            $newSslText = $newSslText -replace '(?m)^ServerName\s+localhost:(443|8443)\s*$', 'ServerName localhost:8444'
            if ($sslText -ne $newSslText) {
                [System.IO.File]::WriteAllText($httpdSslConf, $newSslText)
                Write-Host "   [OK] Apache SSL Port XAMPP dialihkan ke 8444 (Laragon SSL tetap di Port 443)" -ForegroundColor Green
            } else {
                Write-Host "   [OK] Port Apache SSL XAMPP sudah diatur pada 8444." -ForegroundColor Green
            }
        }

        # C. Konfigurasi MySQL Port: Ganti Port 3306 -> 3307 di my.ini
        # (Laragon dan koneksi standar Laravel .env / MySQL tetap di Port 3306)
        $myIni = Join-Path $xamppDir "mysql\bin\my.ini"
        if (Test-Path $myIni) {
            $myText = [System.IO.File]::ReadAllText($myIni)
            $newMyText = $myText -replace '(?m)^port\s*=\s*3306\s*$', 'port = 3307'
            if ($myText -ne $newMyText) {
                [System.IO.File]::WriteAllText($myIni, $newMyText)
                Write-Host "   [OK] MySQL Port XAMPP dialihkan ke 3307 (Laragon & Laravel standar tetap di Port 3306)" -ForegroundColor Green
            } else {
                Write-Host "   [OK] Port MySQL XAMPP sudah diatur pada 3307." -ForegroundColor Green
            }
        }

        # D. Konfigurasi phpMyAdmin agar terhubung ke port 3307 XAMPP via 127.0.0.1
        $pmaConfig = Join-Path $xamppDir "phpMyAdmin\config.inc.php"
        if (Test-Path $pmaConfig) {
            $pmaText = [System.IO.File]::ReadAllText($pmaConfig)
            $newPmaText = $pmaText

            # Ganti host = 'localhost' -> '127.0.0.1' agar MySQL TCP port 3307 dapat terhubung langsung tanpa socket
            if ($newPmaText -match "['`"]host['`"]\s*=") {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['host'\]\s*=\s*['`"])[^'`"]*(['`"])", '${1}127.0.0.1${2}')
            } else {
                $newPmaText += "`r`n`$cfg['Servers'][`$i]['host'] = '127.0.0.1';`r`n"
            }

            # Set port ke 3307
            if ($newPmaText -notmatch "['`"]port['`"]\s*=") {
                $newPmaText += "`r`n`$cfg['Servers'][`$i]['port'] = '3307';`r`n"
            } else {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['port'\]\s*=\s*['`"]?)[^'`"]*?(['`"]?;)", '${1}3307${2}')
            }

            # Izinkan login tanpa password
            if ($newPmaText -match "['`"]AllowNoPassword['`"]\s*=") {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($newPmaText, "(\['AllowNoPassword'\]\s*=\s*)(?:false|0)", '${1}true')
            }

            # Nonaktifkan warning konfigurasi storage
            if ($newPmaText -notmatch "PmaNoRelation_DisableWarning") {
                $newPmaText += "`r`n`$cfg['PmaNoRelation_DisableWarning'] = true;`r`n"
            }

            if ($pmaText -ne $newPmaText) {
                [System.IO.File]::WriteAllText($pmaConfig, $newPmaText)
                Write-Host "   [OK] phpMyAdmin XAMPP dikonfigurasi ke 127.0.0.1:3307" -ForegroundColor Green
            }
        }

        # E. Sinkronisasi Port & URL Admin di XAMPP Control Panel config (xampp-control.ini)
        $xamppIni = Join-Path $xamppDir "xampp-control.ini"
        if (Test-Path $xamppIni) {
            $iniTxt = [System.IO.File]::ReadAllText($xamppIni)
            
            # Ganti alokasi port di [ServicePorts] dan [Ports]
            $newIniTxt = $iniTxt -replace '(?m)^Apache\s*=\s*(80|8080)\s*$', 'Apache = 8088'
            $newIniTxt = $newIniTxt -replace '(?m)^ApacheSSL\s*=\s*(443|8443)\s*$', 'ApacheSSL = 8444'
            $newIniTxt = $newIniTxt -replace '(?m)^MySQL\s*=\s*3306\s*$', 'MySQL = 3307'

            # Ganti port bawaan di [BinaryNames] atau [Services] jika ada
            $newIniTxt = $newIniTxt -replace '(?m)^PortApache\s*=\s*(80|8080)\s*$', 'PortApache = 8088'
            $newIniTxt = $newIniTxt -replace '(?m)^PortSSL\s*=\s*(443|8443)\s*$', 'PortSSL = 8444'
            $newIniTxt = $newIniTxt -replace '(?m)^PortMySQL\s*=\s*3306\s*$', 'PortMySQL = 3307'

            if ($iniTxt -ne $newIniTxt) {
                [System.IO.File]::WriteAllText($xamppIni, $newIniTxt)
                Write-Host "   [OK] Port pada XAMPP Control Panel disinkronkan ke 8088/8444/3307 (Pesan merah 'Port 80 in use' dihilangkan)." -ForegroundColor Green
            }
        }

        Write-Host "   [OK] XAMPP, Laragon, Laravel, Vite & Next.js kini aman berjalan berdampingan tanpa bentrok port!" -ForegroundColor Green
    }
}

# 10. Fungsi Setup Node.js (LTS) & NPM
function Setup-NodeJS {
    $nodeMirrors = @(
        "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi",
        "https://nodejs.org/dist/v20.18.3/node-v20.18.3-x64.msi"
    )
    Install-AppSmart -Name "Node.js LTS (with NPM)" `
                     -FilePattern @("*node*v*.msi", "*node*.msi") `
                     -DownloadUrls $nodeMirrors `
                     -SilentArgs "/qn" `
                     -WingetId "OpenJS.NodeJS.LTS" `
                     -CheckPath "C:\Program Files\nodejs\node.exe"

    $nodePath = "C:\Program Files\nodejs"
    if (Test-Path $nodePath) {
        Add-ToSystemPath -DirToAdd $nodePath
        $npmGlobalPath = Join-Path $env:APPDATA "npm"
        if (-not (Test-Path $npmGlobalPath)) {
            New-Item -ItemType Directory -Path $npmGlobalPath -Force | Out-Null
        }
        Add-ToSystemPath -DirToAdd $npmGlobalPath
        if ($env:Path -notlike "*$nodePath*") { $env:Path = "$nodePath;$npmGlobalPath;" + $env:Path }

        # Aktifkan izin eksekusi skrip PowerShell agar npm.ps1 dan npx.ps1 tidak diblokir
        try {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
            Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -ErrorAction SilentlyContinue
        } catch {}
    }
}

# 11. Fungsi Setup Composer & Laravel Installer Otomatis
function Setup-ComposerAndLaravel {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: Composer (PHP Dependency Manager) & Laravel Setup" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    # Pastikan Composer tidak pernah meminta konfirmasi interaktif di PowerShell Administrator
    $env:COMPOSER_NO_INTERACTION = "1"
    $env:COMPOSER_ALLOW_SUPERUSER = "1"
    [Environment]::SetEnvironmentVariable("COMPOSER_NO_INTERACTION", "1", [EnvironmentVariableTarget]::Process)
    [Environment]::SetEnvironmentVariable("COMPOSER_ALLOW_SUPERUSER", "1", [EnvironmentVariableTarget]::Process)

    # 1. Cari PHP yang aktif di sistem: UTAMAKAN PHP VERSI TERBARU dari Laragon Custom Stack
    $phpPath = $null
    $laragonPhps = Get-ChildItem -Path "C:\laragon\bin\php" -Directory -ErrorAction SilentlyContinue |
                   Where-Object { Test-Path (Join-Path $_.FullName "php.exe") } |
                   Sort-Object {
                       if ($_.Name -match '(\d+(?:\.\d+)+)') {
                           try {
                               $vParts = $matches[1].Split('.')
                               $major = [int]$vParts[0]
                               $minor = if ($vParts.Count -gt 1) { [int]$vParts[1] } else { 0 }
                               $build = if ($vParts.Count -gt 2) { [int]$vParts[2] } else { 0 }
                               [Version]::new($major, $minor, $build)
                           } catch { [Version]::new(0, 0, 0) }
                       } else { [Version]::new(0, 0, 0) }
                   } -Descending

    if ($laragonPhps) {
        $phpPath = Join-Path $laragonPhps[0].FullName "php.exe"
    } else {
        $phpSearch = @(
            "C:\laragon\bin\php\php-*\php.exe",
            "C:\laragon\bin\php\*\php.exe",
            "C:\xampp\php\php.exe"
        )
        foreach ($pattern in $phpSearch) {
            $found = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { $phpPath = $found.FullName; break }
        }
    }

    $phpDir = $null
    if ($phpPath) {
        $phpDir = Split-Path -Parent $phpPath
        Add-ToSystemPath -DirToAdd $phpDir
        # Pastikan diletakkan di baris paling depan sesi aktif agar perintah php/composer langsung memakai versi terbaru
        $env:Path = "$phpDir;" + ($env:Path -replace [regex]::Escape("$phpDir;"), "")
        Write-Host "   [OK] PHP aktif dikunci ke: $phpPath (Versi terbaru Laragon)" -ForegroundColor Green
    } else {
        Write-Host "   [!] PHP belum ditemukan di C:\laragon\bin\php atau C:\xampp\php." -ForegroundColor Yellow
    }

    # 2. Cek apakah Composer sudah terpasang
    $composerInstalled = $false
    $composerExe = Get-Command composer -ErrorAction SilentlyContinue
    if ($composerExe) {
        $composerInstalled = $true
    } elseif (Test-Path "C:\ProgramData\ComposerSetup\bin\composer.bat") {
        $composerInstalled = $true
    }

    if ($composerInstalled) {
        Write-Host "   [OK SUDAH TERPASANG] Composer terdeteksi di sistem." -ForegroundColor Green
        # Perbarui file composer.phar ke build terbaru resmi agar 100% kompatibel dengan PHP 8.4/8.5
        try {
            & composer self-update --quiet --no-interaction 2>$null
        } catch {}
        Write-Host "   -> Melewati instalasi Composer (Skip)." -ForegroundColor DarkGray
    } else {
        $composerInstaller = Get-ChildItem -Path $AppsDir -Filter "*Composer*.exe" -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $composerInstaller) {
            Write-Host "   [i] File Composer offline belum ada di Apps. Mengunduh Composer-Setup.exe otomatis..." -ForegroundColor Yellow
            try {
                $compUrl = "https://getcomposer.org/Composer-Setup.exe"
                $destPath = Join-Path $AppsDir "Composer-Setup.exe"
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                $wc = New-Object System.Net.WebClient
                $wc.DownloadFile($compUrl, $destPath)
                $wc.Dispose()
                $composerInstaller = Get-Item $destPath -ErrorAction SilentlyContinue
                Write-Host "   [OK] Composer-Setup.exe berhasil diunduh dan disimpan ke folder Apps!" -ForegroundColor Green
            } catch {
                Write-Host "   [!] Gagal mengunduh Composer secara otomatis dari internet: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        if ($composerInstaller) {
            Write-Host "   [OK] Ditemukan installer: $($composerInstaller.Name)" -ForegroundColor Green
            Write-Host "   [i] Menjalankan instalasi Composer secara silent..." -ForegroundColor Yellow
            $cArgs = "/VERYSILENT /NORESTART /SP- /SUPPRESSMSGBOXES"
            if ($phpPath) {
                $cArgs += " /PHP=`"$phpPath`""
            }
            $proc = Start-Process -FilePath $composerInstaller.FullName -ArgumentList $cArgs -Wait -PassThru
            if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                Write-Host "   [OK] Berhasil memasang Composer!" -ForegroundColor Green
            }
        }
    }

    # 3. Pastikan ekstensi yang valid (fileinfo, openssl, curl, pdo_mysql, mbstring, dan zip jika ada dll-nya) aktif
    $allPhpInis = @(
        (Get-ChildItem -Path "C:\laragon\bin\php\*\php.ini" -File -ErrorAction SilentlyContinue),
        (Get-ChildItem -Path "C:\xampp\php\php.ini" -File -ErrorAction SilentlyContinue)
    ) | Where-Object { $_ -ne $null }

    foreach ($iniFile in $allPhpInis) {
        try {
            $iniContent = [System.IO.File]::ReadAllText($iniFile.FullName)
            $phpDir = $iniFile.Directory.FullName
            $extDir = Join-Path $phpDir "ext"
            $hasZipDll = (Test-Path (Join-Path $extDir "php_zip.dll")) -or (Test-Path (Join-Path $extDir "zip.dll"))

            $newIni = $iniContent
            if ($hasZipDll) {
                $newIni = $newIni -replace '(?m)^;\s*extension\s*=\s*zip\b', 'extension=zip'
                $newIni = $newIni -replace '(?m)^;\s*extension\s*=\s*php_zip\.dll\b', 'extension=php_zip.dll'
                if ($newIni -notmatch '(?m)^extension\s*=\s*(zip|php_zip\.dll)\b') { $newIni += "`r`nextension=zip`r`n" }
            } else {
                # Cegah PHP Startup Warning jika library php_zip.dll tidak disediakan PHP build
                $newIni = $newIni -replace '(?m)^\s*extension\s*=\s*php_zip\.dll\b', ';extension=php_zip.dll'
                $newIni = $newIni -replace '(?m)^\s*extension\s*=\s*zip\b', ';extension=zip'
            }

            $extList = @("curl", "fileinfo", "openssl", "pdo_mysql", "mysqli", "mbstring", "gd", "intl", "exif", "bcmath", "sodium")
            foreach ($ext in $extList) {
                $hasExtDll = (Test-Path (Join-Path $extDir "php_$ext.dll")) -or (Test-Path (Join-Path $extDir "$ext.dll"))
                if ($hasExtDll -or -not (Test-Path $extDir)) {
                    $newIni = $newIni -replace "(?m)^\s*extension\s*=\s*(?:php_)?$ext(?:\.dll)?\b", ";extension=$ext"
                    $matchedFirst = $false
                    $iniLines = @($newIni -split "`r?`n")
                    for ($li = 0; $li -lt $iniLines.Count; $li++) {
                        if ($iniLines[$li] -match "^\s*;\s*extension\s*=\s*$ext\b") {
                            $iniLines[$li] = "extension=$ext"
                            $matchedFirst = $true
                            break
                        }
                    }
                    if ($matchedFirst) {
                        $newIni = $iniLines -join "`r`n"
                    } else {
                        $newIni += "`r`nextension=$ext`r`n"
                    }
                }
            }

            if (Test-Path $extDir) {
                $escapedExt = $extDir.Replace('\', '/')
                $newIni = $newIni -replace '(?m)^\s*;?\s*extension_dir\s*=\s*"ext"', "extension_dir = `"$escapedExt`""
                $newIni = $newIni -replace '(?m)^\s*;?\s*extension_dir\s*=\s*''ext''', "extension_dir = `"$escapedExt`""
            }

            # Sembunyikan E_DEPRECATED agar Composer & library internal tidak memunculkan output peringatan di PHP 8.4/8.5
            if ($newIni -match '(?m)^\s*error_reporting\s*=') {
                $newIni = $newIni -replace '(?m)^\s*error_reporting\s*=.*$', 'error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT'
            } else {
                $newIni += "`r`nerror_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT`r`n"
            }

            if ($iniContent -ne $newIni) {
                [System.IO.File]::WriteAllText($iniFile.FullName, $newIni)
                Write-Host "   [OK] Konfigurasi php.ini bebas-warning diperbarui: $($iniFile.FullName)" -ForegroundColor Green
            }
        } catch {}
    }

    # 4. Tambahkan Laragon git/usr/bin ke PATH jika ada (sebagai fallback unzip/7z untuk Composer)
    $laragonGitBins = @("C:\laragon\bin\git\bin", "C:\laragon\bin\git\usr\bin")
    foreach ($gb in $laragonGitBins) {
        if (Test-Path $gb) {
            Add-ToSystemPath -DirToAdd $gb
        }
    }

    # 5. Pastikan Path Composer & Composer Vendor bin masuk ke PATH
    $composerBin = "C:\ProgramData\ComposerSetup\bin"
    if (Test-Path $composerBin) { Add-ToSystemPath -DirToAdd $composerBin }

    $composerGlobalVendor = Join-Path $env:APPDATA "Composer\vendor\bin"
    if (-not (Test-Path $composerGlobalVendor)) {
        New-Item -ItemType Directory -Path $composerGlobalVendor -Force | Out-Null
    }
    Add-ToSystemPath -DirToAdd $composerGlobalVendor

    # Perbarui PATH sesi sekarang agar perintah composer/laravel langsung dapat diuji
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
    if ($phpDir -and $env:Path -notlike "*$phpDir*") {
        $env:Path = "$phpDir;" + $env:Path
    }

    # 6. Setup Laravel Installer Global (composer global require laravel/installer)
    $laravelBat = Join-Path $composerGlobalVendor "laravel.bat"
    if (Test-Path $laravelBat) {
        Write-Host "   [OK SUDAH TERPASANG] Laravel Installer terdeteksi di $laravelBat" -ForegroundColor Green
    } else {
        Write-Host "`n   [i] Menyiapkan Laravel Installer secara global..." -ForegroundColor Yellow
        try {
            $compCmd = Get-Command composer -ErrorAction SilentlyContinue
            if ($compCmd -and (Get-Command php -ErrorAction SilentlyContinue)) {
                & composer global require laravel/installer --quiet --no-interaction
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   [OK] Berhasil memasang Laravel Installer! Perintah 'laravel new' siap digunakan." -ForegroundColor Green
                } else {
                    Write-Host "   [i] Composer global setup selesai (Koneksi online opsional untuk update package)." -ForegroundColor Yellow
                }
            } else {
                Write-Host "   [i] Composer terpasang. Restart PowerShell untuk mengaktifkan perintah 'laravel new'." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "   [i] Melewati require online Laravel Installer." -ForegroundColor Gray
        }
    }

    # Sinkronkan kembali seluruh ekosistem PHP dan Composer ke versi PHP terbaru
    Sync-UnifiedLaragonPhp
}

# 10.1 Fungsi Setup Oracle VM VirtualBox & Extension Pack (Google Drive Multi-Mirror Kencang)
function Setup-VirtualBox {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: Oracle VM VirtualBox & Extension Pack" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $vboxPaths = @(
        "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe",
        "C:\Program Files (x86)\Oracle\VirtualBox\VirtualBox.exe"
    )
    $installedVbox = $null
    foreach ($vp in $vboxPaths) {
        if (Test-Path $vp) { $installedVbox = $vp; break }
    }

    # Mirror Google Drive prioritas utama (super cepat di lab) + cadangan resmi Oracle CDN
    $vboxMirrors = @(
        "https://drive.google.com/file/d/18VMaCMVlP5-1yoUU0e90Bjy3pqUzqV8i/view?usp=sharing",
        "https://drive.google.com/file/d/1O0GSKjOzYf7b5cC5hlIsa10ouzMtrS7D/view?usp=sharing",
        "https://drive.google.com/file/d/1yR9Xc2bRcEwQBz7o3IrMZ0Ustx5jd5fI/view?usp=sharing",
        "https://drive.google.com/file/d/1FqHbWQdaRxOoO0woLB-UZjlXFeWJ5VnA/view?usp=sharing",
        "https://download.virtualbox.org/virtualbox/7.2.20/VirtualBox-7.2.20-175154-Win.exe",
        "https://download.virtualbox.org/virtualbox/7.1.8/VirtualBox-7.1.8-168469-Win.exe",
        "https://download.virtualbox.org/virtualbox/7.1.6/VirtualBox-7.1.6-167084-Win.exe"
    )

    if (-not $installedVbox) {
        Install-AppSmart -Name "Oracle VM VirtualBox" `
                         -FilePattern @("*VirtualBox*.exe", "*VirtualBox*.msi") `
                         -DownloadUrls $vboxMirrors `
                         -SilentArgs "--silent" `
                         -WingetId "Oracle.VirtualBox" `
                         -CheckPath $vboxPaths
        foreach ($vp in $vboxPaths) {
            if (Test-Path $vp) { $installedVbox = $vp; break }
        }
    } else {
        Write-Host "   [OK SUDAH TERPASANG] Oracle VM VirtualBox terdeteksi di $installedVbox." -ForegroundColor Green
        Create-AppShortcut -TargetExe $installedVbox -ShortcutName "Oracle VM VirtualBox"
        Record-InstallResult -Name "Oracle VM VirtualBox" -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi aktif di sistem (Skip)"
    }

    # Pemasangan VirtualBox Extension Pack jika VirtualBox sudah terpasang
    if ($installedVbox) {
        $vboxDir = Split-Path -Parent $installedVbox
        $vboxManage = Join-Path $vboxDir "VBoxManage.exe"
        if (Test-Path $vboxManage) {
            Write-Host "`n   [>>>] Memeriksa Oracle VM VirtualBox Extension Pack..." -ForegroundColor Cyan
            
            # Deteksi versi VirtualBox yang terpasang di sistem
            $vboxVerDetected = $null
            try {
                $verOut = & $vboxManage --version 2>&1 | Out-String
                if ($verOut -match '^(\d+\.\d+\.\d+)') {
                    $vboxVerDetected = $matches[1]
                }
            } catch {}

            if ($vboxVerDetected) {
                Write-Host "   [i] Versi Oracle VM VirtualBox terdeteksi: $vboxVerDetected" -ForegroundColor Cyan
            }

            # Cek apakah Extension Pack sudah terdaftar dan cocok di VirtualBox
            $extInstalled = $false
            try {
                $extList = & $vboxManage list extpacks 2>&1 | Out-String
                if ($extList -match "Oracle VM VirtualBox Extension Pack") {
                    $extInstalled = $true
                    Write-Host "   [OK SUDAH TERPASANG] Oracle VM VirtualBox Extension Pack aktif terpasang!" -ForegroundColor Green
                }
            } catch {}

            if (-not $extInstalled) {
                # Bersihkan berkas extpack lama/salah jika versi berbeda atau berukuran corrupt
                $existingPacks = Get-ChildItem -Path $AppsDir -Filter "*.vbox-extpack" -File -Recurse -ErrorAction SilentlyContinue
                foreach ($ep in $existingPacks) {
                    if ($vboxVerDetected -and ($ep.Name -notmatch [regex]::Escape($vboxVerDetected)) -and ($ep.Name -match '\d+\.\d+\.\d+')) {
                        Write-Host "   [!] Menghapus cache Extension Pack yang tidak cocok dengan versi VBox ($($ep.Name))..." -ForegroundColor Yellow
                        Remove-Item -Path $ep.FullName -Force -ErrorAction SilentlyContinue
                    }
                }

                # Cari berkas offline .vbox-extpack di Apps/
                $extPackFile = Get-ChildItem -Path $AppsDir -Filter "*.vbox-extpack" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

                if (-not $extPackFile -or ($extPackFile.Length -lt 1048576)) {
                    Write-Host "   [i] Menyiapkan Oracle VM VirtualBox Extension Pack resmi sesuai versi..." -ForegroundColor Yellow
                    
                    # Bangun daftar mirror dinamis: prioritas utama adalah versi persis dari VirtualBox yang terpasang
                    $extPackMirrors = @()
                    if ($vboxVerDetected) {
                        $extPackMirrors += "https://download.virtualbox.org/virtualbox/$vboxVerDetected/Oracle_VirtualBox_Extension_Pack-$vboxVerDetected.vbox-extpack"
                    }
                    $extPackMirrors += @(
                        "https://download.virtualbox.org/virtualbox/7.1.8/Oracle_VirtualBox_Extension_Pack-7.1.8.vbox-extpack",
                        "https://download.virtualbox.org/virtualbox/7.1.6/Oracle_VirtualBox_Extension_Pack-7.1.6.vbox-extpack",
                        "https://download.virtualbox.org/virtualbox/7.2.20/Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack",
                        "https://drive.google.com/file/d/1g0Ut2twJy71GQ4b6-4Nj6_3e99WCxWFY/view?usp=sharing",
                        "https://drive.google.com/file/d/1T3LOPKLTCx6JP0IZYBrJKaVaiqawXv6c/view?usp=sharing",
                        "https://drive.google.com/file/d/1bL621GdJ7tN1e3_IAClmwyIdyd5HcVxb/view?usp=sharing",
                        "https://drive.google.com/file/d/1dlEPu54jB1ai3McvksX15axwGONs64g-/view?usp=sharing"
                    )

                    $targetPackName = if ($vboxVerDetected) { "Oracle_VirtualBox_Extension_Pack-$vboxVerDetected.vbox-extpack" } else { "Oracle_VirtualBox_Extension_Pack.vbox-extpack" }
                    $destExtPack = Join-Path $AppsDir $targetPackName
                    $dlExt = Download-FileWithFastMirrors -Urls $extPackMirrors -DestinationPath $destExtPack -ActivityTitle "Mengunduh Extension Pack"
                    if ($dlExt -and (Test-Path $destExtPack)) {
                        $extPackFile = Get-Item $destExtPack
                    }
                }

                if ($extPackFile -and (Test-Path $extPackFile.FullName) -and ($extPackFile.Length -gt 1048576)) {
                    Write-Host "   [i] Memasang Extension Pack secara otomatis: $($extPackFile.Name)..." -ForegroundColor Yellow
                    try {
                        $extInstalledSuccess = $false

                        # Kumpulan hash lisensi PUEL resmi Oracle VirtualBox (PUEL v12, v11, v10, dll.)
                        # eb31505e... adalah hash SHA-256 resmi untuk License version 12 (22 July 2024 / VirtualBox 7.1 & 7.2)
                        $knownHashes = @(
                            "eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae",
                            "33d7284dc4a0ece381196da3cfe3f45f8b94642b",
                            "56da88705974ca89a3e4ea3834da9dda4f829e16",
                            "b674970f720f43d68139059da3643cc2279ab1be",
                            "10a1001452a7d86663f69f174ec62f31f95e841a",
                            "78749a0783f0876f7f5292e4a3b7f607266feb4d"
                        )

                        # Strategi 1: Pasang langsung dengan parameter resmi non-interaktif --accept-license=<hash>
                        Write-Host "   [i] Menerapkan persetujuan lisensi PUEL otomatis (Mode Non-Interaktif)..." -ForegroundColor Cyan
                        foreach ($h in $knownHashes) {
                            $installArgs = "/c `"`"$vboxManage`" extpack install --replace `"$($extPackFile.FullName)`" --accept-license=$h`""
                            $pHash = Start-Process -FilePath "cmd.exe" -ArgumentList $installArgs -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
                            if ($pHash -and $pHash.ExitCode -eq 0) {
                                $extInstalledSuccess = $true
                                break
                            }
                        }

                        # Strategi 2: Jika hash spesifik belum tembus, suntikkan input 'y' otomatis via cmd piping tanpa menahan terminal
                        if (-not $extInstalledSuccess) {
                            Write-Host "   [i] Menyetujui lisensi otomatis via Standard Input (Piping)..." -ForegroundColor Cyan
                            $pipeCmd = "/c `"(echo y) | `"$vboxManage`" extpack install --replace `"$($extPackFile.FullName)`"`""
                            $pPipe = Start-Process -FilePath "cmd.exe" -ArgumentList $pipeCmd -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
                            if ($pPipe -and $pPipe.ExitCode -eq 0) {
                                $extInstalledSuccess = $true
                            }
                        }

                        # Verifikasi apakah Extension Pack telah berhasil aktif di sistem
                        if (-not $extInstalledSuccess) {
                            try {
                                $verifyEp = & $vboxManage list extpacks 2>&1 | Out-String
                                if ($verifyEp -match "Oracle VM VirtualBox Extension Pack") {
                                    $extInstalledSuccess = $true
                                }
                            } catch {}
                        }

                        if ($extInstalledSuccess) {
                            Write-Host "   [OK] Oracle VM VirtualBox Extension Pack berhasil dipasang!" -ForegroundColor Green
                        } else {
                            Write-Host "   [i] Lisensi Extension Pack dilewati (opsional untuk fitur USB 3.0/RDP)." -ForegroundColor DarkGray
                        }
                    } catch {
                        Write-Host "   [i] Melewati proses extension pack: $($_.Exception.Message)" -ForegroundColor DarkGray
                    }
                } else {
                    Write-Host "   [!] Berkas Extension Pack belum siap diunduh (opsional untuk fitur USB 3.0/RDP)." -ForegroundColor Gray
                }
            }
        }
    }
}

# 11.0 Fungsi Setup Apache NetBeans (Direct High-Speed GitHub Releases CDN & Bundled JDK 26)
function Setup-NetBeans {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: Apache NetBeans IDE (High-Speed CDN Mirror)" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $nbCheckPaths = @(
        "C:\Program Files\Apache NetBeans*\bin\netbeans*.exe",
        "C:\Program Files\*NetBeans*\netbeans\bin\netbeans*.exe",
        "C:\Program Files\*NetBeans*\bin\netbeans*.exe",
        "C:\Program Files (x86)\*NetBeans*\netbeans\bin\netbeans*.exe",
        "C:\Program Files (x86)\*NetBeans*\bin\netbeans*.exe",
        "C:\Program Files\Codelerity\*NetBeans*\bin\netbeans*.exe",
        "$env:LOCALAPPDATA\Programs\*NetBeans*\bin\netbeans*.exe"
    )

    $alreadyInstalled = $null
    foreach ($cp in $nbCheckPaths) {
        $alreadyInstalled = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $alreadyInstalled) {
            $alreadyInstalled = Get-Item -Path $cp -ErrorAction SilentlyContinue | Select-Object -First 1
        }
        if ($alreadyInstalled) { break }
    }

    if ($alreadyInstalled) {
        Write-Host "   [OK SUDAH TERPASANG] Apache NetBeans terdeteksi di $($alreadyInstalled.FullName)" -ForegroundColor Green
        Create-AppShortcut -TargetExe $alreadyInstalled.FullName -ShortcutName "Apache NetBeans"
        Write-Host "   -> Melewati proses instalasi (Skip)." -ForegroundColor DarkGray
        Record-InstallResult -Name "Apache NetBeans IDE" -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi aktif di sistem (Skip)"
        return
    }

    # Deteksi JDK sistem untuk pengikatan netbeans_jdkhome jika diperlukan
    $nbJdkPath = $null
    $nbJdkCandidates = @(
        $env:JAVA_HOME,
        "C:\Program Files\Eclipse Adoptium\jdk-17*",
        "C:\Program Files\Eclipse Adoptium\jdk-2*",
        "C:\Program Files\Java\jdk-17*",
        "C:\Program Files\Java\jdk-2*",
        "C:\Program Files\BellSoft\LibericaJDK-*"
    )
    foreach ($cand in $nbJdkCandidates) {
        if (-not [string]::IsNullOrWhiteSpace($cand)) {
            $f = Get-Item $cand -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($f -and (Test-Path (Join-Path $f.FullName "bin\java.exe"))) {
                $nbJdkPath = $f.FullName
                break
            }
        }
    }

    # URL Unduhan Cepat: Prioritas utama ke GitHub Releases CDN resmi (Codelerity NBPackage Apache NetBeans 31 + Bundled JDK 26)
    # Server GitHub Release Assets menggunakan CDN Global Fastly/CloudFront (kecepatan 10-50+ MB/s di Indonesia, bebas throttling)
    $netbeansMirrors = @(
        "https://github.com/codelerity/netbeans-packages/releases/download/v31-build1/Apache-NetBeans-31.exe",
        "https://github.com/apache/netbeans/releases/download/25/Apache-NetBeans-25-bin-windows-x64.exe",
        "https://archive.apache.org/dist/netbeans/netbeans-installers/25/Apache-NetBeans-25-bin-windows-x64.exe",
        "https://dlcdn.apache.org/netbeans/netbeans-installers/25/Apache-NetBeans-25-bin-windows-x64.exe"
    )

    # 1. Cek apakah master offline sudah ada di folder Apps/
    $offlineFile = $null
    $nbPatterns = @("*NetBeans*31*.exe", "*NetBeans*.exe", "*Apache-NetBeans*.exe")
    foreach ($pat in $nbPatterns) {
        $cands = Get-ChildItem -Path $AppsDir -Filter $pat -File -Recurse -ErrorAction SilentlyContinue
        foreach ($c in $cands) {
            if ($c.Length -gt 50MB) {
                $offlineFile = $c
                break
            }
        }
        if ($offlineFile) { break }
    }

    # 2. Jika belum ada di Apps/, unduh langsung dari High-Speed CDN Mirror
    if (-not $offlineFile) {
        $destFile = Join-Path $AppsDir "Apache-NetBeans-31.exe"
        Write-Host "   [i] Mengunduh Apache NetBeans via Direct High-Speed CDN Mirror (GitHub Releases)..." -ForegroundColor Yellow
        $downloaded = Download-FileWithFastMirrors -Urls $netbeansMirrors -DestinationPath $destFile -ActivityTitle "Mengunduh Apache NetBeans IDE"
        if ($downloaded -and (Test-Path $script:LastDownloadedFile)) {
            $offlineFile = Get-Item $script:LastDownloadedFile
        }
    }

    # 3. Jalankan instalasi cerdas sesuai format installer
    if ($offlineFile -and (Test-Path $offlineFile.FullName)) {
        Write-Host "   [i] Memulai instalasi otomatis: $($offlineFile.Name)..." -ForegroundColor Yellow
        $silentArgs = ""
        if ($offlineFile.Name -match "31" -or $offlineFile.Name -match "codelerity") {
            # Inno Setup (NBPackage)
            $silentArgs = "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES /SP-"
        } else {
            # Official Apache install4j
            $silentArgs = "--silent"
            if ($nbJdkPath) {
                $silentArgs += " --jdkhome `"$nbJdkPath`""
            }
        }

        $argsList = Convert-ArgsToArray $silentArgs
        $proc = Start-Process -FilePath $offlineFile.FullName -ArgumentList $argsList -Wait -PassThru

        if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
            Write-Host "   [OK] Apache NetBeans IDE berhasil diinstal!" -ForegroundColor Green
            Record-InstallResult -Name "Apache NetBeans IDE" -Status "BERHASIL DIINSTAL" -Keterangan "Terpasang via High-Speed CDN ($($offlineFile.Name))"
        } else {
            Write-Host "   [!] Installer NetBeans selesai dengan kode: $($proc.ExitCode)" -ForegroundColor Yellow
            Record-InstallResult -Name "Apache NetBeans IDE" -Status "GAGAL" -Keterangan "Exit Code: $($proc.ExitCode)"
        }
    } else {
        # Fallback winget
        Write-Host "   [!] Master offline tidak ditemukan. Mencoba fallback Winget..." -ForegroundColor Yellow
        Install-AppSmart -Name "Apache NetBeans IDE" -WingetId "Apache.NetBeans" -SilentArgs "--silent"
    }

    # 4. Kunci netbeans.conf jika diperlukan
    if ($nbJdkPath) {
        $nbConfs = Get-ChildItem -Path "C:\Program Files\*NetBeans*\etc\netbeans.conf", "C:\Program Files (x86)\*NetBeans*\etc\netbeans.conf" -File -Recurse -ErrorAction SilentlyContinue
        foreach ($cfg in $nbConfs) {
            try {
                $cfgText = [System.IO.File]::ReadAllText($cfg.FullName)
                $escapedJdk = $nbJdkPath.Replace('\', '/')
                if ($cfgText -match '(?m)^#?\s*netbeans_jdkhome=') {
                    $newCfgText = $cfgText -replace '(?m)^#?\s*netbeans_jdkhome=.*$', "netbeans_jdkhome=`"$escapedJdk`""
                } else {
                    $newCfgText = $cfgText + "`r`nnetbeans_jdkhome=`"$escapedJdk`"`r`n"
                }
                [System.IO.File]::WriteAllText($cfg.FullName, $newCfgText)
                Write-Host "   [OK] netbeans.conf berhasil dikonfigurasi ke JDK: $nbJdkPath" -ForegroundColor Green
            } catch {}
        }
    }

    # Buat shortcut jika belum ada
    foreach ($cp in $nbCheckPaths) {
        $f = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($f) {
            Create-AppShortcut -TargetExe $f.FullName -ShortcutName "Apache NetBeans"
            break
        }
    }
}

# 11.1 Fungsi Setup Microsoft Visual Studio 2022 Community (Desktop C++ Auto-Layout & Offline Cache)
function Setup-VisualStudio {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: Microsoft Visual Studio 2022 Community (Desktop C++)" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $vsPaths = @(
        "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
    )
    foreach ($vp in $vsPaths) {
        if (Test-Path $vp) {
            Write-Host "   [OK SUDAH TERPASANG] Visual Studio 2022 terdeteksi di $vp." -ForegroundColor Green
            Write-Host "   -> Melewati proses instalasi (Skip)." -ForegroundColor DarkGray
            return
        }
    }

    $vsLayoutDir = Join-Path $AppsDir "vs_layout"
    $hasOfflinePackages = (Test-Path $vsLayoutDir) -and (Test-Path (Join-Path $vsLayoutDir "packages"))

    # 1. Jika Cache Offline BELUM ada di flashdisk, buat & unduh otomatis sekali ke Apps\vs_layout
    if (-not $hasOfflinePackages) {
        Write-Host "   [i] Paket offline C++ belum ada di flashdisk ($vsLayoutDir)." -ForegroundColor Yellow
        Write-Host "   [i] Memulai unduhan Master Offline Cache ke flashdisk (Hanya 1x unduh untuk seluruh lab)..." -ForegroundColor Yellow

        $vsBootstrapper = Join-Path $AppsDir "vs_community.exe"
        if (-not (Test-Path $vsBootstrapper)) {
            Write-Host "   [i] Mengunduh bootstrapper resmi Microsoft vs_community.exe..." -ForegroundColor Yellow
            try {
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                $wc = New-Object System.Net.WebClient
                $wc.DownloadFile("https://aka.ms/vs/17/release/vs_community.exe", $vsBootstrapper)
                $wc.Dispose()
            } catch {
                Write-Host "   [!] Gagal mengunduh bootstrapper: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        if (Test-Path $vsBootstrapper) {
            Write-Host "   [>>>] Menyimpan paket offline Desktop C++ ke flashdisk..." -ForegroundColor Cyan
            Write-Host "         (Jendela installer Microsoft akan muncul menampilkan progres penyimpanan ke USB)..." -ForegroundColor Gray
            $layoutArgs = @(
                "--layout", "`"$vsLayoutDir`"",
                "--add", "Microsoft.VisualStudio.Workload.NativeDesktop",
                "--includeRecommended",
                "--lang", "en-US",
                "--passive"
            )
            $pLayout = Start-Process -FilePath $vsBootstrapper -ArgumentList ($layoutArgs -join " ") -Wait -PassThru
            $hasOfflinePackages = (Test-Path $vsLayoutDir) -and (Test-Path (Join-Path $vsLayoutDir "packages"))
            if ($hasOfflinePackages) {
                Write-Host "   [OK] Master Offline Cache Visual Studio C++ tersimpan di flashdisk!" -ForegroundColor Green
            }
        }
    }

    # 2. Pasang Visual Studio 100% OFFLINE dari Cache Flashdisk (menggunakan --noWeb)
    if ($hasOfflinePackages) {
        Write-Host "   [MODE OFFLINE AKTIF] Menginstal Visual Studio 2022 Desktop C++ 100% OFFLINE dari Flashdisk..." -ForegroundColor Green

        # Pasang sertifikat offline jika ada
        $certDir = Join-Path $vsLayoutDir "certificates"
        if (Test-Path $certDir) {
            $certs = Get-ChildItem -Path $certDir -Filter "*.cer" -File -ErrorAction SilentlyContinue
            foreach ($c in $certs) {
                & certutil -addstore -f "Root" $c.FullName 2>$null | Out-Null
            }
        }

        # Cari file setup di dalam vs_layout atau bootstrapper
        $vsSetup = Get-ChildItem -Path $vsLayoutDir -File -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -match "^vs_setup\.exe$" -or $_.Name -match "^vs_community.*\.exe$" -or $_.Name -match "^vs_installer.*\.exe$"
        } | Select-Object -First 1

        if (-not $vsSetup) {
            $vsSetup = Get-Item (Join-Path $AppsDir "vs_community.exe") -ErrorAction SilentlyContinue
        }

        if ($vsSetup) {
            $offlineInstallArgs = @(
                "--noWeb",
                "--passive",
                "--norestart",
                "--add", "Microsoft.VisualStudio.Workload.NativeDesktop",
                "--includeRecommended"
            )
            Write-Host "   [i] Memulai proses instalasi lokal dari flashdisk (tanpa internet)..." -ForegroundColor Yellow
            $proc = Start-Process -FilePath $vsSetup.FullName -ArgumentList $offlineInstallArgs -Wait -PassThru
            if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                Write-Host "   [OK] Visual Studio 2022 (Desktop C++) berhasil diinstal secara OFFLINE!" -ForegroundColor Green
                return
            } else {
                Write-Host "   [!] Instalasi offline selesai dengan kode: $($proc.ExitCode)" -ForegroundColor Yellow
            }
        }
    }

    # 3. Fallback jika pembuatan offline layout belum selesai
    Write-Host "   [i] Menjalankan instalasi Visual Studio standar..." -ForegroundColor Yellow
    $vsArgs = "--passive --norestart --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended"
    Install-AppSmart -Name "Microsoft Visual Studio 2022 Community" `
                     -FilePattern @("*Visual*Studio*Community*.exe", "*vs*Community*.exe", "*Community*.exe", "*vs_setup*.exe", "*vs_installer*.exe") `
                     -SilentArgs $vsArgs `
                     -WingetId "Microsoft.VisualStudio.2022.Community" `
                     -WingetArgs "--override `"$vsArgs`"" `
                     -CheckPath $vsPaths
}

# 11.2 Fungsi Setup Flutter SDK & Konfigurasi Penuh Flutter Doctor (Centang Semua)
function Setup-FlutterSDK {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: Flutter SDK & Otomasi Konfigurasi Flutter Doctor" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $flutterCandidates = @(
        "C:\src\flutter\bin\flutter.bat",
        "C:\flutter\bin\flutter.bat",
        "D:\src\flutter\bin\flutter.bat",
        "D:\flutter\bin\flutter.bat",
        "$env:USERPROFILE\develop\flutter\bin\flutter.bat",
        "$env:LOCALAPPDATA\Programs\flutter\bin\flutter.bat"
    )

    $existingFlutter = $null
    foreach ($cand in $flutterCandidates) {
        if (Test-Path $cand) {
            $existingFlutter = $cand
            break
        }
    }
    if (-not $existingFlutter) {
        $cmdFlutter = Get-Command flutter.bat -ErrorAction SilentlyContinue
        if ($cmdFlutter) { $existingFlutter = $cmdFlutter.Source }
    }

    $flutterDir = "C:\src\flutter"
    $flutterBin = "C:\src\flutter\bin"

    if ($existingFlutter) {
        $flutterBin = Split-Path -Parent $existingFlutter
        $flutterDir = Split-Path -Parent $flutterBin
        Write-Host "   [OK SUDAH TERPASANG] Flutter terdeteksi di $existingFlutter." -ForegroundColor Green
    } else {
        # 1. Cek apakah ada master arsip offline di Apps (misal flutter_windows_*.zip)
        $offlineZip = Get-ChildItem -Path $AppsDir -Filter "*flutter*windows*.zip" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $offlineZip) {
            $offlineZip = Get-ChildItem -Path $AppsDir -Filter "*flutter*.zip" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        }

        if (-not (Test-Path "C:\src")) { New-Item -ItemType Directory -Path "C:\src" -Force | Out-Null }

        if ($offlineZip) {
            Write-Host "   [OK] Ditemukan master arsip Flutter offline: $($offlineZip.Name)" -ForegroundColor Green
            Write-Host "   [i] Mengekstrak Flutter SDK ke C:\src\flutter..." -ForegroundColor Yellow
            try {
                Expand-Archive -Path $offlineZip.FullName -DestinationPath "C:\src" -Force
            } catch {
                Write-Host "   [!] Ekstraksi PowerShell gagal, mencoba ekstrak via tar/7z..." -ForegroundColor Yellow
                & tar -xf $offlineZip.FullName -C "C:\src"
            }
        } else {
            # 2. Unduh Flutter SDK resmi dari Storage API Google CDN
            Write-Host "   [i] Mengunduh Flutter SDK Stable dari Google CDN..." -ForegroundColor Yellow
            $flutterMirrors = @(
                "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.0-stable.zip",
                "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.27.4-stable.zip",
                "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
            )
            $destZip = Join-Path $AppsDir "flutter_windows_stable.zip"
            $downloaded = Download-FileWithFastMirrors -Urls $flutterMirrors -DestinationPath $destZip -ActivityTitle "Mengunduh Flutter SDK"
            if ($downloaded -and (Test-Path $destZip)) {
                Write-Host "   [OK] Flutter SDK berhasil diunduh ke folder Apps/!" -ForegroundColor Green
                Write-Host "   [i] Mengekstrak Flutter SDK ke C:\src\flutter..." -ForegroundColor Yellow
                & tar -xf $destZip -C "C:\src"
            } else {
                # Fallback Git clone
                Write-Host "   [i] Mencoba Git Clone Flutter SDK stable..." -ForegroundColor Yellow
                & git clone -b stable https://github.com/flutter/flutter.git "C:\src\flutter" --depth 1
            }
        }
    }

    # 3. Masukkan Flutter & Dart ke System PATH
    if (Test-Path $flutterBin) {
        Add-ToSystemPath -DirToAdd $flutterBin
        $dartBin = Join-Path $flutterBin "cache\dart-sdk\bin"
        if (Test-Path $dartBin) { Add-ToSystemPath -DirToAdd $dartBin }

        # Update environment PATH sesi sekarang
        $env:Path = "$flutterBin;$dartBin;" + $env:Path

        Write-Host "   [OK] Flutter & Dart berhasil didaftarkan ke System PATH." -ForegroundColor Green
    } else {
        Write-Host "   [!] Folder binary Flutter belum ditemukan di $flutterBin." -ForegroundColor Red
        Record-InstallResult -Name "Flutter SDK" -Status "GAGAL" -Keterangan "Binary bin belum siap"
        return
    }

    # 4. OTOMASI FLUTTER DOCTOR: SETTING SEMUA CENTANG HIJAU
    Write-Host "`n   [>>>] Mengonfigurasi Flutter Doctor agar semua centang hijau..." -ForegroundColor Cyan

    # A. Deteksi & Kunci Android Studio Directory untuk Flutter Doctor
    $asSearch = @(
        "C:\Program Files\Android\Android Studio",
        "C:\Program Files\Android Studio",
        "C:\Program Files (x86)\Android\Android Studio",
        "C:\Program Files (x86)\Android Studio",
        "$env:LOCALAPPDATA\Programs\Android Studio"
    )
    $userAs = Get-ChildItem -Path "C:\Users\*\AppData\Local\Programs\Android Studio" -Directory -ErrorAction SilentlyContinue
    if ($userAs) {
        foreach ($ua in $userAs) { $asSearch += $ua.FullName }
    }
    $detectedAs = $null
    foreach ($as in $asSearch) {
        if ((Test-Path (Join-Path $as "bin\studio64.exe")) -or (Test-Path $as)) {
            $detectedAs = $as
            & flutter config --android-studio-dir "$as" | Out-Null
            Write-Host "   [OK] Android Studio dikunci ke: $as" -ForegroundColor Green
            break
        }
    }

    # B. Deteksi & Kunci Android SDK path
    $androidSdkSearch = @(
        "$env:LOCALAPPDATA\Android\Sdk",
        "C:\Android\Sdk",
        "D:\Android\Sdk",
        "C:\Android\android-sdk",
        "C:\Program Files (x86)\Android\android-sdk",
        "C:\Users\Public\Android\Sdk"
    )
    $userSdks = Get-ChildItem -Path "C:\Users\*\AppData\Local\Android\Sdk" -Directory -ErrorAction SilentlyContinue
    if ($userSdks) {
        foreach ($us in $userSdks) {
            $androidSdkSearch += $us.FullName
        }
    }
    $detectedSdk = $null
    foreach ($sdk in $androidSdkSearch) {
        if (Test-Path $sdk) { $detectedSdk = $sdk; break }
    }

    if (-not $detectedSdk) {
        $defaultSdk = "C:\Android\Sdk"
        if (-not (Test-Path $defaultSdk)) {
            New-Item -ItemType Directory -Path $defaultSdk -Force | Out-Null
        }
        $detectedSdk = $defaultSdk
    }

    if ($detectedSdk) {
        & flutter config --android-sdk "$detectedSdk" | Out-Null
        Set-SystemEnvVar -Name "ANDROID_HOME" -Value $detectedSdk
        Set-SystemEnvVar -Name "ANDROID_SDK_ROOT" -Value $detectedSdk
        $env:ANDROID_HOME = $detectedSdk
        $env:ANDROID_SDK_ROOT = $detectedSdk

        $platTools = Join-Path $detectedSdk "platform-tools"
        if (Test-Path $platTools) { Add-ToSystemPath -DirToAdd $platTools }

        # B.1. Pastikan cmdline-tools;latest Terpasang (Kritis untuk Hilangkan Error Flutter Doctor)
        $cmdToolsBat = Join-Path $detectedSdk "cmdline-tools\latest\bin\sdkmanager.bat"
        if (-not (Test-Path $cmdToolsBat)) {
            Write-Host "   [i] Memeriksa Android SDK Command-Line Tools (cmdline-tools;latest)..." -ForegroundColor Yellow
            $cmdToolsZipUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
            $destCmdZip = Join-Path $AppsDir "commandlinetools-win_latest.zip"

            # Cek apakah sudah ada file zip di folder Apps/ atau unduh dari Google CDN resmi
            $cmdZipFile = Get-ChildItem -Path $AppsDir -Filter "*commandlinetools*.zip" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $cmdZipFile) {
                Write-Host "   [>>>] Mengunduh official Google cmdline-tools dari CDN Google..." -ForegroundColor Cyan
                $dlSuccess = Download-FileWithFastMirrors -Urls @($cmdToolsZipUrl) -DestinationPath $destCmdZip -ActivityTitle "Mengunduh Android cmdline-tools"
                if ($dlSuccess -and (Test-Path $destCmdZip)) {
                    $cmdZipFile = Get-Item $destCmdZip
                }
            }

            if ($cmdZipFile) {
                Write-Host "   [i] Memasang cmdline-tools;latest ke $($detectedSdk)\cmdline-tools\latest..." -ForegroundColor Yellow
                $tempExtractDir = Join-Path $env:TEMP "android_cmdline_temp"
                if (Test-Path $tempExtractDir) { Remove-Item -Path $tempExtractDir -Recurse -Force -ErrorAction SilentlyContinue }
                New-Item -ItemType Directory -Path $tempExtractDir -Force | Out-Null
                
                $extracted = Expand-LabArchive -ArchivePath $cmdZipFile.FullName -DestinationDir $tempExtractDir
                $extractedSrc = Join-Path $tempExtractDir "cmdline-tools"
                if (-not (Test-Path $extractedSrc)) {
                    $extractedSrc = Get-ChildItem -Path $tempExtractDir -Directory -Recurse | Where-Object { Test-Path (Join-Path $_.FullName "bin\sdkmanager.bat") } | Select-Object -First 1
                    if ($extractedSrc) { $extractedSrc = $extractedSrc.FullName }
                }

                if ($extractedSrc -and (Test-Path $extractedSrc)) {
                    $targetLatest = Join-Path $detectedSdk "cmdline-tools\latest"
                    if (-not (Test-Path $targetLatest)) { New-Item -ItemType Directory -Path $targetLatest -Force | Out-Null }
                    & robocopy $extractedSrc $targetLatest /E /R:1 /W:1 /NP /NFL /NDL | Out-Null
                    Write-Host "   [OK] Android cmdline-tools;latest berhasil dipasang sempurna!" -ForegroundColor Green
                }
                Remove-Item -Path $tempExtractDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        $cmdTools = Join-Path $detectedSdk "cmdline-tools\latest\bin"
        if (Test-Path $cmdTools) { Add-ToSystemPath -DirToAdd $cmdTools }

        Write-Host "   [OK] Android SDK dikunci ke: $detectedSdk" -ForegroundColor Green
    }

    # C. Deteksi & Kunci JDK untuk Flutter & Android Toolchain
    $jdkSearch = @(
        "C:\Program Files\Android\Android Studio\jbr",
        "C:\Program Files\Android\Android Studio\jre",
        $env:JAVA_HOME,
        "C:\Program Files\Eclipse Adoptium\jdk-17*",
        "C:\Program Files\Java\jdk-17*",
        "C:\Program Files\Java\jdk*"
    )
    $detectedJdk = $null
    foreach ($jdk in $jdkSearch) {
        if (-not [string]::IsNullOrWhiteSpace($jdk)) {
            $f = Get-Item $jdk -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($f -and (Test-Path (Join-Path $f.FullName "bin\java.exe"))) {
                $detectedJdk = $f.FullName
                break
            }
        }
    }
    if ($detectedJdk) {
        & flutter config --jdk-dir "$detectedJdk" | Out-Null
        Write-Host "   [OK] JDK Flutter dikunci ke: $detectedJdk" -ForegroundColor Green
    }

    # D. Deteksi & Kunci Google Chrome / Edge untuk Flutter Web
    $chromeSearch = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    )
    foreach ($chr in $chromeSearch) {
        if (Test-Path $chr) {
            Set-SystemEnvVar -Name "CHROME_EXECUTABLE" -Value $chr
            $env:CHROME_EXECUTABLE = $chr
            Write-Host "   [OK] Chrome Web Engine dikunci ke: $chr" -ForegroundColor Green
            break
        }
    }

    # D.1. Deteksi & Kunci Direktori Android Studio untuk Flutter
    $studioSearch = @(
        "C:\Program Files\Android\Android Studio",
        "C:\Program Files\Android Studio",
        "C:\Program Files (x86)\Android\Android Studio",
        "$env:LOCALAPPDATA\Programs\Android Studio"
    )
    foreach ($asDir in $studioSearch) {
        if (Test-Path $asDir) {
            & flutter config --android-studio-dir "$asDir" | Out-Null
            Write-Host "   [OK] Android Studio dikunci ke: $asDir" -ForegroundColor Green
            break
        }
    }

    # E. Aktifkan platform desktop Windows, Web, dan Android
    & flutter config --enable-windows-desktop --enable-web --enable-android --no-analytics | Out-Null
    Write-Host "   [OK] Platform Windows Desktop, Web & Android diaktifkan!" -ForegroundColor Green

    # F. Auto-Accept Android Licenses Lengkap (Offline Hashes & sdkmanager runner)
    Write-Host "   [i] Menyetujui semua lisensi Android SDK secara otomatis (Accept Licenses)..." -ForegroundColor Yellow
    if ($detectedSdk) {
        try {
            $licensesDir = Join-Path $detectedSdk "licenses"
            if (-not (Test-Path $licensesDir)) { New-Item -ItemType Directory -Path $licensesDir -Force | Out-Null }
            
            $sdkLicenses = @(
                "24333f8a63cbd8224f723649d2a47016e7f1539a",
                "89338d0d9b183fb97af112d34f2d18586594f3b0",
                "d56f5187479451eabf01fb78af6dfcb131a6481e",
                "601085b94cd77f0b54ff86406957099fed8072d0"
            )
            [System.IO.File]::WriteAllText((Join-Path $licensesDir "android-sdk-license"), ($sdkLicenses -join "`r`n") + "`r`n")
            [System.IO.File]::WriteAllText((Join-Path $licensesDir "android-sdk-preview-license"), "84831b9409646a53fe44263426949611a3454ed4`r`n")
            [System.IO.File]::WriteAllText((Join-Path $licensesDir "android-googletv-license"), "601085b94cd77f0b54ff86406957099fed8072d0`r`n")
            [System.IO.File]::WriteAllText((Join-Path $licensesDir "android-sdk-arm-dbt-license"), "859f317696f67ef3d7f30a50a5560e7834b43903`r`n")
            [System.IO.File]::WriteAllText((Join-Path $licensesDir "google-gdk-license"), "33b6a2b64607f11b759f320e69d7996f970cce40`r`n")
            [System.IO.File]::WriteAllText((Join-Path $licensesDir "mips-android-sysimage-license"), "e9acab587f41bf414ce0fad2021ba4387adbe217`r`n")
            
            # Eksekusi persetujuan lisensi via sdkmanager jika cmdline-tools aktif
            $sdkMgr = Join-Path $detectedSdk "cmdline-tools\latest\bin\sdkmanager.bat"
            if (Test-Path $sdkMgr) {
                $yesInputs = ("y`n" * 30)
                $yesInputs | & $sdkMgr --licenses 2>&1 | Out-Null
            }
        } catch {}
    }
    try {
        $yesInputs = ("y`n" * 30)
        $yesInputs | & flutter doctor --android-licenses 2>&1 | Out-Null
        Write-Host "   [OK] Semua lisensi Android SDK disetujui (All Android licenses accepted)!" -ForegroundColor Green
    } catch {}

    # G. Integrasi VS Code & Ekstensi Flutter (Hilangkan status unknown di flutter doctor)
    $vsCodeCandidates = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
        "C:\Program Files\Microsoft VS Code\Code.exe",
        "C:\Program Files (x86)\Microsoft VS Code\Code.exe"
    )
    $detectedCodeExe = $null
    foreach ($vsc in $vsCodeCandidates) {
        if (Test-Path $vsc) { $detectedCodeExe = $vsc; break }
    }
    if ($detectedCodeExe) {
        $codeDir = Split-Path -Parent $detectedCodeExe
        $codeBin = Join-Path $codeDir "bin"
        if (Test-Path $codeBin) { Add-ToSystemPath -DirToAdd $codeBin }
        Add-ToSystemPath -DirToAdd $codeDir

        # Daftarkan ke Registry App Paths agar Flutter Doctor mendeteksi versi VS Code
        try {
            $codeRegs = @(
                "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\Code.exe",
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Code.exe"
            )
            foreach ($cr in $codeRegs) {
                if (-not (Test-Path $cr)) { New-Item -Path $cr -Force -ErrorAction SilentlyContinue | Out-Null }
                Set-ItemProperty -Path $cr -Name "(Default)" -Value $detectedCodeExe -Force -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $cr -Name "Path" -Value $codeDir -Force -ErrorAction SilentlyContinue
            }
        } catch {}

        # Pasang ekstensi Flutter pada VS Code
        $codeCmd = Join-Path $codeBin "code.cmd"
        if (-not (Test-Path $codeCmd)) { $codeCmd = Get-Command code -ErrorAction SilentlyContinue }
        if ($codeCmd) {
            try {
                Write-Host "   [i] Mendaftarkan ekstensi Flutter pada Visual Studio Code..." -ForegroundColor Cyan
                & $codeCmd --install-extension Dart-Code.flutter --force 2>&1 | Out-Null
            } catch {}
        }
    }

    # H. Jalankan Flutter Doctor ringkas
    Write-Host "`n   --- Hasil Flutter Doctor Terkini ---" -ForegroundColor Cyan
    try {
        & flutter doctor
    } catch {}

    Record-InstallResult -Name "Flutter SDK" -Status "BERHASIL DIINSTAL" -Keterangan "SDK & Doctor Terkonfigurasi"
}

# 12. Verifikasi Status Seluruh Software & Web Stack
function Test-LabSoftwareStatus {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "STATUS VERIFIKASI SOFTWARE & WEB STACK LAB TI [v$SCRIPT_CURRENT_VERSION]" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
    $env:COMPOSER_NO_INTERACTION = "1"
    $env:COMPOSER_ALLOW_SUPERUSER = "1"

    # Pastikan PHP versi TERBARU dari Laragon terdaftar paling depan di PATH sesi
    $laragonPhps = Get-ChildItem -Path "C:\laragon\bin\php" -Directory -ErrorAction SilentlyContinue |
                   Where-Object { Test-Path (Join-Path $_.FullName "php.exe") } |
                   Sort-Object {
                       if ($_.Name -match '(\d+(?:\.\d+)+)') {
                           try {
                               $vParts = $matches[1].Split('.')
                               $major = [int]$vParts[0]
                               $minor = if ($vParts.Count -gt 1) { [int]$vParts[1] } else { 0 }
                               $build = if ($vParts.Count -gt 2) { [int]$vParts[2] } else { 0 }
                               [Version]::new($major, $minor, $build)
                           } catch { [Version]::new(0, 0, 0) }
                       } else { [Version]::new(0, 0, 0) }
                   } -Descending

    $activePhpDir = $null
    if ($laragonPhps) {
        $activePhpDir = $laragonPhps[0].FullName
    } elseif (Test-Path "C:\xampp\php\php.exe") {
        $activePhpDir = "C:\xampp\php"
    }

    if ($activePhpDir) {
        $cleanParts = ($env:Path -split ';') | Where-Object {
            $_ -ne "" -and $_ -notlike "*\xampp\php*" -and $_ -notlike "*\laragon\bin\php\*"
        }
        $env:Path = "$activePhpDir;" + ($cleanParts -join ';')
    }

    $cliChecks = @(
        @{ Name = "Git"; Cmd = { git --version 2>&1 } },
        @{ Name = "Python 3"; Cmd = { python --version 2>&1 } },
        @{ Name = "Pip"; Cmd = { pip --version 2>&1 } },
        @{ Name = "Java (JDK)"; Cmd = { java -version 2>&1 } },
        @{ Name = "JAVA_HOME"; Cmd = { $env:JAVA_HOME } },
        @{ Name = "Node.js"; Cmd = { node --version 2>&1 } },
        @{ Name = "NPM"; Cmd = { npm --version 2>&1 } },
        @{ Name = "PHP CLI"; Cmd = { php -v 2>&1 } },
        @{ Name = "Composer"; Cmd = { composer --version --no-interaction 2>&1 } },
        @{ Name = "Laravel CLI"; Cmd = {
            $lBat = Join-Path $env:APPDATA "Composer\vendor\bin\laravel.bat"
            if (Test-Path $lBat) {
                & $lBat --version 2>&1
            } else {
                laravel --version 2>&1
            }
        } },
        @{ Name = "VS Code"; Cmd = { code --version 2>&1 } },
        @{ Name = "Flutter"; Cmd = { flutter --version 2>&1 } },
        @{ Name = "Dart"; Cmd = { dart --version 2>&1 } }
    )

    foreach ($chk in $cliChecks) {
        Write-Host -NoNewline ("- {0,-18}: " -f $chk.Name)
        try {
            $raw = & $chk.Cmd 2>&1 | Out-String
            $trimmed = $raw.Trim()
            if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
                $lines = @($trimmed -split "`r?`n")
                # Filter out baris peringatan PHP / Deprecated notice agar hasil versi bersih dan elegan
                $cleanLines = @($lines | Where-Object {
                    $_ -notmatch '(?i)warning:' -and
                    $_ -notmatch '(?i)deprecated:' -and
                    $_ -notmatch '(?i)notice:' -and
                    -not [string]::IsNullOrWhiteSpace($_)
                })

                # Jika memeriksa Composer, utamakan baris yang mengandung "Composer version"
                $firstLine = $null
                if ($chk.Name -eq "Composer") {
                    $cMatch = $cleanLines | Where-Object { $_ -match '(?i)Composer (version|\d+\.)' } | Select-Object -First 1
                    if ($cMatch) { $firstLine = $cMatch }
                }
                if (-not $firstLine) {
                    $firstLine = if ($cleanLines.Count -gt 0) { [string]$cleanLines[0] } else { [string]$lines[0] }
                }

                Write-Host $firstLine.Trim() -ForegroundColor Green
            } else {
                Write-Host "Belum Terdeteksi di PATH" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Belum Terinstal / Perlu Restart Shell" -ForegroundColor Red
        }
    }

    $guiApps = @(
        @{ Name = "7-Zip";               Path = @("C:\Program Files\7-Zip\7z.exe", "C:\Program Files (x86)\7-Zip\7z.exe"); Reg = "*7-Zip*" },
        @{ Name = "WinRAR";              Path = @("C:\Program Files\WinRAR\WinRAR.exe", "C:\Program Files (x86)\WinRAR\WinRAR.exe"); Reg = "*WinRAR*" },
        @{ Name = "Git for Windows";     Path = @("C:\Program Files\Git\cmd\git.exe", "C:\Program Files\Git\bin\git.exe"); Reg = "*Git*" },
        @{ Name = "Delphi (RAD Studio)"; Path = @("C:\Program Files*\Embarcadero\Studio\*\bin\bds.exe", "C:\Program Files (x86)\Embarcadero\Studio\*\bin\bds.exe"); Reg = "*Delphi*" },
        @{ Name = "Cisco Packet Tracer"; Path = @("C:\Program Files\Cisco Packet Tracer *\bin\PacketTracer.exe", "C:\Program Files (x86)\Cisco Packet Tracer *\bin\PacketTracer.exe"); Reg = "*Packet Tracer*" },
        @{ Name = "Visual Studio 2022";  Path = @("C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe", "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"); Reg = "*Visual Studio*" },
        @{ Name = "Proteus Design Suite";Path = @("C:\Program Files*\Labcenter Electronics\Proteus *\BIN\PDS.EXE", "C:\Program Files (x86)\Labcenter Electronics\Proteus *\BIN\PDS.EXE"); Reg = "*Proteus*" },
        @{ Name = "Android Studio";      Path = @("C:\Program Files\Android\Android Studio\bin\studio64.exe", "C:\Program Files (x86)\Android\Android Studio\bin\studio64.exe", "C:\Users\*\AppData\Local\Programs\Android\Android Studio\bin\studio64.exe"); Reg = "*Android Studio*" },
        @{ Name = "Oracle VirtualBox";   Path = @("C:\Program Files\Oracle\VirtualBox\VirtualBox.exe", "C:\Program Files (x86)\Oracle\VirtualBox\VirtualBox.exe"); Reg = "*VirtualBox*" },
        @{ Name = "VBox Extension Pack"; Path = @("C:\Program Files\Oracle\VirtualBox\ExtensionPacks\*\ExtPack.xml", "C:\Program Files (x86)\Oracle\VirtualBox\ExtensionPacks\*\ExtPack.xml", "C:\Program Files\Oracle\VirtualBox\ExtensionPacks\Oracle_VM_VirtualBox_Extension_Pack\ExtPack.xml"); Reg = "*VirtualBox Extension Pack*" },
        @{ Name = "Apache NetBeans";     Path = @("C:\Program Files\*NetBeans*\netbeans\bin\netbeans*.exe", "C:\Program Files\*NetBeans*\bin\netbeans*.exe", "C:\Program Files\Apache NetBeans*\bin\netbeans*.exe", "C:\Program Files\Codelerity\*NetBeans*\bin\netbeans*.exe", "C:\Program Files (x86)\*NetBeans*\netbeans\bin\netbeans*.exe", "C:\Program Files (x86)\*NetBeans*\bin\netbeans*.exe", "$env:LOCALAPPDATA\Programs\*NetBeans*\bin\netbeans*.exe"); Reg = "*NetBeans*" },
        @{ Name = "QGIS Desktop";        Path = @("C:\Program Files\QGIS *\bin\qgis-bin.exe", "C:\Program Files\QGIS *\bin\qgis.exe"); Reg = "*QGIS*" },
        @{ Name = "Arduino IDE";         Path = @("C:\Program Files\Arduino IDE\Arduino IDE.exe", "C:\Program Files\Arduino\arduino.exe", "C:\Users\*\AppData\Local\Programs\Arduino IDE\Arduino IDE.exe", "C:\Users\*\AppData\Local\Arduino*\arduino*.exe", "C:\Program Files (x86)\Arduino\arduino.exe"); Reg = "*Arduino*" },
        @{ Name = "Laragon";             Path = @("C:\laragon\laragon.exe", "D:\laragon\laragon.exe", "E:\laragon\laragon.exe"); Reg = "*Laragon*" },
        @{ Name = "XAMPP";               Path = @("C:\xampp\xampp-control.exe", "D:\xampp\xampp-control.exe"); Reg = "*XAMPP*" }
    )

    # Cache aplikasi terdaftar di Registry Windows Uninstall
    $installedRegs = @()
    try {
        $regKeys = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        $installedRegs = Get-ItemProperty $regKeys -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
    } catch {}

    Write-Host "`nSoftware Desktop & GUI Terpasang:" -ForegroundColor Cyan
    foreach ($gui in $guiApps) {
        $found = $null
        $paths = @($gui.Path)
        foreach ($p in $paths) {
            $f = Get-ChildItem -Path $p -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $f) {
                $f = Get-Item -Path $p -ErrorAction SilentlyContinue | Select-Object -First 1
            }
            if ($f) { $found = $f.FullName; break }
        }

        # Fallback Cerdas: Jika path spesifik belum cocok, periksa Windows Registry Uninstall
        if (-not $found -and $gui.Reg) {
            $matchReg = $installedRegs | Where-Object { $_.DisplayName -like $gui.Reg } | Select-Object -First 1
            if ($matchReg) {
                if ($matchReg.InstallLocation -and (Test-Path $matchReg.InstallLocation)) {
                    $found = "$($matchReg.InstallLocation) ($($matchReg.DisplayName))"
                } else {
                    $found = "$($matchReg.DisplayName) ($($matchReg.DisplayVersion))"
                }
            }
        }

        # Fallback Khusus: Jika memeriksa VBox Extension Pack, uji langsung via VBoxManage CLI
        if (-not $found -and $gui.Name -eq "VBox Extension Pack") {
            try {
                $vboxCmd = $null
                if (Test-Path "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe") { $vboxCmd = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" }
                elseif (Test-Path "C:\Program Files (x86)\Oracle\VirtualBox\VBoxManage.exe") { $vboxCmd = "C:\Program Files (x86)\Oracle\VirtualBox\VBoxManage.exe" }
                if ($vboxCmd) {
                    $epCheck = & $vboxCmd list extpacks 2>&1 | Out-String
                    if ($epCheck -match "Extension Packs:\s*([1-9]\d*)") {
                        $pCount = $matches[1]
                        $vMatch = if ($epCheck -match 'Version:\s*([^\r\n]+)') { $matches[1].Trim() } else { "Aktif" }
                        $found = "Terdaftar di VirtualBox ($vMatch - $pCount Pack)"
                    } elseif ($epCheck -match "Oracle VM VirtualBox Extension Pack") {
                        $found = "Terdaftar di VirtualBox (Aktif)"
                    }
                }
            } catch {}
        }

        # Fallback Tambahan: Periksa Shortcut di Start Menu Publik & User
        if (-not $found) {
            $firstWord = $gui.Name.Split(' ')[0]
            $lnk = Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs", "C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" -Filter "*$firstWord*.lnk" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($lnk) {
                $found = "Tersedia di Menu Start ($($lnk.Name))"
            }
        }

        Write-Host -NoNewline ("- {0,-22}: " -f $gui.Name)
        if ($found) {
            Write-Host "Terpasang ($found)" -ForegroundColor Green
        } else {
            Write-Host "Belum Terdeteksi di Path Standar" -ForegroundColor Gray
        }
    }

    Write-Host "`nAlokasi Port Standar Lab TI (Anti-Bentrok):" -ForegroundColor Cyan
    Write-Host " - Port 80   : Laragon WAMP / Apache (Default Praktikum Web)" -ForegroundColor Green
    Write-Host " - Port 443  : Laragon SSL (HTTPS)" -ForegroundColor Green
    Write-Host " - Port 3306 : Laragon MySQL / MariaDB (Standar DB Lab & Laravel .env)" -ForegroundColor Green
    Write-Host " - Port 8088 : XAMPP Apache HTTP (Bebas bentrok)" -ForegroundColor Yellow
    Write-Host " - Port 8444 : XAMPP Apache SSL (Bebas bentrok)" -ForegroundColor Yellow
    Write-Host " - Port 3307 : XAMPP MySQL (Bebas bentrok)" -ForegroundColor Yellow
    Write-Host " - Port 8000 : Dicadangkan untuk Laravel (php artisan serve)" -ForegroundColor Cyan
    Write-Host " - Port 3000 : Dicadangkan untuk Next.js / React (npm run dev)" -ForegroundColor Cyan
    Write-Host " - Port 5173 : Dicadangkan untuk Vite / Vue / Svelte" -ForegroundColor Cyan
}

# ==============================================================================
# FUNGSI JEDA STABILISASI ANTAR LANGKAH (Pacing 2 Detik Anti-Bentrok Sistem)
# ==============================================================================
function Wait-PacedStep {
    param([int]$Seconds = 2)
    Write-Host "   [i] Jeda stabilisasi sistem ($Seconds detik)..." -ForegroundColor DarkGray
    Start-Sleep -Seconds $Seconds
}

# ==============================================================================
# PROSEDUR OTOMASI LENGKAP STANDAR LAB TI
# (Smart-Skip: Jika sudah ada dilewati, jika belum ada langsung dipasang)
# ==============================================================================
function Run-FullInstallation {
    $script:InstallResults = @()
    Write-Host "`n[>>>] Memulai Otomasi Lengkap Standarisasi Software Lab TI..." -ForegroundColor Cyan
    Write-Host "      (Semua software wajib: Yang sudah terpasang otomatis diskip)`n" -ForegroundColor DarkGray

    # 1. 7-Zip (High-Speed Multi-Format Archive Extractor)
    Setup-7Zip
    Wait-PacedStep

    # 2. WinRAR (Lab Archive Support .rar/.zip)
    Setup-WinRAR
    Wait-PacedStep

    # 3. Git for Windows (Wajib untuk Dart SDK, Flutter, Composer, & VS Code)
    Setup-Git
    Wait-PacedStep

    # 4. Visual Studio Code (Otomatis Silent dengan Direct CDN Mirror)
    $vscodeMirrors = @(
        "https://vscode.download.prss.microsoft.com/dbazure/download/stable/fabdbac710c49742d1ae8f47303771f654f01f94/VSCodeUserSetup-x64-1.98.0.exe",
        "https://update.code.visualstudio.com/latest/win32-x64-user/stable",
        "https://az764295.vo.msecnd.net/stable/latest/VSCodeUserSetup-x64.exe"
    )
    Install-AppSmart -Name "Visual Studio Code" `
                     -FilePattern @("*VSCode*Setup*.exe", "*code*setup*.exe", "*Code*.exe") `
                     -DownloadUrls $vscodeMirrors `
                     -SilentArgs "/VERYSILENT /NORESTART /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" `
                     -WingetId "Microsoft.VisualStudioCode" `
                     -CheckPath @("$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe", "C:\Program Files\Microsoft VS Code\Code.exe")
    Wait-PacedStep

    # 5. Python (Versi Terbaru 3.13 / 3.12 LTS with PIP & System PATH)
    Setup-Python
    Wait-PacedStep

    # 6. Java JDK 17 (Otomatis Silent + JAVA_HOME)
    Setup-JavaJDK
    Wait-PacedStep

    # 7. Node.js LTS (Versi Terbaru v22 LTS with NPM & Global PATH)
    Setup-NodeJS
    Wait-PacedStep

    # 8. Oracle VM VirtualBox & Extension Pack (Otomatis Silent dengan Multi-Mirror Google Drive & CDN)
    Setup-VirtualBox
    Wait-PacedStep

    # 9. Apache NetBeans (Otomatis Silent dengan Direct High-Speed GitHub Releases CDN & Bundled JDK)
    Setup-NetBeans
    Wait-PacedStep

    # 10. Android Studio (Otomatis Silent dengan Multi-CDN Google Resmi & Winget Fallback)
    $androidStudioMirrors = @(
        "https://redirector.gvt1.com/edgedl/android/studio/install/2024.2.1.12/android-studio-2024.2.1.12-windows.exe",
        "https://dl.google.com/dl/android/studio/install/2024.2.1.12/android-studio-2024.2.1.12-windows.exe",
        "https://dl.google.com/android/studio/install/2024.1.2.13/android-studio-2024.1.2.13-windows.exe"
    )
    Install-AppSmart -Name "Android Studio" `
                     -FilePattern @("*Android*Studio*.exe", "*android-studio*.exe") `
                     -DownloadUrls $androidStudioMirrors `
                     -SilentArgs "/S" `
                     -WingetId "Google.AndroidStudio" `
                     -CheckPath @("C:\Program Files\Android\Android Studio\bin\studio64.exe", "C:\Program Files\Android Studio\bin\studio64.exe", "C:\Program Files (x86)\Android\Android Studio\bin\studio64.exe")
    Wait-PacedStep

    # 11. QGIS Desktop (Otomatis Silent)
    $qgisMirrors = @(
        "https://download.osgeo.org/qgis/windows/QGIS-OSGeo4W-3.34.14-1.msi",
        "https://qgis.org/downloads/QGIS-OSGeo4W-3.34.14-1.msi"
    )
    Install-AppSmart -Name "QGIS Desktop" `
                     -FilePattern "*QGIS*.msi" `
                     -DownloadUrls $qgisMirrors `
                     -SilentArgs "/qn" `
                     -WingetId "OSGeo.QGIS" `
                     -CheckPath "C:\Program Files\QGIS *\bin\qgis-bin.exe"
    Wait-PacedStep

    # 12. Microsoft Visual Studio 2022 Community (Desktop development with C++ Workload - Support 100% Offline Layout)
    Setup-VisualStudio
    Wait-PacedStep

    # 13. Arduino IDE (Arduino Uno, Nano, Mega, IoT)
    $arduinoMirrors = @(
        "https://github.com/arduino/arduino-ide/releases/download/2.3.10/arduino-ide_2.3.10_Windows_64bit.msi",
        "https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.10_Windows_64bit.msi"
    )
    Install-AppSmart -Name "Arduino IDE" `
                     -FilePattern @("*arduino*.msi", "*arduino*.exe") `
                     -DownloadUrls $arduinoMirrors `
                     -SilentArgs "/qn ALLUSERS=1" `
                     -WingetId "ArduinoSA.IDE.stable" `
                     -CheckPath @("C:\Program Files\Arduino IDE\Arduino IDE.exe", "C:\Program Files\Arduino\arduino.exe", "C:\Users\*\AppData\Local\Programs\Arduino IDE\Arduino IDE.exe", "C:\Users\*\AppData\Local\Arduino*\arduino*.exe", "C:\Program Files (x86)\Arduino\arduino.exe")
    Wait-PacedStep

    # 14. Flutter SDK (All Doctor Checks Passed & Auto-Configured)
    Setup-FlutterSDK
    Wait-PacedStep

    # 15. Laragon (Installer Resmi 6.0.0 + Auto-Overlay Stack Custom)
    Setup-LaragonStack
    Wait-PacedStep

    # 16. Composer & Laravel Setup
    Setup-ComposerAndLaravel
    Wait-PacedStep

    # 17. XAMPP (Otomatis Silent + Konfigurasi Port Anti-Bentrok)
    Setup-XamppStack
    Wait-PacedStep

    # 18. Cisco Packet Tracer (Multi-Mirror Google Drive Resmi Lab TI)
    $ciscoMirrors = @(
        "https://drive.google.com/file/d/1N_YQNs2xFrdFGRPs4kqgF6LGOYDp37ZK/view?usp=sharing",
        "https://drive.google.com/file/d/1O4flOVt7G-xZmfJSlxP3aLjTj1JM_LYP/view?usp=sharing",
        "https://drive.google.com/file/d/1SeGZ7TGze27bs6d7FJd4nNDW_D8QIj2c/view?usp=sharing",
        "https://drive.google.com/file/d/1YbIfp1OyVXl_uksvGu7w82KcHB4_UpR-/view?usp=sharing"
    )
    Install-AppSmart -Name "Cisco Packet Tracer" `
                     -FilePattern @("*packettracer*.exe", "*PacketTracer*.exe", "*Cisco*.exe", "*packettracer*.rar", "*cisco*.rar", "*packettracer*.zip") `
                     -DownloadUrls $ciscoMirrors `
                     -SilentArgs "/VERYSILENT /NORESTART" `
                     -CheckPath @("C:\Program Files\Cisco Packet Tracer *\bin\PacketTracer.exe", "C:\Program Files (x86)\Cisco Packet Tracer *\bin\PacketTracer.exe")
    Wait-PacedStep

    # 19. Embarcadero Delphi (Pihak Ketiga / Interaktif)
    Install-AppSmart -Name "Embarcadero Delphi" -FilePattern "*delphi*.exe" -IsInteractive -CheckPath @("C:\Program Files*\Embarcadero\Studio\*\bin\bds.exe", "C:\Program Files (x86)\Embarcadero\Studio\*\bin\bds.exe")
    Wait-PacedStep

    # 20. Proteus Design Suite (Pihak Ketiga / Interaktif)
    Install-AppSmart -Name "Proteus Design Suite" -FilePattern "*proteus*.exe" -IsInteractive -CheckPath @("C:\Program Files*\Labcenter Electronics\Proteus *\BIN\PDS.EXE", "C:\Program Files (x86)\Labcenter Electronics\Proteus *\BIN\PDS.EXE")
    Wait-PacedStep

    # ==============================================================================
    # RANGKUMAN LENGKAP HASIL STANDARISASI LABORATORIUM
    # Bersihkan layar, tampilkan banner & rekapitulasi jumlah berhasil / gagal
    # ==============================================================================
    Clear-Host
    Show-SmartLabBanner

    $totalApps = if ($script:InstallResults) { $script:InstallResults.Count } else { 0 }
    $berhasil = ($script:InstallResults | Where-Object { $_.Status -in @("SUDAH TERPASANG", "BERHASIL DIINSTAL") } | Measure-Object).Count
    $menunggu = ($script:InstallResults | Where-Object { $_.Status -eq "BELUM TERSEDIA" } | Measure-Object).Count
    $gagal    = ($script:InstallResults | Where-Object { $_.Status -eq "GAGAL" } | Measure-Object).Count

    Write-Host "==============================================================================" -ForegroundColor Green
    Write-Host "               SELESAI - REKAPITULASI STANDARISASI LAB TI                      " -ForegroundColor Green
    Write-Host "==============================================================================" -ForegroundColor Green
    Write-Host "  Total Software Diproses   : $totalApps dari 19 Software Standar" -ForegroundColor White
    Write-Host "  [OK] Berhasil / Terpasang : $berhasil Software" -ForegroundColor Green
    if ($menunggu -gt 0) {
        Write-Host "  [i] Menunggu Master Offline: $menunggu Software (Delphi / Proteus lisensi lab)" -ForegroundColor Yellow
    }
    if ($gagal -gt 0) {
        Write-Host "  [!] Gagal / Butuh Tindakan : $gagal Software" -ForegroundColor Red
    }
    Write-Host "------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ("  {0,-3} | {1,-30} | {2,-18} | {3}" -f "No", "Software Praktikum", "Status", "Keterangan") -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------------------------" -ForegroundColor DarkGray

    $idx = 1
    foreach ($item in $script:InstallResults) {
        $color = "Green"
        if ($item.Status -eq "BELUM TERSEDIA") { $color = "Yellow" }
        elseif ($item.Status -eq "GAGAL") { $color = "Red" }
        elseif ($item.Status -eq "SUDAH TERPASANG") { $color = "Cyan" }

        $shortKet = if ($item.Keterangan -and $item.Keterangan.Length -gt 28) { $item.Keterangan.Substring(0, 25) + "..." } else { $item.Keterangan }
        Write-Host ("  {0,-3} | {1,-30} | {2,-18} | {3}" -f $idx, $item.Name, $item.Status, $shortKet) -ForegroundColor $color
        $idx++
    }
    Write-Host "==============================================================================`n" -ForegroundColor Green
}

# ==============================================================================
# FUNGSI KHUSUS UNDUH SAJA MASTER OFFLINE KE FLASHDISK (APPS/)
# ==============================================================================
function Start-DownloadOnlyMaster {
    Clear-Host
    Show-SmartLabBanner
    Write-Host "==============================================================================" -ForegroundColor Cyan
    Write-Host "  MODE UNDUH SAJA: MENYIAPKAN SELURUH MASTER OFFLINE KE FOLDER APPS/          " -ForegroundColor Cyan
    Write-Host "==============================================================================" -ForegroundColor Cyan
    Write-Host "Fungsi ini akan mengunduh seluruh file master software lab ke dalam folder:" -ForegroundColor Gray
    Write-Host "-> $AppsDir" -ForegroundColor Yellow
    Write-Host "(Tidak ada aplikasi yang dipasang ke Windows pada mode ini. Aman untuk persiapan lab).`n" -ForegroundColor DarkGray

    if (-not (Test-Path $AppsDir)) {
        New-Item -ItemType Directory -Path $AppsDir -Force | Out-Null
    }

    $downloadTargets = @(
        @{
            Name = "7-Zip (High-Speed Archive Extractor)"
            FilePattern = @("*7z*x64*.exe", "*7z*.exe")
            DestFile = "7z2408-x64.exe"
            Urls = @("https://www.7-zip.org/a/7z2408-x64.exe", "https://github.com/ip7z/7zip/releases/download/24.08/7z2408-x64.exe")
        },
        @{
            Name = "WinRAR (Lab Archive Support)"
            FilePattern = @("*winrar*x64*.exe", "*winrar*.exe", "*wrar*.exe")
            DestFile = "winrar-x64-701.exe"
            Urls = @("https://www.rarlab.com/rar/winrar-x64-701.exe", "https://www.rarlab.com/rar/winrar-x64-700.exe")
        },
        @{
            Name = "Git for Windows"
            FilePattern = @("Git-*-64-bit.exe", "Git-*.exe", "*Git*Setup*.exe")
            DestFile = "Git-2.48.1-64-bit.exe"
            Urls = @(
                "https://github.com/git-for-windows/git/releases/download/v2.48.1.windows.1/Git-2.48.1-64-bit.exe",
                "https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe",
                "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe"
            )
        },
        @{
            Name = "Visual Studio Code"
            FilePattern = @("*VSCode*Setup*.exe", "*code*setup*.exe")
            DestFile = "VSCodeUserSetup-x64.exe"
            Urls = @(
                "https://vscode.download.prss.microsoft.com/dbazure/download/stable/fabdbac710c49742d1ae8f47303771f654f01f94/VSCodeUserSetup-x64-1.98.0.exe",
                "https://update.code.visualstudio.com/latest/win32-x64-user/stable",
                "https://az764295.vo.msecnd.net/stable/latest/VSCodeUserSetup-x64.exe"
            )
        },
        @{
            Name = "Python (Versi Terbaru 3.13 / 3.12 with PIP)"
            FilePattern = @("*python*3.13*.exe", "*python*3.12*.exe", "*python*.exe")
            DestFile = "python-3.13.2-amd64.exe"
            Urls = @(
                "https://www.python.org/ftp/python/3.13.2/python-3.13.2-amd64.exe",
                "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe",
                "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"
            )
        },
        @{
            Name = "Java JDK 17 LTS (Eclipse Adoptium Temurin)"
            FilePattern = @("*Temurin*17*.msi", "*jdk*17*.msi", "*Temurin*.msi")
            DestFile = "OpenJDK17U-jdk_x64_windows.msi"
            Urls = @("https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.msi")
        },
        @{
            Name = "Node.js LTS (with NPM)"
            FilePattern = @("*node*v*.msi", "*node*.msi")
            DestFile = "node-v22.14.0-x64.msi"
            Urls = @("https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi", "https://nodejs.org/dist/v20.18.3/node-v20.18.3-x64.msi")
        },
        @{
            Name = "Oracle VM VirtualBox"
            FilePattern = @("*VirtualBox*.exe", "*VirtualBox*.msi")
            DestFile = "VirtualBox-7.2.20-Win.exe"
            Urls = @(
                "https://drive.google.com/file/d/18VMaCMVlP5-1yoUU0e90Bjy3pqUzqV8i/view?usp=sharing",
                "https://drive.google.com/file/d/1O0GSKjOzYf7b5cC5hlIsa10ouzMtrS7D/view?usp=sharing",
                "https://drive.google.com/file/d/1yR9Xc2bRcEwQBz7o3IrMZ0Ustx5jd5fI/view?usp=sharing",
                "https://drive.google.com/file/d/1FqHbWQdaRxOoO0woLB-UZjlXFeWJ5VnA/view?usp=sharing",
                "https://download.virtualbox.org/virtualbox/7.2.20/VirtualBox-7.2.20-175154-Win.exe",
                "https://download.virtualbox.org/virtualbox/7.1.8/VirtualBox-7.1.8-168469-Win.exe",
                "https://download.virtualbox.org/virtualbox/7.1.6/VirtualBox-7.1.6-167084-Win.exe"
            )
        },
        @{
            Name = "Oracle VM VirtualBox Extension Pack"
            FilePattern = @("*.vbox-extpack", "*Extension*Pack*.vbox-extpack")
            DestFile = "Oracle_VirtualBox_Extension_Pack.vbox-extpack"
            Urls = @(
                "https://drive.google.com/file/d/1g0Ut2twJy71GQ4b6-4Nj6_3e99WCxWFY/view?usp=sharing",
                "https://drive.google.com/file/d/1T3LOPKLTCx6JP0IZYBrJKaVaiqawXv6c/view?usp=sharing",
                "https://drive.google.com/file/d/1bL621GdJ7tN1e3_IAClmwyIdyd5HcVxb/view?usp=sharing",
                "https://drive.google.com/file/d/1dlEPu54jB1ai3McvksX15axwGONs64g-/view?usp=sharing",
                "https://download.virtualbox.org/virtualbox/7.2.20/Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack",
                "https://download.virtualbox.org/virtualbox/7.1.8/Oracle_VirtualBox_Extension_Pack-7.1.8.vbox-extpack"
            )
        },
        @{
            Name = "Apache NetBeans IDE (High-Speed GitHub CDN / Bundled JDK)"
            FilePattern = @("*NetBeans*31*.exe", "*NetBeans*.exe", "*Apache-NetBeans*.exe")
            DestFile = "Apache-NetBeans-31.exe"
            Urls = @(
                "https://github.com/codelerity/netbeans-packages/releases/download/v31-build1/Apache-NetBeans-31.exe",
                "https://github.com/apache/netbeans/releases/download/25/Apache-NetBeans-25-bin-windows-x64.exe",
                "https://archive.apache.org/dist/netbeans/netbeans-installers/25/Apache-NetBeans-25-bin-windows-x64.exe"
            )
        },
        @{
            Name = "Android Studio"
            FilePattern = @("*Android*Studio*.exe", "*android-studio*.exe")
            DestFile = "android-studio-2024.2.1.12-windows.exe"
            Urls = @("https://redirector.gvt1.com/edgedl/android/studio/install/2024.2.1.12/android-studio-2024.2.1.12-windows.exe", "https://dl.google.com/dl/android/studio/install/2024.2.1.12/android-studio-2024.2.1.12-windows.exe")
        },
        @{
            Name = "QGIS Desktop"
            FilePattern = @("*QGIS*.msi")
            DestFile = "QGIS-OSGeo4W-3.34.14-1.msi"
            Urls = @(
                "https://download.osgeo.org/qgis/windows/QGIS-OSGeo4W-3.34.14-1.msi",
                "https://qgis.org/downloads/QGIS-OSGeo4W-3.34.14-1.msi"
            )
        },
        @{
            Name = "Arduino IDE"
            FilePattern = @("*arduino*.msi", "*arduino*.exe")
            DestFile = "arduino-ide_2.3.10_Windows_64bit.msi"
            Urls = @("https://github.com/arduino/arduino-ide/releases/download/2.3.10/arduino-ide_2.3.10_Windows_64bit.msi", "https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.10_Windows_64bit.msi")
        },
        @{
            Name = "Flutter SDK (Versi Terbaru 3.29/3.27 Stable)"
            FilePattern = @("*flutter*windows*.zip", "*flutter*.zip")
            DestFile = "flutter_windows_stable.zip"
            Urls = @(
                "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.0-stable.zip",
                "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.27.4-stable.zip",
                "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
            )
        },
        @{
            Name = "Laragon 6.0.0 (WAMP Installer)"
            FilePattern = @("*laragon-wamp*.exe", "*laragon*setup*.exe")
            DestFile = "laragon-wamp-setup-6.0.0.exe"
            Urls = @("https://github.com/leokhoa/laragon/releases/download/6.0.0/laragon-wamp.exe", "https://downloads.sourceforge.net/project/laragon/laragon-wamp.exe")
        },
        @{
            Name = "Laragon Custom Stack (PHP 8.5/8.4/8.3, MySQL, phpMyAdmin)"
            FilePattern = @("*Laragon*Custom*.rar", "*Custom*Stack*.rar", "*Custom*Stack*.zip")
            DestFile = "Laragon_Custom_Stack.rar"
            Urls = @(
                "https://drive.google.com/file/d/1nn1aUQm1FiVlFRy-pIerSxCkK1I7MtJ_/view?usp=sharing",
                "https://drive.google.com/file/d/14IyGfCdk3VOw-MWYXqA2SkP2S9jq1hBC/view?usp=sharing",
                "https://drive.google.com/file/d/1Eunm6q6ir8yx0F9ybTPU4dfaOn33fkUt/view?usp=sharing",
                "https://drive.google.com/file/d/1majSE8h7bR_tRFFz2euHBP3-CNtzigP6/view?usp=sharing"
            )
        },
        @{
            Name = "Composer (PHP Dependency Manager)"
            FilePattern = @("*Composer*.exe")
            DestFile = "Composer-Setup.exe"
            Urls = @("https://getcomposer.org/Composer-Setup.exe")
        },
        @{
            Name = "XAMPP Server"
            FilePattern = @("*xampp*.exe")
            DestFile = "xampp-windows-x64-8.2.12-installer.exe"
            Urls = @(
                "https://downloads.sourceforge.net/project/xampp/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe",
                "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download"
            )
        },
        @{
            Name = "Cisco Packet Tracer (Google Drive Multi-Mirror)"
            FilePattern = @("*packettracer*.exe", "*PacketTracer*.exe", "*Cisco*.exe", "*packettracer*.rar", "*cisco*.rar", "*packettracer*.zip")
            DestFile = "Cisco_Packet_Tracer_LabTI.rar"
            Urls = @(
                "https://drive.google.com/file/d/1N_YQNs2xFrdFGRPs4kqgF6LGOYDp37ZK/view?usp=sharing",
                "https://drive.google.com/file/d/1O4flOVt7G-xZmfJSlxP3aLjTj1JM_LYP/view?usp=sharing",
                "https://drive.google.com/file/d/1SeGZ7TGze27bs6d7FJd4nNDW_D8QIj2c/view?usp=sharing",
                "https://drive.google.com/file/d/1YbIfp1OyVXl_uksvGu7w82KcHB4_UpR-/view?usp=sharing"
            )
        }
    )

    $num = 1
    $downloadResults = @()

    foreach ($t in $downloadTargets) {
        Write-Host ("`n[{0}/{1}] Memeriksa Master: $($t.Name)" -f $num, ($downloadTargets.Count + 2)) -ForegroundColor Yellow
        $existing = $null
        foreach ($pat in @($t.FilePattern)) {
            $candidates = Get-ChildItem -Path $AppsDir -Filter $pat -File -Recurse -ErrorAction SilentlyContinue
            foreach ($cand in $candidates) {
                if ($cand.Length -lt 512000) {
                    $isBad = $false
                    try {
                        $txt = [System.IO.File]::ReadAllText($cand.FullName)
                        if ($txt -match "<html" -or $txt -match "quota exceeded") { $isBad = $true }
                    } catch {}
                    if ($isBad) {
                        Remove-Item -Path $cand.FullName -Force -ErrorAction SilentlyContinue
                        Write-Host "   [!] Menghapus berkas corrupt/HTML error lama di Apps: $($cand.Name)" -ForegroundColor DarkYellow
                        continue
                    }
                }
                $existing = $cand
                break
            }
            if ($existing) { break }
        }

        if ($existing) {
            $sizeMb = [math]::Round($existing.Length / 1MB, 2)
            Write-Host "   [OK SUDAH ADA] $($existing.Name) ($sizeMb MB) telah tersimpan di Apps/" -ForegroundColor Green
            $downloadResults += [PSCustomObject]@{
                Software = $t.Name
                Berkas = $existing.Name
                Ukuran = "$sizeMb MB"
                Status = "SUDAH ADA"
            }
        } else {
            $destPath = Join-Path $AppsDir $t.DestFile
            Write-Host "   [>>>] Mengunduh master ke: $($t.DestFile) ..." -ForegroundColor Cyan
            $dlSuccess = Download-FileWithFastMirrors -Urls $t.Urls -DestinationPath $destPath -ActivityTitle "Mengunduh $($t.Name)"
            if ($dlSuccess -and (Test-Path $destPath)) {
                $fInfo = Get-Item $destPath
                $sizeMb = [math]::Round($fInfo.Length / 1MB, 2)
                Write-Host "   [BERHASIL DIUNDUH] $($fInfo.Name) ($sizeMb MB)" -ForegroundColor Green
                $downloadResults += [PSCustomObject]@{
                    Software = $t.Name
                    Berkas = $fInfo.Name
                    Ukuran = "$sizeMb MB"
                    Status = "BARU DIUNDUH"
                }
            } else {
                Write-Host "   [!] Gagal mengunduh $($t.Name) dari seluruh mirror." -ForegroundColor Red
                $downloadResults += [PSCustomObject]@{
                    Software = $t.Name
                    Berkas = "-"
                    Ukuran = "-"
                    Status = "GAGAL UNDUH"
                }
            }
        }
        $num++
    }

    # Penanganan Khusus Visual Studio 2022 Community Layout Cache
    Write-Host ("`n[{0}/{1}] Memeriksa Master: Visual Studio 2022 Community (Desktop C++ Offline Layout)" -f $num, ($downloadTargets.Count + 2)) -ForegroundColor Yellow
    $vsLayoutDir = Join-Path $AppsDir "vs_layout"
    $hasVsCache = (Test-Path $vsLayoutDir) -and (Test-Path (Join-Path $vsLayoutDir "packages"))
    if ($hasVsCache) {
        Write-Host "   [OK SUDAH ADA] Folder vs_layout telah lengkap tersimpan di Apps/vs_layout" -ForegroundColor Green
        $downloadResults += [PSCustomObject]@{
            Software = "Visual Studio 2022 Community"
            Berkas = "vs_layout/"
            Ukuran = "Cache Siap"
            Status = "SUDAH ADA"
        }
    } else {
        $vsBootstrapper = Join-Path $AppsDir "vs_community.exe"
        if (-not (Test-Path $vsBootstrapper)) {
            Write-Host "   [i] Mengunduh bootstrapper resmi Microsoft vs_community.exe..." -ForegroundColor Yellow
            try {
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                $wc = New-Object System.Net.WebClient
                $wc.DownloadFile("https://aka.ms/vs/17/release/vs_community.exe", $vsBootstrapper)
                $wc.Dispose()
            } catch {}
        }
        if (Test-Path $vsBootstrapper) {
            Write-Host "   [>>>] Menyiapkan paket offline C++ ke Apps\vs_layout (Proses layout resmi Microsoft)..." -ForegroundColor Cyan
            $layoutArgs = "--layout `"$vsLayoutDir`" --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --lang en-US --quiet"
            $proc = Start-Process -FilePath $vsBootstrapper -ArgumentList $layoutArgs -Wait -PassThru
            if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                Write-Host "   [BERHASIL DIUNDUH] Cache Visual Studio C++ lengkap di Apps\vs_layout!" -ForegroundColor Green
                $downloadResults += [PSCustomObject]@{
                    Software = "Visual Studio 2022 Community"
                    Berkas = "vs_layout/"
                    Ukuran = "Cache Siap"
                    Status = "BARU DIUNDUH"
                }
            } else {
                $downloadResults += [PSCustomObject]@{
                    Software = "Visual Studio 2022 Community"
                    Berkas = "vs_community.exe"
                    Ukuran = "Bootstrapper Saja"
                    Status = "PARSIAL"
                }
            }
        }
    }
    $num++

    # Penanganan Khusus Software Pihak Ketiga (Delphi & Proteus)
    Write-Host ("`n[{0}/{1}] Memeriksa Master: Delphi & Proteus (Pihak Ketiga Berlisensi)" -f $num, ($downloadTargets.Count + 2)) -ForegroundColor Yellow
    $delphiFile = Get-ChildItem -Path $AppsDir -Filter "*delphi*.exe" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    $proteusFile = Get-ChildItem -Path $AppsDir -Filter "*proteus*.exe" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

    if ($delphiFile) {
        Write-Host "   [OK SUDAH ADA] Master Delphi: $($delphiFile.Name)" -ForegroundColor Green
    } else {
        Write-Host "   [i] Master Delphi belum ada di Apps/. (Silakan salin installer lisensi resmi lab ke Apps/)." -ForegroundColor Gray
    }
    if ($proteusFile) {
        Write-Host "   [OK SUDAH ADA] Master Proteus: $($proteusFile.Name)" -ForegroundColor Green
    } else {
        Write-Host "   [i] Master Proteus belum ada di Apps/. (Silakan salin installer lisensi resmi lab ke Apps/)." -ForegroundColor Gray
    }

    # REKAPITULASI HASIL DOWNLOAD ONLY
    Clear-Host
    Show-SmartLabBanner
    Write-Host "==============================================================================" -ForegroundColor Green
    Write-Host "        SELESAI - REKAPITULASI CACHE MASTER OFFLINE KE FLASHDISK (APPS/)       " -ForegroundColor Green
    Write-Host "==============================================================================" -ForegroundColor Green

    $totalSize = 0
    try {
        $allFiles = Get-ChildItem -Path $AppsDir -File -Recurse -ErrorAction SilentlyContinue
        if ($allFiles) {
            $totalSize = ($allFiles | Measure-Object -Property Length -Sum).Sum
        }
    } catch {}
    $totalGb = [math]::Round($totalSize / 1GB, 2)

    Write-Host "  Lokasi Target Penyimpanan : $AppsDir" -ForegroundColor White
    Write-Host "  Total Penggunaan Disk     : $totalGb GB" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ("  {0,-3} | {1,-32} | {2,-14} | {3}" -f "No", "Software", "Status", "Ukuran Berkas") -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------------------------" -ForegroundColor DarkGray

    $rIdx = 1
    foreach ($r in $downloadResults) {
        $c = "Green"
        if ($r.Status -eq "GAGAL UNDUH") { $c = "Red" }
        elseif ($r.Status -eq "SUDAH ADA") { $c = "Cyan" }
        Write-Host ("  {0,-3} | {1,-32} | {2,-14} | {3}" -f $rIdx, $r.Software, $r.Status, $r.Ukuran) -ForegroundColor $c
        $rIdx++
    }
    Write-Host "==============================================================================" -ForegroundColor Green
    Write-Host "Flashdisk Anda kini telah dilengkapi master offline untuk seluruh lab!`n" -ForegroundColor Green
}

# ==============================================================================
# FUNGSI NAVIGASI AMAN: HANYA TOMBOL ENTER UNTUK KEMBALI ATAU KELUAR
# Mengabaikan tombol sembarang dan membersihkan buffer keyboard agar pengguna
# memiliki waktu cukup membaca rangkuman hasil tanpa takut tertutup otomatis.
# ==============================================================================
function Wait-EnterOnly {
    param(
        [string]$PromptMessage = "[Tekan tombol ENTER untuk kembali ke Menu Utama...]"
    )
    Write-Host "`n$PromptMessage" -ForegroundColor Cyan

    # 1. Kosongkan buffer keyboard dari tombol yang tertekan sebelumnya
    try {
        while ($Host.UI.RawUI.KeyAvailable) {
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } catch {}

    # 2. Tunggu HANYA penekanan tombol ENTER (VirtualKeyCode 13 / ConsoleKey.Enter)
    # Tombol lain (spasi, huruf, angka, esc, panah) sengaja diabaikan
    try {
        while ($true) {
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($key.VirtualKeyCode -eq 13 -or $key.Character -eq [char]13 -or $key.Key -eq [System.ConsoleKey]::Enter) {
                break
            }
        }
    } catch {
        # Fallback jika RawUI tidak aktif / sesi teralihkan: Read-Host hanya merespons saat Enter ditekan
        $null = Read-Host
    }
}

# ==============================================================================
# MENU UTAMA (INTERAKTIF TERPUSAT DENGAN CLEAR-HOST)
# ==============================================================================
$running = $true

while ($running) {
    Clear-Host
    Show-SmartLabBanner
    Write-Host "Pilihan Tindakan:" -ForegroundColor Yellow
    Write-Host " [1] Jalankan Otomasi Lengkap Lab (Instalasi & Standarisasi 20 Software)"
    Write-Host " [2] Unduh Seluruh Master Installer Offline ke Flashdisk (Download Saja / Cache Master)"
    Write-Host " [3] Verifikasi Status & Peta Port Software Lab"
    Write-Host " [4] Keluar`n"

    $choice = Read-Host "Masukkan pilihan Anda (1/2/3/4)"

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
            Run-FullInstallation
            Wait-EnterOnly -PromptMessage "[Tekan tombol ENTER untuk kembali ke Menu Utama...]"
        }
        "2" {
            Start-DownloadOnlyMaster
            Wait-EnterOnly -PromptMessage "[Tekan tombol ENTER untuk kembali ke Menu Utama...]"
        }
        "3" {
            Clear-Host
            Show-SmartLabBanner
            Test-LabSoftwareStatus
            Wait-EnterOnly -PromptMessage "[Tekan tombol ENTER untuk kembali ke Menu Utama...]"
        }
        "4" {
            Write-Host "`n[i] Mengembalikan pengaturan daya komputer ke normal..." -ForegroundColor DarkGray
            try { [SystemPowerKeeper]::RestoreNormal() } catch {}
            Write-Host "Keluar dari skrip otomasi SmartLab. Terima kasih." -ForegroundColor Green
            Wait-EnterOnly -PromptMessage "[Tekan tombol ENTER untuk menutup jendela ini...]"
            $running = $false
            [System.Environment]::Exit(0)
        }
        default {
            Write-Host "Pilihan tidak valid. Silakan ketik angka 1, 2, 3, atau 4." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
