#Remove all event logs

#View current log sizes
Get-EventLog -List

#Get a list of log names into a variable
$logs = Get-EventLog -List | ForEach=Object {$_.Logs}

#Clear the logs
ForEach ($log in $logs){Clear-EventLog -LogName $log}

#View cleared log sizes
Get-EventLog -List
