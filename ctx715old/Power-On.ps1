#Script to power on servers by delivery group, created for scheduled reboot failure to power on servers
#Servers must be power managed from the site
#Script should be run from the DDC with elevated rights
# make sure to edit line 13 for your DDC name (-AdminAddress)

Add-PSSnapin Citrix*

Get-BrokerDesktopGroup | Select -ExpandProperty Name | out-file c:\temp\deliverygroups.txt

$grplist = Get-Content 'c:\temp\deliverygroups.txt'

foreach ($dg in $grplist) {
Get-BrokerMachine -AdminAddress DDC01.domain -PowerState 'off' -DesktopGroupName "$dg" -Property MachineName | New-BrokerHostingPowerAction -action TurnOn
}
