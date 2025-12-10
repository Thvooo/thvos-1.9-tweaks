# ===========================================
#       LIQUID TECH PC Tweaker v3.6
#    Aggressive Debloat & Ultimate Process Killer
# ===========================================

# --- SELF-ELEVATION CHECK ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$LTVersion = "3.6"   
# IMPORTANT: Update this URL to point to the raw content of your file on GitHub
$LTRepoURL = "https://raw.githubusercontent.com/Thvooo/thvos-1.9-tweaks/main/thvotweaks.ps1" 

# ------------------------------
#       ASCII LOGO (Liquid)
# ------------------------------
$LTLogo = @"
___________.__                          __                        __            
\__    ___/|  |_____  ______  ______ _/  |___  _  __ ____ _____  |  |__  ______
  |    |   |  |  \  \/ /  _ \/  ___/ \   __\ \/ \/ // __ \\__  \ |  |/ / /  ___/
  |    |   |   Y  \    (  <_> )___ \  |  |  \     /\  ___/ / __ \|    <  \___ \ 
  |____|   |___|  /\_/ \____/____  >  |__|   \/\_/  \___  >____  /__|_ \/____  >
                \/               \/                     \/     \/     \/     \/ 
                          T H V O   T W E A K E R
"@

function LT-Header {
    Clear-Host
    Write-Host $LTLogo -ForegroundColor Cyan
    Write-Host "Version: $LTVersion | Running as Administrator" -ForegroundColor DarkGray
    Write-Host "----------------------------------------------------" -ForegroundColor Gray
    Write-Host ""
}

# ------------------------------
#        Auto Updater 
# ------------------------------
function LT-Update {
    LT-Header
    Write-Host "Checking for updates..." -ForegroundColor Cyan
    try {
        $remote = (iwr -useb $LTRepoURL).Content
        if ($remote -match '\$LTVersion = "(.+?)"') { $remoteVersion = $matches[1] }

        if ($remoteVersion -gt $LTVersion) {
            Write-Host "New version available: $remoteVersion" -ForegroundColor Green
            Write-Host "Updating..." -ForegroundColor Yellow
            $scriptPath = $MyInvocation.MyCommand.Source
            iwr -useb $LTRepoURL | Out-File $scriptPath -Force
            Write-Host "Updated successfully! Restarting..." -ForegroundColor Green
            Start-Sleep 2
            powershell -ExecutionPolicy Bypass -File $scriptPath
            exit
        } else { Write-Host "You are on the latest version." -ForegroundColor Green }
    } catch { Write-Host "Update check failed (Check URL/Internet)." -ForegroundColor Red }
    Pause
}

# ------------------------------
#            Menu 
# ------------------------------
function LT-Menu {
    LT-Header
    Write-Host "  [ SYSTEM ]" -ForegroundColor Cyan
    Write-Host "   1) System Info"
    Write-Host "   2) Clean Temporary Files"
    Write-Host "   3) Safe Startup Optimizer"
    Write-Host "   4) Toggle Dark/Light Mode"
    Write-Host "   5) Create Restore Point"
    
    Write-Host "`n  [ NETWORK ]" -ForegroundColor Cyan
    Write-Host "   6) Basic Network Reset"
    Write-Host "   7) Internet Optimizer (Network Throttling Fix!)"
    Write-Host "   8) Latency Optimizer (Disable Nagle's Algorithm!)"
    Write-Host "   9) DNS Changer (Auto Test & Select Fastest!)"

    Write-Host "`n  [ PERFORMANCE ]" -ForegroundColor Cyan
    Write-Host "   10) Windows Services Optimization (Expanded Services!)"
    Write-Host "   11) Repair Windows Components (DISM/SFC)"
    Write-Host "   12) Aggressive Debloater (Removes 20+ UWP Apps!) (UPDATED!)"
    Write-Host "   13) FPS Booster (Advanced + Power Fix)"
    Write-Host "   14) Aggressive Visual Optimization (MAX FPS Tweak)"
    Write-Host "   15) System Timer Resolution Fix (Thread Priority)"

    Write-Host "`n  [ PROCESS & MEMORY ]" -ForegroundColor Cyan
    Write-Host "   16) Smart Process Reducer (Superfetch/Error Fix!)"
    Write-Host "   17) Deep Process Cleaner (Media/UPnP Services)"
    Write-Host "   18) Extreme Process Purge (Camera/App Experience!)"
    Write-Host "   19) Ultimate Bloatware & Telemetry Silencer"
    Write-Host "   20) Virtual Memory Optimizer"
    Write-Host "   21) Extra Safe Tweaks"

    Write-Host "`n  [ INPUT LATENCY ]" -ForegroundColor Cyan
    Write-Host "   22) Input Latency Optimizer (Submenu)"


    Write-Host "`n  [ OTHER ]" -ForegroundColor Cyan
    Write-Host "   23) Check for Updates"
    Write-Host "   24) Exit"
    Write-Host ""
}

# ------------------------------
#       System Tools 
# ------------------------------
function LT-SystemInfo {
    LT-Header
    Write-Host "System Information:`n" -ForegroundColor Yellow
    Get-ComputerInfo | Select-Object OSName, OSVersion, CsManufacturer, CsModel, CsSystemType, CsRAM, CsNumberOfLogicalProcessors | Format-List
    Pause
}

function LT-CleanTemp {
    LT-Header
    Write-Host "Cleaning temporary files..." -ForegroundColor Yellow
    $paths = @("$env:TEMP\*", "$env:WINDIR\Temp\*")
    foreach ($p in $paths) { 
        Write-Host "Cleaning $p..." -ForegroundColor Gray
        Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue 
    }
    ipconfig /flushdns | Out-Null
    Write-Host "Temp files cleaned." -ForegroundColor Green
    Pause
}

