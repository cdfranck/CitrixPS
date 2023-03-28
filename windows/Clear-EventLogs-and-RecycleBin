# Clear event logs
$logs = Get-EventLog -List | ForEach-Object {$_.Log}
ForEach ($log in $logs) {Clear-EventLog -LogName $log}
Write-host "Event logs cleared."

# Empty Recycle Bin
Clear-RecycleBin DriveLetter C: -Force
Write-host "Emptied Recycle Bin."

Exit
