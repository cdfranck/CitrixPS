<#
.SYNOPSIS
        Script will put tagged servers in maintenance mode on Friday afternoon, drain, power down then power on and remove from maintenance mode early Monday morning.
.DESCRIPTION
        This script places tagged servers in maintenance mode at the appointed time after checking that it would not impact capacity. (Looks for 60% capacity available in delivery group.)
        It then waits for the server to drain all users and powers off the server. (Requires power management of the VDAs from your site.)
        At the appointed time, the server is powered back on, registration is verified, and is removed from maintenance mode.
        There are multiple checkpoints throughout the script that will exit the script if they fail.
.EXAMPLE
        ./Reduce-Usage-onWeekends.ps1
.NOTES 
        You may edit the following variables to suit your environment:
        Variable        Purpose                             Hard-coded value
        $stopTag        Server TAG for shut-down            "AutoShutdown"
        $controller     CVAD Broker Name                    "APWCDDC01.CHILDRENS.SEA.KIDS"      
        $altcntrlr      CVAD Broker Name  (Alt)             "APWCDDC02.CHILDRENS.SEA.KIDS" #         
        $drainTime      Time to start the drain             "15:00"
        $drainDay       Day to start the drain              "Friday"
        $timeZn         Time zone ID                        "Pacific Standard Time"
        $powerTime      Time to power back on               "03:00"
        $powerDay       Day to power back on                "Monday"
        $dGroup         Delivery Group to act on            "Epic Production"
        $safeRatio      Percent of unavailable servers      50

.COMPONENT
        Script requires that the Citrix PowerShell Snap-ins are loaded on the device running the action.
#>

# VARIABLES -- You may edit the following variables to suit your environment:
$stopTag = "AutoShutdown" #Server TAG for shut-down
$controller = "APWCDDC01.CHILDRENS.SEA.KIDS" #CVAD Broker Name     
$altcntrlr = "APWCDDC02.CHILDRENS.SEA.KIDS" #CVAD Broker Name  (Alt)          
$drainTime = "15:00" #Time to start the drain        
$drainDay = "Friday" #Day to start the drain         
$timeZn = "Pacific Standard Time" #Time zone ID                   
$powerTime = "03:00" #Time to power back on          
$powerDay = "Monday" #Day to power back on           
$dGroup = "Epic Production"
$safeRatio = 50 #Percent of total servers allowed to be unavailable
$domain = $env:USERDOMAIN  # requires the short domain name for the Citrix '-MachineName'
$machineName = "$domain\$server"

# Capture script start time
$startTime = (Get-Date)

# Set error behavior
$ErrorActionPreference = "Stop"

# Create Transcript (optional) -- may be safely remarked out 
$rundate = (Get-Date -UFormat "%m-%d-%Y_%I%M%p")
$filename = $server +"_"+ $rundate +"_Auto_Shutdown_Log.txt"
Start-Transcript -Append -Force -IncludeInvocationHeader -Path "C:\TEMP\$filename"

# Load the PS-Snapins for Citrix -- REQUIRED
If ( (Get-PSSnapin -Name Citrix* -ErrorAction SilentlyContinue) -eq $null )
    {$host.ui.RawUI.WindowTitle = "Loading Citrix snap-ins..."
        Try {Add-PsSnapin Citrix*}
        Catch {Write-Host "There is a problem loading the required Citrix Powershell modules. Script will exit.";Exit 1}
    }else{Write-Host "Citrix snap-ins loaded."}

# Determine if there will be enough available capacity if this server is put in maintenance mode
$host.ui.RawUI.WindowTitle = "Calculating available capcity..."

# Part 1 - gather the data
# Get the Delivery (Desktop) Group the servers are in
$deliveryGroup = Get-BrokerDesktopGroup -Name $dGroup
# Get the total number of servers available to that delivery group
$totalServers = Get-BrokerMachine -AdminAddress $controller -DesktopGroupName $deliveryGroup.Name |Measure-Object |Select-Object -ExpandProperty Count
# Get the number of servers from that delivery group that are already in maintenance mode
$lboServers = Get-BrokerMachine -AdminAddress $controller -DesktopGroupName $deliveryGroup -InMaintenanceMode $true |Measure-Object |Select-Object -ExpandProperty Count

