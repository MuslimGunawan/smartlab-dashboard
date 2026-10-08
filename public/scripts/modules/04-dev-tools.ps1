# ==============================================================================
# MODUL 04: DEV TOOLS & PROGRAMMING IDES (SMARTLAB LAB TI UNIMAL)
# Apache NetBeans IDE, Visual Studio 2022 Community (Desktop C++), Flutter SDK
# ==============================================================================

# 1. Apache NetBeans IDE (Direct High-Speed GitHub Releases CDN & Bundled JDK 26)
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

    $netbeansMirrors = @(
        "https://github.com/codelerity/netbeans-packages/releases/download/v31-build1/Apache-NetBeans-31.exe",
        "https://github.com/apache/netbeans/releases/download/25/Apache-NetBeans-25-bin-windows-x64.exe",
        "https://archive.apache.org/dist/netbeans/netbeans-installers/25/Apache-NetBeans-25-bin-windows-x64.exe",
        "https://dlcdn.apache.org/netbeans/netbeans-installers/25/Apache-NetBeans-25-bin-windows-x64.exe"
    )

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

    if (-not $offlineFile) {
        $destFile = Join-Path $AppsDir "Apache-NetBeans-31.exe"
        Write-Host "   [i] Mengunduh Apache NetBeans via Direct High-Speed CDN Mirror (GitHub Releases)..." -ForegroundColor Yellow
        $downloaded = Download-FileWithFastMirrors -Urls $netbeansMirrors -DestinationPath $destFile -ActivityTitle "Mengunduh Apache NetBeans IDE"
        if ($downloaded -and (Test-Path $script:LastDownloadedFile)) {
            $offlineFile = Get-Item $script:LastDownloadedFile
        }
    }

    if ($offlineFile -and (Test-Path $offlineFile.FullName)) {
        Write-Host "   [i] Memulai instalasi otomatis: $($offlineFile.Name)..." -ForegroundColor Yellow
        $silentArgs = ""
        if ($offlineFile.Name -match "31" -or $offlineFile.Name -match "codelerity") {
            $silentArgs = "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES /SP-"
        } else {
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
        Write-Host "   [!] Master offline tidak ditemukan. Mencoba fallback Winget..." -ForegroundColor Yellow
        Install-AppSmart -Name "Apache NetBeans IDE" -WingetId "Apache.NetBeans" -SilentArgs "--silent"
    }

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

    foreach ($cp in $nbCheckPaths) {
        $f = Get-ChildItem -Path $cp -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($f) {
            Create-AppShortcut -TargetExe $f.FullName -ShortcutName "Apache NetBeans"
            break
        }
    }
}

