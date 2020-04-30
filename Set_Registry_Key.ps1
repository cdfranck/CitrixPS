# On all remote machines that need their info changed
Set-ExecutionPolicy Unrestricted
Enable-PSRemoting # Say yes to all prompts

$Computers = Get-Content "Path to Servers.txt"


foreach ($computer in $computers) {
Invoke-Command -AsJob $Computers -ScriptBlock {$path = "HKLM:\REGISTRY KEY";Set-ItemProperty -Path $path -Name “Name of Key” -Value “x”}
}
