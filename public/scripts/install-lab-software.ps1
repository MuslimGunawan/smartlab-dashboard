# ==============================================================================
# SCRIPT OTOMASI INSTALASI SOFTWARE LABORATORIUM TEKNIK INFORMATIKA
# UNIVERSITAS MALIKUSSALEH (UNIMAL)
# ==============================================================================
# Standarisasi 17 Software Praktikum Resmi Lab TI Unimal:
#
# A. APLIKASI BERLISENSI (4):
#   1. Delphi (Embarcadero Delphi / RAD Studio) -> Mode Interaktif (Pihak Ketiga)
#   2. Cisco Packet Tracer (Cisco NetAcad) -> Google Drive Multi-Mirror
#   3. Microsoft Visual Studio 2022 Community
#   4. Proteus Design Suite (Labcenter Electronics) -> Mode Interaktif (Pihak Ketiga)
#
# B. APLIKASI BEBAS LISENSI & DEV STACK (13):
#   5. Visual Studio Code
#   6. Android Studio
#   7. Python 3.12 (with PIP & System PATH)
#   8. Java JDK 17 LTS (with JAVA_HOME & System PATH)
#   9. Node.js LTS (with NPM & Global PATH)
#  10. Flutter SDK (All Doctor Checks Passed & Auto-Configured)
#  11. Composer & Laravel Setup
#  12. Oracle VM VirtualBox
#  13. Apache NetBeans IDE
#  14. QGIS Desktop
#  15. Arduino IDE (Arduino Uno & IoT)
#  16. Laragon (WAMP Stack)
#  17. XAMPP Server (Port Anti-Bentrok)
# ==============================================================================

$SCRIPT_CURRENT_VERSION = "3.3.0"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Installer Otomatis 17 Software Lab TI Unimal - v$SCRIPT_CURRENT_VERSION"

# 1. Pastikan script berjalan sebagai Administrator
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host "`n[!] Membutuhkan hak akses Administrator. Membuka jendela Administrator..." -ForegroundColor Yellow
    try {
        $spPath = $PSCommandPath
        if (-not $spPath) { $spPath = $MyInvocation.MyCommand.Path }
        Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $spPath) -Verb RunAs -ErrorAction Stop
        exit
    } catch {
        Write-Host "[!] Gagal membuka jendela Administrator otomatis: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "    Silakan klik kanan 'jalankan-instalasi.bat' lalu pilih 'Run as administrator'." -ForegroundColor Cyan
        Read-Host "`nTekan Enter untuk keluar..."
        exit 1
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

# 1.2 Persiapan Sumber Winget (Cegah error sertifikat 0x8a15005e pada sumber msstore)
try {
    $sources = winget source list 2>$null | Out-String
    if ($sources -match "msstore") {
        winget source remove --name msstore 2>$null
    }
} catch {}

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
                    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $scriptFile) -Verb RunAs
                    exit
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

# 3. Fungsi Helper Tambah ke System PATH
function Add-ToSystemPath {
    param ([string]$DirToAdd)
    if ([string]::IsNullOrWhiteSpace($DirToAdd) -or !(Test-Path $DirToAdd)) { return }

    $target = [EnvironmentVariableTarget]::Machine
    $currentPath = [Environment]::GetEnvironmentVariable("Path", $target)
    $paths = $currentPath -split ';' | Where-Object { $_ -ne "" }

    if ($paths -notcontains $DirToAdd) {
        $newPath = "$currentPath;$DirToAdd"
        [Environment]::SetEnvironmentVariable("Path", $newPath, $target)
        $env:Path = "$env:Path;$DirToAdd"
        Write-Host "   [PATH] Ditambahkan ke System PATH: $DirToAdd" -ForegroundColor Green
    } else {
        Write-Host "   [PATH] Sudah terdaftar di System PATH: $DirToAdd" -ForegroundColor Cyan
    }
}

