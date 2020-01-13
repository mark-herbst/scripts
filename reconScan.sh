#!/bin/bash
#This bash script was written by Mark Herbst
#Usage ./reconScan.sh 10.11.1.5
#reconScan.sh conducts various types of scans against a provided IP address and
#attempts to identify the operating system, services, protocols, users and certain vulneralbilites on the target
#Scan results are saved in a text file named after the ip address host id
#Example Report Filename:  5.txt

#declare variables
target_IP=$1 #User supplied IP address
target_host=$(echo $target_IP | awk -F'.' '{print $4}') #use awk to assign host variable from target_IP xx.xx.xx.target_host
report_filename=$(echo $target_host.txt)

#function checkInput
#Check to make sure user supplied required input
function checkInput
{
	#use -z to test whether a variable is unset or empty:
	if [ -z $target_IP ]; #if input variable is unset or empty
		then
			echo -e "\e[92mOne or more variables are undefined.  Usage Example:\e[0m  ./recon.sh 127.0.0.1" #Give user example of proper usage
			exit 1 #close program
	fi
}

#function createReport
#creates or overwrites an existing text file to save scan results
function createReport
{
	#If file exists, it will be overwritten!
	#<command | tee output.txt> The standard output stream and standard error stream will be visible on the terminal AND copied to file
	echo "Target: $target_IP" | tee $report_filename
	addCommandList
}

#Using >> means that both the standard output and standard error stream will be redirected to the file only,
#it will not be visible in the terminal. If the file already exists, the new data will get appended to the end of the file.
#<command | &>> output.txt>

#function addCommandList
#appends a list of all commands used during script execution into a report file named $report_filename
function addCommandList
{
	#Log all script commands used during scan by appending them into a report file named $report_filename
	echo "THE FOLLOWING IS A LIST OF ALL COMMANDS USED IN reconScan.sh" >> $report_filename
	echo "Identify OS and Services running on target.  Enable OS detection, version detection, script scanning, and traceroute" >> $report_filename
	echo "Command Used:  nmap -A $target_IP >> $report_filename" >> $report_filename
	echo "Grab banners on any open tcp ports on target" >> $report_filename
	echo "Command Used:  nmap -sV --script=banner $target_IP >> $report_filename" >> $report_filename
	echo "Scan target for active web servers on commonly used web server ports" >> $report_filename
	echo "Command Used:  nmap -v -sS -p 80,443,8080 $target_IP >> $report_filename" >> $report_filename
	echo "Enumerate web server on target" >> $report_filename
	echo "Command Used:  nmap -sV --script=http-enum $target_IP >> $report_filename" >> $report_filename
	echo "Identify mail servers running on target. Listed Ports are common ports for incoming and outgoing SMTP mail servers" >> $report_filename
	echo "Command Used:  nmap -Pn -p 25,110,143,465,587,993,995,2525,2526 $target_IP >> $report_filename" >> $report_filename
	echo "Enumerate users on an SMTP Mail Servers using nmap.  This is an intrusive scan" >> $report_filename
	echo "Command Used:  nmap --script smtp-enum-users.nse --script-args=smtp-enum-users.methods={EXPN,RCPT,VRFY} -p 25,110,143,465,587,993,995,2525,2526 $target_IP >> $report_filename" >> $report_filename
	echo "Enumerate users on an SMTP Mail Server using smtp-user-enum, VRFY method and wordlist /usr/share/wordlists/metasploit/unix_users.txt" >> $report_filename
	echo "#Usage: smtp-user-enum [options] ( -u username | -U file-of-usernames ) ( -t host | -T file-of-targets )" >> $report_filename
	echo "Command Used:  smtp-user-enum -M VRFY -U /usr/share/wordlists/metasploit/unix_users.txt -t $target_IP >> $report_filename" >> $report_filename
	echo "Identify and scan FTP Servers on target which use ports 20 and 21" >> $report_filename
	echo "Command Used:  nmap -Pn -v -sV -p 20,21 $target_IP >> $report_filename" >> $report_filename
	echo "Determine if FTP Server allows anonymous logins on target" >> $report_filename
	echo "Command Used:  nmap --script=ftp-anon $target_IP >> $report_filename" >> $report_filename
	echo "Determine if target is an SMB server based on known SMB ports" >> $report_filename
	echo "Command Used:  nmap -Pn -p 137,138,139,445 $target_IP >> $report_filename" >> $report_filename
	echo "Check the SMB security level of target" >> $report_filename
	echo "Command Used:  nmap -v -p 137,138,139,445 --script=smb-security-mode $target_IP >> $report_filename" >> $report_filename
	echo "Enumerate SMB users on target" >> $report_filename
	echo "Command Used:  nmap --script=smb-enum-users $target_IP >> $report_filename" >> $report_filename
	echo "Scan SMB Server for vulnerabilities" >> $report_filename
	echo "Command Used:  nmap -Pn -p 137,138,139,445 --script=smb-vuln-* --script-args=unsafe=1 $target_IP >> $report_filename" >> $report_filename
	echo "Scan for exposed NETBIOS nameserver and open SMB shares" >> $report_filename
	echo "Command Used:  nbtscan $target_IP >> $report_filename" >> $report_filename
	echo "After using nmap SMB Scripts, refer to scanning-windows-deeper-nmap-scanning-engine-33138.pdf and follow steps 4-7!" >> $report_filename
	echo "Perform a scan of open UDP ports with version checking.  T4 is used to increase scan speed from default T3" >> $report_filename
	echo "Command Used:  nmap -sUV -T4 $target_IP >> $report_filename" >> $report_filename
	echo "Identify which IP protocols are supported by target.  Every open protocol is a potential exploitation vector" >> $report_filename
	echo "Results help determine the purpose of a machine" >> $report_filename
	echo "Command Used:  nmap -sO $target_IP >> $report_filename" >> $report_filename
	echo "Scan for open SNMP port 161" >> $report_filename
	echo "Command Used:  nmap -sU --open -p 161 $target_IP >> $report_filename" >> $report_filename
	echo "Use snmpwalk and onesixtyone for further SNMP Enumeration" >> $report_filename	
}

