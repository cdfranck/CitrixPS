############################################################################
#
#    Remove old profiles to recover resources
#
############################################################################

<#
.SYNOPSIS
Script will clear inactive user profiles greater than 12 hours old.

.DESCRIPTION
Uses the Win32_UserProfile WMI object to find profiles older than 12 hours that are not 'special' or loaded and clears them.

.FORWARDHELPTARGETNAME 
Get-WMIObject

.FORWARDHELPCATEGORY
Cmdlet

.NOTES 
No parameters. Must be run from the server or via a PS-Remote window.

.COMPONENT
Script requires that Windows Management Instrumentation (WMI) is available.
#>
############################################################################

Clear-Host

# Count profiles
$countAll = Get-WMIObject -class Win32_UserProfile | Measure-Object | Select-Object -ExpandProperty count
$countFiltered = Get-WMIObject -class Win32_UserProfile| Where-Object{
        ($_.Loaded -eq $false) -and 
        ($_.Special -eq $false) -and
        ($_.lastusetime) -and
        ($_.localpath) -and
        (Get-Date).ToString($_lastusetime) -gt [datetime]::Today.AddHours(-12)} | Measure-Object | Select-Object -ExpandProperty count

# Show number of profiles to be deleted
write-host "$countFiltered profiles will be deleted of $countAll available."

# Show the names of profiles to be deleted
$profilePaths = Get-WMIObject -class Win32_UserProfile| Where-Object{
        ($_.Loaded -eq $false) -and 
        ($_.Special -eq $false) -and
        ($_.lastusetime) -and
        ($_.localpath) -and
        (Get-Date).ToString($_lastusetime) -gt [datetime]::Today.AddHours(-12)} |Select-Object -ExpandProperty localpath

foreach ($profile in $profilePaths) {Split-Path -Leaf $Profile}


# Delete profiles older than 12 hours
Get-WMIObject -class Win32_UserProfile| Where-Object{
        ($_.Loaded -eq $false) -and 
        ($_.Special -eq $false) -and
        ($_.lastusetime) -and
        ($_.localpath) -and
        (Get-Date).ToString($_lastusetime) -gt [datetime]::Today.AddHours(-12)} | Remove-WmiObject

# Re-Count
$reCountAll = Get-WMIObject -class Win32_UserProfile | Measure-Object | Select-Object -ExpandProperty count
$reCountFiltered = Get-WMIObject -class Win32_UserProfile| Where-Object{
        ($_.Loaded -eq $false) -and 
        ($_.Special -eq $false) -and
        ($_.lastusetime) -and
        ($_.localpath) -and
        (Get-Date).ToString($_lastusetime) -gt [datetime]::Today.AddHours(-12)} | Measure-Object | Select-Object -ExpandProperty count

# Show the new counts
if (($countAll - $reCountAll) -eq $countFiltered){
write-host "The correct number of profiles appear to have been removed."
write-host "Old profiles found is $reCountFiltered of $reCountAll available."}
    else{
        write-host "$countFiltered profiles should have been removed but it looks like ($countAll - $reCountAll) were affected."}

Clear-RecycleBin -Force