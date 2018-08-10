

# ************ GENERATE New AZURE SP CREDS AND FILE ************   
$password =  "password" | ConvertTo-SecureString -AsPlainText -Force

# Create the Azure AD App now, this is the directory services record which identifies an application to AAD
$NewAADApp = New-AzureRmADApplication -DisplayName "azureMonitoringCreds" `
                        -HomePage "http://www.google.com" `
                        -IdentifierUris "http://www.google.com" `
                        -Password $password

 # Create a Service Principal in Azure AD                                                          
New-AzureRmADServicePrincipal -ApplicationId $NewAADApp.ApplicationID

# Grant access to Service Prinicpal for accessing resources in the whole sub
New-AzureRmRoleAssignment -RoleDefinitionName "Contributor" `
    -ServicePrincipalName $NewAADApp.ApplicationId `
    -Scope "/subscriptions/$(Get-AzureRmSubscription).Id"

# Export creds to disk (encrypted using DAPI)
Get-Credential -UserName $NewAADApp.ApplicationId -Message 'Enter App password' |  
    Export-CLixml -Path "~\azureMonitoringCreds.xml"


# ************ GENERATE FROM EXISTING ************
Get-AzureRmADApplication -IdentifierUri "http://www.google.com" 

$appID = "<GET FROM AZURE>"
Get-Credential -UserName $appID -Message 'Enter App password' |  
    Export-CLixml -Path "~\azureMonitoringCreds.xml"
