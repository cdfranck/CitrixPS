# Read in a list of devices
$server = Get-Content -Path "C:\Temp\Servers.txt"
# Define current date and time
$date = Get-Date -Format yyyy-MM-dd
$time = Get-Date -Format HH:mm

# Perform the actions for all devices in the list
foreach ($server in $servers) {
    # Search the event log specified by 'LogName' for events with specified 'ID'
    Get-WinEvent -ComputerName $server -MaxEvents 40 -FilterHashtable  @{LogName = "Application";ID = "1000"}
        {
            # Write results to a file
            -Select-0bject -Property -ComputerName -EventID -Time | Add-Content "C:\Temp\Results.csv"
        }
}