function LT-StartupOptimizer {
    LT-Header
    Write-Host "Startup Programs (View Only):" -ForegroundColor Yellow
    Get-CimInstance Win32_StartupCommand | Select-Object Name, Command | Format-Table -AutoSize
    Write-Host "To disable these, use Task Manager (Ctrl+Shift+Esc)" -ForegroundColor DarkGray
    Pause
}

function LT-ToggleTheme {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $current = (Get-ItemProperty -Path $regPath -Name AppsUseLightTheme).AppsUseLightTheme
    Set-ItemProperty -Path $regPath -Name AppsUseLightTheme -Value ($current -bxor 1)
    Set-ItemProperty -Path $regPath -Name SystemUsesLightTheme -Value ($current -bxor 1)
    Write-Host "Theme toggled." -ForegroundColor Green
    Pause
}

function LT-NetworkReset {
    LT-Header
    Write-Host "Resetting Network Stack..." -ForegroundColor Yellow
    ipconfig /flushdns | Out-Null
    netsh winsock reset | Out-Null
    netsh int ip reset | Out-Null
    Write-Host "Network reset complete." -ForegroundColor Green
    Pause
}

function LT-RestorePoint {
    LT-Header
    Write-Host "Creating Restore Point..." -ForegroundColor Yellow
    try {
        Checkpoint-Computer -Description "LiquidTech Restore Point" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "Restore Point created successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to create Restore Point. Enable System Protection first." -ForegroundColor Red
    }
    Pause
}

# ------------------------------
#      Windows Services Optimization 
# ------------------------------
function LT-ServiceOptimize {
    LT-Header
    Write-Host "Optimizing Windows Services (Disabling Non-Essential)..."
    
    # Expanded list of non-essential services to disable
    $servicesToDisable = @(
        "DiagTrack",          # Connected User Experiences and Telemetry
        "dmwappushservice",   # WAP Push Message Routing Service
        "MapsBroker",         # Downloaded Maps Manager
        "lfsvc",              # Geolocation Service
        "RetailDemo",         # Retail Demo Service
        "RemoteRegistry",     # Remote Registry (Security Risk)
        "SharedAccess",       # Internet Connection Sharing (ICS)
        "TabletInputService", # Tablet and Pen Input Service (If no touch/pen)
        "TrkWks",             # Distributed Link Tracking Client
        "XblAuthManager",     # Xbox Live Auth Manager
        "XblGameSave",        # Xbox Live Game Save
        "XboxNetApiSvc"       # Xbox Live Networking Service
    )
    
    foreach ($svc in $servicesToDisable) { 
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) { 
            Set-Service -Name $svc -StartupType Disabled 
            Stop-Service -Name $svc -ErrorAction SilentlyContinue
            Write-Host "Disabled: $svc" -ForegroundColor Gray
        } 
    }
    Write-Host "Expanded service tweaks applied. Reboot is recommended for full effect." -ForegroundColor Green
    Pause
}