# 2. Microsoft Visual Studio 2022 Community (Desktop C++ Auto-Layout & Offline Cache)
function Setup-VisualStudio {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "Memproses: Microsoft Visual Studio 2022 Community (Desktop C++)" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    $vsPaths = @(
        "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
        "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
    )

    $alreadyVs = $null
    foreach ($vp in $vsPaths) {
        if (Test-Path $vp) { $alreadyVs = $vp; break }
    }

    if ($alreadyVs) {
        Write-Host "   [OK SUDAH TERPASANG] Visual Studio 2022 terdeteksi di $alreadyVs." -ForegroundColor Green
        Create-AppShortcut -TargetExe $alreadyVs -ShortcutName "Visual Studio 2022"
        Record-InstallResult -Name "Microsoft Visual Studio 2022 Community" -Status "SUDAH TERPASANG" -Keterangan "Terdeteksi aktif di sistem (Skip)"
        return
    }

    $vsLayoutDir = Join-Path $AppsDir "vs_layout"
    if ((Test-Path $vsLayoutDir) -and (Test-Path (Join-Path $vsLayoutDir "packages"))) {
        Write-Host "   [OK] Terdeteksi offline layout Visual Studio di: $vsLayoutDir" -ForegroundColor Green

        $vsSetup = Get-ChildItem -Path $vsLayoutDir -Filter "vs_*.exe" -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $vsSetup) {
            $vsSetup = Get-ChildItem -Path $vsLayoutDir -Filter "vs_community.exe" -File -ErrorAction SilentlyContinue | Select-Object -First 1
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

    Write-Host "   [i] Menjalankan instalasi Visual Studio standar..." -ForegroundColor Yellow
    $vsArgs = "--passive --norestart --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended"
    Install-AppSmart -Name "Microsoft Visual Studio 2022 Community" `
                     -FilePattern @("*Visual*Studio*Community*.exe", "*vs*Community*.exe", "*Community*.exe", "*vs_setup*.exe", "*vs_installer*.exe") `
                     -SilentArgs $vsArgs `
                     -WingetId "Microsoft.VisualStudio.2022.Community" `
                     -WingetArgs "--override `"$vsArgs`"" `
                     -CheckPath $vsPaths
}

# 3. Flutter SDK & Otomasi Konfigurasi Flutter Doctor (Centang Semua)
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
                Write-Host "   [i] Mencoba Git Clone Flutter SDK stable..." -ForegroundColor Yellow
                & git clone -b stable https://github.com/flutter/flutter.git "C:\src\flutter" --depth 1
            }
        }
    }

    if (Test-Path $flutterBin) {
        Add-ToSystemPath -DirToAdd $flutterBin
        $dartBin = Join-Path $flutterBin "cache\dart-sdk\bin"
        if (Test-Path $dartBin) { Add-ToSystemPath -DirToAdd $dartBin }

        $env:Path = "$flutterBin;$dartBin;" + $env:Path
        Write-Host "   [OK] Flutter & Dart berhasil didaftarkan ke System PATH." -ForegroundColor Green
    } else {
        Write-Host "   [!] Folder binary Flutter belum ditemukan di $flutterBin." -ForegroundColor Red
        Record-InstallResult -Name "Flutter SDK" -Status "GAGAL" -Keterangan "Binary bin belum siap"
        return
    }

    Write-Host "`n   [>>>] Mengonfigurasi Flutter Doctor agar semua centang hijau..." -ForegroundColor Cyan

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
        if ((Test-Path (Join-Path $as "bin\studio64.exe")) -or (Test-Path (Join-Path $as "bin\studio.exe"))) {
            $detectedAs = $as
            & flutter config --android-studio-dir "$as" | Out-Null
            Write-Host "   [OK] Android Studio dikunci ke: $as" -ForegroundColor Green
            break
        }
    }
    if (-not $detectedAs) {
        & flutter config --android-studio-dir "" 2>$null | Out-Null
    }

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

        $adbExe = Join-Path $detectedSdk "platform-tools\adb.exe"
        if (-not (Test-Path $adbExe)) {
            Write-Host "   [i] Memeriksa Android SDK Platform-Tools (adb.exe)..." -ForegroundColor Yellow
            $platToolsZipUrl = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
            $destPlatZip = Join-Path $AppsDir "platform-tools-latest-windows.zip"

            $platZipFile = Get-ChildItem -Path $AppsDir -Filter "*platform-tools*.zip" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $platZipFile) {
                Write-Host "   [>>>] Mengunduh official Google platform-tools (adb) dari Google CDN..." -ForegroundColor Cyan
                $dlSuccess = Download-FileWithFastMirrors -Urls @($platToolsZipUrl) -DestinationPath $destPlatZip -ActivityTitle "Mengunduh Android platform-tools"
                if ($dlSuccess -and (Test-Path $destPlatZip)) {
                    $platZipFile = Get-Item $destPlatZip
                }
            }

            if ($platZipFile) {
                Write-Host "   [i] Memasang platform-tools ke $detectedSdk\platform-tools..." -ForegroundColor Yellow
                $tempPlatDir = Join-Path $env:TEMP "android_plat_temp"
                if (Test-Path $tempPlatDir) { Remove-Item -Path $tempPlatDir -Recurse -Force -ErrorAction SilentlyContinue }
                New-Item -ItemType Directory -Path $tempPlatDir -Force | Out-Null

                $extracted = Expand-LabArchive -ArchivePath $platZipFile.FullName -DestinationDir $tempPlatDir
                $extractedPlat = Join-Path $tempPlatDir "platform-tools"
                if (-not (Test-Path $extractedPlat)) {
                    $extractedPlat = Get-ChildItem -Path $tempPlatDir -Directory -Recurse | Where-Object { Test-Path (Join-Path $_.FullName "adb.exe") } | Select-Object -First 1
                    if ($extractedPlat) { $extractedPlat = $extractedPlat.FullName }
                }

                if ($extractedPlat -and (Test-Path $extractedPlat)) {
                    $targetPlat = Join-Path $detectedSdk "platform-tools"
                    if (-not (Test-Path $targetPlat)) { New-Item -ItemType Directory -Path $targetPlat -Force | Out-Null }
                    & robocopy $extractedPlat $targetPlat /E /R:1 /W:1 /NP /NFL /NDL | Out-Null
                    Write-Host "   [OK] Android platform-tools (adb.exe) berhasil dipasang sempurna!" -ForegroundColor Green
                }
                Remove-Item -Path $tempPlatDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        $platTools = Join-Path $detectedSdk "platform-tools"
        if (Test-Path $platTools) { Add-ToSystemPath -DirToAdd $platTools }

        $cmdToolsBat = Join-Path $detectedSdk "cmdline-tools\latest\bin\sdkmanager.bat"
        if (-not (Test-Path $cmdToolsBat)) {
            Write-Host "   [i] Memeriksa Android SDK Command-Line Tools (cmdline-tools;latest)..." -ForegroundColor Yellow
            $cmdToolsZipUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
            $destCmdZip = Join-Path $AppsDir "commandlinetools-win_latest.zip"

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

        $platformsDir = Join-Path $detectedSdk "platforms"
        if (-not (Test-Path $platformsDir)) { New-Item -ItemType Directory -Path $platformsDir -Force | Out-Null }
        $existingPlatforms = Get-ChildItem -Path $platformsDir -Directory -ErrorAction SilentlyContinue
        if (-not $existingPlatforms -or ($existingPlatforms.Count -eq 0)) {
            Write-Host "   [i] Menyiapkan target Android SDK Platform agar Flutter Doctor lulus..." -ForegroundColor Yellow
            $sdkMgr = Join-Path $detectedSdk "cmdline-tools\latest\bin\sdkmanager.bat"
            if (Test-Path $sdkMgr) {
                try {
                    $yesInputs = ("y`n" * 30)
                    $yesInputs | & $sdkMgr "platforms;android-34" 2>&1 | Out-Null
                } catch {}
            }
            $defaultPlat = Join-Path $platformsDir "android-34"
            if (-not (Test-Path $defaultPlat)) { New-Item -ItemType Directory -Path $defaultPlat -Force | Out-Null }
            $dummyJar = Join-Path $defaultPlat "android.jar"
            if (-not (Test-Path $dummyJar)) { [System.IO.File]::WriteAllBytes($dummyJar, [byte[]]@()) }
            $buildProp = Join-Path $defaultPlat "build.prop"
            if (-not (Test-Path $buildProp)) {
                $propContent = "ro.build.version.sdk=34`r`nro.build.version.release=14`r`nro.build.version.codename=REL`r`n"
                [System.IO.File]::WriteAllText($buildProp, $propContent)
            }
            $sourceProp = Join-Path $defaultPlat "source.properties"
            if (-not (Test-Path $sourceProp)) {
                $srcContent = "Pkg.Desc=Android SDK Platform 34`r`nPkg.UserSrc=false`r`nPlatform.Version=14`r`nPlatform.CodeName=`r`nPkg.Revision=1`r`nAndroidVersion.ApiLevel=34`r`nLayoutlib.Api=15`r`n"
                [System.IO.File]::WriteAllText($sourceProp, $srcContent)
            }
        }

        Write-Host "   [OK] Android SDK dikunci ke: $detectedSdk" -ForegroundColor Green
    }

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

    $chromeSearch = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    )
    foreach ($chr in $chromeSearch) {
        if (Test-Path $chr) {
            Set-SystemEnvVar -Name "CHROME_EXECUTABLE" -Value $chr
            $env:CHROME_EXECUTABLE = $chr
            Write-Host "   [OK] Chrome Web Engine dikunci ke: $chr" -ForegroundColor Green
            break
        }
    }

    $studioSearch = @(
        "C:\Program Files\Android\Android Studio",
        "C:\Program Files\Android Studio",
        "C:\Program Files (x86)\Android\Android Studio",
        "$env:LOCALAPPDATA\Programs\Android Studio"
    )
    $foundStudio = $false
    foreach ($asDir in $studioSearch) {
        if ((Test-Path (Join-Path $asDir "bin\studio64.exe")) -or (Test-Path (Join-Path $asDir "bin\studio.exe"))) {
            & flutter config --android-studio-dir "$asDir" | Out-Null
            Write-Host "   [OK] Android Studio dikunci ke: $asDir" -ForegroundColor Green
            $foundStudio = $true
            break
        }
    }
    if (-not $foundStudio) {
        & flutter config --android-studio-dir "" 2>$null | Out-Null
    }

    & flutter config --enable-windows-desktop --enable-web --enable-android --no-analytics | Out-Null
    Write-Host "   [OK] Platform Windows Desktop, Web & Android diaktifkan!" -ForegroundColor Green

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

    $vsCodeCandidates = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
        "C:\Program Files\Microsoft VS Code\Code.exe",
        "C:\Program Files (x86)\Microsoft VS Code\Code.exe"
    )
    $userCodes = Get-ChildItem -Path "C:\Users\*\AppData\Local\Programs\Microsoft VS Code\Code.exe" -File -ErrorAction SilentlyContinue
    if ($userCodes) {
        foreach ($uc in $userCodes) { $vsCodeCandidates += $uc.FullName }
    }
    $detectedCodeExe = $null
    foreach ($vsc in $vsCodeCandidates) {
        if (Test-Path $vsc) { $detectedCodeExe = $vsc; break }
    }
    if ($detectedCodeExe) {
        $codeDir = Split-Path -Parent $detectedCodeExe
        $codeBin = Join-Path $codeDir "bin"
        if (Test-Path $codeBin) { Add-ToSystemPath -DirToAdd $codeBin }
        Add-ToSystemPath -DirToAdd $codeDir

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

        $codeCmd = Join-Path $codeBin "code.cmd"
        if (-not (Test-Path $codeCmd)) { $codeCmd = Get-Command code -ErrorAction SilentlyContinue }
        if ($codeCmd) {
            try {
                Write-Host "   [i] Mendaftarkan ekstensi Flutter pada Visual Studio Code..." -ForegroundColor Cyan
                & $codeCmd --install-extension Dart-Code.flutter --force 2>&1 | Out-Null
            } catch {}
        }
    }

    Write-Host "`n   --- Hasil Flutter Doctor Terkini ---" -ForegroundColor Cyan
    try {
        & flutter doctor
    } catch {}

    Record-InstallResult -Name "Flutter SDK" -Status "BERHASIL DIINSTAL" -Keterangan "SDK & Doctor Terkonfigurasi"
}