#########################
#OS and Version Detection
#########################	
#function enumOSsvcs
#uses nmap Aggressive Scan option to identify OS and Services running on target using all default scripts
#this is an intrusive scan!
#-A: Enable OS detection, version detection, script scanning, and traceroute
function enumOSsvcs
{
	nmap -A $target_IP >> $report_filename
}

################
#Banner Grabbing
################
#function bannerGrab
#uses nmap to grab banners on any open tcp ports on target
#appends results to $report_filename
function bannerGrab
{
	nmap -sV --script=banner $target_IP >> $report_filename	
}

#################
#Web Server Scans
#################
#function webServerScan
#uses nmap to scan target for active web servers on commonly used web server ports
function webServerScan
{
	nmap -v -sS -p 80,443,8080 $target_IP >> $report_filename
}

#function enumWebServer
#uses nmap to enumerate web server on target
function enumWebServer
{
	nmap -sV --script=http-enum $target_IP >> $report_filename
}

#######################
#SMTP Mail Server Scans
#######################
#function SMTPscan
#uses nmap to identify mail servers running on target
#Listed Ports are common ports for incoming and outgoing SMTP mail servers
#More info can be found at https://www.arclab.com/en/kb/email/list-of-smtp-and-pop3-servers-mailserver-list.html
function SMTPscan
{
	nmap -Pn -p 25,110,143,465,587,993,995,2525,2526 $target_IP >> $report_filename
}

#function nmapEnumSMTPusers
#uses nmap to enumerate SMTP users
#this is an intrusive scan
function nmapEnumSMTPusers
{
	nmap --script smtp-enum-users.nse --script-args=smtp-enum-users.methods={EXPN,RCPT,VRFY} -p 25,110,143,465,587,993,995,2525,2526 $target_IP >> $report_filename
}

#function smtpUserEnum
#uses smtp-user-enum and VRFY method to enumerate users on an SMTP Mail Server
#uses wordlist /usr/share/wordlists/metasploit/unix_users.txt
function SMTPuserEnum
{
	#Usage: smtp-user-enum [options] ( -u username | -U file-of-usernames ) ( -t host | -T file-of-targets )
	smtp-user-enum -M VRFY -U /usr/share/wordlists/metasploit/unix_users.txt -t $target_IP >> $report_filename

}	

##########
#FTP Scans
##########
#function FTPscan
#uses nmap to identify and scan FTP Servers on target which use ports 20 and 21
function FTPscan
{
	nmap -Pn -v -sV -p 20,21 $target_IP >> $report_filename
}

#function FTPanon
#uses nmap to determine if FTP Servers allow anonymous logins on target
function FTPanon
{
	nmap --script=ftp-anon $target_IP >> $report_filename
}

##########
#SMB Scans
##########
#After using this script, refer to scanning-windows-deeper-nmap-scanning-engine-33138.pdf and follow steps 4-7!

#function SMBscan
#uses nmap to determine if target is an SMB server based on known SMB ports
#appends results to $report_filename
function SMBscan
{
	nmap -Pn -p 137,138,139,445 $target_IP >> $report_filename
}

