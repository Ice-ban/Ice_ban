#!/bin/bash

# read black list and remove text, comments and blank lines; also remove duplicates
cat ip.blacklist | grep -Ev "[[:alpha:]]" | grep -Ev "#" | grep -e '^$' -v | sort | uniq > temp.hammer

# stop if done
if [ -s temp.hammer ]
then
  echo "Found IPs that could be banned."
else  
  echo "Did not find anything worth banning"
  exit
fi

# read prepared list to determine if they should be banned
while read ip; do
  temp=$(geoiplookup $(echo $ip | awk 'BEGIN {FS="/"}{print $1}') | awk '{print $4}')

# ignore regions you wish not to permaban
  case "$temp" in
    "US,") 
      echo "ignoring US IP: " $ip
      ;;
    "CA,")
      echo "ignoring Canada IP: " $ip
      ;;
# all others are fair game for banishment
    *)
      echo $ip >> iplist.hammer
      ;;
    esac
done <temp.hammer

# clean up
rm temp.hammer

# stop if done
if [ -s iplist.hammer ]
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
done <iplist.hammer

# final clean up
rm iplist.hammer

