# Functions
Monitors the following:
  Windows Servers CPU + RAM usage
  IIS Response time and Status Codes
  Azure Load Balancers



# Setup
To monitor the Azure Resources you will need a service Principle and create a credentials file. 
If monitoring from a Windows host you can use the azureMonitoringCreds.xml.

Unfortunatley due to some of the current limitations of powershell core, you are not able to use this method for Unix hosts.
Instead create two files `/opt/monitoring/appID.txt` and `/opt/monitoring/appPW.txt` with the application ID and Password in, 
then be sure to CHMOD the files to only allow root access:
`chown root:root pw.txt`
`chmod 700 pw.txt`
Example below:

```
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
    Export-CLixml -Path "azureMonitoringCreds.xml"


# ************ GENERATE FROM EXISTING ************ ONLY FOR WINDOWS
$app = Get-AzureRmADApplication -IdentifierUri "http://www.google.com" 

$appID = $app.ApplicationId
Get-Credential -UserName $appID -Message 'Enter App password' |  
    Export-CLixml -Path "azureMonitoringCreds.xml"
```
There is also a "hostsListFile.txt" which is specificed at runtime, this is a plain text file with hostnames to monitor.
Be sure to populate this!

You will also need [Pode](https://github.com/badgerati/Pode) for this to run. 

# Starting Listener
Once you have the above Service Principle created, get the tennant ID for your Azure subscription and run the following:

```
# To call with slack notifications

$portNo = 8085                                  # MANDATORY 
$hostsListFile = ".\hostslist.txt"              # MANDATORY 
$alertType = "<EMAIL or SLACK>"                 # MANDATORY (If empty no alerts take place)
LBrg = "<LOAD BALANCER RESOURCE GROUP>"         # MANDATORY 

$slackURI = "https://hooks.slack.com/services/<WEBHOOK GOES HERE>"
$slackChannel = "@username"
$LBname = "<Load Balancer Name>"          
$tenantID = "This can be pulled from azure with get-azurermsubscription once logged in"

.\check_server_health.ps1 -Port $portNo -hostsListFile $hostsListFile -slackURI $slackURI -slackChannel $slackChannel `
-alertType $alertType -LBrg $LBrg -LBname $LBname -tenantID $tenantID
```
You can instead pass Email Configuration.

- smtpUser
- smtpPassword
- smtpServer (IP or hostname is fine)
- smtpAlertTarget (an email address to send to)

# to do
monitor event log IDs
capture logs
graph responses 
