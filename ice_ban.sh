#!/bin/bash

# create temp file for processing
file=$(mktemp)
ip4=$(mktemp)
ip6=$(mktemp)

# read black list and remove text, comments and blank lines; also remove duplicates
cat ip.blacklist | grep -Ev "[[:alpha:]]" | grep -Ev "#" | grep -e '^$' -v | sort | uniq > $file
grep -Ev ":" $file > $ip4
grep -E ":" $file > $ip6

# stop if done
if [ -s $file ]
then
  echo "Found IPs that should be banned."
else
  echo "No IPs that should be banned were found"
  exit
fi

# nuke the IP4s we have selected for elimination
while read ip; do
  echo "banning: "$ip
  sudo iptables -A INPUT -s $ip -j DROP
done <$ip4

# nuke the IP6s we have selected for elimination
while read ip; do
   echo "banning: "$ip
   sudo ip6tables -A INPUT -s $ip -j DROP
done <$ip6


# final clean up
rm $file $ip4 $ip6

