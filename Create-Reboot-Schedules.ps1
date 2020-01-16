# Script to set Multiple Reboot Schedules for a Delivery Group

﻿# add Snapin for Citrix.
Add-PSSNAPIN Citrix*

# Reminder about tags
write-host "Servers must be tagged appropriately: "
Write-Host "TAG: SundayREBOOT  REBOOT DAY-TIME: Sunday 03:15AM"
Write-Host "TAG: MondayREBOOT  REBOOT DAY-TIME: Monday 02:05AM"
Write-Host "TAG: TuesdayREBOOT  REBOOT DAY-TIME: Tuesday 02:05AM"
Write-Host "TAG: WednesdayREBOOT  REBOOT DAY-TIME: Wednesday 02:05AM"
Write-Host "TAG: ThusddayREBOOT  REBOOT DAY-TIME: Thursday 02:05AM"
Write-Host "TAG: FridayREBOOT  REBOOT DAY-TIME: Friday 02:05AM"
Write-Host "TAG: SaturdayREBOOT  REBOOT DAY-TIME: Saturday 02:05AM"

# Declare Variables -- script must be run from the controller
$deliveryGroup = Read-Host "Please enter the EXACT name of your Delivery Group (do not use quotes)"

# Create schedules
New-BrokerRebootScheduleV2 -Name "$deliverygroup Sunday Reboot Schedule" -DesktopGroupName $deliveryGroup -Day Sunday -Frequency Weekly -StartTime “3:15” -RebootDuration 120 -RestrictToTag SundayREBOOT -WarningDuration 60 -WarningRepeatInterval 10 -WarningMessage “This machine will restart in %m% minutes. Please save your work and logoff.” -WarningTitle “Warning: Weekly Scheduled Reboot” -Enabled $true
New-BrokerRebootScheduleV2 -Name "$deliverygroup Monday Reboot Schedule" -DesktopGroupName $deliveryGroup -Day Monday -Frequency Weekly -StartTime “2:05” -RebootDuration 120 -RestrictToTag MondayREBOOT -WarningDuration 60 -WarningRepeatInterval 10 -WarningMessage “This machine will restart in %m% minutes. Please save your work and logoff.” -WarningTitle “Warning: Weekly Scheduled Reboot” -Enabled $true
New-BrokerRebootScheduleV2 -Name "$deliverygroup Tuesday Reboot Schedule" -DesktopGroupName $deliveryGroup -Day Tuesday -Frequency Weekly -StartTime “2:05” -RebootDuration 120 -RestrictToTag TuesdayREBOOT -WarningDuration 60 -WarningRepeatInterval 10 -WarningMessage “This machine will restart in %m% minutes. Please save your work and logoff.” -WarningTitle “Warning: Weekly Scheduled Reboot” -Enabled $true
New-BrokerRebootScheduleV2 -Name "$deliverygroup Wednesday Reboot Schedule" -DesktopGroupName $deliveryGroup -Day Wednesday -Frequency Weekly -StartTime “2:05” -RebootDuration 120 -RestrictToTag WednesdayREBOOT -WarningDuration 60 -WarningRepeatInterval 10 -WarningMessage “This machine will restart in %m% minutes. Please save your work and logoff.” -WarningTitle “Warning: Weekly Scheduled Reboot” -Enabled $true
New-BrokerRebootScheduleV2 -Name "$deliverygroup Thursday Reboot Schedule" -DesktopGroupName $deliveryGroup -Day Thursday -Frequency Weekly -StartTime “2:05” -RebootDuration 120 -RestrictToTag ThursdayREBOOT -WarningDuration 60 -WarningRepeatInterval 10 -WarningMessage “This machine will restart in %m% minutes. Please save your work and logoff.” -WarningTitle “Warning: Weekly Scheduled Reboot” -Enabled $true
New-BrokerRebootScheduleV2 -Name "$deliverygroup Friday Reboot Schedule" -DesktopGroupName $deliveryGroup -Day Friday -Frequency Weekly -StartTime “2:05” -RebootDuration 120 -RestrictToTag FridayREBOOT -WarningDuration 60 -WarningRepeatInterval 10 -WarningMessage “This machine will restart in %m% minutes. Please save your work and logoff.” -WarningTitle “Warning: Weekly Scheduled Reboot” -Enabled $true
New-BrokerRebootScheduleV2 -Name "$deliverygroup Saturday Reboot Schedule" -DesktopGroupName $deliveryGroup -Day Saturday -Frequency Weekly -StartTime “2:05” -RebootDuration 120 -RestrictToTag SaturdayREBOOT -WarningDuration 60 -WarningRepeatInterval 10 -WarningMessage “This machine will restart in %m% minutes. Please save your work and logoff.” -WarningTitle “Warning: Weekly Scheduled Reboot” -Enabled $true

# Show results
Get-BrokerRebootScheduleV2 -DesktopGroupName $deliveryGroup | FT -AutoSize



# Cmdlets Info
# New-BrokerRebootScheduleV2 (Creates a new reboot schedule for a Delivery Group)
# Get-BrokerRebootScheduleV2 (Lists existing reboot schedules)
# Set-BrokerRebootScheduleV2 (Update an existing reboot schedule)
# Remove-BrokerRebootScheduleV2 (Remove a reboot schedule)
# Rename-BrokerRebootScheduleV2 (Rename a reboot schedule)

# Common Parameters
# Name -- A friendly name for the new reboot schedule
# DesktopGroupName -- The name of the Delivery Group to which the reboot schedule is being applied
# RebootDuration -- Approximate maximum number of minutes over which the scheduled reboot cycle runs
# Day -- For weekly cycles, the day of the week on which the scheduled reboot cycle starts
# Description -- An optional description for the reboot schedule
# Enabled -- Boolean that indicates if the new reboot schedule is enabled
# Frequency -- Frequency with which this schedule runs – either weekly or daily
# RestrictToTag -- If set, the reboot schedule only applies to machines in the Delivery Group with the specified tag
# StartTime -- Time of day at which the scheduled reboot cycle starts
# WarningDuration -- Time prior to the start of a machine reboot at which a warning message is displayed to all the users on the machine
# WarningMessage -- Warning message displayed in user sessions on a machine scheduled for reboot
# WarningRepeatInterval -- Time to wait after the previous reboot warning before displaying the warning message in all user sessions on that machine again
# WarningTitle -- The window title used when showing the warning message in user sessions on a machine scheduled for reboot
