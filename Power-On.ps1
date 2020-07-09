Add-PSSnapin Citrix*

Get-BrokerDesktopGroup | Select -ExpandProperty Name | out-file c:\temp\deliverygroups.txt

$grplist = Get-Content 'c:\temp\deliverygroups.txt'

foreach ($dg in $grplist) {
Get-BrokerMachine -AdminAddress DDC01.domain -PowerState 'off' -DesktopGroupName "$dg" -Property MachineName | New-BrokerHostingPowerAction -action TurnOn
}
