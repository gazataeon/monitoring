#SMTP Mail User Function
function mailUser($serverName, $message, $smtpUser, $smtpPassword, $smtpServer, $smtpAlertTarget)

{
$SMTPhost = $smtpServer
$SMTPfrom = $smtpUser
$SMTPto = $smtpAlertTarget

$secpasswd = ConvertTo-SecureString $smtpPassword -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ("username", $secpasswd)

Send-MailMessage –From $SMTPfrom –To $SMTPto –Subject "ALERT FOR $($servername) " –Body "$($message)" -SmtpServer $SMTPhost -Credential $creds
}

#Slack Message Send Function
function slackMessage($message, $slackURI, $channel)
{
    # generate the request
    $payload = @{
        "channel" = $channel
        "icon_url" = $iconUrl
        "text" = $message
        "username" = 'MonKip'
        "link_names" = 1 #added this to allow us to call users in messages
    }

    Invoke-WebRequest -UseBasicParsing `
        -Body (ConvertTo-Json -Compress -InputObject $payload) `
        -Method Post `
        -Uri $slackURI | Out-Null
}