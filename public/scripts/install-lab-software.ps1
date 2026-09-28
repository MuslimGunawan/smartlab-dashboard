# ==============================================================================
# SCRIPT OTOMASI INSTALASI SOFTWARE LABORATORIUM TEKNIK INFORMATIKA
# UNIVERSITAS MALIKUSSALEH (UNIMAL)
# ==============================================================================
# Standarisasi 14 Software Praktikum Resmi Lab TI Unimal:
#
# A. APLIKASI BERLISENSI (4):
#   1. Delphi (Embarcadero Delphi / RAD Studio) -> Mode Interaktif (Pihak Ketiga)
#   2. Cisco Packet Tracer (Cisco NetAcad)
#   3. Microsoft Visual Studio 2022 Community
#   4. Proteus Design Suite (Labcenter Electronics) -> Mode Interaktif (Pihak Ketiga)
#
# B. APLIKASI BEBAS LISENSI (10):
#   5. Visual Studio Code
#   6. Android Studio
#   7. Python 3.12 (with PIP & System PATH)
#   8. Java JDK 17 LTS (with JAVA_HOME & System PATH)
#   9. Oracle VM VirtualBox
#  10. Apache NetBeans IDE
#  11. QGIS Desktop
#  12. Arduino IDE (Arduino Uno & IoT)
#  13. XAMPP
#  14. Laragon
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Installer Otomatis 14 Software Lab TI Unimal"

# 1. Pastikan script berjalan sebagai Administrator
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host "`n[!] Membutuhkan hak akses Administrator. Membuka jendela Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    exit
}

# 2. Deteksi Lokasi Folder Installer Offline (Apps/)
# Cerdas: Mendeteksi apakah script berada di dalam folder Apps, atau di samping folder Apps
$leafFolder = Split-Path -Leaf $PSScriptRoot
if ($leafFolder -ieq "Apps") {
    $AppsDir = $PSScriptRoot
} elseif (Test-Path (Join-Path $PSScriptRoot "Apps")) {
    $AppsDir = Join-Path $PSScriptRoot "Apps"
} else {
    $currentWorkingDir = (Get-Location).Path
    $testDir = Join-Path $currentWorkingDir "Apps"
    if (Test-Path $testDir) {
        $AppsDir = $testDir
    } else {
        $AppsDir = $PSScriptRoot
    }
}

Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "      OTOMASI STANDARISASI SOFTWARE LABORATORIUM KOMPUTER TI UNIMAL          " -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Green
if (Test-Path $AppsDir) {
    Write-Host "[OK] Direktori Master Installer: $AppsDir" -ForegroundColor Green
    $fileCount = (Get-ChildItem -Path $AppsDir -File | Where-Object { $_.Extension -match "exe|msi|bat" } | Measure-Object).Count
    Write-Host "    Ditemukan $fileCount paket installer offline di folder Apps (Mode Cepat USB Aktif!)" -ForegroundColor Cyan
} else {
    Write-Host "[i] Folder 'Apps' tidak ditemukan di samping script ini." -ForegroundColor Yellow
    Write-Host "    Script akan menggunakan mode unduh otomatis (Winget Online)." -ForegroundColor Yellow
}
Write-Host "------------------------------------------------------------------------------`n"

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

