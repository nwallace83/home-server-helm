#!/bin/bash

COUNT=1
GRAVITY_FILE="/etc/pihole/gravity.db"
while [ ! -f $GRAVITY_FILE ]
do
  echo "Waiting for /etc/pihole/gravity.db to exist #$COUNT"
  COUNT=$(expr $COUNT + 1)
  sleep 1
done

echo "Found /etc/pihole/gravity.db, waiting a while before inserting adlists"

sleep 60

sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt',1,'');"
echo "https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt done"

sleep 5

sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (address, enabled, comment) VALUES ('https://big.oisd.nl',1,'');"
echo "https://big.oisd.nl done"

sleep 10
echo "Updating gravity"
pihole updateGravity

echo "poststart script complete"
