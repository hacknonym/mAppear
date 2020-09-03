# mAppear

[![Language](https://img.shields.io/badge/Bash-4.2%2B-brightgreen.svg?style=for-the-badge)]()
[![Build](https://img.shields.io/badge/Supported_OS-Debian-orange.svg?style=for-the-badge)]()
[![Target](https://img.shields.io/badge/Target-Windows-blue.svg?style=for-the-badge)]()
[![License](https://img.shields.io/badge/License-GPL%20v3%2B-red.svg?style=for-the-badge)](https://github.com/hacknonym/scanNport/blob/master/LICENSE)

### Author: github.com/hacknonym

##  For a Initial Recognition

![Banner](https://user-images.githubusercontent.com/55319869/92112399-ffa11400-eded-11ea-9b39-f59d3b0a008c.png)

**mAppear** create Stage-1 executable scripts. #mAppear #stage1 #stage-1

## Legal disclaimer
Usage of **mAppear** for attacking targets without prior mutual consent is illegal.
Do not use in military or secret service organizations, or for illegal purposes.
It's the end user's responsibility to obey all applicable local, state and federal laws. 
Developer assume no liability and is not responsible for any misuse or damage caused by this program.

## What is a Stage-1 ?
First-level code, also known as **Stage-1**, is defined here as a restricted functional implant whose goal is to deploy a more sophisticated code and possibly to make a rapid discovery of the infected system to help the operating mode to determine if the victim and his IS (Information System) are interesting.

The program performs a basic recognition of the machine it infects by sending information to its server such as the name of the infected machine, the name of the user, etc. It is then up to you to determine if the machine is deemed to be infected. 'interest, and if so, you will only need to specify the URL where it can download the higher level **Stage-2** malware.

Once its first level **Stage-1** code has been deployed, the operating mode can deploy several malicious codes also called **Stage-2**. These second level codes are generally used for the purpose of obtaining remote access to the target machine.

## Operating Steps
![operation](https://user-images.githubusercontent.com/55319869/92112026-77bb0a00-eded-11ea-981f-dbf396f1d88b.png)

## Installation and Usage
Necessary to have root rights
```bash
git clone https://github.com/hacknonym/mAppear.git
cd mAppear
sudo chmod +x mAppear.sh
sudo ./mAppear.sh
```

## Anonymity Procedure
**mAppear** allows the use of multiple HTTP relay servers allowing Remote Port Forwarding
- Public Relay Server
(**serveo.net**, **ssh.localhost.run**, **openport**, **Localtunnel**, **LocalXpose**, **PageKite**, **Ngrok**)
<br/>However these servers present several problems :
    * We have no knowledge of the logs stored there as well as their potential disclosure to the authorities.
    * In addition, some public relays only perform redirects for a limited time.
    * Some are paying.
    * It is not uncommon for some of these servers to be out of service.

- Your own SSH Relay Server
<br/>For complete anonymity, it is recommended : 
    * The server must be hosted on an anonymous VPS, make sure that the service provider does not register the latter does not disclose them to the authorities.
    * Whether it is purchased with an untraceable means of payment.
    * No linked to your name or other personal information.
    * **mAppear** makes it possible to use the **Tor proxy** (9050) via [proxychains](http://proxychains.sourceforge.net/) to connect to your server.

## Information Collected (Stage-1)
- Computer name
- User information
- The version of the Windows operating system
- List of processes active on the machine
- Public IP address
- System information (network card / product identifier / version / etc ...)
- Network information (network interfaces, local IP addresses)
- List of current connections and servers present
- Personal directories on the local Computer
- Shared directories on the local network
- List of updates and patch applied
- Wi-Fi AP (Access Point) passwords list

After recovery, the information are **encoded** in Base64 then **segmented** before being sent to the PHP Server.

## Decoy Program
The program uses two ways of compilation.
- C Language
    * Downlaod a remote program on Internet (http(s)://..)
    * Launch a local program e.g. (calc.exe)
- [**Bat to Exe Converter**](https://bat-to-exe-converter-x64.en.softonic.com/) 
    * Downlaod a remote program on Internet (http(s)://..)
    * Launch a local program e.g. (calc.exe)
    * (+) Include any decoy program

## Tools Overview
![menu](https://user-images.githubusercontent.com/55319869/92118119-54e12380-edf6-11ea-8f49-5b1b973fc7d7.png)
![anonymity](https://user-images.githubusercontent.com/55319869/92163200-8fb57c80-ee33-11ea-9b96-81b770ed375f.png)
![forwarding](https://user-images.githubusercontent.com/55319869/92118117-54e12380-edf6-11ea-90be-84f4ac4d10fc.png)

## License
GNU General Public License v3.0 for mAppear
AUTHOR: @hacknonym
