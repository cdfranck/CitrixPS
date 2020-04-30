$reportReg = @()
$Computers = Get-Content  "Path to Servers.txt"
Foreach ($Computer in $computers){
    If(Test-Connection -ComputerName $Computer -Count 1 -ErrorAction 0){
            Try{
                # This is were the registry key is looked for on the remote server
                $RegLine = "" | Select ComputerName, RegistryKey
                $objReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
                $objRegKey= $objReg.OpenSubKey("REGISTRY LOCATION")
                $RegLine.ComputerName = $Computer
                $RegLine.Registrykey = $objRegkey.GetValue("NAME OF KEY")
                $reportReg += $RegLine
            }
            Catch{
                Write-Warning "Unable to reach $Computer, adding to bad list to look at later."
                $Computer | Add-Content  "PATH TO FILE FOR FILE THAT INDICATES KEY IS NOT PRESENT\Registry_Key_Not_Found.txt"
                Continue
            }
    }
}
$reportReg | Export-Csv  "Path to file\Registry_Key.CSV"
 