# ------------------------------
#      Smart Process Reducer 
# ------------------------------
function LT-SmartProcessReducer {
    LT-Header
    Write-Host "SMART PROCESS REDUCER" -ForegroundColor Cyan
    Write-Host "Disabling background tasks including SysMain, Error Reporting, and Virtual Printers." -ForegroundColor Gray
    Write-Host ""

    # Disable SysMain (Superfetch)
    Write-Host "Disabling SysMain (Superfetch) service..." -ForegroundColor Yellow
    Stop-Service "SysMain" -ErrorAction SilentlyContinue
    Set-Service "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue

    # Disable Windows Error Reporting Service
    Write-Host "Disabling Windows Error Reporting (WerSvc)..." -ForegroundColor Yellow
    Stop-Service "WerSvc" -ErrorAction SilentlyContinue
    Set-Service "WerSvc" -StartupType Disabled -ErrorAction SilentlyContinue


    # 1. Printer Check
    $print = Read-Host "Do you use a Physical Printer? (Y/N)"
    if ($print -eq "N" -or $print -eq "n") {
        Write-Host "Disabling Print Spooler..." -ForegroundColor Yellow
        Stop-Service "Spooler" -ErrorAction SilentlyContinue
        Set-Service "Spooler" -StartupType Disabled -ErrorAction SilentlyContinue
    }
    
    # Disable virtual/software printers
    Write-Host "Disabling Virtual Printers (PDF, XPS)..." -ForegroundColor Yellow
    $virtualPrinters = @(
        "Microsoft XPS Document Writer", 
        "Microsoft Print to PDF"
    )
    foreach ($vp in $virtualPrinters) {
        Write-Host "  Removing virtual printer: $vp" -ForegroundColor DarkGray
        (Get-WmiObject -Class Win32_Printer | Where-Object {$_.Name -eq $vp}) | Remove-WmiObject -ErrorAction SilentlyContinue
    }

    # Disable Fax Service
    $fax = Read-Host "Do you use a Fax Machine? (Y/N)"
    if ($fax -eq "N" -or $fax -eq "n") {
        Write-Host "Disabling Fax Service..." -ForegroundColor Yellow
        Stop-Service "Fax" -ErrorAction SilentlyContinue
        Set-Service "Fax" -StartupType Disabled -ErrorAction SilentlyContinue
    }


    # 2. Bluetooth Check
    $bt = Read-Host "Do you use Bluetooth? (Y/N)"
    if ($bt -eq "N" -or $bt -eq "n") {
        Write-Host "Disabling Bluetooth Services..." -ForegroundColor Yellow
        $btServices = @("bthserv", "BthHFSrv") 
        foreach ($s in $btServices) {
            Stop-Service $s -ErrorAction SilentlyContinue
            Set-Service $s -StartupType Disabled -ErrorAction SilentlyContinue
        }
    }

    # 3. Disable Background Apps (Global)
    Write-Host "Disabling global background app execution..." -ForegroundColor Yellow
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle" -Value 0 -PropertyType DWord -Force | Out-Null

    # 4. Kill Active Bloat
    Write-Host "Stopping active bloat processes..." -ForegroundColor Yellow
    $bloatProcs = @("OneDrive", "SkypeApp", "PhoneExperienceHost", "Cortana", "YourPhone")
    foreach ($proc in $bloatProcs) {
        Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Process optimization complete! A reboot is recommended." -ForegroundColor Green
    Pause
}

# ------------------------------
#      Deep Process Cleaner 
# ------------------------------
function LT-DeepProcessCleaner {
    LT-Header
    Write-Host "DEEP PROCESS CLEANER" -ForegroundColor Cyan
    Write-Host "Targets media sharing, network discovery, and secondary printer services." -ForegroundColor Gray
    Write-Host ""
    
    $deepServices = @(
        "SSDPSRV",      # SSDP Discovery Service (Used for UPnP/network discovery)
        "upnphost",     # UPnP Device Host
        "PcaSvc",       # Program Compatibility Assistant Service
        "WMPNetworkSvc",# Windows Media Player Network Sharing Service
        "Fax"           # Fax Service (If user missed it in Smart Reducer)
    )

    Write-Host "Disabling deep system services..." -ForegroundColor Yellow
    foreach ($svc in $deepServices) { 
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) { 
            Set-Service -Name $svc -StartupType Disabled 
            Stop-Service -Name $svc -ErrorAction SilentlyContinue
            Write-Host "Disabled: $svc" -ForegroundColor Gray
        } 
    }
    
    Write-Host "Killing desktop bloat processes..." -ForegroundColor Yellow
    $desktopBloat = @("ShellExperienceHost", "SearchUI")
    foreach ($proc in $desktopBloat) {
        # Note: Killing these can cause Explorer to restart, which is fine.
        Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Deep clean complete. Reboot for maximum effect." -ForegroundColor Green
    Pause
}

# ------------------------------
#      Extreme Process Purge 
# ------------------------------
function LT-ExtremeProcessPurge {
    LT-Header
    Write-Host "🔥 EXTREME PROCESS PURGE" -ForegroundColor Red
    Write-Host "WARNING: This targets services for Windows Hello, secondary devices, and application experience. Do NOT run if you rely on cameras, PIN/fingerprint login, or specialized devices." -ForegroundColor Yellow
    Write-Host ""
    
    $extremeServices = @(
        "TokenBroker",        # Token Broker (Used by modern apps, can be high CPU)
        "DeviceAssociationService", # Enables pairing of devices (e.g., Bluetooth, peripherals)
        "WebcamService",      # Camera related services
        "FrameServer",        # Windows Camera Frame Server
        "PimIndexMaintenanceSvc", # Contact Data maintenance
        "cbdhsvc_26e7a",      # ClipSVC related (License management)
        "ServiceBus",         # App-related background component
        "AppReadiness",       # App Readiness Service (Pre-caching for apps)
        "DoSvc"               # Delivery Optimization Service (P2P updates)
    )

    Write-Host "Disabling extreme background services..." -ForegroundColor Yellow
    foreach ($svc in $extremeServices) { 
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) { 
            Set-Service -Name $svc -StartupType Disabled 
            Stop-Service -Name $svc -ErrorAction SilentlyContinue
            Write-Host "Disabled: $svc" -ForegroundColor Gray
        } 
    }
    
    Write-Host "Extreme process purge complete. **A reboot is highly recommended.**" -ForegroundColor Green
    Pause
}

# ------------------------------
#      Ultimate Bloatware Silencer 
# ------------------------------
function LT-UltimateBloatSilencer {
    LT-Header
    Write-Host "☠️ ULTIMATE BLOATWARE & TELEMETRY SILENCER" -ForegroundColor Red
    Write-Host "Disabling heavily entrenched background services (Biometrics, Wallet, Insider, AllJoyn)." -ForegroundColor Gray
    Write-Host "This will reduce process count significantly." -ForegroundColor Yellow
    Write-Host ""

    $ultimateServices = @(
        "WbioSrvc",       # Windows Biometric Service (Fingerprint/Face)
        "AJRouter",       # AllJoyn Router Service
        "PhoneSvc",       # Phone Service
        "WpcMonSvc",      # Parental Controls
        "CscService",     # Offline Files
        "icssvc",         # Windows Mobile Hotspot Service
        "wisvc",          # Windows Insider Service
        "WalletService",  # Wallet Service
        "EntAppSvc",      # Enterprise App Management
        "SensorService",  # Sensor Service (Rotation/Auto-brightness)
        "SensrSvc",       # Adaptive Brightness
        "lfsvc"           # Geolocation Service
    )

    foreach ($svc in $ultimateServices) { 
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) { 
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "Disabled: $svc" -ForegroundColor Red
        } 
    }

    Write-Host "Ultimate silencing complete. Reboot required." -ForegroundColor Green
    Pause
}


