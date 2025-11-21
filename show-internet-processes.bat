@echo off
REM Script to show which processes are using the internet on Windows
REM This batch file runs a PowerShell command to display network connections

echo =====================================================
echo    Internet-Connected Processes Monitor
echo =====================================================
echo.
echo Gathering network connection information...
echo Please wait...
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with Administrator privileges
    echo.
) else (
    echo WARNING: Not running as Administrator
    echo Some process information may be limited
    echo.
)

REM Run PowerShell command to get network connections
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Get-NetTCPConnection | ^
Where-Object {$_.State -eq 'Established' -and $_.RemoteAddress -ne '127.0.0.1' -and $_.RemoteAddress -ne '::1'} | ^
ForEach-Object { ^
  $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue; ^
  if ($proc) { ^
    [PSCustomObject]@{ ^
      Process=$proc.ProcessName; ^
      PID=$_.OwningProcess; ^
      LocalAddress=$_.LocalAddress; ^
      LocalPort=$_.LocalPort; ^
      RemoteAddress=$_.RemoteAddress; ^
      RemotePort=$_.RemotePort; ^
      State=$_.State ^
    } ^
  } ^
} | ^
Group-Object PID | ^
Sort-Object { $_.Group[0].Process } | ^
ForEach-Object { ^
  Write-Host ''; ^
  Write-Host \"Process: $($_.Group[0].Process) (PID: $($_.Name))\" -ForegroundColor Yellow; ^
  $_.Group | ForEach-Object { ^
    Write-Host \"  $($_.LocalAddress):$($_.LocalPort) -> $($_.RemoteAddress):$($_.RemotePort) [$($_.State)]\" -ForegroundColor Cyan ^
  } ^
}"

echo.
echo =====================================================
echo Press any key to exit...
pause >nul
