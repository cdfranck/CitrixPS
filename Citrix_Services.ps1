#applies to citrix 7.15
# start the following Windows services in the specified order:
[Array] $Services = 'CitrixADIdentityService','CitrixAnalytics','CitrixAppLibrary','CitrixBrokerService','CitrixConfigSyncService','CitrixConfigurationLogging','CitrixConfigurationService','CitrixDelegatedAdmin','CitrixEnvTest','CitrixHighAvailabilityService','CitrixHostService','CitrixMachineCreationService','CitrixMonitor','CitrixOrchestration','XaXdCloudProxy','CitrixConnector','CitrixPrivilegedService','CitrixStorefront','CitrixTelemetryService','CitrixTrust';

# loop through each service, if its not running, start it
foreach($ServiceName in $Services)
{
    $arrService = Get-Service -Name $ServiceName
    write-host $ServiceName
    while ($arrService.Status -ne 'Running')
    {
        Start-Service $ServiceName
        write-host $arrService.status
        write-host 'Service starting'
        Start-Sleep -seconds 60
        $arrService.Refresh()
        if ($arrService.Status -eq 'Running')
        {
          Write-Host 'Service is now Running'
        }
    }
}
