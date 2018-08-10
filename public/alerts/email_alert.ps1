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


Send-MailMessage –From $SMTPfrom –To $SMTPto –Subject "ALERT FOR $($servername) " –Body "$($message)" -SmtpServer $SMTPhost
}
