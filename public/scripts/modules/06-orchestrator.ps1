# ==============================================================================
# MODUL 06: WORKFLOW ORCHESTRATOR & MENU HANDLERS (SMARTLAB LAB TI UNIMAL)
# Run-FullInstallation, Test-LabSoftwareStatus, Start-DownloadOnlyMaster,
# Run-CustomInstallation, Wait-PacedStep, Wait-EnterOnly
# ==============================================================================

function Wait-PacedStep {
    param([int]$Seconds = 2)
    Write-Host "   [i] Jeda stabilisasi sistem ($Seconds detik)..." -ForegroundColor DarkGray
    Start-Sleep -Seconds $Seconds
}

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

    # 3. Google Chrome Enterprise (Browser Resmi Lab & Engine Flutter Web)
    Setup-GoogleChrome
    Wait-PacedStep

    # 4. Git for Windows (Wajib untuk Dart SDK, Flutter, Composer, & VS Code)
    Setup-Git
    Wait-PacedStep

    # 5. Visual Studio Code (Otomatis Silent dengan Direct CDN Mirror)
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

    # 6. Python (Versi Terbaru 3.13 / 3.12 LTS with PIP & System PATH)
    Setup-Python
    Wait-PacedStep

    # 7. Java JDK 17 (Otomatis Silent + JAVA_HOME)
    Setup-JavaJDK
    Wait-PacedStep

    # 8. Node.js LTS (Versi Terbaru v22 LTS with NPM & Global PATH)
    Setup-NodeJS
    Wait-PacedStep

    # 9. Oracle VM VirtualBox & Extension Pack (Otomatis Silent dengan Multi-Mirror Google Drive & CDN)
    Setup-VirtualBox
    Wait-PacedStep

    # 10. Apache NetBeans (Otomatis Silent dengan Direct High-Speed GitHub Releases CDN & Bundled JDK)
    Setup-NetBeans
    Wait-PacedStep

    # 11. Android Studio (Otomatis Silent dengan Multi-CDN Google Resmi & Winget Fallback)
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

    # 12. QGIS Desktop (Otomatis Silent)
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

    # 13. Google Earth Pro (Pemetaan Spasial 3D / GIS)
    Setup-GoogleEarth
    Wait-PacedStep

    # 14. Microsoft Visual Studio 2022 Community (Desktop C++ Workload - 100% Offline Layout)
    Setup-VisualStudio
    Wait-PacedStep

    # 15. Arduino IDE (Arduino Uno, Nano, Mega, IoT)
    $arduinoMirrors = @(
        "https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.10_Windows_64bit.msi",
        "https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.10_Windows_64bit.exe",
        "https://github.com/arduino/arduino-ide/releases/download/2.3.10/arduino-ide_2.3.10_Windows_64bit.msi",
        "https://github.com/arduino/arduino-ide/releases/download/2.3.10/arduino-ide_2.3.10_Windows_64bit.exe"
    )
    Install-AppSmart -Name "Arduino IDE" `
                     -FilePattern @("*arduino*.msi", "*arduino*.exe") `
                     -DownloadUrls $arduinoMirrors `
                     -SilentArgs "ALLUSERS=1 /S" `
                     -WingetId "ArduinoSA.IDE.stable" `
                     -CheckPath @("C:\Program Files\Arduino IDE\Arduino IDE.exe", "C:\Program Files\Arduino\arduino.exe", "C:\Users\*\AppData\Local\Programs\Arduino IDE\Arduino IDE.exe", "C:\Users\*\AppData\Local\Arduino*\arduino*.exe", "C:\Program Files (x86)\Arduino\arduino.exe")
    Wait-PacedStep

    # 16. Flutter SDK (All Doctor Checks Passed & Auto-Configured)
    Setup-FlutterSDK
    Wait-PacedStep

    # 17. Laragon (Installer Resmi 6.0.0 + Auto-Overlay Stack Custom)
    Setup-LaragonStack
    Wait-PacedStep

    # 18. Composer & Laravel Setup
    Setup-ComposerAndLaravel
    Wait-PacedStep

    # 19. XAMPP (Otomatis Silent + Konfigurasi Port Anti-Bentrok)
    Setup-XamppStack
    Wait-PacedStep

    # 20. Cisco Packet Tracer (Multi-Mirror Google Drive Resmi Lab TI)
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

    # 21. Embarcadero Delphi (Pihak Ketiga / Interaktif)
    Install-AppSmart -Name "Embarcadero Delphi" -FilePattern "*delphi*.exe" -IsInteractive -CheckPath @("C:\Program Files*\Embarcadero\Studio\*\bin\bds.exe", "C:\Program Files (x86)\Embarcadero\Studio\*\bin\bds.exe")
    Wait-PacedStep

    # 22. Proteus Design Suite (Pihak Ketiga / Interaktif)
    Install-AppSmart -Name "Proteus Design Suite" -FilePattern "*proteus*.exe" -IsInteractive -CheckPath @("C:\Program Files*\Labcenter Electronics\Proteus *\BIN\PDS.EXE", "C:\Program Files (x86)\Labcenter Electronics\Proteus *\BIN\PDS.EXE")

    # Bersihkan & rapikan Desktop (Hapus duplikat dan icon background CLI/runtime)
    Clean-LabDesktopIcons
    Wait-PacedStep -Seconds 1

    # REKAPITULASI HASIL INSTALASI
    Clear-Host
    Show-SmartLabBanner
    Write-Host "  ┌────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
    Write-Host "  │ " -NoNewline -ForegroundColor Green
    Write-Host "RANGKUMAN HASIL STANDARISASI OTOMASI SOFTWARE LAB TI" -NoNewline -ForegroundColor White
    Write-Host (" " * (51 - "RANGKUMAN HASIL STANDARISASI OTOMASI SOFTWARE LAB TI".Length)) -NoNewline
    Write-Host "[v$SCRIPT_CURRENT_VERSION] │" -ForegroundColor Yellow
    Write-Host "  └────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Green

    $totalApp = $script:InstallResults.Count
    $sudah = ($script:InstallResults | Where-Object { $_.Status -eq "SUDAH TERPASANG" } | Measure-Object).Count
    $berhasil = ($script:InstallResults | Where-Object { $_.Status -eq "BERHASIL DIINSTAL" } | Measure-Object).Count
    $gagal = ($script:InstallResults | Where-Object { $_.Status -eq "GAGAL" } | Measure-Object).Count
    $lewat = ($script:InstallResults | Where-Object { $_.Status -eq "BELUM TERSEDIA" } | Measure-Object).Count

    Write-Host "`n  METRIK HASIL EKSEKUSI:" -ForegroundColor Yellow
    Write-Host ("  [● Sukses Baru: {0}]  [✓ Sudah Ada: {1}]  [▲ Menunggu File: {2}]  [✕ Gagal: {3}]" -f $berhasil, $sudah, $lewat, $gagal) -ForegroundColor Cyan
    Write-Host "`n  ┌─────┬──────────────────────────────┬──────────────────┬────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │ No  │ Nama Software Lab            │ Status Akhir     │ Keterangan         │" -ForegroundColor Cyan
    Write-Host "  ├─────┼──────────────────────────────┼──────────────────┼────────────────────┤" -ForegroundColor DarkGray

    $idx = 1
    foreach ($item in $script:InstallResults) {
        $color = "Green"
        if ($item.Status -eq "GAGAL") { $color = "Red" }
        elseif ($item.Status -eq "BELUM TERSEDIA") { $color = "Yellow" }
        elseif ($item.Status -eq "SUDAH TERPASANG") { $color = "Cyan" }

        $shortKet = if ($item.Keterangan -and $item.Keterangan.Length -gt 18) { $item.Keterangan.Substring(0, 15) + "..." } else { $item.Keterangan }
        Write-Host ("  │ {0,3} │ {1,-28} │ " -f $idx, $item.Name) -NoNewline -ForegroundColor DarkGray
        Write-Host ("{0,-16}" -f $item.Status) -NoNewline -ForegroundColor $color
        Write-Host " │ " -NoNewline -ForegroundColor DarkGray
        Write-Host ("{0,-18}" -f $shortKet) -NoNewline -ForegroundColor Gray
        Write-Host "│" -ForegroundColor DarkGray
        $idx++
    }
    Write-Host "  └─────┴──────────────────────────────┴──────────────────┴────────────────────┘`n" -ForegroundColor DarkGray
}

