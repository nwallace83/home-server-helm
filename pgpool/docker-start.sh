#!/bin/sh

if [ ! -e /app/database-credentials/username ] || [ ! -e /app/database-credentials/password ]; then
  echo "Missing one or more files:"
  echo "- /app/database-credentials/username"
  echo "- /app/database-credentials/password"
  exit 1
fi

if [ -z $PGHOSTADDR ] || [ -z $PGPORT ] || [ -z $PGDATABASE ]; then
  echo "Missing one or more variables: PGHOSTADDR PGPORT PGDATABASE"
  exit 1
fi

DBUSERNAME=$(cat /app/database-credentials/username)
DBPASSWORD=$(cat /app/database-credentials/password)

echo "$DBUSERNAME:$DBPASSWORD" >> /tmp/pool_passwd
echo "$PGHOSTADDR:$PGPORT:$PGDATABASE:$DBUSERNAME:$DBPASSWORD" > /app/.pgpass

pgpool -n