#! /usr/bin/env bash

DATADIR="/var/lib/postgresql/9.3/main"
CONF="/etc/postgresql/9.3/main/postgresql.conf"
POSTGRES="/usr/lib/postgresql/9.3/bin/postgres"

# This should show up in docker logs afterwards
# su - postgres -c "psql -l"

# PID=`cat /var/run/postgresql/9.3-main.pid`
# kill -9 ${PID}

echo "Postgres initialisation process completed .... restarting in foreground"
su - postgres -c "$POSTGRES -D $DATADIR -c config_file=$CONF"

# bash ./loader_generate_script.sh

wait $!