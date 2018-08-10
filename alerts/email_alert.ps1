param (
    [string]
    $serverName,
    [string]
    $message,
    [string]
    $smtpUser,
    [string]
    $smtpPassword,
    [string]
    $smtpServer,
    [string]
    $smtpAlertTarget

)

function mailUser(
    [string]
    $serverName,
    [string]
    $message,
    [string]
    $smtpUser,
    [string]
    $smtpPassword,
    [string]
    $smtpServer,
    [string]
    $smtpAlertTarget
)

{
$SMTPhost = $smtpServer
$SMTPfrom = $smtpUser
$SMTPto = $smtpAlertTarget

$secpasswd = ConvertTo-SecureString $smtpPassword -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ("username", $secpasswd)


Send-MailMessage –From $SMTPfrom –To $SMTPto –Subject "ALERT FOR $($servername) " –Body "$($message)" -SmtpServer $SMTPhost -Credential $creds
}