# ------------------------------
#      Virtual Memory Optimizer 
# ------------------------------
function LT-MemoryOptimizer {
    LT-Header
    Write-Host "VIRTUAL MEMORY OPTIMIZER" -ForegroundColor Cyan
    Write-Host "This will reduce processes by setting a fixed Page File size and disabling Hibernation." -ForegroundColor Gray
    Write-Host ""

    # 1. Disable Dynamic Paging and Set Fixed Size
    Write-Host "Setting fixed Page File size (Recommended: 1.5x to 3x your RAM)..." -ForegroundColor Yellow
    
    # Get physical RAM size in MB
    $RAM_MB = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB
    $InitialSize = [math]::Round($RAM_MB * 1.5)
    $MaximumSize = [math]::Round($RAM_MB * 3)

    Write-Host "  RAM Detected: $($RAM_MB / 1024) GB" -ForegroundColor DarkGray
    Write-Host "  Setting Initial Size to $InitialSize MB" -ForegroundColor DarkGray
    Write-Host "  Setting Maximum Size to $MaximumSize MB" -ForegroundColor DarkGray

    # Set page file size (C:\ only for simplicity)
    Set-CimInstance -Query "SELECT * FROM Win32_PageFileSetting WHERE Name = 'C:\\pagefile.sys'" -Property @{InitialSize=$InitialSize; MaximumSize=$MaximumSize} -ErrorAction SilentlyContinue
    
    # 2. Disable Dynamic Management
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentVersion\Control\Session Manager\Memory Management" -Name "PagingFiles" -Value "C:\pagefile.sys $InitialSize $MaximumSize" -Type MultiString -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentVersion\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force | Out-Null

    # 3. Disable Hibernation (Removes hiberfil.sys and related background processes)
    $hibernation = Read-Host "Do you use Hibernation (saving session to disk)? (Y/N)"
    if ($hibernation -eq "N" -or $hibernation -eq "n") {
        Write-Host "Disabling Hibernation..." -ForegroundColor Yellow
        powercfg /hibernate off
    }

    Write-Host "Virtual Memory optimization applied. A reboot is REQUIRED." -ForegroundColor Green
    Pause
}

# ------------------------------
#      Extra Safe Tweaks 
# ------------------------------
function LT-ExtraSafeTweaks {
    LT-Header
    Write-Host "EXTRA SAFE TWEAKS" -ForegroundColor Cyan
    Write-Host "Applying low-impact quality of life and minor performance improvements." -ForegroundColor Gray
    Write-Host ""
    
    # 1. Disable Search Indexer (unless required for large document searching)
    $search = Read-Host "Disable Windows Search Indexer (Better for SSDs, Worse for File Search)? (Y/N)"
    if ($search -eq "Y" -or $search -eq "y") {
        Write-Host "Disabling Windows Search..." -ForegroundColor Yellow
        Stop-Service "WSearch" -ErrorAction SilentlyContinue
        Set-Service "WSearch" -StartupType Disabled
    }

    # 2. Disable Diagnostic Data/Telemetry
    Write-Host "Disabling Telemetry and Diagnostics..." -ForegroundColor Yellow
    Set-Service "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    Set-Service "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
    
    # 3. Disable Game DVR/Background Recording
    Write-Host "Disabling Game DVR/Background Recording..." -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force | Out-Null

    Write-Host "Extra safe tweaks applied." -ForegroundColor Green
    Pause
}

# ------------------------------
#      Input Latency Optimizer 
# ------------------------------
function LT-InputLatencyOptimizerMenu {
    LT-Header
    Write-Host "  [ INPUT LATENCY OPTIMIZER ]" -ForegroundColor Cyan
    Write-Host "   22.1) Standard Mouse/Keyboard Fixes (Queue, Speed, Acceleration)"
    Write-Host "   22.2) USB Polling & Interrupt Tweak (Force High Priority)"
    Write-Host "   22.3) Gaming Input Buffer Reduction (Desktop Composition)"
    Write-Host "   22.4) Advanced Kernel & Thread Priority Tweaks"
    Write-Host "   22.5) Return to Main Menu"
    Write-Host ""

    $subChoice = Read-Host "Select a sub-option"
    switch ($subChoice) {
        "22.1" { LT-StandardInputFixes }
        "22.2" { LT-USBPriorityFix }
        "22.3" { LT-GamingBufferReduce }
        "22.4" { LT-KernelInputTweaks }
        "22.5" { return }
        default { Write-Host "Invalid selection." -ForegroundColor Red; Start-Sleep 1 }
    }
    Pause
}

function LT-StandardInputFixes {
    LT-Header
    Write-Host "1. Standard Mouse/Keyboard Fixes" -ForegroundColor Yellow

    # Mouse/Keyboard Input Queue Reduction 
    Write-Host "Applying Low Latency Input Queue Tweak (Class keys)..." -ForegroundColor Cyan
    
    # Mouse Class GUID
    $mouseQueuePathBase = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e96f-e325-11ce-bfc1-08002be10318}"
    # Keyboard Class GUID
    $keyboardQueuePathBase = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e96b-e325-11ce-bfc1-08002be10318}"

    $paths = @($mouseQueuePathBase, $keyboardQueuePathBase)
    
    foreach ($path in $paths) {
        try {
            New-ItemProperty -Path $path -Name "MaxInputDataQueueLength" -Value 20 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
            Write-Host "  Set MaxInputDataQueueLength on $path" -ForegroundColor DarkGreen
        } catch {
            Write-Host "  ERROR: Failed to set MaxInputDataQueueLength on $path." -ForegroundColor Red
        }
    }
    
    # DISABLE Mouse Acceleration (Enhanced Pointer Precision)
    Write-Host "Disabling Enhanced Pointer Precision (Mouse Acceleration)..." -ForegroundColor Cyan
    $mouseReg = "HKCU:\Control Panel\Mouse"
    
    Set-ItemProperty -Path $mouseReg -Name "MouseThreshold1" -Value 0 -Type String -Force | Out-Null
    Set-ItemProperty -Path $mouseReg -Name "MouseThreshold2" -Value 0 -Type String -Force | Out-Null
    Set-ItemProperty -Path $mouseReg -Name "MouseSpeed" -Value 1 -Type String -Force | Out-Null 
    Set-ItemProperty -Path $mouseReg -Name "MouseAcceleration" -Value 0 -Type String -Force | Out-Null

    # Keyboard Repeat Rate Fix (Minimum delay/Maximum repeat speed)
    Write-Host "Setting Keyboard Repeat Rate to Max Speed..." -ForegroundColor Cyan
    $keyboardReg = "HKCU:\Control Panel\Keyboard"
    Set-ItemProperty -Path $keyboardReg -Name "KeyboardDelay" -Value 0 -Type String -Force | Out-Null # Minimum delay (0-3)
    Set-ItemProperty -Path $keyboardReg -Name "KeyboardSpeed" -Value 31 -Type String -Force | Out-Null # Maximum speed (0-31)

    Write-Host "Standard input fixes applied." -ForegroundColor Green
}

