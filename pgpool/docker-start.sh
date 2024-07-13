#!/bin/sh

if [ -z $DBUSER ] || [ -z $DBPASSWORD ]; then
  echo "Missing one or more variables: DBUSER, DBPASSWORD"
  exit 1
fi

echo "$DBUSER:$DBPASSWORD" >> /tmp/pool_passwd

pgpool -n