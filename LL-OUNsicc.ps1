#VARIABLES
$DownloadFolder = "(Specify your desired school here)" #"C:\Users\<yourusername>\Muse\" 
$URL = "https://huzz.io"

#Change school to either "Otonokizaka"(Muse), "Uranoshi"(Aqours), "Nijigasaki"(NijiGakuen) 
$School = "uranohoshi".ToLower()



#Tests if the $DownloadFolder path stated in VARIABLES exists 

if(!(Test-Path $DownloadFolder))
{
    Write-Host -ForegroundColor Red "Please make sure the downloads folder is valid"
    break
}


#Code to download the FLAC files by $School
try
{
    $Response = Invoke-WebRequest -Uri "$URL/love-live/$School/all.php"
}
catch
{
    Write-Host -BackgroundColor Red "$URL/love-live/$School/all.php was unreachable"
    break
}
Write-Host -ForegroundColor Cyan "Retrieving flac files"
$FlacFiles = $Response.Links | ?{$_.class -eq "download flac small "}
$FlacFiles | %{
    Write-Host -ForegroundColor Yellow "Downloading: $($_.download)"
    try
    {
        $BadIndex = $_.download.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars())

        #Fixes all discovered bad characters in retrieved file names
        while($BadIndex -ne -1){
            $_.download = $_.download -replace "\$($_.download[$BadIndex])", ""
            $BadIndex = $_.download.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars())
        }
        Start-BitsTransfer -Source "$($URL)$($_.href)" -Destination "$DownloadFolder\$($_.download)" -ErrorAction Stop
        Write-Host -ForegroundColor Green "Downloaded successfully!"
        Write-Host ""
    }
    catch
    {
        if($Error[0].Exception -match "404")
        {
            Write-Host -ForegroundColor Red "$($_.download) was not found on the server"
        }
        else
        {
            Write-Host -ForegroundColor Red "Couldn't download $($_.download)"
        }
        Write-Host ""
    }
}