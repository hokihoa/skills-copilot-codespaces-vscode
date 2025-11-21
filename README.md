# skills-copilot-codespaces-vscode
My clone repository

## Windows Internet Process Monitor

This repository contains scripts to monitor which processes are using the internet on Windows systems.

### Available Scripts

#### 1. Show-InternetProcesses.ps1 (PowerShell)
A comprehensive PowerShell script that displays detailed information about all processes with active network connections.

**Features:**
- Shows process name, PID, and path
- Displays both TCP and UDP connections
- Shows local and remote addresses with ports
- Color-coded connection states
- Groups connections by process
- Provides summary statistics

**Usage:**
```powershell
# Run the script (may require execution policy change)
.\Show-InternetProcesses.ps1

# Or with execution policy bypass
powershell -ExecutionPolicy Bypass -File .\Show-InternetProcesses.ps1

# Filter for only established connections
.\Show-InternetProcesses.ps1 | Where-Object {$_.State -eq "Established"}
```

**Requirements:**
- Windows PowerShell 5.1+ or PowerShell Core 7+
- Administrator privileges recommended for full process information

#### 2. show-internet-processes.bat (Batch File)
A simpler batch file alternative that shows established TCP connections.

**Usage:**
```cmd
# Simply double-click the file or run from command prompt
show-internet-processes.bat
```

**Features:**
- Easy to use - just double-click to run
- Shows established connections
- Grouped by process name
- No execution policy concerns

### Running with Administrator Privileges

For complete process information, run the scripts as Administrator:

**PowerShell:**
1. Right-click on PowerShell
2. Select "Run as Administrator"
3. Navigate to the script directory
4. Run the script

**Batch File:**
1. Right-click on `show-internet-processes.bat`
2. Select "Run as Administrator"

### Output Information

The scripts display:
- **Process Name**: Name of the executable
- **PID**: Process ID
- **Protocol**: TCP or UDP
- **Local Address**: Your computer's IP and port
- **Remote Address**: The remote server's IP and port
- **State**: Connection state (Established, Listen, etc.)

### Example Output

```
Process: chrome (PID: 1234)
  Path: C:\Program Files\Google\Chrome\Application\chrome.exe
  Connections:
    [TCP] 192.168.1.100:54321 -> 142.250.185.46:443 [Established]
    [TCP] 192.168.1.100:54322 -> 172.217.164.110:443 [Established]

Process: firefox (PID: 5678)
  Path: C:\Program Files\Mozilla Firefox\firefox.exe
  Connections:
    [TCP] 192.168.1.100:54323 -> 151.101.1.69:443 [Established]
```

### Troubleshooting

**"Execution of scripts is disabled on this system"**
- Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Or use: `powershell -ExecutionPolicy Bypass -File .\Show-InternetProcesses.ps1`

**"Some process information may be limited"**
- Run the script as Administrator for full access to all process information

**No output or empty results**
- Ensure you have active internet connections
- Check Windows Firewall isn't blocking network monitoring
- Try running as Administrator
