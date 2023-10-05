#!/bin/bash

export PATH="PATH=/opt/pihole:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

COUNT=1
GRAVITY_FILE="/etc/pihole/gravity.db"
while [ ! -f $GRAVITY_FILE ]
do
  echo "Attempt #$COUNT"
  echo "Waiting for /etc/pihole/gravity.db to exist"
  COUNT=$(expr $COUNT + 1)
  sleep 1
done

echo "Found /etc/pihole/gravity.db, inserting adlists"

RESULT=1
COUNT=1
while [ "$RESULT" != "0" ]
do 
  echo "Attempt #$COUNT"
  RESULT=$(sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt',1,'');")
  COUNT=$(expr $COUNT + 1)
  sleep 1
done

echo "https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt done"

RESULT=1
COUNT=1
while [ "$RESULT" != "0" ]
do
  echo "Attempt #$COUNT"
  RESULT=$(sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://dbl.oisd.nl',1,'');")
  COUNT=$(expr $COUNT + 1)
  sleep 1
done

echo "https://dbl.oisd.nl done"

echo "Updating gravity"
pihole updateGravity