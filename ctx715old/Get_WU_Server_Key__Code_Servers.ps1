$reportReg = @()
$Computers = Get-Content  "PATH_TO_ervers.txt"
Foreach ($Computer in $computers){
    If(Test-Connection -ComputerName $Computer -Count 1 -ErrorAction 0){
            Try{
                # This is were the registry key is looked for on the remote server
                $RegLine = "" | Select ComputerName, RegistryKey
                $objReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
                $objRegKey= $objReg.OpenSubKey("SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")
                $RegLine.ComputerName = $Computer
                $RegLine.Registrykey = $objRegkey.GetValue("UseWUServer")
                $reportReg += $RegLine
            }
            Catch{
                Write-Warning "Unable to reach $Computer, adding to bad list to look at later."
                Remove-Item -Path "PATH_TO_\WU_Server_Key_Not_Found.txt" -Force
                $Computer | Add-Content  "PATH_TO_\WU_Server_Key_Not_Found.txt"
                Continue
            }
    }
}
$reportReg | Export-Csv  "Path_TO\Server_WUServer_Registr_Key.CSV"
 