Add-Content -Path C:\Temp\Reduce-Usage-Output.txt -Value "Delivery Group is $dGroup.Name"

write-host "*---*---* Math is FUN *---*---*" #separating out some of the output
# Part 2 - do the math
# If server count in maintenance mode is greater than zero, divide the total number of servers by the number in maintenance mode to get the percentage already out of rotation
if ($lboServers -gt 0) {$ratioOut = ($lboServers/$totalServers)} else {$ratioOut=0}
$newLBOservers = ($lboServers +1)
if ($newlboServers -gt 0) {$newRatioOut = ($newLBOServers/$totalServers)} else {$newRatioOut=0}
if ($lboServers -gt 0) {$percentout=[math]::Round(($ratioOut*100),4)} elseif ($lboServers -le 0) {$percentout=0} else {out-null}
if ($newlboServers -gt 0) {$newPercentOut=[math]::Round(($newRatioOut*100),4)} elseif ($newlboServers -le 0) {$newPercentOut=0} else {out-null}
# Show your work
write-host "Servers already in maint mode [$lboServers] divided by the total servers [$totalServers] in the delivery group [$deliveryGroup] is $percentOut%."

# Part 3 - Will capacity suffer? (Require 60% available if more than 2 servers in the group. Require 50% available if only 2 servers in the group. Groups with single server will not be put in maintenance mode.)
# This section does not put the server in mm, it sets a variable based on the calculations for the next block to check against.
$result = switch ($putInMM) {
   {$newPercentOut -gt 30}  {Write-host "$newLBOServers is more than 30% out. Decision set to False"; $putInMM = $false;break} 
   {$newPercentOut -lt 30 -and $newPercentOut -ne 0 -and $totalServers -gt 3}   {Write-host "Putting $newLBOServers servers in maint mode is less than 30% capacity out. Decision set to True."; $putInMM = $true;break}
   {$newPercentOut -eq 1 -and $totalServers -gt 3}  {Write-host "Putting $newLBOServers server in maint mode is less than 30% of capcity out. Decision set to True."; $putInMM = $true; break}
   {$newPercentOut -eq 1 -and $totalServers -eq 2}  {Write-host "Putting $newLBOServers server in maint mode will result in 50% of capacity out. Decision set to True."; $putInMM = $true; break}
   {($totalServers-$percentOut) -eq 0} {Write-host "Putting $server in MaintMode would result in orphaned apps. Decision set to False."; $putInMM = $false; break}
   default {Write-host "Nothing balanced out. Server requires manual intervention. Script will exit.";Exit 1}
}
write-host "*--*--*--*--*--*--*--*--*--*--*" # end math section

write-host "*--*--*--*MAINT*--*MODE*--*--*--*--*" # start maint mode section
# Confirm the decision (still not performing the balance out)
If ($putInMM -eq $true) {write-host "$server will be placed in Maintenance Mode."}
    else{
        Write-host "Nothing will be balanced out. $server requires manual intervention. Script will exit."
        Exit 1}
$remaining = ($totalServers - $newLBOservers)
Write-host "$remaining servers of $totalServers will remain available."
write-host "Servers proposed in maint mode [$newLBOservers] divided by the total servers [$totalServers] in the delivery group [$deliveryGroup] is $newPercentOut%."

# Put the server in maintenance mode, FINALLY!
$host.ui.RawUI.WindowTitle = "Putting $machineName put in maintenance mode..."
try {
        if ($putInMM -eq $true){Set-BrokerMachine -AdminAddress $adminAddress -MachineName $machineName -InMaintenanceMode $true}
} catch {Write-Host "Nothing balanced out. $server requires manual intervention. Script will exit.";Exit 1}

# Confirm
Get-BrokerMachine -AdminAddress $adminAddress -MachineName $machineName | Select MachineName,InMaintenanceMode | ft
write-host "*--*--*--*--*--*--*--*--*--*--*" #end maint mode section

