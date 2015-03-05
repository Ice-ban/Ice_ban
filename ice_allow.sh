#!/bin/bash

# create temp file for processing
file=mktemp

# read black list and remove text, comments and blank lines; also remove duplicates
grep -Ev "[[:alpha:]]" ip.whitelist | grep -Ev "#" | grep -e '^$' -v | sort -h | uniq > $file

# stop if done
if [ -s $file ]
then
  echo "Found IPs that are Allowed."
else
  echo "No IPs that are Allowed were found"
  echo "This is normally a sign that you have not properly setup your IP_RANGES.txt"
  echo "We are bailing until the file atleast contains 1 IP address that should not be blocked"
  echo "Should you actually wish to block all traffic, use [[ iptables -P INPUT DROP ]] instead"
  exit
fi

# Default Policy to DROP all incoming traffic
sudo iptables -P INPUT DROP

# nuke the IPs we have selected for elimination
while read ip; do
  echo "Allowing: "$ip
  sudo iptables -A INPUT -s $ip -j ACCEPT
done <$file

# final clean up
rm $file

