#!/bin/sh

if [ ! -e /app/database-credentials/username ] || [ ! -e /app/database-credentials/password ]; then
  echo "Missing one or more files:"
  echo "- /app/database-credentials/username"
  echo "- /app/database-credentials/password"
  exit 1
fi

if [ -z $PGHOST ] || [ -z $PGPORT ] || [ -z $PGDATABASE ]; then
  echo "Missing one or more variables: PGHOSTADDR PGPORT PGDATABASE"
  exit 1
fi

DBUSERNAME=$(cat /app/database-credentials/username)
DBPASSWORD=$(cat /app/database-credentials/password)

echo "$DBUSERNAME:$DBPASSWORD" >> /app/pool_passwd
echo "$PGHOST:$PGPORT:$PGDATABASE:$DBUSERNAME:$DBPASSWORD" > /app/.pgpass
chmod 600 /app/.pgpass

pgpool -n