write-host "0--o--0--o--0--o--Down the drain!--o--0--o--0--o--0*" # start drain section -- no timeout, loops until sessions are zero
# Drain the server -- you may need to tweak the values for your environment  -- do not set a timeout value on the ControlUp script action because this code block is likely to exceed it.
$host.ui.RawUI.WindowTitle = "CHILDRENS\$server is draining..."
$sessions = Get-BrokerSession -AdminAddress $adminAddress -MachineName $machineName -SessionState Active -MaxRecordCount 3000| Measure | Select -ExpandProperty Count

# Check for active sessions until they reach 0
do {$sessions = Get-BrokerSession -AdminAddress $adminAddress -MachineName $machineName -SessionState Active -MaxRecordCount 3000| Measure | Select -ExpandProperty Count
    write-host "Active session(s) are: $sessions"
    write-host "Waiting 30 minutes before re-checking the session count, please hold..."
    start-sleep 1800}  
        while ($sessions -gt 0)

# Exits the script if for some reason it exits the loop with active sessions
if ($sessions -eq 0) {write-host "Active session(s) are: $sessions"} else 
    {write-host "Something went wrong. $server requires manual intervention. Script will exit.";Exit 1}
write-host "0--o--0--o--0--o--No more users!--o--0--o--0--o--0*" # stop drain section

write-host "/////REBOOT////REBOOT///REBOOT//REBOOT\\REBOOT\\\REBOOT\\\\REBOOT\\\\\" #start the reboot section
# Reboot the server to a clean image  -- REQUIRES that your site has power management access, if not you'll need to change the 'New-BrokerHostingPowerAction' statement to something else. 
# Check that the server is still in mainenance mode and has zero users (in case someone else took manual action while draining).
$mmState = Get-BrokerMachine -AdminAddress $adminaddress -MachineName $machineName | Select -ExpandProperty InMaintenanceMode
$sessions = Get-BrokerSession -AdminAddress $adminaddress -MachineName $machineName -SessionState Active -MaxRecordCount 3000| Measure | Select -ExpandProperty Count
$realboyz = Get-BrokerSession -AdminAddress $adminaddress -MachineName $machineName | Select -ExpandProperty UserName | Measure |Select -ExpandProperty Count

if ($sessions -eq 0 -and $mmState -eq $true -and $realboyz -eq 0){

    $host.ui.RawUI.WindowTitle = "$machineName is rebooting..."   
    try {New-BrokerHostingPowerAction -AdminAddress $adminAddress -Action "Reset" -MachineName $machineName}
        Catch{write-host "Something went wrong. $server requires manual intervention. Script will exit.";Exit 1}
            }else{write-host "Conditions not met for reboot."
                    write-host "Check $server is in Maintenance Mode with Zero active sessions." 
                    write-host "Script will exit."
                    Exit 1}
write-host "/////BOO////BOOT///BOOTE//BOOTED\\BOOTE\\\BOOT\\\\BOO\\\\\" # end of reboot section

write-host "~~~can you hear me now?~~~" # start registration check (5 minute timeout)
# Wait for restart to initiate and refresh variables
start-sleep 30
$mmState = Get-BrokerMachine -AdminAddress $adminaddress -MachineName $machineName | Select -ExpandProperty InMaintenanceMode
$regState = Get-BrokerMachine -AdminAddress $adminaddress -MachineName $machineName | Select -ExpandProperty RegistrationState
$host.ui.RawUI.WindowTitle = "Checking $server for valid registration..."

# Make sure server is registered first, if not registered after 5 minutes it will timeout
$refresh=0
if ($mmState -eq $true){
    do {$regState = (Get-BrokerMachine -AdminAddress $adminaddress -MachineName $machineName | Select -ExpandProperty RegistrationState);start-sleep 30;$refresh++}
        until ($regState -eq "Registered" -or $refresh -ge 10)
            }elseif ($regState -ne "Registered" -or $refresh -ge 10){
                Get-BrokerMachine -AdminAddress $adminaddress -MachineName $machineName | Select MachineName,RegistrationState,InMaintenanceMode,FaultState
                Write-host "Something went wrong. $server requires manual intervention. Script will exit."
                Exit 1}
