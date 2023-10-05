#!/bin/bash

COUNT=1
GRAVITY_FILE="/etc/pihole/gravity.db"
while [ ! -f $GRAVITY_FILE ]
do
  echo "Waiting for /etc/pihole/gravity.db to exist #$COUNT"
  COUNT=$(expr $COUNT + 1)
  sleep 1
done

echo "Found /etc/pihole/gravity.db, inserting adlists"

sleep 5

RESULT=1
COUNT=1
while [ $RESULT -ne 0 ]
do 
  echo "Attempt #$COUNT"
  $(sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt',1,'');")
  RESULT=$?
  COUNT=$(expr $COUNT + 1)
  sleep 1
done

echo "https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt done"

RESULT=1
COUNT=1
while [ $RESULT -ne 0 ]
do
  echo "Attempt #$COUNT"
  $(sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://dbl.oisd.nl',1,'');")
  RESULT=RESULT=$?
  COUNT=$(expr $COUNT + 1)
  sleep 1
done

echo "https://dbl.oisd.nl done"

sleep 60
echo "Updating gravity"
pihole updateGravity

echo "poststart script complete"