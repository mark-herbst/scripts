#!/bin/bash
#This custom bash script was written by Mark Herbst
#Usage ./fastScan.sh 10.11.1.105
#fastScan.sh conducts a scan against a provided IP address using nmap's top 100 ports as found in the nmap-services file
#Scan results are saved in a text file named after the ip address host id and '-top100ports' appended after host id
#Example of scan results filename:  105-top100ports.txt

#declare variables
target_IP=$1 #User supplied IP address
target_host=$(echo $target_IP | awk -F'.' '{print $4}') #use awk to assign host variable from target_IP xx.xx.xx.target_host
report_filename=$(echo $target_host'-fastScan.txt')

#function checkInput
#Check to make sure user supplied required input
function checkInput
{
if [ -z "$target_IP" ]; #if input variable is unset or empty
  then
    echo -e "\e[92mOne or more variables are undefined.  Usage Example:\e[0m  ./fastScan.sh 127.0.0.1" #Give user example of proper usage
    exit 1 #close program
fi
}

#function createReport
#creates or overwrites an existing text file to save scan results
function createReport
{
	#If file exists, it will be overwritten!
	#<command | tee output.txt> The standard output stream will be visible on the terminal and copied to file
	echo "Target: $target_IP" | tee $report_filename
	addCommandList
}
##########
#Fast Scan
##########

#function fastScan
#uses nmap to scan top 100 ports found in the nmap-services file
#appends results to $report_filename
#also prints results to console with -vv
function fastScan
{
	#Fast scan of top 100 ports.  Normally Nmap scans the most common 1,000 ports for each scanned protocol. With -F, this is reduced to 100.
	nmap -Pn -F -vv $target_IP >> $report_filename
}

##############
#Service Scan
##############

#function serviceScan
#uses safe script scan -sC: equivalent to --script=default with service and version checking of nmap's top default ports
#also print realtime results to console with -vv
function serviceScan
{
	nmap -sC -sV $target_IP >> $report_filename
}

#function addCommandList
#appends a list of all commands used during script execution to end of file $report_filename
function addCommandList
{
	#Log all script commands used during scan by appending them to the end of the report $report_filename
	echo "THE FOLLOWING IS A LIST OF ALL COMMANDS USED IN fastScan.sh" >> $report_filename
	echo "Scan top 100 ports found in the nmap-services file" >> $report_filename
	echo "Command used:  nmap -Pn -F $target_IP >> $report_filename" >> $report_filename
	echo "Scan for running services, identify versions and run safe scripts of top default ports found in the nmap-services file" >> $report_filename
	echo "Command used:  nmap -sC -sV -vv $target_IP >> $report_filename" >> $report_filename
}

#run functions
checkInput #Program will end here if there is no user supplied input
createReport
	echo -e "\e[92mReport created for" $target_IP "Saved as" $report_filename "...\e[0m"	
	echo -e "\e[92mA list of all commands used in this script have been appended to the beginning of report saved as" $report_filename "\e[0m"
	echo -e "\e[92mFast Scan Initiated... Scanning target for Top 100 Ports...\e[0m"
fastScan
	echo -e "\e[92mFast Scan results appended to report...\e[0m"
	echo -e "\e[92mService, Version and Safe Script Scan Initiated on nmap default top ports...\e[0m"
serviceScan
	echo -e "\e[92mService and Version Scan results appended to report...\e[0m"
	echo -e "\e[92mAppending a list of all commands used in this script to the report...\e[0m"
	echo -e "\e[92mNever Give Up!\e[0m"