#function SMBsecurityLevel
#uses nmap to check the SMB security level of target
function SMBsecurityLevel
{
	nmap -v -p 137,138,139,445 --script=smb-security-mode $target_IP >> $report_filename
}

#function enumSMBusers
#enumerates SMB users on target
function enumSMBusers
{
	nmap --script=smb-enum-users $target_IP >> $report_filename
}

#function SMBvulnScan
#scan SMB Server for vulnerabilities
#uses nmap smb-vuln-* scripts to scan target
function SMBvulnScan
{
	nmap -Pn -p 137,138,139,445 --script=smb-vuln-* --script-args=unsafe=1 $target_IP >> $report_filename
}

#function SMBsharesScan
#scan for exposed NETBIOS nameserver and open SMB shares
function SMBsharesScan
{
	nbtscan $target_IP >> $report_filename
}

##########
#UDP Scans
##########
#function udpScan
#uses nmap to perform a scan of open UDP ports with version checking
#T4 is used to increase scan speed from default T3
function udpScan
{
	nmap -sUV -T4 $target_IP >> $report_filename
}

#################
#IP Protocol Scan
#################
#function IPprotocolScan
#identifies which IP protocols are supported by target.  Every open protocol is a potential exploitation vector
#results help determine the purpose of a machine
function IPprotocolScan
{
	nmap -sO $target_IP >> $report_filename
}

##########
#SNMP Scan
##########
#function SNMPscan
#uses nmap to scan for open SNMP port 161
function SNMPscan
{
	nmap -sU --open -p 161 $target_IP >> $report_filename
}
	
#run functions
checkInput #Program will end here if there is no user supplied input
createReport
	echo -e "\e[92mReport created for" $target_IP "Saved as" $report_filename "...\e[0m"
addCommandList
	echo -e "\e[92mA list of all commands used in this script have been appended to the beginning of report" $report_filename "\e[0m"
#OS and Version function
	echo -e "\e[92mEnumerating Operating System and Services on target...\e[0m"
enumOSsvcs
	echo -e "\e[92mOperating System and Services Enumeration complete!\e[0m"	
#Banner Grabbing function
	echo -e "\e[92mGrabbing Banners from target...\e[0m"
bannerGrab
	echo -e "\e[92mBanner Grabbing complete!\e[0m"
#Web Server functions
	echo -e "\e[92mScanning target for active Web Servers...\e[0m"
webServerScan
	echo -e "\e[92mWeb Server scan results appended to report.\e[0m"
	echo -e "\e[92mEnumerating Web Servers...\e[0m"
enumWebServer
	echo -e "\e[92mWeb Server Enumeration complete!\e[0m"
#SMTP functions
	echo -e "\e[92mScanning for active SMTP Servers...\e[0m"
SMTPscan
	echo -e "\e[92mEnumerating SMTP Users... \e[0m"
nmapEnumSMTPusers
SMTPuserEnum
	echo -e "\e[92mSMTP Server and User Enumeration complete!\e[0m"
#FTP functions
	echo -e "\e[92mScanning for active FTP Servers...\e[0m"
FTPscan
	echo -e "\e[92mIdentifying FTP Servers that allow anonymous logins...\e[0m"
FTPanon
	echo -e "\e[92mFTP Server Enumeration complete!\e[0m"
#SMB functions
	echo -e "\e[92mScanning target for active SMB server ports...\e[0m"
SMBscan	
	echo -e "\e[92mEnumerating SMB Users on target...\e[0m"
enumSMBusers
	echo -e "\e[92mConducting SMB security level check on target...\e[0m"
SMBsecurityLevel
	echo -e "\e[92mScanning for SMB vulnerabilities...\e[0m"
SMBvulnScan
	echo -e "\e[92mScanning for exposed NETBIOS nameserver and open SMB shares...\e[0m"
SMBsharesScan
	echo -e "\e[92mSMB Server Enumeration complete!  Results appended to report.\e[0m"
#UDP functions
	echo -e "\e[92mScanning for UDP (User Datagram Protocol) Services...\e[0m"
udpScan
	echo -e "\e[92mUDP scan complete!\e[0m"
#IP Protocol functions
	echo -e "\e[92mIdentifying IP protocols supported by target...\e[0m"
IPprotocolScan
	echo -e "\e[92mTarget IP protocol identification complete!\e[0m"
#SNMP functions
	echo -e "\e[92mScanning for open SNMP port 161\e[0m"
SNMPscan	
	echo -e "\e[92mSNMP scan complete!\e[0m"
	echo -e "\e[92mRecon Scan and Enumeration of" $target_IP "is complete!  Full report saved as" $report_filename "\e[0m"
	echo -e "\e[92mNever Give Up!\e[0m"
