<#
.SYNOPSIS
    Shows which processes are currently using the internet on Windows.

.DESCRIPTION
    This script displays all processes with active network connections, including:
    - Process name and ID
    - Protocol (TCP/UDP)
    - Local and remote addresses and ports
    - Connection state

.EXAMPLE
    .\Show-InternetProcesses.ps1
    Shows all processes with active network connections.

.EXAMPLE
    .\Show-InternetProcesses.ps1 | Where-Object {$_.State -eq "Established"}
    Shows only processes with established connections.

.NOTES
    Requires Administrator privileges for full process information.
    Works on Windows PowerShell 5.1+ and PowerShell Core 7+
#>

[CmdletBinding()]
param()

# Check if running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "Not running as Administrator. Some process information may be limited."
    Write-Host ""
}

Write-Host "Gathering network connections and process information..." -ForegroundColor Cyan
Write-Host ""

try {
    # Get all TCP connections
    $connections = Get-NetTCPConnection | Where-Object {
        # Filter out local-only connections (localhost)
        $_.RemoteAddress -ne "127.0.0.1" -and 
        $_.RemoteAddress -ne "::1" -and
        $_.RemoteAddress -ne "0.0.0.0" -and
        $_.RemoteAddress -ne "::"
    }

    # Create a collection to store results
    $results = @()

    foreach ($conn in $connections) {
        try {
            # Get process information
            $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            
            if ($process) {
                $results += [PSCustomObject]@{
                    ProcessName   = $process.ProcessName
                    PID           = $conn.OwningProcess
                    Protocol      = "TCP"
                    LocalAddress  = "$($conn.LocalAddress):$($conn.LocalPort)"
                    RemoteAddress = "$($conn.RemoteAddress):$($conn.RemotePort)"
                    State         = $conn.State
                    ProcessPath   = $process.Path
                }
            }
        }
        catch {
            # Skip processes we can't access
            continue
        }
    }

    # Get UDP endpoints (they don't have a "state" like TCP)
    # Note: UDP is connectionless, so we only filter LocalAddress (RemoteAddress doesn't exist for UDP)
    $udpEndpoints = Get-NetUDPEndpoint | Where-Object {
        $_.LocalAddress -ne "127.0.0.1" -and 
        $_.LocalAddress -ne "::1" -and
        $_.LocalAddress -ne "0.0.0.0" -and
        $_.LocalAddress -ne "::"
    }

    foreach ($udp in $udpEndpoints) {
        try {
            $process = Get-Process -Id $udp.OwningProcess -ErrorAction SilentlyContinue
            
            if ($process) {
                $results += [PSCustomObject]@{
                    ProcessName   = $process.ProcessName
                    PID           = $udp.OwningProcess
                    Protocol      = "UDP"
                    LocalAddress  = "$($udp.LocalAddress):$($udp.LocalPort)"
                    RemoteAddress = "N/A"
                    State         = "Listening"
                    ProcessPath   = $process.Path
                }
            }
        }
        catch {
            continue
        }
    }

    # Display results grouped by process
    if ($results.Count -gt 0) {
        Write-Host "Processes Using the Internet:" -ForegroundColor Green
        Write-Host ("=" * 80) -ForegroundColor Green
        Write-Host ""

        # Group by PID (unique per process) but display with process name
        $grouped = $results | Group-Object -Property PID | Sort-Object { ($_.Group[0]).ProcessName }

        foreach ($group in $grouped) {
            $firstItem = $group.Group[0]
            Write-Host "Process: $($firstItem.ProcessName) (PID: $($firstItem.PID))" -ForegroundColor Yellow
            
            if ($firstItem.ProcessPath) {
                Write-Host "  Path: $($firstItem.ProcessPath)" -ForegroundColor Gray
            }
            
            Write-Host "  Connections:" -ForegroundColor Gray
            
            foreach ($item in $group.Group) {
                $stateColor = switch ($item.State) {
                    "Established" { "Green" }
                    "Listen" { "Cyan" }
                    "Listening" { "Cyan" }
                    default { "White" }
                }
                
                Write-Host "    [$($item.Protocol)] $($item.LocalAddress) -> $($item.RemoteAddress) [$($item.State)]" -ForegroundColor $stateColor
            }
            
            Write-Host ""
        }

        # Summary statistics
        $uniqueProcesses = ($results | Select-Object -Property PID -Unique).Count
        $establishedConnections = ($results | Where-Object { $_.State -eq "Established" }).Count
        
        Write-Host ("=" * 80) -ForegroundColor Green
        Write-Host "Summary:" -ForegroundColor Cyan
        Write-Host "  Total Processes: $uniqueProcesses"
        Write-Host "  Total Connections: $($results.Count)"
        Write-Host "  Established Connections: $establishedConnections"
        Write-Host ""

    } else {
        Write-Host "No processes with internet connections found." -ForegroundColor Yellow
    }

    # Return results for pipeline usage
    return $results

}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}
