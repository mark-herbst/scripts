#!/bin/bash
#This custom script was written by Mark Herbst
#Usage ./IPlistBuilder.sh 10.11.1. 1 254
#IPlistBuilder.sh takes user input, validates the input,
#creates a sequential list of IP addresses of a target network
#and saves the list to targetIPs.txt

#declare variables
baseIP=$1 #First user input format xxx.xxx.xxx. or xx.xx.xx.
subnetStart=$2 #Second user input
subnetEnd=$3 #Third user input

#function checkInput
#Check to make sure user supplied required input parameters
function checkInput
if [ -z "$baseIP" ] || [ -z "$subnetStart" ] || [ -z "$subnetEnd" ]; #if any input variable is unset or empty
  then
    echo "One or more variables are undefined.  Usage Example:  ./recon.sh 10.11.1. 1 254" #Give user example of proper usage
    exit 1 #close program
fi

#function buildTargetIPs
#build a list of target ip addresses from following input:
#base ip xx.xx.xx. (baseIP=$1)
#subnet starting point a (subnetStart=$2)
#subnet ending point b (subnetEnd=$3)
#then saves the list of target ip addresses to a text file named targetIPs.txt
function buildTargetIPs
{
for ((counter=$subnetStart; counter<=$subnetEnd; counter++))
do
echo $baseIP$counter >> targetIPs.txt
done
}

#run functions
checkInput
buildTargetIPs
echo -e "\e[92m List of target IPs saved to targetIPs.txt... \e[0m"