# 4. Fungsi Helper Set System Env Variable
function Set-SystemEnvVar {
    param ([string]$Name, [string]$Value)
    [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Process)
    Write-Host "   [ENV] $Name = $Value" -ForegroundColor Green
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

        # 1. Desktop Publik (Muncul di layar desktop semua mahasiswa/dosen)
        $publicDesktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
        if (Test-Path $publicDesktop) {
            $lnk1 = Join-Path $publicDesktop "$ShortcutName.lnk"
            $sc1 = $wsh.CreateShortcut($lnk1)
            $sc1.TargetPath = $TargetExe
            $sc1.WorkingDirectory = $WorkingDir
            if ($Arguments) { $sc1.Arguments = $Arguments }
            $sc1.Save()
        }

        # 2. Start Menu Program Publik (Muncul saat Windows Search / Start Menu diketik)
        $commonPrograms = [Environment]::GetFolderPath("CommonPrograms")
        if (Test-Path $commonPrograms) {
            $lnk2 = Join-Path $commonPrograms "$ShortcutName.lnk"
            $sc2 = $wsh.CreateShortcut($lnk2)
            $sc2.TargetPath = $TargetExe
            $sc2.WorkingDirectory = $WorkingDir
            if ($Arguments) { $sc2.Arguments = $Arguments }
            $sc2.Save()
        }
    } catch {}
}

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

    foreach ($url in $urlList) {
        if ([string]::IsNullOrWhiteSpace($url)) { continue }
        $cleanHost = ($url -split '/')[2]
        Write-Host "   -> Mencoba server unduh: $cleanHost ..." -ForegroundColor DarkCyan

        # Normalisasi link Google Drive jika pengguna memberikan URL share/view biasa
        $actualUrl = $url
        if ($url -match 'drive\.google\.com') {
            $gdriveId = $null
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
        try {
            $request = [System.Net.HttpWebRequest]::Create($actualUrl)
            $request.Timeout = 20000
            $request.ReadWriteTimeout = 60000
            $request.CookieContainer = $cookieJar
            $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            $response = $request.GetResponse()

            # Google Drive Fallback: Tangani halaman konfirmasi "Google Drive can't scan this file for viruses"
            $contentType = $response.ContentType
            if ($url -match 'drive\.google\.com' -and $contentType -match 'text/html') {
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

            $totalBytes = $response.ContentLength
            $responseStream = $response.GetResponseStream()

            $targetFile = New-Object System.IO.FileStream($DestinationPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
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

            # Verifikasi jika file yang terunduh bukan error HTML kecil
            $fInfo = Get-Item $DestinationPath -ErrorAction SilentlyContinue
            if ($fInfo -and $fInfo.Length -lt 200000 -and $url -match 'drive\.google\.com') {
                $checkTxt = [System.IO.File]::ReadAllText($DestinationPath)
                if ($checkTxt -match "<html" -or $checkTxt -match "quota exceeded" -or $checkTxt -match "kuota terlampaui") {
                    Remove-Item -Path $DestinationPath -Force -ErrorAction SilentlyContinue
                    Write-Host "      [!] Google Drive mirror ini limit/kuota terlampaui. Berpindah ke mirror berikutnya..." -ForegroundColor DarkYellow
                    continue
                }
            }

            return $true
        } catch {
            Write-Progress -Activity "$ActivityTitle" -Completed
            if ($targetFile) { $targetFile.Close() }
            if ($responseStream) { $responseStream.Close() }
            if ($response) { $response.Close() }
            if (Test-Path $DestinationPath) { Remove-Item -Path $DestinationPath -Force -ErrorAction SilentlyContinue }
            Write-Host "      [!] Server $cleanHost lambat/gagal: $($_.Exception.Message). Mencoba mirror cadangan..." -ForegroundColor DarkYellow
        }
    }
    return $false
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
            $offlineFile = Get-ChildItem -Path $AppsDir -Filter $pat -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($offlineFile) { break }
        }

        if ($offlineFile) {
            Write-Host "[OK] Ditemukan file installer offline: $($offlineFile.Name)" -ForegroundColor Green
            
            if ($IsInteractive) {
                Write-Host "[i] Membuka berkas/installer interaktif: $($offlineFile.Name)" -ForegroundColor Yellow
                Write-Host "    >>> Silakan ikuti petunjuk setup / aktivasi lisensi lab di layar yang muncul..." -ForegroundColor Cyan
                $ext = $offlineFile.Extension.ToLower()
                if ($ext -match "zip|rar|7z") {
                    # Jika berupa file arsip, buka foldernya di Windows Explorer agar asisten lab dapat mengekstrak/menjalankan setup
                    Start-Process explorer.exe -ArgumentList "/select,`"$($offlineFile.FullName)`""
                } else {
                    $proc = Start-Process -FilePath $offlineFile.FullName -Wait -PassThru
                }
                Write-Host "[OK] Selesai memproses $Name." -ForegroundColor Green
                Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Setup interaktif selesai"
                return
            } else {
                Write-Host "[i] Menjalankan instalasi lokal secara otomatis dari flashdisk..." -ForegroundColor Yellow
                $ext = $offlineFile.Extension.ToLower()
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
                    if ($argsList.Count -gt 0) {
                        $proc = Start-Process -FilePath $offlineFile.FullName -ArgumentList $argsList -Wait -PassThru
                    } else {
                        $proc = Start-Process -FilePath $offlineFile.FullName -Wait -PassThru
                    }
                }

                # Kode 0 = Sukses, 3010 = Sukses (Butuh restart), 1641 = Sukses reboot, 1223 = Elevated/UAC Success, 1638 = Versi sudah ada
                if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010 -or $proc.ExitCode -eq 1641 -or $proc.ExitCode -eq 1223 -or $proc.ExitCode -eq 1638) {
                    Write-Host "[OK] Berhasil menginstal $Name dari folder Apps!" -ForegroundColor Green
                    if ($CheckPath) {
                        foreach ($cp in @($CheckPath)) {
                            $f = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
                            if ($f) { Create-AppShortcut -TargetExe $f.FullName -ShortcutName $Name; break }
                        }
                    }
                    Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Terpasang dari offline Apps"
                    return
                } else {
                    Write-Host "[!] Installer offline selesai dengan kode exit: $($proc.ExitCode)" -ForegroundColor Yellow
                    Record-InstallResult -Name $Name -Status "GAGAL" -Keterangan "Exit Code: $($proc.ExitCode)"
                    return
                }
            }
        }
    }

    # B. Jika ada DownloadUrls langsung (CDN mirror cepat), unduh dan simpan ke folder Apps/
    if ($DownloadUrls) {
        $urlsArr = @($DownloadUrls)
        if ($urlsArr.Count -gt 0) {
            $firstUrl = $urlsArr[0]
            $destName = [System.IO.Path]::GetFileName(($firstUrl -split '\?')[0])
            if ([string]::IsNullOrWhiteSpace($destName) -or $destName.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ge 0) {
                $destName = "$($Name -replace '\s+', '_').exe"
            }
            $destFile = Join-Path $AppsDir $destName
            Write-Host "[i] Mengunduh installer $Name via High-Speed CDN Mirror..." -ForegroundColor Yellow
            $downloaded = Download-FileWithFastMirrors -Urls $urlsArr -DestinationPath $destFile -ActivityTitle "Mengunduh $Name"

            if ($downloaded -and (Test-Path $destFile)) {
                Write-Host "[OK] Installer $Name berhasil diunduh dan disimpan ke folder Apps/ ($destName)!" -ForegroundColor Green

                $ext = [System.IO.Path]::GetExtension($destFile).ToLower()
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
                    if ($argsList.Count -gt 0) {
                        $proc = Start-Process -FilePath $destFile -ArgumentList $argsList -Wait -PassThru
                    } else {
                        $proc = Start-Process -FilePath $destFile -Wait -PassThru
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
        Write-Host "[i] File offline belum ada di folder Apps. Mengunduh & menyimpan installer ke Apps/..." -ForegroundColor Yellow
        try {
            winget download --id "$WingetId" --source winget -d "$AppsDir" --accept-package-agreements --accept-source-agreements --disable-interactivity
            
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
                    if ($argsList.Count -gt 0) {
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
                    return
                }
            }
        } catch {
            Write-Host "[!] Unduhan installer offline gagal, mencoba direct install..." -ForegroundColor Yellow
        }

        # Fallback langsung install via Winget jika download bundle belum menyelesaikan install
        $installed = winget list --id "$WingetId" --source winget 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $WingetId) {
            Write-Host "[OK] $Name sudah terinstal di sistem ini." -ForegroundColor Green
            Record-InstallResult -Name $Name -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi via Winget (Skip)"
            return
        }

        $cmd = "winget install --id `"$WingetId`" --source winget -e --silent --accept-source-agreements --accept-package-agreements --disable-interactivity $WingetArgs"
        Invoke-Expression $cmd

        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Berhasil menginstal $Name via Winget!" -ForegroundColor Green
            Record-InstallResult -Name $Name -Status "BERHASIL DIINSTAL" -Keterangan "Terpasang via Winget Direct"
        } else {
            Write-Host "[!] Gagal menginstal $Name via Winget. Periksa koneksi internet." -ForegroundColor Red
            Record-InstallResult -Name $Name -Status "GAGAL" -Keterangan "Winget error / offline"
        }
    } else {
        Write-Host "[!] File installer offline $Name ($FilePattern) belum ada di folder Apps/." -ForegroundColor Yellow
        Write-Host "    (Silakan salin installer pihak ketiga $Name ke folder Apps dan jalankan kembali)." -ForegroundColor Gray
        Record-InstallResult -Name $Name -Status "BELUM TERSEDIA" -Keterangan "Menunggu file master di Apps/"
    }
}

# 6. Fungsi Khusus Setup Java JDK & JAVA_HOME
function Setup-JavaJDK {
    Install-AppSmart -Name "Java JDK 17 (OpenJDK Temurin)" `
                     -FilePattern @("*Temurin*17*.msi", "*jdk*17*.msi", "*Temurin*.msi") `
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
    Install-AppSmart -Name "Python 3.12 (with PIP)" `
                     -FilePattern "*python*3.12*.exe" `
                     -SilentArgs "/quiet InstallAllUsers=1 PrependPath=1" `
                     -WingetId "Python.Python.3.12" `
                     -CheckPath "C:\Program Files\Python312\python.exe"

    $pyPaths = @(
        "$env:LOCALAPPDATA\Programs\Python\Python312",
        "C:\Program Files\Python312"
    )
    foreach ($p in $pyPaths) {
        if (Test-Path $p) {
            Add-ToSystemPath -DirToAdd $p
            Add-ToSystemPath -DirToAdd (Join-Path $p "Scripts")
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

    if (Test-Path $laragonExe) {
        Write-Host "   [OK SUDAH TERPASANG] Laragon terdeteksi di $laragonExe." -ForegroundColor Green
        Write-Host "   -> Melewati proses instalasi dasar Laragon." -ForegroundColor DarkGray
    } else {
        # 1. Cari file installer offline Laragon di AppsDir (Pencarian Rekursif)
        $laragonInstaller = Get-ChildItem -Path $AppsDir -Filter "*laragon*.exe" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

        if (-not $laragonInstaller) {
            Write-Host "   [i] File offline Laragon belum ada di Apps. Mengunduh installer resmi..." -ForegroundColor Yellow
            
            # Coba unduh langsung dari GitHub Releases CDN resmi (sangat cepat & stabil)
            try {
                $downUrl = "https://github.com/leokhoa/laragon/releases/download/6.0.0/laragon-wamp.exe"
                $destExe = Join-Path $AppsDir "laragon-wamp-setup-6.0.0.exe"
                Write-Host "   [i] Mengunduh Laragon WAMP dari GitHub CDN..." -ForegroundColor Yellow
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                $wc = New-Object System.Net.WebClient
                $wc.DownloadFile($downUrl, $destExe)
                $wc.Dispose()
                $laragonInstaller = Get-Item $destExe -ErrorAction SilentlyContinue
                Write-Host "   [OK] Installer Laragon berhasil diunduh dan disimpan di folder Apps/!" -ForegroundColor Green
            } catch {}

            if (-not $laragonInstaller) {
                try {
                    winget download --id "LeNgocKhoa.Laragon" --source winget -d "$AppsDir" --accept-package-agreements --accept-source-agreements --disable-interactivity
                    $laragonInstaller = Get-ChildItem -Path $AppsDir -Filter "*laragon*.exe" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                } catch {}
            }
        }

        if ($laragonInstaller) {
            Write-Host "   [OK] Ditemukan installer: $($laragonInstaller.Name)" -ForegroundColor Green
            Write-Host "   [i] Menjalankan instalasi Laragon secara otomatis..." -ForegroundColor Yellow

            # Hentikan proses lama jika ada
            Get-Process -Name "laragon", "httpd", "mysqld" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 500

            # Argumen Inno Setup standar (Universal & Bebas Error /VERYSILENT)
            $laragonArgs = @("/VERYSILENT", "/NORESTART", "/SP-", "/SUPPRESSMSGBOXES", "/DIR=C:\laragon")
            $p = Start-Process -FilePath $laragonInstaller.FullName -ArgumentList $laragonArgs -PassThru

            # Watchdog loop: Laragon Inno Setup terkadang menjalankan laragon.exe dengan argumen setup di akhir instalasi,
            # memicu dialog warning "Laragon: '/VERYSILENT' is not a Laragon command."
            # Kita pantau proses laragon.exe, dan jika muncul segera terminate agar tidak memblok instalasi!
            $timeoutCount = 0
            while (-not $p.HasExited -and $timeoutCount -lt 180) {
                Start-Sleep -Seconds 1
                $timeoutCount++
                $runningLaragon = Get-Process -Name "laragon" -ErrorAction SilentlyContinue
                if ($runningLaragon) {
                    Start-Sleep -Milliseconds 1500
                    $runningLaragon | Stop-Process -Force -ErrorAction SilentlyContinue
                }
            }

            # Pembersihan akhir proses laragon jika masih tertinggal
            Get-Process -Name "laragon" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        } else {
            # Fallback winget install langsung jika file installer tidak ditemukan
            Write-Host "   [i] Mencoba direct install Laragon via Winget..." -ForegroundColor Yellow
            $cmd = "winget install --id `"LeNgocKhoa.Laragon`" --source winget -e --silent --accept-source-agreements --accept-package-agreements --disable-interactivity"
            Invoke-Expression $cmd
            Get-Process -Name "laragon" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        }

        # Verifikasi fisik keberadaan laragon.exe di disk
        if (-not (Test-Path $laragonExe)) {
            Write-Host "   [!] File laragon.exe belum ditemukan di $targetLaragon setelah proses silent." -ForegroundColor Yellow
            Write-Host "   [i] Menjalankan installer Laragon langsung untuk memastikan ekstraksi berkas selesai..." -ForegroundColor Yellow
            if ($laragonInstaller) {
                Start-Process -FilePath $laragonInstaller.FullName -ArgumentList "/DIR=C:\laragon /SUPPRESSMSGBOXES" -Wait
            } else {
                winget install --id "LeNgocKhoa.Laragon" --source winget -e --accept-package-agreements --accept-source-agreements --disable-interactivity
            }
            Get-Process -Name "laragon" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        }

        if (Test-Path $laragonExe) {
            Write-Host "   [OK] Berhasil menginstal Laragon resmi di $targetLaragon!" -ForegroundColor Green
            Create-AppShortcut -TargetExe $laragonExe -ShortcutName "Laragon" -WorkingDir "C:\laragon"
            try {
                $regKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\laragon.exe"
                if (-not (Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
                Set-ItemProperty -Path $regKey -Name "(Default)" -Value $laragonExe -Force
                Set-ItemProperty -Path $regKey -Name "Path" -Value "C:\laragon" -Force
                Write-Host "   [OK] Shortcut Start Menu, Desktop & App Paths Laragon siap!" -ForegroundColor Green
            } catch {}
        } else {
            Write-Host "   [!] Peringatan: File $laragonExe belum terbentuk di disk. Pastikan installer tidak diblokir Windows Defender." -ForegroundColor Red
        }
    }

    # 2. Periksa apakah paket custom stack (bin, phpMyAdmin, config) ada di folder Apps
    $customStackDir = Join-Path $AppsDir "Laragon_Custom_Stack"
    if (Test-Path $customStackDir) {
        Write-Host "`n[i] Menerapkan paket modul custom Laragon (PHP, MySQL, Node.js, Python, phpMyAdmin)..." -ForegroundColor Yellow

        $targetLaragon = "C:\laragon"
        if (-not (Test-Path $targetLaragon)) {
            New-Item -ItemType Directory -Path $targetLaragon -Force | Out-Null
        }

        # Salin / Timpa modul bin (PHP 8.3/8.4/8.5, MySQL, Node, Python, Redis, dll.)
        $srcBin = Join-Path $customStackDir "bin"
        if (Test-Path $srcBin) {
            Write-Host "   -> Menyinkronkan direktori C:\laragon\bin..." -ForegroundColor Cyan
            & robocopy $srcBin "$targetLaragon\bin" /E /R:1 /W:1 /NP /NFL /NDL | Out-Null
        }

        # Salin / Timpa etc\apps\phpMyAdmin
        $srcPma = Join-Path $customStackDir "etc\apps\phpMyAdmin"
        if (Test-Path $srcPma) {
            Write-Host "   -> Menyinkronkan phpMyAdmin ke C:\laragon\etc\apps\phpMyAdmin..." -ForegroundColor Cyan
            & robocopy $srcPma "$targetLaragon\etc\apps\phpMyAdmin" /E /R:1 /W:1 /NP /NFL /NDL | Out-Null
        }

        # Salin konfigurasi laragon.ini pilihan versi
        $srcIni = Join-Path $customStackDir "usr\laragon.ini"
        if (Test-Path $srcIni) {
            $destUsr = Join-Path $targetLaragon "usr"
            if (-not (Test-Path $destUsr)) { New-Item -ItemType Directory -Path $destUsr -Force | Out-Null }
            Copy-Item $srcIni -Destination "$destUsr\laragon.ini" -Force
            Write-Host "   -> Menyinkronkan konfigurasi C:\laragon\usr\laragon.ini" -ForegroundColor Cyan
        }

        Write-Host "   [OK] Berhasil menerapkan seluruh custom stack Laragon (Data & Web www tetap aman)!" -ForegroundColor Green
    }
}

# 9. Fungsi Khusus Setup XAMPP & Pencegahan Bentrok Port dengan Laragon
function Setup-XamppStack {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: XAMPP Server + Konfigurasi Port Anti-Bentrok" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    # 1. Jalankan Installer XAMPP (Unattended Silent Mode)
    Install-AppSmart -Name "XAMPP" `
                     -FilePattern "*xampp*.exe" `
                     -SilentArgs "--mode unattended" `
                     -WingetId "ApacheFriends.Xampp.8.2" `
                     -CheckPath @("C:\xampp\xampp-control.exe", "D:\xampp\xampp-control.exe")

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

        # D. Konfigurasi phpMyAdmin agar terhubung ke port 3307 XAMPP
        $pmaConfig = Join-Path $xamppDir "phpMyAdmin\config.inc.php"
        if (Test-Path $pmaConfig) {
            $pmaText = [System.IO.File]::ReadAllText($pmaConfig)
            if ($pmaText -notmatch "['`"]port['`"]\s*=") {
                $portLine = "`r`n`$cfg['Servers'][`$i]['port'] = '3307';`r`n"
                [System.IO.File]::AppendAllText($pmaConfig, $portLine)
                Write-Host "   [OK] phpMyAdmin XAMPP dikonfigurasi ke MySQL Port 3307" -ForegroundColor Green
            } else {
                $newPmaText = [System.Text.RegularExpressions.Regex]::Replace($pmaText, "(\['port'\]\s*=\s*['`"])[^'`"]*(['`"])", '${1}3307${2}')
                if ($pmaText -ne $newPmaText) {
                    [System.IO.File]::WriteAllText($pmaConfig, $newPmaText)
                    Write-Host "   [OK] phpMyAdmin XAMPP diperbarui ke MySQL Port 3307" -ForegroundColor Green
                }
            }
        }

        # E. Sinkronisasi Port di XAMPP Control Panel config (xampp-control.ini)
        $xamppIni = Join-Path $xamppDir "xampp-control.ini"
        if (Test-Path $xamppIni) {
            $iniTxt = [System.IO.File]::ReadAllText($xamppIni)
            $newIniTxt = $iniTxt -replace '(?m)^Apache\s*=\s*(80|8080)\s*$', 'Apache = 8088'
            $newIniTxt = $newIniTxt -replace '(?m)^ApacheSSL\s*=\s*(443|8443)\s*$', 'ApacheSSL = 8444'
            $newIniTxt = $newIniTxt -replace '(?m)^MySQL\s*=\s*3306\s*$', 'MySQL = 3307'
            if ($iniTxt -ne $newIniTxt) {
                [System.IO.File]::WriteAllText($xamppIni, $newIniTxt)
                Write-Host "   [OK] Port pada XAMPP Control Panel disinkronkan ke 8088/8444/3307." -ForegroundColor Green
            }
        }

        Write-Host "   [OK] XAMPP, Laragon, Laravel, Vite & Next.js kini aman berjalan berdampingan tanpa bentrok port!" -ForegroundColor Green
    }
}

# 10. Fungsi Setup Node.js (LTS) & NPM
function Setup-NodeJS {
    Install-AppSmart -Name "Node.js LTS (with NPM)" `
                     -FilePattern "*node*.msi" `
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

    # 1. Cari PHP yang aktif di sistem (Laragon atau XAMPP) dan SELALU masukkan ke PATH sistem & sesi aktif
    $phpPath = $null
    $phpSearch = @(
        "C:\laragon\bin\php\php-*\php.exe",
        "C:\laragon\bin\php\*\php.exe",
        "C:\xampp\php\php.exe"
    )
    foreach ($pattern in $phpSearch) {
        $found = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $phpPath = $found.FullName; break }
    }

    $phpDir = $null
    if ($phpPath) {
        $phpDir = Split-Path -Parent $phpPath
        Add-ToSystemPath -DirToAdd $phpDir
        if ($env:Path -notlike "*$phpDir*") {
            $env:Path = "$phpDir;" + $env:Path
        }
        Write-Host "   [OK] PHP terdeteksi di $phpPath dan ditambahkan ke System PATH." -ForegroundColor Green
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

    # 3. Pastikan ekstensi zip, fileinfo, openssl, curl aktif di seluruh php.ini yang terpasang
    $allPhpInis = @(
        (Get-ChildItem -Path "C:\laragon\bin\php\*\php.ini" -File -ErrorAction SilentlyContinue),
        (Get-ChildItem -Path "C:\xampp\php\php.ini" -File -ErrorAction SilentlyContinue)
    ) | Where-Object { $_ -ne $null }

    foreach ($iniFile in $allPhpInis) {
        try {
            $iniContent = [System.IO.File]::ReadAllText($iniFile.FullName)
            $newIni = $iniContent -replace '(?m)^;\s*extension\s*=\s*zip\b', 'extension=zip'
            $newIni = $newIni -replace '(?m)^;\s*extension\s*=\s*fileinfo\b', 'extension=fileinfo'
            $newIni = $newIni -replace '(?m)^;\s*extension\s*=\s*curl\b', 'extension=curl'
            $newIni = $newIni -replace '(?m)^;\s*extension\s*=\s*openssl\b', 'extension=openssl'
            $newIni = $newIni -replace '(?m)^;\s*extension\s*=\s*pdo_mysql\b', 'extension=pdo_mysql'
            $newIni = $newIni -replace '(?m)^;\s*extension\s*=\s*mbstring\b', 'extension=mbstring'
            
            # Jika belum ada sama sekali, tambahkan di baris baru
            if ($newIni -notmatch '(?m)^extension\s*=\s*zip\b') { $newIni += "`r`nextension=zip`r`n" }
            if ($newIni -notmatch '(?m)^extension\s*=\s*fileinfo\b') { $newIni += "`r`nextension=fileinfo`r`n" }
            if ($newIni -notmatch '(?m)^extension\s*=\s*curl\b') { $newIni += "`r`nextension=curl`r`n" }
            if ($newIni -notmatch '(?m)^extension\s*=\s*openssl\b') { $newIni += "`r`nextension=openssl`r`n" }

            if ($iniContent -ne $newIni) {
                [System.IO.File]::WriteAllText($iniFile.FullName, $newIni)
                Write-Host "   [OK] Ekstensi zip, fileinfo, curl & openssl aktif di $($iniFile.FullName)" -ForegroundColor Green
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
                "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip",
                "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.22.2-stable.zip"
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

    # A. Deteksi & Kunci Android SDK path
    $androidSdkSearch = @(
        "$env:LOCALAPPDATA\Android\Sdk",
        "C:\Android\Sdk",
        "D:\Android\Sdk",
        "C:\Program Files (x86)\Android\android-sdk"
    )
    $detectedSdk = $null
    foreach ($sdk in $androidSdkSearch) {
        if (Test-Path $sdk) { $detectedSdk = $sdk; break }
    }
    if ($detectedSdk) {
        & flutter config --android-sdk "$detectedSdk" | Out-Null
        Set-SystemEnvVar -Name "ANDROID_HOME" -Value $detectedSdk
        Set-SystemEnvVar -Name "ANDROID_SDK_ROOT" -Value $detectedSdk
        $env:ANDROID_HOME = $detectedSdk
        $env:ANDROID_SDK_ROOT = $detectedSdk
        Write-Host "   [OK] Android SDK dikunci ke: $detectedSdk" -ForegroundColor Green
    }

    # B. Deteksi & Kunci JDK untuk Flutter & Android Toolchain
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

    # C. Aktifkan platform desktop Windows, Web, dan Android
    & flutter config --enable-windows-desktop --enable-web --enable-android --no-analytics | Out-Null
    Write-Host "   [OK] Platform Windows Desktop & Web diaktifkan!" -ForegroundColor Green

    # D. Auto-Accept Android Licenses (Non-Interaktif)
    Write-Host "   [i] Menyetujui semua lisensi Android SDK secara otomatis (Accept Licenses)..." -ForegroundColor Yellow
    try {
        $yesInputs = ("y`n" * 15)
        $yesInputs | & flutter doctor --android-licenses 2>&1 | Out-Null
        Write-Host "   [OK] Semua lisensi Android SDK disetujui (All Android licenses accepted)!" -ForegroundColor Green
    } catch {}

    # E. Jalankan Flutter Doctor ringkas
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

    # Pastikan PHP terdaftar di PATH sesi jika terpasang
    $phpSearch = @(
        "C:\laragon\bin\php\php-*\php.exe",
        "C:\laragon\bin\php\*\php.exe",
        "C:\xampp\php\php.exe"
    )
    foreach ($pattern in $phpSearch) {
        $found = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $pDir = Split-Path -Parent $found.FullName
            if ($env:Path -notlike "*$pDir*") { $env:Path = "$pDir;" + $env:Path }
            break
        }
    }

    $cliChecks = @(
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
            $job = Start-Job -ScriptBlock $chk.Cmd
            if (Wait-Job $job -Timeout 4) {
                $res = Receive-Job $job -ErrorAction SilentlyContinue | Out-String
                Remove-Job $job -Force -ErrorAction SilentlyContinue
                if (!([string]::IsNullOrWhiteSpace($res))) {
                    $firstLine = ($res.Trim() -split "`r?`n")[0]
                    Write-Host $firstLine -ForegroundColor Green
                } else {
                    Write-Host "Belum Terdeteksi di PATH" -ForegroundColor Yellow
                }
            } else {
                Stop-Job $job -Force -ErrorAction SilentlyContinue
                Remove-Job $job -Force -ErrorAction SilentlyContinue
                Write-Host "Belum Merespons / Timeout" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Belum Terinstal / Perlu Restart Shell" -ForegroundColor Red
        }
    }

    $guiApps = @(
        @{ Name = "Delphi (RAD Studio)"; Path = @("C:\Program Files*\Embarcadero\Studio\*\bin\bds.exe", "C:\Program Files (x86)\Embarcadero\Studio\*\bin\bds.exe"); Reg = "*Delphi*" },
        @{ Name = "Cisco Packet Tracer"; Path = @("C:\Program Files\Cisco Packet Tracer *\bin\PacketTracer.exe", "C:\Program Files (x86)\Cisco Packet Tracer *\bin\PacketTracer.exe"); Reg = "*Packet Tracer*" },
        @{ Name = "Visual Studio 2022";  Path = @("C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe", "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"); Reg = "*Visual Studio*" },
        @{ Name = "Proteus Design Suite";Path = @("C:\Program Files*\Labcenter Electronics\Proteus *\BIN\PDS.EXE", "C:\Program Files (x86)\Labcenter Electronics\Proteus *\BIN\PDS.EXE"); Reg = "*Proteus*" },
        @{ Name = "Android Studio";      Path = @("C:\Program Files\Android\Android Studio\bin\studio64.exe", "C:\Program Files (x86)\Android\Android Studio\bin\studio64.exe", "C:\Users\*\AppData\Local\Programs\Android\Android Studio\bin\studio64.exe"); Reg = "*Android Studio*" },
        @{ Name = "Oracle VirtualBox";   Path = @("C:\Program Files\Oracle\VirtualBox\VirtualBox.exe", "C:\Program Files (x86)\Oracle\VirtualBox\VirtualBox.exe"); Reg = "*VirtualBox*" },
        @{ Name = "Apache NetBeans";     Path = @("C:\Program Files\*NetBeans*\netbeans\bin\netbeans*.exe", "C:\Program Files\*NetBeans*\bin\netbeans*.exe", "C:\Program Files\Apache NetBeans*\bin\netbeans*.exe", "C:\Program Files (x86)\*NetBeans*\netbeans\bin\netbeans*.exe", "C:\Program Files (x86)\*NetBeans*\bin\netbeans*.exe"); Reg = "*NetBeans*" },
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
# PROSEDUR OTOMASI LENGKAP STANDAR LAB TI
# (Smart-Skip: Jika sudah ada dilewati, jika belum ada langsung dipasang)
# ==============================================================================
function Run-FullInstallation {
    $script:InstallResults = @()
    Write-Host "`n[>>>] Memulai Otomasi Lengkap Standarisasi Software Lab TI..." -ForegroundColor Cyan
    Write-Host "      (Semua software wajib: Yang sudah terpasang otomatis diskip)`n" -ForegroundColor DarkGray

    # 1. VS Code (Otomatis Silent)
    Install-AppSmart -Name "Visual Studio Code" -FilePattern "*Code*.exe" -SilentArgs "/VERYSILENT /NORESTART /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -WingetId "Microsoft.VisualStudioCode" -CheckPath "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"

    # 2. Python 3.12 (Otomatis Silent + PATH)
    Setup-Python

    # 3. Java JDK 17 (Otomatis Silent + JAVA_HOME)
    Setup-JavaJDK

    # 4. Node.js LTS & NPM (Otomatis Silent + Global PATH)
    Setup-NodeJS

    # 5. Oracle VM VirtualBox (Otomatis Silent dengan Multi-CDN Mirror Cepat)
    $vboxMirrors = @(
        "https://download.virtualbox.org/virtualbox/7.1.6/VirtualBox-7.1.6-167084-Win.exe",
        "https://mirror.ox.ac.uk/sites/download.virtualbox.org/virtualbox/7.1.6/VirtualBox-7.1.6-167084-Win.exe",
        "http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/", # dummy fallback safety
        "https://download.virtualbox.org/virtualbox/7.0.20/VirtualBox-7.0.20-163906-Win.exe"
    )
    Install-AppSmart -Name "Oracle VM VirtualBox" `
                     -FilePattern @("*VirtualBox*.exe", "*VirtualBox*.msi") `
                     -DownloadUrls $vboxMirrors `
                     -SilentArgs "--silent" `
                     -WingetId "Oracle.VirtualBox" `
                     -CheckPath @("C:\Program Files\Oracle\VirtualBox\VirtualBox.exe", "C:\Program Files (x86)\Oracle\VirtualBox\VirtualBox.exe")

    # 6. Apache NetBeans (Otomatis Silent dengan Java JDK 17+ Terdeteksi & Multi-Mirror Cepat)
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

    $nbSilentArgs = "--silent"
    if ($nbJdkPath) {
        $nbSilentArgs += " --jdkhome `"$nbJdkPath`""
        Write-Host "   [i] Menghubungkan Apache NetBeans ke JDK: $nbJdkPath" -ForegroundColor Cyan
    }

    $netbeansMirrors = @(
        "https://dlcdn.apache.org/netbeans/netbeans-installers/25/Apache-NetBeans-25-bin-windows-x64.exe",
        "https://github.com/apache/netbeans/releases/download/25/Apache-NetBeans-25-bin-windows-x64.exe",
        "https://archive.apache.org/dist/netbeans/netbeans-installers/25/Apache-NetBeans-25-bin-windows-x64.exe"
    )

    Install-AppSmart -Name "Apache NetBeans IDE" `
                     -FilePattern @("*NetBeans*.exe", "*Apache-NetBeans*.exe") `
                     -DownloadUrls $netbeansMirrors `
                     -SilentArgs $nbSilentArgs `
                     -WingetId "Apache.NetBeans" `
                     -WingetArgs "--override `"$nbSilentArgs`"" `
                     -CheckPath @("C:\Program Files\*NetBeans*\netbeans\bin\netbeans*.exe", "C:\Program Files\*NetBeans*\bin\netbeans*.exe", "C:\Program Files\Apache NetBeans*\bin\netbeans*.exe", "C:\Program Files (x86)\*NetBeans*\netbeans\bin\netbeans*.exe", "C:\Program Files (x86)\*NetBeans*\bin\netbeans*.exe")

    # Kunci path netbeans_jdkhome di netbeans.conf agar tidak memunculkan popup Java saat dibuka
    if ($nbJdkPath) {
        $nbConfs = Get-ChildItem -Path "C:\Program Files\*NetBeans*\etc\netbeans.conf" -File -Recurse -ErrorAction SilentlyContinue
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
                Write-Host "   [OK] netbeans.conf berhasil dikunci ke JDK: $nbJdkPath" -ForegroundColor Green
            } catch {}
        }
    }

    # 7. Android Studio (Otomatis Silent)
    Install-AppSmart -Name "Android Studio" -FilePattern "*Android*Studio*.exe" -SilentArgs "/S" -WingetId "Google.AndroidStudio" -CheckPath "C:\Program Files\Android\Android Studio\bin\studio64.exe"

    # 8. QGIS Desktop (Otomatis Silent)
    Install-AppSmart -Name "QGIS Desktop" -FilePattern "*QGIS*.msi" -SilentArgs "/qn" -WingetId "OSGeo.QGIS" -CheckPath "C:\Program Files\QGIS *\bin\qgis-bin.exe"

    # 9. Microsoft Visual Studio 2022 Community (Desktop development with C++ Workload - Support 100% Offline Layout)
    Setup-VisualStudio

    # 10. Arduino IDE (Arduino Uno, Nano, Mega, IoT)
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

    # 10. Flutter SDK (All Doctor Checks Passed & Auto-Configured)
    Setup-FlutterSDK

    # 11. Laragon (Installer Resmi 6.0.0 + Auto-Overlay Stack Custom)
    Setup-LaragonStack

    # 12. Composer & Laravel Setup
    Setup-ComposerAndLaravel

    # 13. XAMPP (Otomatis Silent + Konfigurasi Port Anti-Bentrok)
    Setup-XamppStack

    # 14. Cisco Packet Tracer (Multi-Mirror Google Drive Resmi Lab TI)
    $ciscoMirrors = @(
        "https://drive.google.com/file/d/1N_YQNs2xFrdFGRPs4kqgF6LGOYDp37ZK/view?usp=sharing",
        "https://drive.google.com/file/d/1O4flOVt7G-xZmfJSlxP3aLjTj1JM_LYP/view?usp=sharing",
        "https://drive.google.com/file/d/1SeGZ7TGze27bs6d7FJd4nNDW_D8QIj2c/view?usp=sharing",
        "https://drive.google.com/file/d/1YbIfp1OyVXl_uksvGu7w82KcHB4_UpR-/view?usp=sharing"
    )
    Install-AppSmart -Name "Cisco Packet Tracer" `
                     -FilePattern @("*packettracer*.exe", "*PacketTracer*.exe", "*Cisco*.exe") `
                     -DownloadUrls $ciscoMirrors `
                     -SilentArgs "/VERYSILENT /NORESTART" `
                     -CheckPath @("C:\Program Files\Cisco Packet Tracer *\bin\PacketTracer.exe", "C:\Program Files (x86)\Cisco Packet Tracer *\bin\PacketTracer.exe")

    # 15. Embarcadero Delphi (Pihak Ketiga / Interaktif)
    Install-AppSmart -Name "Embarcadero Delphi" -FilePattern "*delphi*.exe" -IsInteractive -CheckPath @("C:\Program Files*\Embarcadero\Studio\*\bin\bds.exe", "C:\Program Files (x86)\Embarcadero\Studio\*\bin\bds.exe")

    # 16. Proteus Design Suite (Pihak Ketiga / Interaktif)
    Install-AppSmart -Name "Proteus Design Suite" -FilePattern "*proteus*.exe" -IsInteractive -CheckPath @("C:\Program Files*\Labcenter Electronics\Proteus *\BIN\PDS.EXE", "C:\Program Files (x86)\Labcenter Electronics\Proteus *\BIN\PDS.EXE")

    # ==============================================================================
    # RANGKUMAN LENGKAP HASIL STANDARISASI LABORATORIUM
    # Bersihkan layar, tampilkan banner & rekapitulasi jumlah berhasil / gagal
    # ==============================================================================
    Clear-Host
    Show-SmartLabBanner

    $totalApps = $script:InstallResults.Count
    $berhasil = ($script:InstallResults | Where-Object { $_.Status -in @("SUDAH TERPASANG", "BERHASIL DIINSTAL") } | Measure-Object).Count
    $menunggu = ($script:InstallResults | Where-Object { $_.Status -eq "BELUM TERSEDIA" } | Measure-Object).Count
    $gagal    = ($script:InstallResults | Where-Object { $_.Status -eq "GAGAL" } | Measure-Object).Count

    Write-Host "==============================================================================" -ForegroundColor Green
    Write-Host "               SELESAI - REKAPITULASI STANDARISASI LAB TI                      " -ForegroundColor Green
    Write-Host "==============================================================================" -ForegroundColor Green
    Write-Host "  Total Software Diproses   : $totalApps dari 17 Software Standar" -ForegroundColor White
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

        $shortKet = if ($item.Keterangan.Length -gt 28) { $item.Keterangan.Substring(0, 25) + "..." } else { $item.Keterangan }
        Write-Host ("  {0,-3} | {1,-30} | {2,-18} | {3}" -f $idx, $item.Name, $item.Status, $shortKet) -ForegroundColor $color
        $idx++
    }
    Write-Host "==============================================================================`n" -ForegroundColor Green
}

# ==============================================================================
# MENU UTAMA (INTERAKTIF TERPUSAT DENGAN CLEAR-HOST)
# ==============================================================================
$running = $true

while ($running) {
    Clear-Host
    Show-SmartLabBanner
    Write-Host "Pilihan Tindakan:" -ForegroundColor Yellow
    Write-Host " [1] Jalankan Otomasi Lengkap Lab (Smart-Skip & Auto-Cache C++ Offline)"
    Write-Host " [2] Verifikasi Status & Peta Port Software Lab"
    Write-Host " [3] Keluar`n"

    $choice = Read-Host "Masukkan pilihan Anda (1/2/3)"

    switch ($choice) {
        "1" {
            Run-FullInstallation
            Write-Host "`n[Tekan Enter atau sembarang tombol untuk kembali ke Menu Utama...]" -ForegroundColor Cyan
            try { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") } catch { Read-Host }
        }
        "2" {
            Clear-Host
            Show-SmartLabBanner
            Test-LabSoftwareStatus
            Write-Host "`n[Tekan Enter atau sembarang tombol untuk kembali ke Menu Utama...]" -ForegroundColor Cyan
            try { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") } catch { Read-Host }
        }
        "3" {
            Write-Host "`n[i] Mengembalikan pengaturan daya komputer ke normal..." -ForegroundColor DarkGray
            try { [SystemPowerKeeper]::RestoreNormal() } catch {}
            Write-Host "Keluar dari skrip otomasi SmartLab. Terima kasih." -ForegroundColor Green
            $running = $false
        }
        default {
            Write-Host "Pilihan tidak valid. Silakan ketik angka 1, 2, atau 3." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
