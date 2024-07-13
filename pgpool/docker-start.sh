#!/bin/bash

if [ ! -e /app/database-credentials/username ] || [ ! -e /app/database-credentials/password ]; then
  echo "Missing one or more files:"
  echo "- /app/database-credentials/username"
  echo "- /app/database-credentials/password"
  exit 1
fi

if [[ -z $PGDATABASE || -z $PGUSER ]]; then
  echo "Missing one or more variables: PGDATABASE PGUSER"
  exit 1
fi

DBUSERNAME=$(cat /app/database-credentials/username)
DBPASSWORD=$(cat /app/database-credentials/password)

echo "$DBUSERNAME:$DBPASSWORD" >> /app/pool_passwd
echo "$PGHOST:$PGPORT:$PGDATABASE:$DBUSERNAME:$DBPASSWORD" > $PGPASSFILE
chmod 600 $PGPASSFILE

pgpool -n