function Test-LabSoftwareStatus {
    Write-Host "`n  ┌────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │ " -NoNewline -ForegroundColor Cyan
    Write-Host "STATUS VERIFIKASI SOFTWARE & WEB STACK LAB TI" -NoNewline -ForegroundColor White
    Write-Host (" " * (58 - "STATUS VERIFIKASI SOFTWARE & WEB STACK LAB TI".Length)) -NoNewline
    Write-Host "[v$SCRIPT_CURRENT_VERSION] │" -ForegroundColor Yellow
    Write-Host "  └────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan

    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
    $env:COMPOSER_NO_INTERACTION = "1"
    $env:COMPOSER_ALLOW_SUPERUSER = "1"

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

    Write-Host "`n  [1] LINGKUNGAN RUNTIME & PERINTAH CLI (PATH SYSTEM):" -ForegroundColor Yellow
    Write-Host "  ┌─────┬──────────────────────┬───────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │ No  │ Perintah / Runtime   │ Versi / Output Aktif Terdeteksi               │" -ForegroundColor Cyan
    Write-Host "  ├─────┼──────────────────────┼───────────────────────────────────────────────┤" -ForegroundColor DarkGray

    $cIdx = 1
    foreach ($chk in $cliChecks) {
        $outStr = "Belum Terdeteksi di PATH"
        $color = "Yellow"
        try {
            $raw = & $chk.Cmd 2>&1 | Out-String
            $trimmed = $raw.Trim()
            if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
                $lines = @($trimmed -split "`r?`n")
                $cleanLines = @($lines | Where-Object {
                    $_ -notmatch '(?i)warning:' -and
                    $_ -notmatch '(?i)deprecated:' -and
                    $_ -notmatch '(?i)notice:' -and
                    -not [string]::IsNullOrWhiteSpace($_)
                })

                $firstLine = $null
                if ($chk.Name -eq "Composer") {
                    $cMatch = $cleanLines | Where-Object { $_ -match '(?i)Composer (version|\d+\.)' } | Select-Object -First 1
                    if ($cMatch) { $firstLine = $cMatch }
                }
                if (-not $firstLine) {
                    $firstLine = if ($cleanLines.Count -gt 0) { [string]$cleanLines[0] } else { [string]$lines[0] }
                }
                $outStr = $firstLine.Trim()
                $color = "Green"
            }
        } catch {
            $outStr = "Belum Terinstal / Perlu Restart Shell"
            $color = "Red"
        }

        if ($outStr.Length -gt 45) { $outStr = $outStr.Substring(0, 42) + "..." }
        Write-Host ("  │ {0,3} │ {1,-20} │ " -f $cIdx, $chk.Name) -NoNewline -ForegroundColor DarkGray
        Write-Host ("{0,-45}" -f $outStr) -NoNewline -ForegroundColor $color
        Write-Host " │" -ForegroundColor DarkGray
        $cIdx++
    }
    Write-Host "  └─────┴──────────────────────┴───────────────────────────────────────────────┘" -ForegroundColor DarkGray

    $guiApps = @(
        @{ Name = "7-Zip";               Path = @("C:\Program Files\7-Zip\7z.exe", "C:\Program Files (x86)\7-Zip\7z.exe"); Reg = "*7-Zip*" },
        @{ Name = "WinRAR";              Path = @("C:\Program Files\WinRAR\WinRAR.exe", "C:\Program Files (x86)\WinRAR\WinRAR.exe"); Reg = "*WinRAR*" },
        @{ Name = "Google Chrome";       Path = @("C:\Program Files\Google\Chrome\Application\chrome.exe", "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"); Reg = "*Google Chrome*" },
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
        @{ Name = "Google Earth Pro";    Path = @("C:\Program Files\Google\Google Earth Pro\client\googleearth.exe", "C:\Program Files (x86)\Google\Google Earth Pro\client\googleearth.exe", "$env:LOCALAPPDATA\Google\Google Earth Pro\client\googleearth.exe"); Reg = "*Google Earth Pro*" },
        @{ Name = "Arduino IDE";         Path = @("C:\Program Files\Arduino IDE\Arduino IDE.exe", "C:\Program Files\Arduino\arduino.exe", "C:\Users\*\AppData\Local\Programs\Arduino IDE\Arduino IDE.exe", "C:\Users\*\AppData\Local\Arduino*\arduino*.exe", "C:\Program Files (x86)\Arduino\arduino.exe"); Reg = "*Arduino*" },
        @{ Name = "Laragon";             Path = @("C:\laragon\laragon.exe", "D:\laragon\laragon.exe", "E:\laragon\laragon.exe"); Reg = "*Laragon*" },
        @{ Name = "XAMPP";               Path = @("C:\xampp\xampp-control.exe", "D:\xampp\xampp-control.exe"); Reg = "*XAMPP*" }
    )

    $installedRegs = @()
    try {
        $regKeys = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        $installedRegs = Get-ItemProperty $regKeys -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
    } catch {}

    Write-Host "`n  [2] APLIKASI DESKTOP & IDE PRAKTIKUM:" -ForegroundColor Yellow
    Write-Host "  ┌─────┬──────────────────────┬────────────────┬──────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │ No  │ Nama Aplikasi Lab    │ Status Sistem  │ Lokasi / Keterangan          │" -ForegroundColor Cyan
    Write-Host "  ├─────┼──────────────────────┼────────────────┼──────────────────────────────┤" -ForegroundColor DarkGray

    $gIdx = 1
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

        if (-not $found -and $gui.Reg) {
            $matchReg = $installedRegs | Where-Object { $_.DisplayName -like $gui.Reg } | Select-Object -First 1
            if ($matchReg) {
                if ($matchReg.InstallLocation -and (Test-Path $matchReg.InstallLocation)) {
                    $found = "$($matchReg.InstallLocation)"
                } else {
                    $found = "$($matchReg.DisplayName) $($matchReg.DisplayVersion)"
                }
            }
        }

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
                        $found = "VirtualBox ($vMatch - $pCount Pack)"
                    } elseif ($epCheck -match "Oracle VM VirtualBox Extension Pack") {
                        $found = "VirtualBox (Aktif)"
                    }
                }
            } catch {}
        }

        if (-not $found) {
            $firstWord = $gui.Name.Split(' ')[0]
            $lnk = Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs", "C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" -Filter "*$firstWord*.lnk" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($lnk) {
                $found = "Menu Start ($($lnk.Name))"
            }
        }

        $statusBadge = if ($found) { "TERPASANG" } else { "BELUM ADA" }
        $bColor = if ($found) { "Green" } else { "DarkGray" }
        $desc = if ($found) { $found } else { "Belum terdeteksi di path sistem" }
        if ($desc.Length -gt 28) { $desc = $desc.Substring(0, 25) + "..." }

        Write-Host ("  │ {0,3} │ {1,-20} │ " -f $gIdx, $gui.Name) -NoNewline -ForegroundColor DarkGray
        Write-Host ("{0,-14}" -f $statusBadge) -NoNewline -ForegroundColor $bColor
        Write-Host " │ " -NoNewline -ForegroundColor DarkGray
        Write-Host ("{0,-28}" -f $desc) -NoNewline -ForegroundColor Gray
        Write-Host "│" -ForegroundColor DarkGray
        $gIdx++
    }
    Write-Host "  └─────┴──────────────────────┴────────────────┴──────────────────────────────┘" -ForegroundColor DarkGray

    Write-Host "`n  [3] PETA ALOKASI PORT RESMI LAB TI (STANDAR ANTI-BENTROK):" -ForegroundColor Yellow
    Write-Host "  ┌──────────┬──────────────────────┬──────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │ Port     │ Layanan / Web Server │ Penggunaan Praktikum Lab TI              │" -ForegroundColor Cyan
    Write-Host "  ├──────────┼──────────────────────┼──────────────────────────────────────────┤" -ForegroundColor DarkGray
    Write-Host "  │ 80       │ Laragon Apache HTTP  │ Web Server Praktikum Utama               │" -ForegroundColor Green
    Write-Host "  │ 443      │ Laragon Apache SSL   │ HTTPS Secure Local Web                   │" -ForegroundColor Green
    Write-Host "  │ 3306     │ Laragon MySQL/MariaDB│ Database Standar Lab & Laravel .env      │" -ForegroundColor Green
    Write-Host "  │ 8088     │ XAMPP Apache HTTP    │ Web Server Sekunder (Bebas Konflik)      │" -ForegroundColor Yellow
    Write-Host "  │ 8444     │ XAMPP Apache SSL     │ HTTPS Sekunder XAMPP                     │" -ForegroundColor Yellow
    Write-Host "  │ 3307     │ XAMPP MySQL Database │ Port Khusus XAMPP (Anti-Bentrok)         │" -ForegroundColor Yellow
    Write-Host "  │ 8000     │ Laravel Server       │ php artisan serve                        │" -ForegroundColor Cyan
    Write-Host "  │ 3000     │ Node / Next / React  │ npm run dev / Frontend Dev Server        │" -ForegroundColor Cyan
    Write-Host "  │ 5173     │ Vite Dev Server      │ Vue / Svelte / React Vite                │" -ForegroundColor Cyan
    Write-Host "  └──────────┴──────────────────────┴──────────────────────────────────────────┘`n" -ForegroundColor DarkGray
}

