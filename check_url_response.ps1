##############################################################################
##
## URL Responce Time Check
##
##############################################################################


## Site list to test
$siteListFile = "sites.txt" 
$siteListdata = Get-Content $siteListFile -ErrorAction SilentlyContinue

#create the results array
$Result = @()
  
#Checks each site in the sites.txt
Foreach($Uri in $siteListdata) 
{
	$time = try{
	$request = $null
	## Request the URI, and measure how long the response took.
	$result1 = Measure-Command { $request = Invoke-WebRequest -Uri $uri }
	$result1.TotalMilliseconds
	} 
catch
{
#Called in the event there's a 404
$request = $_.Exception.Response
$time = -1
}  
	$result += [PSCustomObject] @{
	Time = Get-Date;
	Uri = $uri;
	StatusCode = [int] $request.StatusCode;
	StatusDescription = $request.StatusDescription;
	ResponseLength = "$($request.RawContentLength) bytes";
	TimeTaken =  "$($time) ms"; 
	}

}


Write-Output $Result | Format-Table

