# ==============================================================================
# MODUL 05: VIRTUALIZATION, GIS, HARDWARE & APPS (SMARTLAB LAB TI UNIMAL)
# Oracle VM VirtualBox & Extension Pack, Google Earth Pro, QGIS Desktop,
# Arduino IDE, Cisco Packet Tracer, Embarcadero Delphi, Proteus Design Suite
# ==============================================================================

# 1. Oracle VM VirtualBox & Extension Pack (Google Drive Multi-Mirror Kencang)
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
        if ($installedVbox) {
            Create-AppShortcut -TargetExe $installedVbox -ShortcutName "Oracle VM VirtualBox"
            Record-InstallResult -Name "Oracle VM VirtualBox" -Status "BERHASIL DIINSTAL" -Keterangan "Terpasang & shortcut dibuat"
        }
    } else {
        Write-Host "   [OK SUDAH TERPASANG] Oracle VM VirtualBox terdeteksi di $installedVbox." -ForegroundColor Green
        Create-AppShortcut -TargetExe $installedVbox -ShortcutName "Oracle VM VirtualBox"
        Record-InstallResult -Name "Oracle VM VirtualBox" -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi aktif di sistem (Skip)"
    }

    if ($installedVbox) {
        $vboxDir = Split-Path -Parent $installedVbox
        $vboxManage = Join-Path $vboxDir "VBoxManage.exe"
        if (Test-Path $vboxManage) {
            Write-Host "`n   [>>>] Memeriksa Oracle VM VirtualBox Extension Pack..." -ForegroundColor Cyan

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

            $extInstalled = $false
            try {
                $extList = & $vboxManage list extpacks 2>&1 | Out-String
                if ($extList -match "Oracle VM VirtualBox Extension Pack") {
                    $extInstalled = $true
                    Write-Host "   [OK SUDAH TERPASANG] Oracle VM VirtualBox Extension Pack aktif terpasang!" -ForegroundColor Green
                }
            } catch {}

            if (-not $extInstalled) {
                $existingPacks = Get-ChildItem -Path $AppsDir -Filter "*.vbox-extpack" -File -Recurse -ErrorAction SilentlyContinue
                foreach ($ep in $existingPacks) {
                    if ($vboxVerDetected -and ($ep.Name -notmatch [regex]::Escape($vboxVerDetected)) -and ($ep.Name -match '\d+\.\d+\.\d+')) {
                        Write-Host "   [!] Menghapus cache Extension Pack yang tidak cocok dengan versi VBox ($($ep.Name))..." -ForegroundColor Yellow
                        Remove-Item -Path $ep.FullName -Force -ErrorAction SilentlyContinue
                    }
                }

                $extPackFile = Get-ChildItem -Path $AppsDir -Filter "*.vbox-extpack" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

                if (-not $extPackFile -or ($extPackFile.Length -lt 1048576)) {
                    Write-Host "   [i] Menyiapkan Oracle VM VirtualBox Extension Pack resmi sesuai versi..." -ForegroundColor Yellow

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

                        $extractedLicenseHash = $null
                        try {
                            $tarTool = "tar.exe"
                            if (Get-Command $tarTool -ErrorAction SilentlyContinue) {
                                $licText = & $tarTool -xOf "$($extPackFile.FullName)" --wildcards "*ExtPack-license.txt*" 2>$null | Out-String
                                if (-not $licText) {
                                    $licText = & $tarTool -xOf "$($extPackFile.FullName)" --wildcards "*License*" 2>$null | Out-String
                                }
                                if ($licText -and $licText.Length -gt 100) {
                                    $sha256 = [System.Security.Cryptography.SHA256]::Create()
                                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($licText.Replace("`r`n", "`n"))
                                    $hashBytes = $sha256.ComputeHash($bytes)
                                    $extractedLicenseHash = [System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()
                                }
                            }
                        } catch {}

                        $knownHashes = @(
                            "eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae",
                            "33d7284dc4a0ece381196da3cfe3f45f8b94642b",
                            "56da88705974ca89a3e4ea3834da9dda4f829e16",
                            "b674970f720f43d68139059da3643cc2279ab1be",
                            "10a1001452a7d86663f69f174ec62f31f95e841a",
                            "78749a0783f0876f7f5292e4a3b7f607266feb4d"
                        )
                        if ($extractedLicenseHash) {
                            $knownHashes = @($extractedLicenseHash) + $knownHashes
                        }

                        Write-Host "   [i] Menerapkan persetujuan lisensi PUEL otomatis (Mode Non-Interaktif)..." -ForegroundColor Cyan
                        foreach ($h in $knownHashes) {
                            $installArgs = "/c `"`"$vboxManage`" extpack install --replace `"$($extPackFile.FullName)`" --accept-license=$h`""
                            $pHash = Start-Process -FilePath "cmd.exe" -ArgumentList $installArgs -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
                            if ($pHash -and $pHash.ExitCode -eq 0) {
                                $extInstalledSuccess = $true
                                break
                            }
                        }

                        if (-not $extInstalledSuccess) {
                            Write-Host "   [i] Menyetujui lisensi otomatis via Standard Input (Piping)..." -ForegroundColor Cyan
                            $pipeCmd = "/c `"(echo y) | `"$vboxManage`" extpack install --replace `"$($extPackFile.FullName)`"`""
                            $pPipe = Start-Process -FilePath "cmd.exe" -ArgumentList $pipeCmd -PassThru -NoNewWindow -ErrorAction SilentlyContinue
                            if ($pPipe) {
                                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                                while (-not $pPipe.HasExited -and $sw.ElapsedMilliseconds -lt 15000) {
                                    Start-Sleep -Milliseconds 500
                                }
                                if (-not $pPipe.HasExited) {
                                    $pPipe | Stop-Process -Force -ErrorAction SilentlyContinue
                                } elseif ($pPipe.ExitCode -eq 0) {
                                    $extInstalledSuccess = $true
                                }
                            }
                        }

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

# 2. Google Earth Pro (Pemetaan Spasial 3D / GIS)
function Setup-GoogleEarth {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: Google Earth Pro (Pemetaan Spasial 3D / GIS)" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $gePaths = @(
        "C:\Program Files\Google\Google Earth Pro\client\googleearth.exe",
        "C:\Program Files (x86)\Google\Google Earth Pro\client\googleearth.exe",
        "C:\Program Files\Google\Google Earth\client\googleearth.exe",
        "C:\Program Files (x86)\Google\Google Earth\client\googleearth.exe",
        "$env:LOCALAPPDATA\Google\Google Earth Pro\client\googleearth.exe",
        "$env:LOCALAPPDATA\Google\Google Earth\client\googleearth.exe",
        "$env:ProgramData\Google\Google Earth Pro\client\googleearth.exe"
    )

    $installedGe = $null
    foreach ($gp in $gePaths) {
        if (Test-Path $gp) { $installedGe = $gp; break }
    }

    if (-not $installedGe) {
        $startLnk = Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs" -Filter "*Google*Earth*.lnk" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($startLnk) {
            try {
                $wsh = New-Object -ComObject WScript.Shell
                $target = $wsh.CreateShortcut($startLnk.FullName).TargetPath
                if ($target -and (Test-Path $target)) { $installedGe = $target }
            } catch {}
        }
    }

    if ($installedGe) {
        Write-Host "   [OK SUDAH TERPASANG] Google Earth Pro terdeteksi di $installedGe." -ForegroundColor Green
        Create-AppShortcut -TargetExe $installedGe -ShortcutName "Google Earth Pro"
        Record-InstallResult -Name "Google Earth Pro" -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi aktif di sistem (Skip)"
        return
    }

    $existingGe = Get-ChildItem -Path $AppsDir -Filter "*googleearth*.exe" -File -Recurse -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -notmatch "unins" -and $_.Length -gt 10485760 } | Select-Object -First 1
    if (-not $existingGe) {
        $existingGe = Get-ChildItem -Path $AppsDir -Filter "*googleearth*.msi" -File -Recurse -ErrorAction SilentlyContinue |
                      Where-Object { $_.Length -gt 10485760 } | Select-Object -First 1
    }

    if (-not $existingGe) {
        $googleEarthMirrors = @(
            "https://dl.google.com/release2/Earth/fnndz6bt2usy3ez2s7f3i6aq6i_7.3.7.1327/googleearth-win-pro-7.3.7.1327-x64.exe",
            "https://dl.google.com/dl/earth/client/advanced/current/googleearthprowin-x64.exe",
            "https://dl.google.com/earth/client/advanced/current/googleearthprowin-x64.exe",
            "https://dl.google.com/dl/earth/client/advanced/current/googleearthprowin.exe"
        )
        $destExe = Join-Path $AppsDir "googleearth-win-pro-x64.exe"
        Write-Host "   [i] Mengunduh standalone offline installer Google Earth Pro..." -ForegroundColor Yellow
        $dlGe = Download-FileWithFastMirrors -Urls $googleEarthMirrors -DestinationPath $destExe -ActivityTitle "Mengunduh Google Earth Pro"
        if ($dlGe -and (Test-Path $destExe)) {
            $existingGe = Get-Item $destExe -ErrorAction SilentlyContinue
        }
    }

    $sevenZipExe = "C:\Program Files\7-Zip\7z.exe"
    if (-not (Test-Path $sevenZipExe)) { $sevenZipExe = "C:\Program Files (x86)\7-Zip\7z.exe" }

    if ($existingGe) {
        Write-Host "   [i] Memproses installer Google Earth Pro: $($existingGe.Name)..." -ForegroundColor Cyan

        if ($existingGe.Extension -ieq ".msi") {
            Write-Host "   [i] Memasang MSI Google Earth Pro langsung..." -ForegroundColor Cyan
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$($existingGe.FullName)`" /qn /norestart" -Wait -NoNewWindow
            $pollCount = 15
            while ($pollCount -gt 0) {
                Start-Sleep -Seconds 2
                foreach ($gp in $gePaths) {
                    if (Test-Path $gp) { $checkInstalled = $gp; break }
                }
                if ($checkInstalled) { break }
                $pollCount--
            }
        } elseif (Test-Path $sevenZipExe) {
            Write-Host "   [i] Membongkar installer .exe Google Earth Pro untuk mengambil file MSI..." -ForegroundColor Yellow
            $extractGeDir = Join-Path $AppsDir "GoogleEarth_Extracted"
            if (-not (Test-Path $extractGeDir)) { New-Item -ItemType Directory -Path $extractGeDir -Force | Out-Null }
            & "$sevenZipExe" x "$($existingGe.FullName)" "-o$extractGeDir" -y | Out-Null

            $extractedMsi = Get-ChildItem -Path $extractGeDir -Filter "*.msi" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($extractedMsi) {
                Write-Host "   [i] Menjalankan MSI resmi: $($extractedMsi.Name)..." -ForegroundColor Green
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$($extractedMsi.FullName)`" /qn /norestart" -Wait -NoNewWindow
                $pollCount = 15
                while ($pollCount -gt 0) {
                    Start-Sleep -Seconds 2
                    foreach ($gp in $gePaths) {
                        if (Test-Path $gp) { $checkInstalled = $gp; break }
                    }
                    if ($checkInstalled) { break }
                    $pollCount--
                }
            }
        }

        if (-not $checkInstalled -and $existingGe.Extension -ieq ".exe") {
            $switches = @("OMAHA=1 /silent", "/qn", "/S", "/VERYSILENT /NORESTART")
            foreach ($sw in $switches) {
                Write-Host "   [i] Menjalankan silent switch Google Earth Pro ($sw)..." -ForegroundColor Yellow
                $argList = Convert-ArgsToArray $sw
                Start-Process -FilePath $existingGe.FullName -ArgumentList $argList -Wait -NoNewWindow -ErrorAction SilentlyContinue
                
                # Tunggu proses background installer menyalin file ke disk
                $pollWait = 12
                while ($pollWait -gt 0) {
                    Start-Sleep -Seconds 2
                    foreach ($gp in $gePaths) {
                        if (Test-Path $gp) { $checkInstalled = $gp; break }
                    }
                    if ($checkInstalled) { break }
                    $pollWait--
                }
                if ($checkInstalled) { break }
            }
        }
    }

    if (-not $checkInstalled -and (Test-WingetAvailable)) {
        Write-Host "   [i] Memasang Google Earth Pro via Winget..." -ForegroundColor Yellow
        try {
            $wExe = Get-WingetExe
            & $wExe install --id "Google.EarthPro" --source winget -e --silent --accept-source-agreements --accept-package-agreements --disable-interactivity 2>$null
            $wPoll = 15
            while ($wPoll -gt 0) {
                Start-Sleep -Seconds 2
                foreach ($gp in $gePaths) {
                    if (Test-Path $gp) { $checkInstalled = $gp; break }
                }
                if ($checkInstalled) { break }
                $wPoll--
            }
        } catch {}
    }

    if (-not $checkInstalled) {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\googleearth.exe",
            "HKLM:\SOFTWARE\Google\Google Earth Pro",
            "HKLM:\SOFTWARE\WOW6432Node\Google\Google Earth Pro"
        )
        foreach ($rp in $regPaths) {
            if (Test-Path $rp) {
                $val = (Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue)."(Default)"
                if (-not $val) { $val = (Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue).InstallLocation }
                if ($val) {
                    if (Test-Path $val -PathType Leaf) { $checkInstalled = $val; break }
                    elseif (Test-Path (Join-Path $val "client\googleearth.exe")) { $checkInstalled = Join-Path $val "client\googleearth.exe"; break }
                    elseif (Test-Path (Join-Path $val "googleearth.exe")) { $checkInstalled = Join-Path $val "googleearth.exe"; break }
                }
            }
        }

        if (-not $checkInstalled) {
            $regUninstall = Get-ItemProperty @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*") -ErrorAction SilentlyContinue |
                            Where-Object { $_.DisplayName -like "*Google Earth*" } | Select-Object -First 1
            if ($regUninstall) {
                $loc = $regUninstall.InstallLocation
                if ($loc -and (Test-Path (Join-Path $loc "client\googleearth.exe"))) {
                    $checkInstalled = Join-Path $loc "client\googleearth.exe"
                } elseif ($loc -and (Test-Path $loc)) {
                    $checkInstalled = $loc
                } else {
                    $checkInstalled = "Google Earth Pro ($($regUninstall.DisplayVersion))"
                }
            }
        }

        if (-not $checkInstalled) {
            $postLnk = Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs" -Filter "*Google*Earth*.lnk" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($postLnk) {
                try {
                    $wsh = New-Object -ComObject WScript.Shell
                    $target = $wsh.CreateShortcut($postLnk.FullName).TargetPath
                    if ($target -and (Test-Path $target)) { $checkInstalled = $target }
                } catch {}
            }
        }
    }

    if ($checkInstalled) {
        if (Test-Path $checkInstalled -PathType Leaf) {
            Create-AppShortcut -TargetExe $checkInstalled -ShortcutName "Google Earth Pro"
        }
        Record-InstallResult -Name "Google Earth Pro" -Status "BERHASIL DIINSTAL" -Keterangan "Terpasang & shortcut dibuat"
        Write-Host "   [OK] Google Earth Pro berhasil dipasang: $checkInstalled" -ForegroundColor Green
    } else {
        Write-Host "   [!] Google Earth Pro belum berhasil terpasang otomatis." -ForegroundColor Yellow
        Record-InstallResult -Name "Google Earth Pro" -Status "GAGAL" -Keterangan "Gagal dieksekusi atau installer tidak kompatibel"
    }
}