function Start-DownloadOnlyMaster {
    Clear-Host
    Show-SmartLabBanner
    Write-Host "  ┌────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │ " -NoNewline -ForegroundColor Cyan
    Write-Host "MODE UNDUH SAJA: CACHE MASTER OFFLINE KE FOLDER APPS/" -NoNewline -ForegroundColor White
    Write-Host (" " * (60 - "MODE UNDUH SAJA: CACHE MASTER OFFLINE KE FOLDER APPS/".Length)) -NoNewline
    Write-Host "[v$SCRIPT_CURRENT_VERSION] │" -ForegroundColor Yellow
    Write-Host "  └────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host "  Fungsi ini akan mengunduh seluruh file master software lab ke dalam folder:" -ForegroundColor Gray
    Write-Host "  -> $AppsDir" -ForegroundColor Yellow
    Write-Host "  (Tidak ada aplikasi yang dipasang ke Windows pada mode ini. Aman untuk persiapan lab).`n" -ForegroundColor DarkGray

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
            Name = "WinRAR 7.23 (Lab Archive Support)"
            FilePattern = @("*winrar*x64*.exe", "*winrar*.exe", "*wrar*.exe")
            DestFile = "winrar-x64-723.exe"
            Urls = @(
                "https://www.rarlab.com/rar/winrar-x64-723.exe",
                "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-723.exe",
                "https://www.rarlab.com/rar/winrar-x64-701.exe"
            )
        },
        @{
            Name = "Google Chrome Enterprise"
            FilePattern = @("*chrome*.msi", "*Chrome*.msi", "*chrome*.exe")
            DestFile = "googlechromestandaloneenterprise64.msi"
            Urls = @(
                "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BADED07C9-40E0-4CB7-8055-2CA3BFD15EF0%7D%26browser%3D3%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCEA/dl/chrome/install/googlechromestandaloneenterprise64.msi",
                "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi"
            )
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
            Name = "Google Earth Pro"
            FilePattern = @("*googleearthprowin*.exe", "*GoogleEarth*.exe", "*GoogleEarthPro*.exe", "*googleearth*.exe", "*googleearth*.msi")
            DestFile = "googleearthprowin-x64.exe"
            Urls = @(
                "https://dl.google.com/dl/earth/client/advanced/current/googleearthprowin-x64.exe",
                "https://dl.google.com/earth/client/advanced/current/googleearthprowin-x64.exe",
                "https://dl.google.com/dl/earth/client/advanced/current/googleearthprowin.exe"
            )
        },
        @{
            Name = "Arduino IDE"
            FilePattern = @("*arduino*.msi", "*arduino*.exe")
            DestFile = "arduino-ide_2.3.10_Windows_64bit.msi"
            Urls = @(
                "https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.10_Windows_64bit.msi",
                "https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.10_Windows_64bit.exe",
                "https://github.com/arduino/arduino-ide/releases/download/2.3.10/arduino-ide_2.3.10_Windows_64bit.msi",
                "https://github.com/arduino/arduino-ide/releases/download/2.3.10/arduino-ide_2.3.10_Windows_64bit.exe"
            )
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

    Clear-Host
    Show-SmartLabBanner
    Write-Host "  ┌────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
    Write-Host "  │ " -NoNewline -ForegroundColor Green
    Write-Host "SELESAI - REKAPITULASI CACHE MASTER OFFLINE KE FLASHDISK (APPS/)" -NoNewline -ForegroundColor White
    Write-Host (" " * (60 - "SELESAI - REKAPITULASI CACHE MASTER OFFLINE KE FLASHDISK (APPS/)".Length)) -NoNewline
    Write-Host "[v$SCRIPT_CURRENT_VERSION] │" -ForegroundColor Yellow
    Write-Host "  └────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Green

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
    Write-Host "`n  ┌─────┬────────────────────────────────┬────────────────┬────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │ No  │ Software Lab                   │ Status Berkas  │ Ukuran Master      │" -ForegroundColor Cyan
    Write-Host "  ├─────┼────────────────────────────────┼────────────────┼────────────────────┤" -ForegroundColor DarkGray

    $rIdx = 1
    foreach ($r in $downloadResults) {
        $c = "Green"
        if ($r.Status -eq "GAGAL UNDUH") { $c = "Red" }
        elseif ($r.Status -eq "SUDAH ADA") { $c = "Cyan" }
        Write-Host ("  │ {0,3} │ {1,-30} │ " -f $rIdx, $r.Software) -NoNewline -ForegroundColor DarkGray
        Write-Host ("{0,-14}" -f $r.Status) -NoNewline -ForegroundColor $c
        Write-Host " │ " -NoNewline -ForegroundColor DarkGray
        Write-Host ("{0,-18}" -f $r.Ukuran) -NoNewline -ForegroundColor Gray
        Write-Host "│" -ForegroundColor DarkGray
        $rIdx++
    }
    Write-Host "  └─────┴────────────────────────────────┴────────────────┴────────────────────┘`n" -ForegroundColor DarkGray
    Write-Host "  Flashdisk Anda kini telah dilengkapi master offline untuk seluruh lab!`n" -ForegroundColor Green
}

