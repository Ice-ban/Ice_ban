#!/bin/bash

# read black list and remove text, comments and blank lines; also remove duplicates
cat ip.blacklist | grep -Ev "[[:alpha:]]" | grep -Ev "#" | grep -e '^$' -v | sort | uniq > temp.hammer

# stop if done
if [ -s temp.hammer ]
then
  echo "Found IPs that should be banned."
else
  echo "No IPs that should be banned were found"
  exit
fi

# nuke the IPs we have selected for elimination
while read ip; do
  echo "banning: "$ip
  sudo iptables -A INPUT -s $ip -j DROP
done <temp.hammer

# final clean up
rm temp.hammer

