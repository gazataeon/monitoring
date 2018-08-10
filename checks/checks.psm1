function checkAzureLB($LBrg,$lbName,$tenantID,$alertType,$slackURI,$slackChan,$smtpUser,$smtpPassword,$smtpServer,$smtpAlertTarget)
{
    #$LBrg | Out-Default
    
     # Authenticate now using the new Service Principal
    $cred = Import-Clixml -Path "azureMonitoringCreds.xml"
    
    # Authenticate using the Service Principal now
    $loginAccount = Add-AzureRmAccount -ServicePrincipal -Credential $cred -TenantId $tenantID
    
    #get Load Balancer info
    $loadBalancer = Get-AzureRmLoadBalancer -ResourceGroupName $LBrg -Name $lbName
    $lbNodeCount = $loadBalancer.BackendAddressPools.Capacity
    
    $lbBackEnd = Get-AzureRmLoadBalancerBackendAddressPoolConfig -LoadBalancer $loadBalancer
    
    #Check all web  VMs are in Load balancer
    $webVms = get-azurermvm -ResourceGroupName $LBrg | Where-Object name -Like "*web*"
    
    #test a failure
    #$lbNodeCount = 3
    
    If ($lbNodeCount -lt ($webvms.count) )
    {
        if ($alertType -eq  "slack")
        {
            slackmessage -message "WARNING!!! You have $($lbNodeCount) LB nodes out of $($webvms.count) Web Vms in the Load Balancer pool '$lbName', resource group : '$LBrg'." -channel $slackChan -slackURI $slackURI
        }
        elseif ($data.alertType -eq "email")
        {
            mailuser -message "WARNING!!! You have $($lbNodeCount) LB nodes out of $($webvms.count) Web Vms in the Load Balancer pool '$lbName', resource group : '$LBrg'." -smtpUser $smtpUser -smtpPassword $smtpPassword -smtpServer $smtpServer -smtpAlertTarget $smtpAlertTarget
        }
        return "WARNING!!! You have $($lbNodeCount) LB nodes out of $($webvms.count) Web Vms in the Load Balancer pool '$lbName', resource group : '$LBrg'."
    }
    else
    {
    
    return "You have $($lbNodeCount) nodes out of the total $($webvms.count) Web Servers in the Load Balancer pool."
    }

}