function LT-USBPriorityFix {
    LT-Header
    Write-Host "2. USB Polling & Interrupt Tweak" -ForegroundColor Yellow

    # Force Mouse Interrupt Priority to High (Prevents CPU from delaying mouse processing)
    Write-Host "Setting Mouse Interrupt Priority to high..." -ForegroundColor Cyan
    $mouseInterruptPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    try {
        # This key forces system to prioritize input writes
        New-ItemProperty -Path $mouseInterruptPath -Name "SaturatedWriteWhenMiceOrKeyboardsAreUsed" -Value 1 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        Write-Host "  Set SaturatedWriteWhenMiceOrKeyboardsAreUsed to 1" -ForegroundColor DarkGreen
    } catch {
        Write-Host "  ERROR: Failed to set Mouse Interrupt Priority value." -ForegroundColor Red
    }
    
    # Disable USB Selective Suspend (Stops USB ports from entering low-power states, reducing polling delay)
    Write-Host "Disabling USB Selective Suspend Power Save..." -ForegroundColor Cyan
    $usbRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
    Set-ItemProperty -Path $usbRegPath -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force | Out-Null
    
    # Set power plan settings (for the currently active scheme) to disable USB power saving
    Write-Host "Disabling USB power saving in active Power Scheme..." -ForegroundColor Cyan
    $activeGuid = (powercfg -getactivescheme | Select-String -Pattern "Power Scheme GUID: (.*?) ").Matches[0].Groups[1].Value.Trim()
    
    # Setting the USB Selective Suspend global flag to 0 (Disabled)
    powercfg /SETACVALUEINDEX $activeGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 | Out-Null
    powercfg /SETDCVALUEINDEX $activeGuid 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 | Out-Null
    
    Write-Host "USB polling and interrupt tweaks applied." -ForegroundColor Green
}

function LT-GamingBufferReduce {
    LT-Header
    Write-Host "3. Gaming Input Buffer Reduction" -ForegroundColor Yellow

    # Force Feedback Desktop Delay Reduction (Affects gaming input buffer/RDP compatibility)
    Write-Host "Applying Force Feedback Delay Reduction (Low-latency gaming input)..." -ForegroundColor Cyan
    $ffRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
    try {
        New-ItemProperty -Path $ffRegPath -Name "ForceFeedbackDesktop" -Value 0 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        Write-Host "  Set ForceFeedbackDesktop to 0" -ForegroundColor DarkGreen
    } catch {
        Write-Host "  ERROR: Failed to set ForceFeedbackDesktop value." -ForegroundColor Red
    }
    
    # Disable Desktop Composition for input (Windows 7 legacy, but still affects input pipeline on some Win10/11 versions)
    Write-Host "Disabling Desktop Composition Input Delay..." -ForegroundColor Cyan
    $desktopCompositionReg = "HKCU:\Software\Microsoft\Windows\DWM"
    try {
        New-ItemProperty -Path $desktopCompositionReg -Name "Composition" -Value 0 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        New-ItemProperty -Path $desktopCompositionReg -Name "CompositionPolicy" -Value 0 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        Write-Host "  Desktop Composition Input settings set to 0" -ForegroundColor DarkGreen
    } catch {
        Write-Host "  ERROR: Failed to apply Desktop Composition tweaks." -ForegroundColor Red
    }
    
    Write-Host "Gaming input buffer reductions applied." -ForegroundColor Green
}

function LT-KernelInputTweaks {
    LT-Header
    Write-Host "4. Advanced Kernel & Thread Priority Tweaks" -ForegroundColor Yellow

    # Win32PrioritySeparation (Optimizes foreground application priority)
    # Value 26 (Hex) is commonly used for performance/responsiveness in games.
    Write-Host "Optimizing Win32PrioritySeparation (Foreground Priority)..." -ForegroundColor Cyan
    $priorityControlPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    try {
        New-ItemProperty -Path $priorityControlPath -Name "Win32PrioritySeparation" -Value 38 -PropertyType DWord -Force -ErrorAction Stop | Out-Null # 0x26 = 38 decimal
        Write-Host "  Set Win32PrioritySeparation to 26 (Hex)" -ForegroundColor DarkGreen
    } catch {
        Write-Host "  ERROR: Failed to set Win32PrioritySeparation." -ForegroundColor Red
    }

    # IRQ8 Priority (System Real Time Clock)
    # Raising priority of the system clock interrupt can improve timing consistency.
    Write-Host "Raising IRQ8 (System Clock) Priority..." -ForegroundColor Cyan
    $irq8Path = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    try {
        New-ItemProperty -Path $irq8Path -Name "IRQ8Priority" -Value 1 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        Write-Host "  Set IRQ8Priority to 1 (High)" -ForegroundColor DarkGreen
    } catch {
        Write-Host "  ERROR: Failed to set IRQ8Priority." -ForegroundColor Red
    }

    # Disable Dynamic Tick (Tickless Kernel)
    # Forces the system timer to be consistent, preventing it from idling to save power.
    Write-Host "Disabling Dynamic Tick (Consistent Kernel Timer)..." -ForegroundColor Cyan
    $bcdResult = bcdedit /set disabledynamictick yes
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Dynamic Tick disabled successfully." -ForegroundColor DarkGreen
    } else {
        Write-Host "  ERROR: Failed to disable Dynamic Tick." -ForegroundColor Red
    }

    Write-Host "Advanced kernel input tweaks applied. Reboot REQUIRED." -ForegroundColor Green
}


