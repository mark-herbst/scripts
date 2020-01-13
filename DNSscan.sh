#!/bin/bash
#This bash script was written by Mark Herbst
#Usage ./DNSscan.sh cisco.com or ./DNSscan.sh 10.11.1.105
#DNSscan.sh uses host and other tools to perform reverse Domain Name System (DNS) and other server queries using a provided IP address or domain
#Scan results are saved in a text file named 'DNS-report.txt'

#declare variables
target_domain=$1 #User supplied IP address or domain
report_filename='DNS-report.txt'

#function checkInput
#Check to make sure user supplied required input
function checkInput
{
if [ -z "$target_domain" ]; #if input variable is unset or empty
  then
    echo -e "\e[92mOne or more variables are undefined.  Usage Example:\e[0m  ./DNSscan.sh 127.0.0.1 or ./DNSscan.sh microsoft.com" #Give user example of proper usage
    exit 1 #close program
fi
}

#function createReport
#creates or overwrites an existing text file to save scan results
function createReport
{
	#If file exists, it will be overwritten!
	#<command | tee output.txt> The standard output stream will be visible on the terminal and copied to file
	echo "Target: $target_domain" | tee $report_filename
}
##########
#DNS Scans
##########

#function DNSscan
#uses host command to perform DNS lookup of an IP Address or Domain Name
#appends results to $report_filename
function DNSscan
{
	host $target_domain >> $report_filename
}

#function DNSall
#uses host -a command to perform DNS lookup of an IP Address or Domain Name
#appends results to $report_filename
function DNSall
{
	host -a $target_domain >> $report_filename
}

#function DNSzoneTransfer
#performs a DNS Zone Transfer request using results from host command
#appends results to $report_filename
#One liner for list of servers: host -a newberlin.org|cut -d" " -f1|awk '{print $5}'|sed /^$/d
#One liner for types of servers, duplicates and blank lines removed: host -a newberlin.org|cut -d" " -f1|awk '{print $4}'|uniq|sed /^$/d
function DNSzoneTransfer
{
for server in $(host -t ns $target_domain |cut -d" " -f4); do
    host -l $target_domain $server >> $report_filename;
done
}

#function addCommandList
#appends a list of all commands used during script execution to end of file $report_filename
function addCommandList
{
	#Log all script commands used during scan by appending them to the end of the report $report_filename
	echo "" >> $report_filename
	echo "THE FOLLOWING IS A LIST OF ALL COMMANDS USED IN DNSscan.sh" >> $report_filename
	echo "Conduct a Domain Name System (DNS) scan of target domain" >> $report_filename
	echo "Command used:  host $target_domain >> $report_filename" >> $report_filename
	echo "Conduct a FULL Domain Name System (DNS) scan of target domain" >> $report_filename
	echo "Command used:  host -a $target_domain >> $report_filename" >> $report_filename
	echo "Conduct a DNS Zone Transfer of target domain" >> $report_filename
	echo "Command used:  for server in $(host -t ns $target_domain |cut -d" " -f4); do host -l $target_domain $server >> $report_filename; done" >> $report_filename	
}

#run functions
checkInput #Program will end here if there is no user supplied input
createReport
	echo -e "\e[92mReport created for" $target_domain "Saved as" $report_filename "...\e[0m"
	echo -e "\e[92mDomain Name System (DNS) Scan Initiated... Scanning target for Servers...\e[0m"
#DNSscan function
DNSscan
	echo -e "\e[92mBasic DNS Scan results appended to report...\e[0m"
	echo -e "\e[92mConducting a FULL DNS scan of target domain...\e[0m"
#DNSall function
DNSall
	echo -e "\e[92mDNS FULL Scan results appended to report...\e[0m"
	echo -e "\e[92mConducting DNS Zone Transfer Requests for all servers on target domain...\e[0m"
#DNSzoneTransfer function
DNSzoneTransfer
	echo -e "\e[92mDNS Zone Transfer results appended to report...\e[0m"
	echo -e "\e[92mAppending a list of all commands used in this script to the report...\e[0m"
addCommandList
	echo -e "\e[92mA list of all commands used in this script have been appended to the end of report saved as" $report_filename "!\e[0m"
	echo -e "\e[92mNever Give Up!\e[0m"
