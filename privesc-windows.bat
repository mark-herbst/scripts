REM Windows Enumeration and Privilege Escalation Script
REM This custom Windows batch file was written by Mark Herbst
REM References used for creating this script:
REM https://github.com/azmatt/windowsEnum/blob/master/windowsEnum.bat
REM https://github.com/joshruppe/winprivesc/blob/master/winprivesc.bat
REM privesc-windows.bat runs a series of local Windows commands to enumerate a Windows target
REM for the purpose of finding conditions that will allow local privilege escalation
REM Results are sent to the console to minimize alteration of the target environment
REM Usage:  Type privesc-windows.bat or the path and name of the batch file and press Enter: C:\PATH\TO\FOLDER\privesc-windows.bat

REM SYSTEM INFO
echo System Info
systeminfo
echo Hostname
hostname
echo Current Domain/Computer Name and Username
whoami

REM USER INFO
echo System Users type net user username for more details
net users

REM MOUNTED DRIVES
echo Mounted Drives
fsutil fsinfo drives

REM NETWORK INFO
echo Network Info
ipconfig /all

echo Network Shares
net share

echo IP Routing Table
route

echo ARP Cache IP Addresses and Associated MACs
arp -a

echo Current Network Connections
netstat -ano

REM SECURITY
echo Firewall State
netsh firewall show state

echo Firewall Configuration
netsh firewall show config

REM CURRENTLY RUNNING SERVICES
echo Currently Running Services
tasklist /SVC

REM CURRENT DIRECTORY
echo Current Directory
dir

REM STARTUP PROGRAMS
echo Programs that Run at Startup
wmic startup
