# Set variables
$outFldr = "C:\Tools\Info\"
$output = "C:\Tools\Info\output.txt"
$myICO = "C:\Tools\Info\ComputerNameICO.ico"
$serverPurpose = "Citrix Virtual Apps 1912 LTSR - Virtual Delivery Agent"

# Create resources if needed
if ((Test-Path -Path $outFldr) -ne $true) {New-Item -Type Directory -Path $outFldr -Force}
if (Test-Path $output) {Remove-Item $output -Force}
Set-Content -Path $output  -Value "Server Info"
Add-Content -Path $output -Value "---------------------"
if ((Test-Path -Path $myICO) -ne $true) {Write-host "Custom ICO is missing! Script will exit.;Exit"}

# Create Desktop Info Content
$serverInfo = Get-ComputerInfo
Add-Content -Path $output -Value "Server Name:  " -NoNewline
Add-Content -Path $output -Value ($serverInfo.csname)
Add-Content -Path $output -Value "Server Domain:  "  -NoNewline
Add-Content -Path $output -Value ($serverInfo.csdomain)
Add-Content -Path $output -Value "Server OS:  "  -NoNewline
Add-Content -Path $output -Value ($serverInfo.OSName)
Add-Content -Path $output -Value "Last Boot Time:  "  -NoNewline
Add-Content -Path $output -Value ($serverInfo.OSLastBootUpTime)
Add-Content -Path $output -Value "Server TimeZone:  "  -NoNewline
Add-Content -Path $output -Value ($serverInfo.TimeZone)
Add-Content -Path $output -Value "Server Purpose:  " $serverPurpose
Add-Content -Path $output -Value "---------------------"
Add-Content -Path $output -Value (get-date)

# Create 'myComputer' Icon
$server = $env:COMPUTERNAME
if (Test-Path "C:\Users\Public\Desktop\$server.lnk") {Remove-Item "C:\Users\Public\Desktop\$server.lnk" -Force}
$TargetFile = "$env:SystemRoot\System32\notepad.exe"
$ShortcutFile = "$env:Public\Desktop\$server.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Arguments = $output
$Shortcut.WorkingDirectory = $outFldr
$Shortcut.IconLocation = $myICO
$Shortcut.Save()

Clear-RecycleBin -DriveLetter C: -Force
Exit
