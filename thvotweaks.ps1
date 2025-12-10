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
#        Extra Debloater (Aggressive) 
# ------------------------------
function LT-ExtraDebloat {
    LT-Header
    Write-Host "WARNING: This Mode is AGGRESSIVE." -ForegroundColor Red
    Write-Host "It will remove: Calculator, Photos, Camera, Voice Recorder, etc."
    Write-Host "Are you sure? (Y/N)" -ForegroundColor Yellow
    $confirm = Read-Host ""
    
    if ($confirm -ne "Y" -and $confirm -ne "y") { 
        Write-Host "Aggressive Debloat aborted." -ForegroundColor DarkYellow
        Pause
        return 
    }

    Write-Host "Applying aggressive debloat..." -ForegroundColor Yellow

    $extraBloat = @(
        "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.SkypeApp",
        "Microsoft.WindowsAlarms", "Microsoft.WindowsCalculator",
        "Microsoft.WindowsCamera", "Microsoft.WindowsMaps", "Microsoft.WindowsSoundRecorder",
        "Microsoft.WindowsFeedbackHub", "Microsoft.MSPaint", "Microsoft.Office.OneNote", 
        "Microsoft.WindowsPhotos"
    )
    foreach ($app in $extraBloat) { Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue }

    # Visual Tweaks
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 100 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -ErrorAction SilentlyContinue

    Write-Host "Aggressive tweaks applied." -ForegroundColor Green
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
        "12" { LT-Debloat }
        "13" { LT-FPSBoost }
        "14" { LT-VisualOptimize } 
        "15" { LT-TimerResolution } 
        "16" { LT-SmartProcessReducer }
        "17" { LT-DeepProcessCleaner } 
        "18" { LT-ExtremeProcessPurge } 
        "19" { LT-MemoryOptimizer } 
        "20" { LT-ExtraSafeTweaks } 
        "21" { LT-InputLatencyOptimizerMenu } 
        "22" { LT-Update }
        "23" { Write-Host "Exiting THVO Tweaker..." -ForegroundColor Cyan; Start-Sleep 1 }
        default { Write-Host "Invalid selection." -ForegroundColor Red; Start-Sleep 1 }
    }
} while ($choice -ne 23)
