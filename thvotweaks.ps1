# ===========================================
#       LIQUID TECH PC Tweaker v3.2
#    Dynamic DNS Optimizer Build
# ===========================================

# --- SELF-ELEVATION CHECK ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$LTVersion = "3.2"   
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
    Write-Host "   12) Debloater (Safe Apps Only)"
    Write-Host "   13) FPS Booster (Advanced + Power Fix)"
    Write-Host "   14) Aggressive Visual Optimization (MAX FPS Tweak)"
    Write-Host "   15) System Timer Resolution Fix (Thread Priority)"

    Write-Host "`n  [ PROCESS & MEMORY ]" -ForegroundColor Cyan
    Write-Host "   16) Smart Process Reducer (Superfetch/Error Fix!)"
    Write-Host "   17) Deep Process Cleaner (Media/UPnP Services)"
    Write-Host "   18) Extreme Process Purge (Camera/App Experience!)"
    Write-Host "   19) Virtual Memory Optimizer"
    Write-Host "   20) Extra Safe Tweaks"

    Write-Host "`n  [ INPUT LATENCY ]" -ForegroundColor Cyan
    Write-Host "   21) Input Latency Optimizer (Submenu)"


    Write-Host "`n  [ OTHER ]" -ForegroundColor Cyan
    Write-Host "   22) Check for Updates"
    Write-Host "   23) Exit"
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
    
    # Expanded list of non
