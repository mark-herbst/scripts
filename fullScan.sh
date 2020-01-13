#!/bin/bash
#This custom script was written by Mark Herbst
#Usage:  ./fullScan.sh 10.11.1.115
#Uses nmap and a user supplied target IP to conduct
#a scan of all 65,535 ports and attempts to identify
#the services, versions and OS running on target

#declare variables
target_IP=$1 #User supplied IP address
target_host=$(echo $target_IP | awk -F'.' '{print $4}') #use awk to assign host variable from target_IP xx.xx.xx.target_host
report_filename=$(echo $target_host-fullScan.txt)

#function checkInput
#Check to make sure user supplied required input
function checkInput
{
if [ -z "$target_IP" ]; #if input variable is unset or empty
  then
    echo -e "\e[92mOne or more variables are undefined.  Usage Example:\e[0m  ./fullScan.sh 10.11.1.5" #Give user example of proper usage
    exit 1 #close program
fi
}

#function createReport
#creates or overwrites an existing text file to save ALL scan results
function createReport
{
	#If file exists, it will be overwritten!
	#<command | tee output.txt> The standard output stream will be visible on the terminal and copied to file
	echo "Target: $target_IP" | tee $report_filename
}

#function deepScan
function deepScan
{
	#All port scan, services and OS
	nmap -Pn -sV -T4 -O -p0-65535 $target_IP >> $report_filename
}

#run function
checkInput
createReport
	echo -e "\e[92mA Full Scan Report has been created for" $target_IP "Saved as" $report_filename "...\e[0m"
	echo -e "\e[92m Running a Full Scan on " $target_IP " ... \e[0m"
deepScan
	echo -e "\e[92m Full Scan of " $target_IP " complete! \e[0m"