# ------------------------------
#        Internet Optimizer 
# ------------------------------
function LT-InternetOptimize {
    LT-Header
    Write-Host "Optimizing TCP/IP Stack and Network Throttling..." -ForegroundColor Yellow
    
    ipconfig /flushdns | Out-Null
    netsh winsock reset | Out-Null
    netsh int ip reset | Out-Null
    
    # Default recommended TCP settings
    netsh interface tcp set global autotuninglevel=normal | Out-Null
    netsh interface tcp set global congestionprovider=ctcp | Out-Null
    
    # Disable Network Throttling (improves bandwidth for background apps/games)
    Write-Host "Disabling Network Throttling..." -ForegroundColor Cyan
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    New-ItemProperty -Path $regPath -Name "NetworkThrottlingIndex" -Value 0 -PropertyType DWord -Force | Out-Null
    
    Write-Host "Internet optimization complete. Reboot for best effect." -ForegroundColor Green
    Pause
}

# ------------------------------
#           Repair Tools 
# ------------------------------
function LT-RepairTools {
    LT-Header
    Write-Host "Running DISM Repair..." -ForegroundColor Yellow
    dism /online /cleanup-image /restoreHealth
    Write-Host "Running SFC Scan..." -ForegroundColor Yellow
    sfc /scannow
    Write-Host "Repairs complete." -ForegroundColor Green
    Pause
}

# ------------------------------
#      Aggressive Debloater (New Option 12) 
# ------------------------------
function LT-AggressiveDebloat {
    LT-Header
    Write-Host "💀 AGGRESSIVE UWP DEBLOATER" -ForegroundColor Red
    Write-Host "WARNING: This removes most Windows Store apps (Calculator, Mail, Photos, Xbox, etc.)." -ForegroundColor Yellow
    Write-Host "You must reinstall them from the Store if you need them later." -ForegroundColor Yellow
    Write-Host ""
    $confirm = Read-Host "Proceed with Aggressive Debloat? (Y/N)"
    
    if ($confirm -ne "Y" -and $confirm -ne "y") { 
        Write-Host "Aggressive Debloat aborted." -ForegroundColor DarkYellow
        Pause
        return 
    }

    $appsToKill = @(
        # Office/Productivity
        "Microsoft.Office.OneNote", 
        
        # Communication/Social
        "Microsoft.People", "Microsoft.SkypeApp", "Microsoft.GetHelp",
        
        # Media & Gaming
        "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.XboxApp",
        "Microsoft.Xbox.TCUI", "Microsoft.XboxIdentityProvider", "Microsoft.XboxGameCallableUI",
        "Microsoft.MinecraftUWP", "Microsoft.WindowsSoundRecorder",
        
        # Tools & Utilities
        "Microsoft.3DBuilder", "Microsoft.Getstarted", "Microsoft.WindowsAlarms", 
        "Microsoft.WindowsCalculator", "Microsoft.WindowsCamera", "Microsoft.WindowsMaps",
        "Microsoft.WindowsPhotos", "Microsoft.Paint",
        
        # Other Bloat
        "Microsoft.BingWeather", "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.WindowsFeedbackHub", "Microsoft.MixedReality.Portal"
    )

    Write-Host "Removing Apps..." -ForegroundColor Yellow
    foreach ($app in $appsToKill) { 
        Write-Host "  Removing: $app" -ForegroundColor Gray
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue 
    }
    
    Write-Host "Disabling Provisioned App Packages (Prevents reinstallation for new users)..." -ForegroundColor Yellow
    foreach ($app in $appsToKill) {
        Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "$app*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
    }

    Write-Host "Aggressive Debloat complete. Some remnants may require a reboot." -ForegroundColor Green
    Pause
}


# ------------------------------
#    FPS Booster (Fixed Power Plan) 
# ------------------------------
function LT-FPSBoost {
    LT-Header
    Write-Host "Applying FPS optimizations..." -ForegroundColor Yellow

    # 1. FIX POWER PLAN (High Performance / Ultimate)
    Write-Host "Configuring Power Plan..." -ForegroundColor Cyan
    
    $ultimateGUID = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    $highPerfGUID = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

    # Try to unlock Ultimate Performance
    powercfg -duplicatescheme $ultimateGUID 2>$null | Out-Null
    
    # Try setting Ultimate
    powercfg -setactive $ultimateGUID
    
    # Verification & Fallback
    $currentPlan = powercfg -getactivescheme
    if ($currentPlan -match $ultimateGUID) {
        Write-Host "Active Plan: Ultimate Performance" -ForegroundColor Green
    } else {
        # Fallback to High Performance
        powercfg -setactive $highPerfGUID
        $currentPlanCheck = powercfg -getactivescheme
        if ($currentPlanCheck -match $highPerfGUID) {
             Write-Host "Active Plan: High Performance" -ForegroundColor Green
        } else {
             Write-Host "Could not force Power Plan. Please set manually in Control Panel." -ForegroundColor Red
        }
    }

    # 2. GPU Scheduling
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force -ErrorAction SilentlyContinue

    # 3. Game Mode
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1 -Force -ErrorAction SilentlyContinue

    # 4. Memory Flush
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    Write-Host "FPS boost applied. Reboot recommended." -ForegroundColor Green
    Pause
}

