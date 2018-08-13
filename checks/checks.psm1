function checkAzureLB($LBrg,$lbName,$tenantID,$alertType,$slackURI,$slackChan,$smtpUser,$smtpPassword,$smtpServer,$smtpAlertTarget, $scriptDir)
{
    #$LBrg | Out-Default
    
    #Check to see if Azure Modules are imported and  Authenticate now using the new Service Principal
     

    #Check OS Ver
    if ($PSVersionTable.Platform -ieq 'unix')
    {
        if (!(Get-Module -ListAvailable -Name azurerm.netcore) )
        {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Install-Module -Name AzureRM.Netcore
        Import-Module -Name AzureRM.Netcore
        }
        # Using secure creds is not possible with PS core, so lock these files with the following:
        # chown root:root pw.txt
        # chmod 700 pw.txt
        $appid = Get-Content -path /opt/monitoring/appID.txt
        $secpasswd = ConvertTo-SecureString (Get-Content -Path /opt/monitoring/appPW.txt) -AsPlainText -Force

         
        $cred = New-Object System.Management.Automation.PSCredential ($appID, $secpasswd)
        # Authenticate using the Service Principal now
        try {
            $loginAccount = Add-AzureRmAccount -ServicePrincipal -Credential $cred -TenantId $tenantID
        }
        catch {
            $_.Exception.Message  | Out-Default 
        }
    }
    else 
    {
        if (!(Get-Module -ListAvailable -Name azurerm) )
        {
        Install-Module -Name AzureRM
        Import-Module -Name AzureRM
        }
       
        #Login
        $cred = Import-Clixml -Path "$($scriptDir)\azureMonitoringCreds.xml"
        
        # Authenticate using the Service Principal now
        try {
            $loginAccount = Add-AzureRmAccount -ServicePrincipal -Credential $cred -TenantId $tenantID
        }
        catch {
            $_.Exception.Message  | Out-Default
        }
    }



    
    

    
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
    
    return "You have $($lbNodeCount) nodes out of the total $($webvms.count) Web Servers in the Load Balancer pool '$lbName', resource group : '$LBrg'."
    }

}