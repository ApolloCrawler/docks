#! /usr/bin/env bash

DATADIR="/var/lib/postgresql/9.3/main"
CONF="/etc/postgresql/9.3/main/postgresql.conf"
POSTGRES="/usr/lib/postgresql/9.3/bin/postgres"
INITDB="/usr/lib/postgresql/9.3/bin/initdb"
SQLDIR="/usr/share/postgresql/9.3/contrib/postgis-2.1/"

# test if DATADIR is existent
if [ ! -d $DATADIR ]; then
  echo "Creating Postgres data at $DATADIR"
  mkdir -p $DATADIR
fi

# Make sure we have a user set up
if [ -z "$USERNAME" ]; then
  USERNAME=docker
fi
if [ -z "$PASS" ]; then
  PASS=docker
fi


# test if DATADIR has content
if [ ! "$(ls -A $DATADIR)" ]; then
  echo "Initializing Postgres Database at $DATADIR"
  chown -R postgres $DATADIR
  su postgres sh -c "$INITDB $DATADIR"
  su postgres sh -c "$POSTGRES --single -D $DATADIR -c config_file=$CONF" <<< "CREATE USER $USERNAME WITH SUPERUSER PASSWORD '$PASS';"
fi

trap "echo \"Sending SIGTERM to postgres\"; killall -s SIGTERM postgres" SIGTERM

su postgres sh -c "$POSTGRES -D $DATADIR -c config_file=$CONF" &

# Wait for the db to start up before trying to use it....

sleep 10

RESULT=`su - postgres -c "psql -l | grep postgis | wc -l"`
if [[ ${RESULT} == '1' ]]
then
    echo 'Postgis Already There'
else
    echo "Postgis is missing, installing now"

    echo "Downloading address_standardizer"
    svn co svn://svn.code.sf.net/p/pagc/code/branches/sew-refactor/postgresql address_standardizer
    cd address_standardizer
    make
    make install

    # Note the dockerfile must have put the postgis.sql and spatialrefsys.sql scripts into /root/
    # We use template0 since we want t different encoding to template1
    echo "Creating template postgis"
    su - postgres -c "createdb template_postgis -E UTF8 -T template0"
    echo "Enabling template_postgis as a template"
    CMD="UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';"

    su - postgres -c "psql postgres -c 'create extension adminpack;'"

    su - postgres -c "psql template_postgis -c 'create extension postgis;'"
    su - postgres -c "psql template_postgis -c 'create extension postgis_topology;'"
    su - postgres -c "psql template_postgis -c 'create extension address_standardizer;'"
    su - postgres -c "psql template_postgis -c 'create extension fuzzystrmatch;'"
    su - postgres -c "psql template_postgis -c 'create extension postgis_tiger_geocoder;'"

    su - postgres -c "psql template_postgis -c 'create extension adminpack;'"
    su - postgres -c "psql template_postgis -c 'create extension cube;'"
    su - postgres -c "psql template_postgis -c 'create extension earthdistance;'"
    su - postgres -c "psql template_postgis -c 'create extension hstore;'"
    su - postgres -c "psql template_postgis -c 'create extension ltree;'"
    su - postgres -c "psql template_postgis -c 'create extension pgcrypto;'"
    su - postgres -c "psql template_postgis -c 'create extension refint;'"
    su - postgres -c "psql template_postgis -c 'create extension seg;'"

#    su - postgres -c "$CMD"
#    echo "Loading postgis.sql"
#    su - postgres -c "psql template_postgis -f $SQLDIR/postgis.sql"
#    echo "Loading spatial_ref_sys.sql"
#    su - postgres -c "psql template_postgis -f $SQLDIR/spatial_ref_sys.sql"
#
    # Needed when importing old dumps using e.g ndims for constraints
    echo "Loading legacy sql"
    su - postgres -c "psql template_postgis -f $SQLDIR/legacy_minimal.sql"
    su - postgres -c "psql template_postgis -f $SQLDIR/legacy_gist.sql"

    echo "Granting on geometry columns"
    su - postgres -c "psql template_postgis -c 'GRANT ALL ON geometry_columns TO PUBLIC;'"

    echo "Granting on geography columns"
    su - postgres -c "psql template_postgis -c 'GRANT ALL ON geography_columns TO PUBLIC;'"

    echo "Granting on spatial ref sys"
    su - postgres -c "psql template_postgis -c 'GRANT ALL ON spatial_ref_sys TO PUBLIC;'"

    echo "Setting search_path=public,tiger"
    su - postgres -c "psql template_postgis -c 'ALTER USER postgres SET search_path = public,tiger,topology;'";
    su - postgres -c "psql template_postgis -c 'ALTER USER $USERNAME SET search_path = public,tiger,topology;'";

    # echo "Generating script loader_generate_script()"
    # su - postgres < ./loader_generate_script.sh

    # Create a default db called 'gis' that you can use to get up and running quickly
    # It will be owned by the docker db user
    echo "Creating gis database from template_postgis"
    su - postgres -c "createdb -O $USERNAME -T template_postgis gis"
fi