# ------------------------------
#    Aggressive Visual Optimization 
# ------------------------------
function LT-VisualOptimize {
    LT-Header
    Write-Host "AGGRESSIVE VISUAL OPTIMIZATION" -ForegroundColor Cyan
    Write-Host "Disabling Windows animations, shadows, and Aero for maximum raw FPS." -ForegroundColor Gray
    Write-Host ""
    
    # 1. Disable Window Animations (Aero Peek, fading, sliding)
    Write-Host "Disabling window animations (Visual effects)..." -ForegroundColor Yellow
    $desktopReg = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $desktopReg -Name "UserPreferencesMask" -Value ([byte[]](0x9e, 0x1e, 0x07, 0x80, 0x12, 0x00, 0x00, 0x00)) -Force -Type Binary | Out-Null
    Set-ItemProperty -Path $desktopReg -Name "DragFullWindows" -Value 0 -Force | Out-Null
    Set-ItemProperty -Path $desktopReg -Name "MenuShowDelay" -Value 0 -Force | Out-Null
    
    # 2. Disable Taskbar Translucency (Aero)
    Write-Host "Disabling Taskbar transparency/translucency..." -ForegroundColor Yellow
    $aeroReg = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Set-ItemProperty -Path $aeroReg -Name "EnableTransparency" -Value 0 -Type DWord -Force | Out-Null
    
    # 3. Disable Visual Effects on the fly
    Write-Host "Setting Visual Effects to 'Adjust for best performance'..." -ForegroundColor Yellow
    # This involves setting many values in the registry, the UserPreferencesMask above usually covers it all,
    # but we will manually ensure the key low-impact flags are set to 0.
    $aeroReg2 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $aeroReg2 -Name "ListviewShadow" -Value 0 -Type DWord -Force | Out-Null
    Set-ItemProperty -Path $aeroReg2 -Name "TaskbarAnimations" -Value 0 -Type DWord -Force | Out-Null
    
    Write-Host "Visual optimization complete. Log off and back on for full effect." -ForegroundColor Green
    Pause
}

# ------------------------------
#    System Timer Resolution Fix 
# ------------------------------
function LT-TimerResolution {
    LT-Header
    Write-Host "SYSTEM TIMER RESOLUTION FIX" -ForegroundColor Cyan
    Write-Host "Optimizing kernel timer to reduce thread scheduling jitter (1ms)." -ForegroundColor Gray
    Write-Host "Requires a third-party tool to set persistently, but we will fix the registry." -ForegroundColor Yellow
    Write-Host ""
    
    # The registry tweak forces the system to prioritize timer resolution
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    
    Write-Host "Applying SystemProfile registry tweak..." -ForegroundColor Yellow
    
    # Set priority to 'Gaming' or a high priority
    New-ItemProperty -Path $regPath -Name "SystemResponsiveness" -Value 0 -PropertyType DWord -Force | Out-Null
    
    # Create or update the Task folder for high priority threads
    $taskPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (-not (Test-Path $taskPath)) { New-Item -Path $taskPath -Force | Out-Null }
    
    # Set Gaming Profile values
    New-ItemProperty -Path $taskPath -Name "Scheduling Category" -Value "High" -Force | Out-Null
    New-ItemProperty -Path $taskPath -Name "Priority" -Value 6 -Type DWord -Force | Out-Null
    New-ItemProperty -Path $taskPath -Name "SFIO Priority" -Value "High" -Force | Out-Null
    
    Write-Host "Timer registry settings applied. You may need to run a 3rd party timer tool (e.g., Timer Resolution) for constant 1ms." -ForegroundColor Green
    Pause
}


# ------------------------------
#        Latency Optimizer 
# ------------------------------
function LT-Latency {
    LT-Header
    Write-Host "Applying Low Latency Network Tweaks..." -ForegroundColor Yellow
    
    # Default low latency network tweaks
    netsh int tcp set global autotuninglevel=normal | Out-Null
    netsh int tcp set global ecncapability=disabled | Out-Null
    netsh int tcp set global rss=enabled | Out-Null
    
    # Disable Nagle's Algorithm (Crucial for low latency gaming/VOIP)
    Write-Host "Disabling Nagle's Algorithm for lower latency..." -ForegroundColor Cyan
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    
    # Iterate through all network interfaces
    Get-ChildItem -Path $tcpPath | ForEach-Object {
        New-ItemProperty -Path $_.PSPath -Name "TcpNoDelay" -Value 1 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -PropertyType DWord -Force | Out-Null
    }
    
    Write-Host "Network latency optimized. Reboot recommended." -ForegroundColor Green
    Pause
}


# ------------------------------
#        DNS Changer Module (UPDATED)
# ------------------------------
function LT-GetAdapter {
    Write-Host "Detecting active network adapter..." -ForegroundColor Yellow
    $adapterObj = Get-NetAdapter -Physical | Where-Object Status -eq "Up" | Select-Object -First 1
    if (!$adapterObj) { $adapterObj = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1 }

    if (!$adapterObj) {
        Write-Host "No active network adapter found!" -ForegroundColor Red
        return $null
    }
    return $adapterObj.Name
}