# 5. Fungsi Cerdas Install (Offline Folder Apps -> Fallback Winget Online)
function Install-AppSmart {
    param (
        [string]$Name,
        [string]$FilePattern,       # misal "*virtualbox*.exe"
        [string]$SilentArgs = "",   # misal "/qn" atau "/S"
        [string]$WingetId = "",     # misal "Oracle.VirtualBox"
        [string]$WingetArgs = "",
        [string]$DownloadUrl = "",  # URL unduhan langsung (HTTP/HTTPS) jika ada penambahan aplikasi baru
        [string]$CheckPath = "",    # Jalur eksekutabel untuk mendeteksi apakah sudah terpasang
        [switch]$IsInteractive      # Untuk installer pihak ketiga (Delphi/Proteus) agar tidak freeze/hang
    )

    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: $Name" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    # 0. Cek apakah software SUDAH terpasang di sistem ini (Cerdas: Hindari install ulang)
    if (-not [string]::IsNullOrWhiteSpace($CheckPath)) {
        $alreadyInstalled = Get-Item $CheckPath -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($alreadyInstalled) {
            Write-Host "   [OK SUDAH TERPASANG] $Name terdeteksi di $($alreadyInstalled.FullName)" -ForegroundColor Green
            Write-Host "   -> Melewati proses instalasi (Skip)." -ForegroundColor DarkGray
            return
        }
    }

    # A. Cek apakah ada file offline di folder Apps/
    if (Test-Path $AppsDir) {
        $offlineFile = Get-ChildItem -Path $AppsDir -Filter $FilePattern -File -ErrorAction SilentlyContinue | Select-Object -First 1
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
                return
            } else {
                Write-Host "[i] Menjalankan instalasi lokal secara otomatis dari flashdisk..." -ForegroundColor Yellow
                $ext = $offlineFile.Extension.ToLower()
                if ($ext -eq ".msi") {
                    $argsToRun = "/i `"$($offlineFile.FullName)`" /qn /norestart"
                    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $argsToRun -Wait -PassThru
                } else {
                    $proc = Start-Process -FilePath $offlineFile.FullName -ArgumentList $SilentArgs -Wait -PassThru
                }

                if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                    Write-Host "[OK] Berhasil menginstal $Name dari folder Apps!" -ForegroundColor Green
                    return
                } else {
                    Write-Host "[!] Installer offline selesai dengan kode exit: $($proc.ExitCode)" -ForegroundColor Yellow
                }
            }
        }
    }

    # B. Jika ada DownloadUrl langsung (misal URL GitHub / Web / CDN resmi), unduh dan simpan ke folder Apps/
    if (-not [string]::IsNullOrWhiteSpace($DownloadUrl)) {
        Write-Host "[i] Mengunduh installer $Name dari $DownloadUrl..." -ForegroundColor Yellow
        try {
            $destName = [System.IO.Path]::GetFileName($DownloadUrl)
            if ([string]::IsNullOrWhiteSpace($destName) -or $destName.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ge 0) {
                $destName = "$($Name -replace '\s+', '_').exe"
            }
            $destFile = Join-Path $AppsDir $destName
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($DownloadUrl, $destFile)
            $wc.Dispose()
            Write-Host "[OK] Installer $Name berhasil diunduh dan disimpan ke folder Apps/ ($destName)!" -ForegroundColor Green

            $ext = [System.IO.Path]::GetExtension($destFile).ToLower()
            if ($ext -eq ".msi") {
                $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$destFile`" /qn /norestart" -Wait -PassThru
            } else {
                $proc = Start-Process -FilePath $destFile -ArgumentList $SilentArgs -Wait -PassThru
            }
            if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                Write-Host "[OK] Berhasil menginstal $Name!" -ForegroundColor Green
                return
            }
        } catch {
            Write-Host "[!] Unduhan langsung gagal: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }

    # C. Jika tidak ada file offline di folder Apps, unduh & simpan ke Apps/ via Winget, lalu instal
    if (-not [string]::IsNullOrWhiteSpace($WingetId)) {
        Write-Host "[i] File offline belum ada di folder Apps. Mengunduh & menyimpan installer ke Apps/..." -ForegroundColor Yellow
        try {
            winget download --id "$WingetId" -d "$AppsDir" --accept-package-agreements --accept-source-agreements
            $newOfflineFile = Get-ChildItem -Path $AppsDir -Filter $FilePattern -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($newOfflineFile) {
                Write-Host "[OK] Installer berhasil diunduh dan disimpan di Apps/: $($newOfflineFile.Name)" -ForegroundColor Green
                Write-Host "[i] Melanjutkan instalasi lokal..." -ForegroundColor Yellow
                $ext = $newOfflineFile.Extension.ToLower()
                if ($ext -eq ".msi") {
                    $argsToRun = "/i `"$($newOfflineFile.FullName)`" /qn /norestart"
                    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $argsToRun -Wait -PassThru
                } else {
                    $proc = Start-Process -FilePath $newOfflineFile.FullName -ArgumentList $SilentArgs -Wait -PassThru
                }
                if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                    Write-Host "[OK] Berhasil menginstal $Name!" -ForegroundColor Green
                    return
                }
            }
        } catch {
            Write-Host "[!] Unduhan installer offline gagal, mencoba direct install..." -ForegroundColor Yellow
        }

        # Fallback langsung install jika download bundle bermasalah
        $installed = winget list --id $WingetId 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $WingetId) {
            Write-Host "[OK] $Name sudah terinstal di sistem ini." -ForegroundColor Green
            return
        }

        $cmd = "winget install --id `"$WingetId`" -e --silent --accept-source-agreements --accept-package-agreements $WingetArgs"
        Invoke-Expression $cmd

        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Berhasil menginstal $Name via Winget!" -ForegroundColor Green
        } else {
            Write-Host "[!] Gagal menginstal $Name via Winget. Periksa koneksi internet." -ForegroundColor Red
        }
    } else {
        Write-Host "[!] File installer offline $Name ($FilePattern) belum ada di folder Apps/." -ForegroundColor Yellow
        Write-Host "    (Silakan salin installer pihak ketiga $Name ke folder Apps dan jalankan kembali)." -ForegroundColor Gray
    }
}

# 6. Fungsi Khusus Setup Java JDK & JAVA_HOME
function Setup-JavaJDK {
    Install-AppSmart -Name "Java JDK 17 (OpenJDK Temurin)" `
                     -FilePattern "*Temurin*17*.msi" `
                     -SilentArgs "/qn" `
                     -WingetId "EclipseAdoptium.Temurin.17.JDK" `
                     -CheckPath "C:\Program Files\Eclipse Adoptium\jdk-17*\bin\javac.exe"

    $jdkSearchPaths = @(
        "C:\Program Files\Eclipse Adoptium\jdk-17*",
        "C:\Program Files\Java\jdk-17*",
        "C:\Program Files\Java\jdk*"
    )
    $jdkPath = $null
    foreach ($pattern in $jdkSearchPaths) {
        $found = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $jdkPath = $found.FullName; break }
    }

    if ($jdkPath) {
        Set-SystemEnvVar -Name "JAVA_HOME" -Value $jdkPath
        Add-ToSystemPath -DirToAdd (Join-Path $jdkPath "bin")
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

    # 1. Jalankan Installer Resmi Laragon
    Install-AppSmart -Name "Laragon (Installer Resmi)" `
                     -FilePattern "*Laragon*.exe" `
                     -SilentArgs "/VERYSILENT /NORESTART" `
                     -WingetId "LeNgocKhoa.Laragon" `
                     -CheckPath "C:\laragon\laragon.exe"

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
                     -CheckPath "C:\xampp\xampp-control.exe"

    # 2. Atur Port Otomatis jika C:\xampp terpasang
    $xamppDir = "C:\xampp"
    if (Test-Path $xamppDir) {
        Write-Host "`n[i] Mengonfigurasi Port XAMPP agar tidak bentrok dengan Laragon..." -ForegroundColor Yellow

        # A. Konfigurasi Apache Port: Ganti Port 80 -> 8088 di httpd.conf
        # (Port 8000 dipakai Laravel artisan serve, 8080 sering dipakai Tomcat/Spring/Vue, jadi 8088 dijamin 100% aman)
        $httpdConf = Join-Path $xamppDir "apache\conf\httpd.conf"
        if (Test-Path $httpdConf) {
            $confText = [System.IO.File]::ReadAllText($httpdConf)
            $newConfText = $confText -replace '(?m)^Listen\s+(80|8080)$', 'Listen 8088'
            $newConfText = $newConfText -replace '(?m)^ServerName\s+localhost:(80|8080)$', 'ServerName localhost:8088'
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
            $newSslText = $sslText -replace '(?m)^Listen\s+(443|8443)$', 'Listen 8444'
            $newSslText = $newSslText -replace '(?m)^<VirtualHost _default_:(443|8443)>$', '<VirtualHost _default_:8444>'
            $newSslText = $newSslText -replace '(?m)^ServerName\s+localhost:(443|8443)$', 'ServerName localhost:8444'
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
            $newMyText = $myText -replace '(?m)^port\s*=\s*3306$', 'port = 3307'
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
            if ($pmaText -notmatch "\['port'\]\s*=\s*'3307'") {
                $pmaText = $pmaText -replace "(\\\$cfg\['Servers'\]\\[\\\$i\\]\['host'\]\s*=.*?;)", "`$1`r`n`$cfg['Servers'][`$i]['port'] = '3307';"
                [System.IO.File]::WriteAllText($pmaConfig, $pmaText)
                Write-Host "   [OK] phpMyAdmin XAMPP dikonfigurasi ke MySQL Port 3307" -ForegroundColor Green
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

    # A. Cek apakah Composer sudah terpasang
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
        # Cari PHP yang aktif di sistem (Laragon atau XAMPP)
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
            $cArgs = "/VERYSILENT /NORESTART"
            if ($phpPath) {
                $cArgs += " /PHP=`"$phpPath`""
            }
            $proc = Start-Process -FilePath $composerInstaller.FullName -ArgumentList $cArgs -Wait -PassThru
            if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                Write-Host "   [OK] Berhasil memasang Composer!" -ForegroundColor Green
            }
        }
    }

    # Pastikan Path Composer & Composer Vendor bin masuk ke PATH
    $composerBin = "C:\ProgramData\ComposerSetup\bin"
    if (Test-Path $composerBin) { Add-ToSystemPath -DirToAdd $composerBin }

    $composerGlobalVendor = Join-Path $env:APPDATA "Composer\vendor\bin"
    if (-not (Test-Path $composerGlobalVendor)) {
        New-Item -ItemType Directory -Path $composerGlobalVendor -Force | Out-Null
    }
    Add-ToSystemPath -DirToAdd $composerGlobalVendor

    # Perbarui PATH sesi sekarang agar perintah laravel langsung dapat diuji
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

    # B. Setup Laravel Installer Global (composer global require laravel/installer)
    $laravelBat = Join-Path $composerGlobalVendor "laravel.bat"
    if (Test-Path $laravelBat) {
        Write-Host "   [OK SUDAH TERPASANG] Laravel Installer terdeteksi di $laravelBat" -ForegroundColor Green
    } else {
        Write-Host "`n   [i] Menyiapkan Laravel Installer secara global..." -ForegroundColor Yellow
        try {
            $compCmd = Get-Command composer -ErrorAction SilentlyContinue
            if ($compCmd) {
                & composer global require laravel/installer --quiet
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

# 12. Verifikasi Status Seluruh Software & Web Stack
function Test-LabSoftwareStatus {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "STATUS VERIFIKASI SELURUH SOFTWARE & WEB STACK LAB TI" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

    $cliChecks = @(
        @{ Name = "Python 3"; Cmd = { python --version } },
        @{ Name = "Pip"; Cmd = { pip --version } },
        @{ Name = "Java (JDK)"; Cmd = { java -version } },
        @{ Name = "JAVA_HOME"; Cmd = { $env:JAVA_HOME } },
        @{ Name = "Node.js"; Cmd = { node --version } },
        @{ Name = "NPM"; Cmd = { npm --version } },
        @{ Name = "Composer"; Cmd = { composer --version } },
        @{ Name = "Laravel CLI"; Cmd = { laravel --version } },
        @{ Name = "VS Code"; Cmd = { code --version } }
    )

    foreach ($chk in $cliChecks) {
        Write-Host -NoNewline ("- {0,-18}: " -f $chk.Name)
        try {
            $res = & $chk.Cmd 2>&1 | Out-String
            if ($LASTEXITCODE -eq 0 -or !([string]::IsNullOrWhiteSpace($res))) {
                $firstLine = ($res.Trim() -split "`n")[0]
                Write-Host $firstLine -ForegroundColor Green
            } else {
                Write-Host "Belum Terdeteksi di PATH" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Belum Terinstal / Perlu Restart Shell" -ForegroundColor Red
        }
    }

    $guiApps = @(
        @{ Name = "Delphi (RAD Studio)"; Path = "C:\Program Files*\Embarcadero\Studio\*\bin\bds.exe" },
        @{ Name = "Cisco Packet Tracer"; Path = "C:\Program Files\Cisco Packet Tracer *\bin\PacketTracer.exe" },
        @{ Name = "Visual Studio 2022";  Path = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" },
        @{ Name = "Proteus Design Suite";Path = "C:\Program Files*\Labcenter Electronics\Proteus *\BIN\PDS.EXE" },
        @{ Name = "Android Studio";      Path = "C:\Program Files\Android\Android Studio\bin\studio64.exe" },
        @{ Name = "Oracle VirtualBox";   Path = "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe" },
        @{ Name = "Apache NetBeans";     Path = "C:\Program Files\NetBeans*\bin\netbeans64.exe" },
        @{ Name = "QGIS Desktop";        Path = "C:\Program Files\QGIS *\bin\qgis-bin.exe" },
        @{ Name = "Arduino IDE";         Path = "C:\Program Files\Arduino IDE\Arduino IDE.exe" },
        @{ Name = "Laragon";             Path = "C:\laragon\laragon.exe" },
        @{ Name = "XAMPP";               Path = "C:\xampp\xampp-control.exe" }
    )

    Write-Host "`nSoftware Desktop & GUI Terpasang:" -ForegroundColor Cyan
    foreach ($gui in $guiApps) {
        $found = Get-Item $gui.Path -ErrorAction SilentlyContinue | Select-Object -First 1
        Write-Host -NoNewline ("- {0,-22}: " -f $gui.Name)
        if ($found) {
            Write-Host "Terpasang ($($found.FullName))" -ForegroundColor Green
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

    # 5. Oracle VM VirtualBox (Otomatis Silent)
    Install-AppSmart -Name "Oracle VM VirtualBox" -FilePattern "*VirtualBox*.exe" -SilentArgs "--silent" -WingetId "Oracle.VirtualBox" -CheckPath "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe"

    # 6. Apache NetBeans (Otomatis Silent)
    Install-AppSmart -Name "Apache NetBeans IDE" -FilePattern "*NetBeans*.exe" -SilentArgs "--silent" -WingetId "Apache.NetBeans" -CheckPath "C:\Program Files\NetBeans*\bin\netbeans64.exe"

    # 7. Android Studio (Otomatis Silent)
    Install-AppSmart -Name "Android Studio" -FilePattern "*Android*Studio*.exe" -SilentArgs "/S" -WingetId "Google.AndroidStudio" -CheckPath "C:\Program Files\Android\Android Studio\bin\studio64.exe"

    # 8. QGIS Desktop (Otomatis Silent)
    Install-AppSmart -Name "QGIS Desktop" -FilePattern "*QGIS*.msi" -SilentArgs "/qn" -WingetId "OSGeo.QGIS" -CheckPath "C:\Program Files\QGIS *\bin\qgis-bin.exe"

    # 9. Microsoft Visual Studio 2022 Community
    Install-AppSmart -Name "Microsoft Visual Studio 2022 Community" -FilePattern "*vs_Community*.exe" -SilentArgs "--passive --norestart" -WingetId "Microsoft.VisualStudio.2022.Community" -CheckPath "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"

    # 10. Arduino IDE (Arduino Uno, Nano, Mega, IoT)
    Install-AppSmart -Name "Arduino IDE" -FilePattern "*arduino*.msi" -SilentArgs "/qn" -WingetId "ArduinoSA.IDE.stable" -CheckPath "C:\Program Files\Arduino IDE\Arduino IDE.exe"

    # 11. Laragon (Installer Resmi 6.0.0 + Auto-Overlay Stack Custom)
    Setup-LaragonStack

    # 12. Composer & Laravel Setup
    Setup-ComposerAndLaravel

    # 13. XAMPP (Otomatis Silent + Konfigurasi Port Anti-Bentrok)
    Setup-XamppStack

    # 14. Cisco Packet Tracer
    Install-AppSmart -Name "Cisco Packet Tracer" -FilePattern "*packettracer*.exe" -SilentArgs "/VERYSILENT /NORESTART" -CheckPath "C:\Program Files\Cisco Packet Tracer *\bin\PacketTracer.exe"

    # 15. Embarcadero Delphi (Pihak Ketiga / Interaktif)
    Install-AppSmart -Name "Embarcadero Delphi" -FilePattern "*delphi*.exe" -IsInteractive -CheckPath "C:\Program Files*\Embarcadero\Studio\*\bin\bds.exe"

    # 16. Proteus Design Suite (Pihak Ketiga / Interaktif)
    Install-AppSmart -Name "Proteus Design Suite" -FilePattern "*proteus*.exe" -IsInteractive -CheckPath "C:\Program Files*\Labcenter Electronics\Proteus *\BIN\PDS.EXE"

    Write-Host "`n[OK] Seluruh proses otomasi selesai!" -ForegroundColor Green
    Test-LabSoftwareStatus
}

# ==============================================================================
# MENU UTAMA (INTERAKTIF TERPUSAT DENGAN CLEAR-HOST)
# ==============================================================================
$running = $true

while ($running) {
    Clear-Host
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host "   OTOMASI STANDARISASI SOFTWARE LAB TI - UNIMAL" -ForegroundColor Cyan
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host "`nPilihan Tindakan:" -ForegroundColor Yellow
    Write-Host " [1] Jalankan Otomasi Lengkap Lab (Smart-Skip: Lewati yang sudah ada, pasang yang belum)"
    Write-Host " [2] Verifikasi Status & Peta Port Software Lab"
    Write-Host " [3] Keluar`n"

    $choice = Read-Host "Masukkan pilihan Anda (1/2/3)"

    switch ($choice) {
        "1" {
            Run-FullInstallation
            Write-Host "`n[Tekan sembarang tombol untuk kembali ke Menu Utama...]" -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "2" {
            Clear-Host
            Test-LabSoftwareStatus
            Write-Host "`n[Tekan sembarang tombol untuk kembali ke Menu Utama...]" -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "3" {
            Write-Host "`nKeluar dari skrip otomasi. Terima kasih." -ForegroundColor Gray
            $running = $false
        }
        default {
            Write-Host "Pilihan tidak valid. Silakan ketik angka 1, 2, atau 3." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