function Run-CustomInstallation {
    Clear-Host
    Show-SmartLabBanner
    Write-Host "  ┌────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │ " -NoNewline -ForegroundColor Cyan
    Write-Host "MENU INSTALASI KUSTOM & PAKET SOFTWARE LAB" -NoNewline -ForegroundColor White
    Write-Host (" " * (60 - "MENU INSTALASI KUSTOM & PAKET SOFTWARE LAB".Length)) -NoNewline
    Write-Host "[v$SCRIPT_CURRENT_VERSION] │" -ForegroundColor Yellow
    Write-Host "  └────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host "  Pilih software yang ingin diinstal. Paket keterkaitan otomatis disertakan:`n" -ForegroundColor DarkGray

    $catalog = @(
        @{ Id = 1;  Name = "QGIS Desktop"; Description = "Sistem Informasi Geografis (Otomatis ikut Google Earth Pro)"; Deps = @("Google Earth Pro"); Action = "QGIS" },
        @{ Id = 2;  Name = "Google Earth Pro"; Description = "Pemetaan Spasial 3D / Citra Satelit"; Deps = @(); Action = "GoogleEarth" },
        @{ Id = 3;  Name = "Oracle VM VirtualBox"; Description = "Virtualisasi Lab (Otomatis ikut Extension Pack)"; Deps = @("VBox Extension Pack"); Action = "VirtualBox" },
        @{ Id = 4;  Name = "Laragon (WAMP Stack)"; Description = "Web Server Utama Lab (PHP 8.x + MySQL + Composer/Laravel)"; Deps = @("Composer"); Action = "Laragon" },
        @{ Id = 5;  Name = "XAMPP Server"; Description = "Web Server Sekunder (Port Anti-Bentrok 8088/3307)"; Deps = @(); Action = "XAMPP" },
        @{ Id = 6;  Name = "Flutter SDK"; Description = "Mobile & Web Dev (Otomatis ikut Git, Chrome, VS Code, Android Studio)"; Deps = @("Git", "Chrome", "VSCode", "AndroidStudio"); Action = "Flutter" },
        @{ Id = 7;  Name = "Visual Studio Code"; Description = "Code Editor Standar Lab"; Deps = @(); Action = "VSCode" },
        @{ Id = 8;  Name = "Microsoft Visual Studio 2022"; Description = "IDE Desktop C++ (100% Offline Layout)"; Deps = @(); Action = "VisualStudio" },
        @{ Id = 9;  Name = "Android Studio"; Description = "IDE Pemrograman Mobile Android"; Deps = @(); Action = "AndroidStudio" },
        @{ Id = 10; Name = "Apache NetBeans IDE"; Description = "IDE Java / C++ (High-Speed GitHub CDN / Bundled JDK)"; Deps = @("JavaJDK"); Action = "NetBeans" },
        @{ Id = 11; Name = "Arduino IDE"; Description = "Pemrograman Mikrokontroler & IoT"; Deps = @(); Action = "Arduino" },
        @{ Id = 12; Name = "Python 3.13 / 3.12 LTS"; Description = "Interpreter Python with PIP & PATH"; Deps = @(); Action = "Python" },
        @{ Id = 13; Name = "Java JDK 17 LTS"; Description = "Temurin OpenJDK with JAVA_HOME"; Deps = @(); Action = "JavaJDK" },
        @{ Id = 14; Name = "Node.js LTS (v22)"; Description = "JavaScript Runtime & NPM"; Deps = @(); Action = "NodeJS" },
        @{ Id = 15; Name = "Git for Windows"; Description = "Version Control System & Bash Tools"; Deps = @(); Action = "Git" },
        @{ Id = 16; Name = "Google Chrome Enterprise"; Description = "Browser Utama Lab & Engine Flutter Web"; Deps = @(); Action = "Chrome" },
        @{ Id = 17; Name = "7-Zip & WinRAR"; Description = "Utilitas Ekstraksi Arsip Lab (.zip, .rar, .7z)"; Deps = @(); Action = "Extractors" },
        @{ Id = 18; Name = "Cisco Packet Tracer"; Description = "Simulasi Jaringan Komputer (NetAcad)"; Deps = @(); Action = "Cisco" },
        @{ Id = 19; Name = "Embarcadero Delphi"; Description = "Pemrograman Visual Pascal (Interaktif)"; Deps = @(); Action = "Delphi" },
        @{ Id = 20; Name = "Proteus Design Suite"; Description = "Simulasi Rangkaian Elektronika (Interaktif)"; Deps = @(); Action = "Proteus" }
    )

    foreach ($item in $catalog) {
        $depText = if ($item.Deps.Count -gt 0) { " [Paket: +$($item.Deps -join ', ')]" } else { "" }
        Write-Host ("  [{0,2}] {1,-26} {2}" -f $item.Id, $item.Name, $depText) -ForegroundColor Cyan
        Write-Host ("       └─ {0}" -f $item.Description) -ForegroundColor DarkGray
    }

    Write-Host "`n  Contoh input: ketik '1' untuk QGIS (otomatis + Google Earth)" -ForegroundColor Yellow
    Write-Host "                ketik '3' untuk VirtualBox (otomatis + Extension Pack)" -ForegroundColor Yellow
    Write-Host "                ketik '1, 3, 7' untuk memilih beberapa aplikasi sekaligus" -ForegroundColor Yellow
    Write-Host "                ketik '0' untuk Batal dan kembali ke Menu Utama`n" -ForegroundColor DarkCyan

    $inputChoice = Read-Host "Masukkan nomor pilihan aplikasi yang ingin diinstal"
    if ([string]::IsNullOrWhiteSpace($inputChoice) -or $inputChoice.Trim() -eq "0") {
        Write-Host "Instalasi kustom dibatalkan." -ForegroundColor Yellow
        return
    }

    $selectedIds = @()
    $tokens = $inputChoice -split '[,; ]+'
    foreach ($tok in $tokens) {
        $trimmed = $tok.Trim()
        if ($trimmed -match '^\d+$') {
            $val = [int]$trimmed
            if ($val -ge 1 -and $val -le 20) {
                if ($selectedIds -notcontains $val) { $selectedIds += $val }
            }
        }
    }

    if ($selectedIds.Count -eq 0) {
        Write-Host "[!] Tidak ada nomor aplikasi valid yang dipilih." -ForegroundColor Red
        return
    }

    $actionsToRun = @()
    Write-Host "`n[>>>] Menganalisis Keterkaitan & Paket Ketergantungan Software..." -ForegroundColor Cyan

    foreach ($id in $selectedIds) {
        $mod = $catalog | Where-Object { $_.Id -eq $id } | Select-Object -First 1
        if ($mod) {
            Write-Host " -> Dipilih: $($mod.Name)" -ForegroundColor Green
            if ($actionsToRun -notcontains $mod.Action) { $actionsToRun += $mod.Action }

            if ($mod.Action -eq "QGIS") {
                if ($actionsToRun -notcontains "GoogleEarth") {
                    $actionsToRun += "GoogleEarth"
                    Write-Host "    [+ Auto-Paket] Menambahkan dependensi: Google Earth Pro" -ForegroundColor Yellow
                }
            }

            if ($mod.Action -eq "VirtualBox") {
                Write-Host "    [+ Auto-Paket] Menambahkan dependensi: Oracle VM VirtualBox Extension Pack" -ForegroundColor Yellow
            }

            if ($mod.Action -eq "Laragon") {
                if ($actionsToRun -notcontains "Composer") {
                    $actionsToRun += "Composer"
                    Write-Host "    [+ Auto-Paket] Menambahkan dependensi: Composer & Laravel Installer" -ForegroundColor Yellow
                }
            }

            if ($mod.Action -eq "NetBeans") {
                if ($actionsToRun -notcontains "JavaJDK") {
                    $actionsToRun += "JavaJDK"
                    Write-Host "    [+ Auto-Paket] Menambahkan dependensi: Java JDK 17 LTS (Diperlukan NetBeans)" -ForegroundColor Yellow
                }
            }

            if ($mod.Action -eq "Flutter") {
                if ($actionsToRun -notcontains "Git") {
                    $actionsToRun += "Git"
                    Write-Host "    [+ Auto-Paket] Menambahkan dependensi: Git for Windows (Wajib Flutter)" -ForegroundColor Yellow
                }
                if ($actionsToRun -notcontains "Chrome") {
                    $actionsToRun += "Chrome"
                    Write-Host "    [+ Auto-Paket] Menambahkan dependensi: Google Chrome (Engine Flutter Web)" -ForegroundColor Yellow
                }
            }
        }
    }

    Write-Host "`nMemulai proses instalasi untuk pilihan Anda..." -ForegroundColor Cyan
    $script:InstallResults = @()

    foreach ($act in $actionsToRun) {
        switch ($act) {
            "Extractors"    { Setup-7Zip; Setup-WinRAR }
            "Chrome"        { Setup-GoogleChrome }
            "Git"           { Setup-Git }
            "VSCode"        {
                $vscodeMirrors = @(
                    "https://vscode.download.prss.microsoft.com/dbazure/download/stable/fabdbac710c49742d1ae8f47303771f654f01f94/VSCodeUserSetup-x64-1.98.0.exe",
                    "https://update.code.visualstudio.com/latest/win32-x64-user/stable",
                    "https://az764295.vo.msecnd.net/stable/latest/VSCodeUserSetup-x64.exe"
                )
                Install-AppSmart -Name "Visual Studio Code" -FilePattern @("*VSCode*Setup*.exe", "*code*setup*.exe") -DownloadUrls $vscodeMirrors -SilentArgs "/VERYSILENT /NORESTART /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -WingetId "Microsoft.VisualStudioCode" -CheckPath @("$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe", "C:\Program Files\Microsoft VS Code\Code.exe")
            }
            "Python"        { Setup-Python }
            "JavaJDK"       { Setup-JavaJDK }
            "NodeJS"        { Setup-NodeJS }
            "VirtualBox"    { Setup-VirtualBox }
            "GoogleEarth"   { Setup-GoogleEarth }
            "QGIS"          {
                $qgisMirrors = @(
                    "https://download.osgeo.org/qgis/windows/QGIS-OSGeo4W-3.34.14-1.msi",
                    "https://qgis.org/downloads/QGIS-OSGeo4W-3.34.14-1.msi"
                )
                Install-AppSmart -Name "QGIS Desktop" -FilePattern "*QGIS*.msi" -DownloadUrls $qgisMirrors -SilentArgs "/qn" -WingetId "OSGeo.QGIS" -CheckPath "C:\Program Files\QGIS *\bin\qgis-bin.exe"
            }
            "VisualStudio"  { Setup-VisualStudio }
            "NetBeans"      { Setup-NetBeans }
            "AndroidStudio" {
                $androidStudioMirrors = @(
                    "https://redirector.gvt1.com/edgedl/android/studio/install/2024.2.1.12/android-studio-2024.2.1.12-windows.exe",
                    "https://dl.google.com/dl/android/studio/install/2024.2.1.12/android-studio-2024.2.1.12-windows.exe"
                )
                Install-AppSmart -Name "Android Studio" -FilePattern @("*Android*Studio*.exe", "*android-studio*.exe") -DownloadUrls $androidStudioMirrors -SilentArgs "/S" -WingetId "Google.AndroidStudio" -CheckPath @("C:\Program Files\Android\Android Studio\bin\studio64.exe", "C:\Program Files\Android Studio\bin\studio64.exe")
            }
            "Arduino"       {
                $arduinoMirrors = @(
                    "https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.10_Windows_64bit.msi",
                    "https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.10_Windows_64bit.exe"
                )
                Install-AppSmart -Name "Arduino IDE" -FilePattern @("*arduino*.msi", "*arduino*.exe") -DownloadUrls $arduinoMirrors -SilentArgs "ALLUSERS=1 /S" -WingetId "ArduinoSA.IDE.stable" -CheckPath @("C:\Program Files\Arduino IDE\Arduino IDE.exe", "C:\Program Files\Arduino\arduino.exe", "C:\Users\*\AppData\Local\Programs\Arduino IDE\Arduino IDE.exe")
            }
            "Flutter"       { Setup-FlutterSDK }
            "Laragon"       { Setup-LaragonStack }
            "Composer"      { Setup-ComposerAndLaravel }
            "XAMPP"         { Setup-XamppStack }
            "Cisco"         {
                $ciscoMirrors = @(
                    "https://drive.google.com/file/d/1N_YQNs2xFrdFGRPs4kqgF6LGOYDp37ZK/view?usp=sharing",
                    "https://drive.google.com/file/d/1O4flOVt7G-xZmfJSlxP3aLjTj1JM_LYP/view?usp=sharing"
                )
                Install-AppSmart -Name "Cisco Packet Tracer" -FilePattern @("*packettracer*.exe", "*PacketTracer*.exe", "*Cisco*.exe", "*packettracer*.rar", "*cisco*.rar", "*packettracer*.zip") -DownloadUrls $ciscoMirrors -SilentArgs "/VERYSILENT /NORESTART" -CheckPath @("C:\Program Files\Cisco Packet Tracer *\bin\PacketTracer.exe", "C:\Program Files (x86)\Cisco Packet Tracer *\bin\PacketTracer.exe")
            }
            "Delphi"        { Install-AppSmart -Name "Embarcadero Delphi" -FilePattern "*delphi*.exe" -IsInteractive -CheckPath @("C:\Program Files*\Embarcadero\Studio\*\bin\bds.exe", "C:\Program Files (x86)\Embarcadero\Studio\*\bin\bds.exe") }
            "Proteus"       { Install-AppSmart -Name "Proteus Design Suite" -FilePattern "*proteus*.exe" -IsInteractive -CheckPath @("C:\Program Files*\Labcenter Electronics\Proteus *\BIN\PDS.EXE", "C:\Program Files (x86)\Labcenter Electronics\Proteus *\BIN\PDS.EXE") }
        }
        Wait-PacedStep -Seconds 1
    }

    Clean-LabDesktopIcons

    Write-Host "`n==============================================================================" -ForegroundColor Green
    Write-Host "                SELESAI - INSTALASI KUSTOM LAB TI SELESAI                     " -ForegroundColor Green
    Write-Host "==============================================================================" -ForegroundColor Green
    $berhasil = ($script:InstallResults | Where-Object { $_.Status -in @("SUDAH TERPASANG", "BERHASIL DIINSTAL") } | Measure-Object).Count
    Write-Host "  [OK] Software Diproses Berhasil : $berhasil Software" -ForegroundColor Green
}

function Wait-EnterOnly {
    param(
        [string]$PromptMessage = "[Tekan tombol ENTER untuk kembali ke Menu Utama...]"
    )
    Write-Host "`n$PromptMessage" -ForegroundColor Cyan

    try {
        while ($Host.UI.RawUI.KeyAvailable) {
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } catch {}

    try {
        while ($true) {
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($key.VirtualKeyCode -eq 13 -or $key.Character -eq [char]13 -or $key.Key -eq [System.ConsoleKey]::Enter) {
                break
            }
        }
    } catch {
        $null = Read-Host
    }
}
