#!/bin/bash

# create temp file for processing
file=mktemp

# read black list and remove text, comments and blank lines; also remove duplicates
cat ip.blacklist | grep -Ev "[[:alpha:]]" | grep -Ev "#" | grep -e '^$' -v | sort | uniq > $file

# stop if done
if [ -s $file ]
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
done <$file

# final clean up
rm $file