write-host "~~~S~U~C~C~E~S~S~~~" # end registration check (5 minute timeout)

write-host "^^^^^ Are we there yet, Papa Smurf?? ^^^^^" # start take server out of maint mode section
# Take the server out of maintenance mode
$host.ui.RawUI.WindowTitle = "Taking $server out of maint mode..."
$mmState = Get-BrokerMachine -AdminAddress $adminaddress -MachineName $machineName | Select -ExpandProperty InMaintenanceMode
$regState = Get-BrokerMachine -AdminAddress $adminaddress -MachineName $machineName | Select -ExpandProperty RegistrationState
$faultState = Get-BrokerMachine -AdminAddress $adminaddress -MachineName $machineName | Select -ExpandProperty FaultState

if ($regState -eq "Registered" -and $mmState -eq $true -and $faultState -eq "None"){
    try{Set-BrokerMachine -AdminAddress $adminaddress -MachineName $machineName -InMaintenanceMode $false}
            catch{write-host "Something went wrong. $server requires manual intervention. Script will exit.";Exit 1}
                }else{
                    write-host "Conditions not met for removal from maintenance mode."
                    write-host "Check $server conditions: "
                    write-host "MaintMode must be True, actual value is $mmState" 
                    write-host "Registration must be True, actual value is: $regState" 
                    write-host "Fault State must be None, actual value is: $faultState"
                    write-host "Script will exit."
                    Exit 1}
write-host "^^^^^ Don't make me turn this script around! ^^^^^" # end take server out of maint mode section

write-host "---------- Everything is awesome! ----------" #start summary block    
# Final word
$stopTime = (Get-Date)
$scriptTime =(New-TimeSpan -Start $startTime -End $stopTime)
$regState = Get-BrokerMachine -AdminAddress $adminaddress -MachineName $machineName | Select -ExpandProperty RegistrationState
$rebootTime = Get-CimInstance -ClassName win32_operatingsystem -ComputerName $server| select -ExpandProperty lastbootuptime
if ($regState -eq "Registered" -and $rebootTime -gt $startTime){
    write-host $server "has been successfully cycled."
    write-host "Last reboot time was: "$rebootTime
    Write-host "Script started at: $startTime."
    Write-host "Script finished at: $stopTime."
    Write-host "Script Time was: " $scriptTime.ToString("dd' days 'hh' hours 'mm' minutes 'ss' seconds'")}
        else{
            Write-host "Script started at: $startTime."
            Write-Host "Last reboot time was: $rebootTime, which appears to be prior to this script action."
            write-host "Something went wrong. $server requires manual intervention. Script will exit."
            Exit 1}


# Close Transcript
Stop-Transcript

# Email the transcript (optional) - you may safely remove this section
# Change these variables for your company -- please don't spam me!
If (Test-Path "C:\Temp\$filename"){
    $mAttach = get-item "c:\temp\$filename" | select -ExpandProperty FullName
    }

$mFrom = "ControlUp@virtustream.com"
$mTo = "candi.franck@virtustream.com"
$mSMTP = "email.seattlechildrens.org"

if ($mAttach -ne $null){
$mSubject = "$server was rebooted by script at $rebootTime"
$message = "$server was rebooted at $rebootTime. This was initiated by the 'Place Broken Server in Maint Mode' trigger which ran the 'Managed VDA Reboot' script. Results are attached."
Send-MailMessage -From $mFrom -Subject $mSubject -To $mTo -Attachments $mAttach -Body $message -Port 25 -SmtpServer $mSMTP}
    else{
        $mSubject = "$server needs review"
        $message = "$server needs review. This was initiated by the 'Place Broken Server in Maint Mode' trigger which tried to run the 'Managed VDA Reboot' script but something failed."
        Send-MailMessage -From $mFrom -Subject $mSubject -To $mTo -Attachments $mAttach -Body $message -Port 25 -SmtpServer $mSMTP}

# close script
Exit

