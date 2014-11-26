#!/bin/bash

# read black list and remove text, comments and blank lines; also remove duplicates
cat ip.blacklist | grep -Ev "[[:alpha:]]" | grep -Ev "#" | grep -e '^$' -v | sort | uniq > temp.hammer

# stop if Empty List ERROR
if [ -s temp.hammer ]
then
  echo "Found IPs To Examine"
else  
  echo "Did not find any IPs AT ALL!"
  exit
fi

# read prepared list to ensure that nothing should be changed
while read ip; do
  temp=$(geoiplookup $(echo $ip | awk 'BEGIN {FS="/"}{print $1}') | awk '{print $4}')

# Alert regions you wish not to permaban
  case "$temp" in
    "US,") 
      echo -ne "\nWARNING US IP: " $ip
      bool="true"
      ;;
    "CA,")
      echo -ne "\nWARNING Canada IP: " $ip "\n"
      ;;
# all others are fair game for banishment
    *)
      if [[ "$bool" == "true" ]]
      then
        echo -ne "\n"
      fi
      echo -n "."
      bool="false"
      ;;
    esac
done <temp.hammer

# clean up
rm temp.hammer
echo -ne "\nDONE\n"
