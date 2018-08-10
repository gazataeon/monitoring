param (
    [string]
    $resourceGroup,
    [string]
    $lbName,
    [string]
    $tenantID,
    [string]
    $alertType,
    [string]
    $slackURI,
    [string]
    $slackChan,
    [string]
    $smtpUser,
    [securestring]
    $smtpPassword,
    [string]
    $smtpServer,
    [string]
    $smtpAlertTarget
)

# Import Alert files 
. ..\alerts\email_alert.ps1
. ..\alerts\slack_alert.ps1

# Authenticate now using the new Service Principal 
$cred = Import-Clixml -Path ..\..\azureMonitoringCreds.xml

# Authenticate using the Service Principal now
Add-AzureRmAccount -ServicePrincipal -Credential $cred -TenantId $tenantID

#get Load Balancer info
$loadBalancer = Get-AzureRmLoadBalancer -ResourceGroupName $prodRg -Name $lbName

$lbNodeCount = $loadBalancer.BackendAddressPools.Capacity

$lbBackEnd = Get-AzureRmLoadBalancerBackendAddressPoolConfig -LoadBalancer $loadBalancer

#Check all web  VMs are in Load balancer

$webVms = get-azurermvm -ResourceGroupName $prodRg | Where-Object name -Like "*web*"

#test a failure
$lbNodeCount = 3

If ($lbNodeCount -lt ($webvms.count) )
{

    if ($alertType = "slack")
    {
        slackmessage -message "WARNING!!! You have $($lbNodeCount) LB nodes out of $($webvms.count) Web Vms in the Load Balancer pool '$lbName', resource group : '$resourceGroup'." -channel $slackChan -slackURI $slackURI
    }
    else
    {
        mailuser -message "WARNING!!! You have $($lbNodeCount) LB nodes out of $($webvms.count) Web Vms in the Load Balancer pool '$lbName', resource group : '$resourceGroup'." -smtpUser $smtpUser -smtpPassword $smtpPassword -smtpServer $smtpServer -smtpAlertTarget $smtpAlertTarget
    }
}
else
{
Write-Host "All is well :) "
write-host "You have $($lbNodeCount) LB nodes out of $($webvms.count) Web Vms in the Load Balancer pool."
return "SUCCESS"
}