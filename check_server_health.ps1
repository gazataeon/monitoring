param (
    [int]
    $port = 8085,
    [string]
    $smtpUser,
    [securestring]
    $smtpPassword,
    [string]
    $smtpServer,
    [string]
    $smtpAlertTarget,
    [string]
    $hostsListFile,
    [string]
    $slackURI,
    [string]
    $slackChannel,
    [string]
    $alertType, #slack or email
    [string]
    $LBrg,
    [string]
    $LBname,
    [string]
    $tenantID
 )

#Module Imports
if ((Get-Module -Name Pode | Measure-Object).Count -ne 0)
{
    Remove-Module -Name Pode
}
Import-Module ..\pode\src\Pode.psm1 -ErrorAction Stop

#Pull in hosts to check
If (!([string]::IsNullOrEmpty($hostsListFile)))
{
    $hostsListdata = Get-Content $hostsListFile
}
else 
{
    $hostsListdata = @("127.0.0.1", "127.0.0.1")
}

if ([string]::IsNullOrEmpty($hostsListdata))
{
    ThrowError -ExceptionMessage "Your Host List Text file is empty!" | Out-Default
    $hostsListdata = "ERROR"
}

#find script Dir and pass it to modules
$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

# create a server, and start listening on port 8085
Server -Threads 2 {

    #get Present Working Dir

    #pull in PS modules
    script './alerts/alerts.psm1'
    script './checks/checks.psm1'

    # listen on localhost:8085
    listen *:$Port http

    #limit ip @('127.0.0.1', '[::1]') 5 10

    # allow the local ip and some other ips
    access allow ip @('127.0.0.1', '[::1]')
    access allow ip @('192.169.0.1', '192.168.0.2')
    access allow ip @('10.14.0.0/24' )

    # deny an ip
    #access deny ip 10.10.10.10
    #access deny ip '10.10.0.0/24'
    #access deny ip all

    # log requests to the terminal
    logger terminal

    # set view engine to pode renderer
    engine pode

    schedule 'test' '@minutely' {
        'hello' | Out-Default
    }

    # add to state
    state set 'data-params' @{
        'hostsListdata' = $hostsListdata;
        'scriptDir' =  $scriptDir;
        'smtpUser' = $smtpUser;
        'smtpPassword' = $smtpPassword;
        'smtpServer' = $smtpServer;
        'smtpAlertTarget' = $smtpAlertTarget;
        'slackChannel' = $slackChannel;
        'slackURI' = $slackURI;
        'alertType' = $alertType;
        'LBrg' = $LBrg;
        'LBname' = $LBname;
        'tenantID' = $tenantID
    } | Out-Null

    #$d | Out-Default
    # GET request for web page on "localhost:8085/"
    route 'get' '/' {
        param($session)
        $d = (state get 'data-params')
        $d | Out-Default
        view 'simple' -Data $d
    }



    # GET request throws fake "500" server error status code
    route 'get' '/error' {
        param($session)
        status 500
    }

    # GET request to page that merely redirects to google
    route 'get' '/redirect' {
        redirect 'https://google.com'
    }

    # GET request that redirects to same host, just different port
    route 'get' '/redirect-port' {
        param($session)
        if ($session.Request.Url.Port -ne 8086) {
            redirect -port 8086
        }
        else {
            json @{ 'value' = 'you got redirected!'; }
        }
    }

    # GET request to download a file
    route 'get' '/download' {
        param($session)
        attach 'Anger.jpg'
    }

    # GET request with parameters
    route 'get' '/:userId/details' {
        param($session)
        json @{ 'userId' = $session.Parameters['userId'] }
    }

    # ALL request, that supports every method and it a default drop route
    route * '/all' {
        json @{ 'value' = 'works for every http method' }
    }

    route get '/api/*/hello' {
        json @{ 'value' = 'works for every hello route' }
    }

    # ALL request, supports every method and route (good for mass https redirect)
    route * * {
        redirect -protocol https
    }

} -FileMonitor