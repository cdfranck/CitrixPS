# Setup a scheduled task to call this script on a Windows Event

# Restart Service if Stopped
Clear-Host

# Set variables
$ErrorActionPreference = "SilentlyContinue"
$myService = "wuauserv"  #this is an example
$myServiceState = (Get-Service -Name $myService).Status
$myServiceStart = (Get-Service -Name $myService).StartType

# Make sure service is not disabled
if ($myServiceStart -eq "Disabled") {Set-Service -Name $myService -StartupType Automatic
Write-Host $myService "has been changed from" $myServiceStart "to Automatic."}

# Restart service if stopped
if ($myServiceState -ne "Running") {Start-Service -Name $myService -Force}
do {
    $myServiceState = (Get-Service -Name $myService).Status
    Write-Host "Service is starting..."
} while ($myServiceState -ne "Running")
Write-Host $myService "is" $myServiceState
exit