function LT-PingDNS($ip) {
    try {
        $result = Test-NetConnection -ComputerName $ip -Port 53 -InformationLevel Detailed -Count 4 -ErrorAction Stop
        # Calculate average response time, ignoring errors if some pings fail
        $avgResponse = ($result | Where-Object { $_.PingSucceeded -eq $True } | Measure-Object -Property ResponseTime -Average).Average
        if ($avgResponse) {
            return [int]$avgResponse
        } else {
            return 9999 # Max value for unreachable servers
        }
    }
    catch {
        return 9999
    }
}

function LT-TestFastestDNS {
    LT-Header
    Write-Host "TESTING DNS LATENCY..." -ForegroundColor Cyan
    
    $dnsServers = @(
        @{Name="Cloudflare"; Primary="1.1.1.1"; Secondary="1.0.0.1"},
        @{Name="Google"; Primary="8.8.8.8"; Secondary="8.8.4.4"},
        @{Name="Quad9"; Primary="9.9.9.9"; Secondary="149.112.112.112"},
        @{Name="OpenDNS"; Primary="208.67.222.222"; Secondary="208.67.220.220"}
    )
    
    $results = @()
    
    foreach ($server in $dnsServers) {
        Write-Host "  Testing $($server.Name)..." -ForegroundColor Yellow
        $ping = LT-PingDNS($server.Primary)
        $results += @{Name=$server.Name; Primary=$server.Primary; Secondary=$server.Secondary; Latency=$ping}
    }
    
    $fastest = $results | Sort-Object Latency | Select-Object -First 1
    
    Write-Host "`n--- RESULTS (Average Ping) ---" -ForegroundColor Gray
    $results | Sort-Object Latency | Format-Table Name, Latency -AutoSize
    
    if ($fastest.Latency -lt 9999) {
        Write-Host "`n✅ The fastest server is $($fastest.Name) with a latency of $($fastest.Latency) ms." -ForegroundColor Green
        Write-Host "   Primary: $($fastest.Primary), Secondary: $($fastest.Secondary)"
        
        $choice = Read-Host "Apply this DNS server? (Y/N)"
        if ($choice -eq "Y" -or $choice -eq "y") {
            return $fastest
        }
    } else {
        Write-Host "❌ Could not determine a fast DNS server. Please check your network connection." -ForegroundColor Red
    }
    return $null
}

function LT-DNSChanger {
    LT-Header
    $adapter = LT-GetAdapter
    if (!$adapter) { Pause; return }

    Write-Host "Targeting Adapter: $adapter" -ForegroundColor Cyan
    Write-Host "--------------------------------"

    Write-Host "1) Automatically Test and Select Fastest DNS" -ForegroundColor Green
    Write-Host "2) Cloudflare (1.1.1.1)"
    Write-Host "3) Google (8.8.8.8)"
    Write-Host "4) Quad9 (9.9.9.9)"
    Write-Host "5) OpenDNS (208.67.222.222)"
    Write-Host "6) Reset to ISP DNS"
    
    $choice = Read-Host "Select"
    
    $dnsToApply = $null
    
    switch($choice){
        "1" { $dnsToApply = LT-TestFastestDNS }
        "2" { $dnsToApply = @{Primary="1.1.1.1"; Secondary="1.0.0.1"} }
        "3" { $dnsToApply = @{Primary="8.8.8.8"; Secondary="8.8.4.4"} }
        "4" { $dnsToApply = @{Primary="9.9.9.9"; Secondary="149.112.112.112"} }
        "5" { $dnsToApply = @{Primary="208.67.222.222"; Secondary="208.67.220.220"} }
        "6" { Set-DnsClientServerAddress -InterfaceAlias $adapter -ResetServerAddresses; Write-Host "DNS Reset to ISP/DHCP." -ForegroundColor Green; Pause; return }
        default { Write-Host "Invalid option." -ForegroundColor Red; Pause; return }
    }
    
    if ($dnsToApply) {
        Write-Host "Applying DNS: $($dnsToApply.Primary) and $($dnsToApply.Secondary)..." -ForegroundColor Yellow
        Set-DnsClientServerAddress -InterfaceAlias $adapter -ServerAddresses ($dnsToApply.Primary, $dnsToApply.Secondary)
        ipconfig /flushdns | Out-Null
        Write-Host "DNS Updated and flushed." -ForegroundColor Green
    }
    Pause
}

# ------------------------------
#            MAIN LOOP 
# ------------------------------
do {
    LT-Menu
    $choice = Read-Host "Select an option"
    switch ($choice) {
        "1" { LT-SystemInfo }
        "2" { LT-CleanTemp }
        "3" { LT-StartupOptimizer }
        "4" { LT-ToggleTheme }
        "5" { LT-RestorePoint }
        "6" { LT-NetworkReset }
        "7" { LT-InternetOptimize }
        "8" { LT-Latency }
        "9" { LT-DNSChanger }
        "10" { LT-ServiceOptimize }
        "11" { LT-RepairTools }
        "12" { LT-AggressiveDebloat } # NEW/UPDATED
        "13" { LT-FPSBoost }
        "14" { LT-VisualOptimize } 
        "15" { LT-TimerResolution } 
        "16" { LT-SmartProcessReducer }
        "17" { LT-DeepProcessCleaner } 
        "18" { LT-ExtremeProcessPurge } 
        "19" { LT-UltimateBloatSilencer }
        "20" { LT-MemoryOptimizer } 
        "21" { LT-ExtraSafeTweaks } 
        "22" { LT-InputLatencyOptimizerMenu } 
        "23" { LT-Update }
        "24" { Write-Host "Exiting THVO Tweaker..." -ForegroundColor Cyan; Start-Sleep 1 }
        default { Write-Host "Invalid selection." -ForegroundColor Red; Start-Sleep 1 }
    }
} while ($choice -ne 24)
