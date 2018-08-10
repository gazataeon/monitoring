param (
     [string]
    $message,
    [string]
    $channel,
    [string]
    $slackURI
)

$iconUrl = "https://i1.kym-cdn.com/photos/images/original/000/154/766/406.png"

function slackMessage($message)
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


