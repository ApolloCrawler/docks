#! /usr/bin/env bash

TMPDIR="/tmp/"
UNZIPTOOL=unzip
WGETTOOL="/usr/bin/wget"
export PGBIN=/usr/bin
export PGPORT=5432
export PGHOST=localhost
export PGUSER=docker
export PGPASSWORD=docker
export PGDATABASE=gis
PSQL=${PGBIN}/psql
SHP2PGSQL=${PGBIN}/shp2pgsql

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_01_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_01*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_01*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AL_place(CONSTRAINT pk_AL_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_01_place.dbf tiger_staging.al_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AL_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('AL_place'), lower('AL_place')); ALTER TABLE tiger_data.AL_place ADD CONSTRAINT uidx_AL_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_AL_place_soundex_name ON tiger_data.AL_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_AL_place_the_geom_gist ON tiger_data.AL_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.AL_place ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_01_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_01*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_01*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AL_cousub(CONSTRAINT pk_AL_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_AL_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_01_cousub.dbf tiger_staging.al_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AL_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('AL_cousub'), lower('AL_cousub')); ALTER TABLE tiger_data.AL_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
${PSQL} -c "CREATE INDEX tiger_data_AL_cousub_the_geom_gist ON tiger_data.AL_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AL_cousub_countyfp ON tiger_data.AL_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_01_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_01*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_01*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AL_tract(CONSTRAINT pk_AL_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_01_tract.dbf tiger_staging.al_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AL_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('AL_tract'), lower('AL_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_AL_tract_the_geom_gist ON tiger_data.AL_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.AL_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.AL_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_01_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_01*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_01*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AL_tabblock(CONSTRAINT pk_AL_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_01_tabblock.dbf tiger_staging.al_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AL_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('AL_tabblock'), lower('AL_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.AL_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
${PSQL} -c "CREATE INDEX tiger_data_AL_tabblock_the_geom_gist ON tiger_data.AL_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.AL_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_01_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_01*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_01*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AL_bg(CONSTRAINT pk_AL_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_01_bg.dbf tiger_staging.al_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AL_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('AL_bg'), lower('AL_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.AL_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
${PSQL} -c "CREATE INDEX tiger_data_AL_bg_the_geom_gist ON tiger_data.AL_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.AL_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_01*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_01*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AL_zcta5(CONSTRAINT pk_AL_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_AL_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AL_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AL_zcta510'), lower('AL_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AL_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
${PSQL} -c "CREATE INDEX tiger_data_AL_zcta5_the_geom_gist ON tiger_data.AL_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_01*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_01*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AL_faces(CONSTRAINT pk_AL_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AL_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AL_faces'), lower('AL_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_AL_faces_the_geom_gist ON tiger_data.AL_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AL_faces_tfid ON tiger_data.AL_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AL_faces_countyfp ON tiger_data.AL_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.AL_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
	${PSQL} -c "vacuum analyze tiger_data.AL_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_01*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_01*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AL_featnames(CONSTRAINT pk_AL_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.AL_featnames ALTER COLUMN statefp SET DEFAULT '01';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AL_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AL_featnames'), lower('AL_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_AL_featnames_snd_name ON tiger_data.AL_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_AL_featnames_lname ON tiger_data.AL_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_AL_featnames_tlid_statefp ON tiger_data.AL_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.AL_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
${PSQL} -c "vacuum analyze tiger_data.AL_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_01*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_01*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AL_edges(CONSTRAINT pk_AL_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AL_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AL_edges'), lower('AL_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AL_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
${PSQL} -c "CREATE INDEX idx_tiger_data_AL_edges_tlid ON tiger_data.AL_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AL_edgestfidr ON tiger_data.AL_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AL_edges_tfidl ON tiger_data.AL_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AL_edges_countyfp ON tiger_data.AL_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_AL_edges_the_geom_gist ON tiger_data.AL_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AL_edges_zipl ON tiger_data.AL_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.AL_zip_state_loc(CONSTRAINT pk_AL_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.AL_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'AL', '01', p.name FROM tiger_data.AL_edges AS e INNER JOIN tiger_data.AL_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.AL_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_AL_zip_state_loc_place ON tiger_data.AL_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.AL_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
${PSQL} -c "vacuum analyze tiger_data.AL_edges;"
${PSQL} -c "vacuum analyze tiger_data.AL_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.AL_zip_lookup_base(CONSTRAINT pk_AL_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.AL_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'AL', c.name,p.name,'01'  FROM tiger_data.AL_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '01') INNER JOIN tiger_data.AL_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.AL_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.AL_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
${PSQL} -c "CREATE INDEX idx_tiger_data_AL_zip_lookup_base_citysnd ON tiger_data.AL_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_01* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_01*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_01*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AL_addr(CONSTRAINT pk_AL_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.AL_addr ALTER COLUMN statefp SET DEFAULT '01';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AL_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AL_addr'), lower('AL_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AL_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AL_addr_least_address ON tiger_data.AL_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AL_addr_tlid_statefp ON tiger_data.AL_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AL_addr_zip ON tiger_data.AL_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.AL_zip_state(CONSTRAINT pk_AL_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.AL_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'AL', '01' FROM tiger_data.AL_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.AL_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '01');"
	${PSQL} -c "vacuum analyze tiger_data.AL_addr;"
cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_02_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_02*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_02*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AK_place(CONSTRAINT pk_AK_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_02_place.dbf tiger_staging.ak_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AK_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('AK_place'), lower('AK_place')); ALTER TABLE tiger_data.AK_place ADD CONSTRAINT uidx_AK_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_AK_place_soundex_name ON tiger_data.AK_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_AK_place_the_geom_gist ON tiger_data.AK_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.AK_place ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_02_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_02*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_02*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AK_cousub(CONSTRAINT pk_AK_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_AK_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_02_cousub.dbf tiger_staging.ak_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AK_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('AK_cousub'), lower('AK_cousub')); ALTER TABLE tiger_data.AK_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
${PSQL} -c "CREATE INDEX tiger_data_AK_cousub_the_geom_gist ON tiger_data.AK_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AK_cousub_countyfp ON tiger_data.AK_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_02_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_02*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_02*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AK_tract(CONSTRAINT pk_AK_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_02_tract.dbf tiger_staging.ak_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AK_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('AK_tract'), lower('AK_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_AK_tract_the_geom_gist ON tiger_data.AK_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.AK_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.AK_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_02_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_02*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_02*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AK_tabblock(CONSTRAINT pk_AK_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_02_tabblock.dbf tiger_staging.ak_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AK_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('AK_tabblock'), lower('AK_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.AK_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
${PSQL} -c "CREATE INDEX tiger_data_AK_tabblock_the_geom_gist ON tiger_data.AK_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.AK_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_02_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_02*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_02*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AK_bg(CONSTRAINT pk_AK_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_02_bg.dbf tiger_staging.ak_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AK_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('AK_bg'), lower('AK_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.AK_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
${PSQL} -c "CREATE INDEX tiger_data_AK_bg_the_geom_gist ON tiger_data.AK_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.AK_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_02* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_02*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_02*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AK_zcta5(CONSTRAINT pk_AK_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_AK_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AK_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AK_zcta510'), lower('AK_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AK_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
${PSQL} -c "CREATE INDEX tiger_data_AK_zcta5_the_geom_gist ON tiger_data.AK_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_02* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_02*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_02*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AK_faces(CONSTRAINT pk_AK_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AK_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AK_faces'), lower('AK_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_AK_faces_the_geom_gist ON tiger_data.AK_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AK_faces_tfid ON tiger_data.AK_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AK_faces_countyfp ON tiger_data.AK_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.AK_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
	${PSQL} -c "vacuum analyze tiger_data.AK_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_02* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_02*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_02*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AK_featnames(CONSTRAINT pk_AK_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.AK_featnames ALTER COLUMN statefp SET DEFAULT '02';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AK_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AK_featnames'), lower('AK_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_AK_featnames_snd_name ON tiger_data.AK_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_AK_featnames_lname ON tiger_data.AK_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_AK_featnames_tlid_statefp ON tiger_data.AK_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.AK_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
${PSQL} -c "vacuum analyze tiger_data.AK_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_02* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_02*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_02*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AK_edges(CONSTRAINT pk_AK_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AK_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AK_edges'), lower('AK_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AK_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
${PSQL} -c "CREATE INDEX idx_tiger_data_AK_edges_tlid ON tiger_data.AK_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AK_edgestfidr ON tiger_data.AK_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AK_edges_tfidl ON tiger_data.AK_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AK_edges_countyfp ON tiger_data.AK_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_AK_edges_the_geom_gist ON tiger_data.AK_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AK_edges_zipl ON tiger_data.AK_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.AK_zip_state_loc(CONSTRAINT pk_AK_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.AK_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'AK', '02', p.name FROM tiger_data.AK_edges AS e INNER JOIN tiger_data.AK_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.AK_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_AK_zip_state_loc_place ON tiger_data.AK_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.AK_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
${PSQL} -c "vacuum analyze tiger_data.AK_edges;"
${PSQL} -c "vacuum analyze tiger_data.AK_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.AK_zip_lookup_base(CONSTRAINT pk_AK_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.AK_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'AK', c.name,p.name,'02'  FROM tiger_data.AK_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '02') INNER JOIN tiger_data.AK_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.AK_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.AK_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
${PSQL} -c "CREATE INDEX idx_tiger_data_AK_zip_lookup_base_citysnd ON tiger_data.AK_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_02* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_02*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_02*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AK_addr(CONSTRAINT pk_AK_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.AK_addr ALTER COLUMN statefp SET DEFAULT '02';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AK_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AK_addr'), lower('AK_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AK_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AK_addr_least_address ON tiger_data.AK_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AK_addr_tlid_statefp ON tiger_data.AK_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AK_addr_zip ON tiger_data.AK_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.AK_zip_state(CONSTRAINT pk_AK_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.AK_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'AK', '02' FROM tiger_data.AK_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.AK_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '02');"
	${PSQL} -c "vacuum analyze tiger_data.AK_addr;"
cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_04_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_04*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_04*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AZ_place(CONSTRAINT pk_AZ_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_04_place.dbf tiger_staging.az_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AZ_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('AZ_place'), lower('AZ_place')); ALTER TABLE tiger_data.AZ_place ADD CONSTRAINT uidx_AZ_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_AZ_place_soundex_name ON tiger_data.AZ_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_AZ_place_the_geom_gist ON tiger_data.AZ_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.AZ_place ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_04_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_04*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_04*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AZ_cousub(CONSTRAINT pk_AZ_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_AZ_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_04_cousub.dbf tiger_staging.az_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AZ_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('AZ_cousub'), lower('AZ_cousub')); ALTER TABLE tiger_data.AZ_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
${PSQL} -c "CREATE INDEX tiger_data_AZ_cousub_the_geom_gist ON tiger_data.AZ_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_cousub_countyfp ON tiger_data.AZ_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_04_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_04*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_04*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AZ_tract(CONSTRAINT pk_AZ_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_04_tract.dbf tiger_staging.az_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AZ_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('AZ_tract'), lower('AZ_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_AZ_tract_the_geom_gist ON tiger_data.AZ_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.AZ_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.AZ_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_04_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_04*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_04*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AZ_tabblock(CONSTRAINT pk_AZ_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_04_tabblock.dbf tiger_staging.az_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AZ_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('AZ_tabblock'), lower('AZ_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.AZ_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
${PSQL} -c "CREATE INDEX tiger_data_AZ_tabblock_the_geom_gist ON tiger_data.AZ_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.AZ_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_04_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_04*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_04*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AZ_bg(CONSTRAINT pk_AZ_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_04_bg.dbf tiger_staging.az_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AZ_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('AZ_bg'), lower('AZ_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.AZ_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
${PSQL} -c "CREATE INDEX tiger_data_AZ_bg_the_geom_gist ON tiger_data.AZ_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.AZ_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_04* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_04*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_04*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AZ_zcta5(CONSTRAINT pk_AZ_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_AZ_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AZ_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AZ_zcta510'), lower('AZ_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AZ_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
${PSQL} -c "CREATE INDEX tiger_data_AZ_zcta5_the_geom_gist ON tiger_data.AZ_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_04* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_04*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_04*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AZ_faces(CONSTRAINT pk_AZ_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AZ_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AZ_faces'), lower('AZ_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_AZ_faces_the_geom_gist ON tiger_data.AZ_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_faces_tfid ON tiger_data.AZ_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_faces_countyfp ON tiger_data.AZ_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.AZ_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
	${PSQL} -c "vacuum analyze tiger_data.AZ_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_04* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_04*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_04*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AZ_featnames(CONSTRAINT pk_AZ_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.AZ_featnames ALTER COLUMN statefp SET DEFAULT '04';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AZ_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AZ_featnames'), lower('AZ_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_featnames_snd_name ON tiger_data.AZ_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_featnames_lname ON tiger_data.AZ_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_featnames_tlid_statefp ON tiger_data.AZ_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.AZ_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
${PSQL} -c "vacuum analyze tiger_data.AZ_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_04* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_04*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_04*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AZ_edges(CONSTRAINT pk_AZ_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AZ_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AZ_edges'), lower('AZ_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AZ_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_edges_tlid ON tiger_data.AZ_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_edgestfidr ON tiger_data.AZ_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_edges_tfidl ON tiger_data.AZ_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_edges_countyfp ON tiger_data.AZ_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_AZ_edges_the_geom_gist ON tiger_data.AZ_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_edges_zipl ON tiger_data.AZ_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.AZ_zip_state_loc(CONSTRAINT pk_AZ_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.AZ_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'AZ', '04', p.name FROM tiger_data.AZ_edges AS e INNER JOIN tiger_data.AZ_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.AZ_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_zip_state_loc_place ON tiger_data.AZ_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.AZ_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
${PSQL} -c "vacuum analyze tiger_data.AZ_edges;"
${PSQL} -c "vacuum analyze tiger_data.AZ_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.AZ_zip_lookup_base(CONSTRAINT pk_AZ_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.AZ_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'AZ', c.name,p.name,'04'  FROM tiger_data.AZ_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '04') INNER JOIN tiger_data.AZ_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.AZ_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.AZ_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_zip_lookup_base_citysnd ON tiger_data.AZ_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_04* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_04*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_04*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AZ_addr(CONSTRAINT pk_AZ_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.AZ_addr ALTER COLUMN statefp SET DEFAULT '04';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AZ_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AZ_addr'), lower('AZ_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AZ_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_addr_least_address ON tiger_data.AZ_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_addr_tlid_statefp ON tiger_data.AZ_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AZ_addr_zip ON tiger_data.AZ_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.AZ_zip_state(CONSTRAINT pk_AZ_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.AZ_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'AZ', '04' FROM tiger_data.AZ_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.AZ_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '04');"
	${PSQL} -c "vacuum analyze tiger_data.AZ_addr;"
cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_05_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_05*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_05*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AR_place(CONSTRAINT pk_AR_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_05_place.dbf tiger_staging.ar_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AR_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('AR_place'), lower('AR_place')); ALTER TABLE tiger_data.AR_place ADD CONSTRAINT uidx_AR_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_AR_place_soundex_name ON tiger_data.AR_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_AR_place_the_geom_gist ON tiger_data.AR_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.AR_place ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_05_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_05*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_05*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AR_cousub(CONSTRAINT pk_AR_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_AR_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_05_cousub.dbf tiger_staging.ar_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AR_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('AR_cousub'), lower('AR_cousub')); ALTER TABLE tiger_data.AR_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
${PSQL} -c "CREATE INDEX tiger_data_AR_cousub_the_geom_gist ON tiger_data.AR_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AR_cousub_countyfp ON tiger_data.AR_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_05_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_05*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_05*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AR_tract(CONSTRAINT pk_AR_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_05_tract.dbf tiger_staging.ar_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AR_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('AR_tract'), lower('AR_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_AR_tract_the_geom_gist ON tiger_data.AR_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.AR_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.AR_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_05_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_05*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_05*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AR_tabblock(CONSTRAINT pk_AR_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_05_tabblock.dbf tiger_staging.ar_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AR_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('AR_tabblock'), lower('AR_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.AR_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
${PSQL} -c "CREATE INDEX tiger_data_AR_tabblock_the_geom_gist ON tiger_data.AR_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.AR_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_05_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_05*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_05*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AR_bg(CONSTRAINT pk_AR_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_05_bg.dbf tiger_staging.ar_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.AR_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('AR_bg'), lower('AR_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.AR_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
${PSQL} -c "CREATE INDEX tiger_data_AR_bg_the_geom_gist ON tiger_data.AR_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.AR_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_05* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_05*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_05*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AR_zcta5(CONSTRAINT pk_AR_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_AR_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AR_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AR_zcta510'), lower('AR_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AR_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
${PSQL} -c "CREATE INDEX tiger_data_AR_zcta5_the_geom_gist ON tiger_data.AR_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_05* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_05*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_05*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AR_faces(CONSTRAINT pk_AR_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AR_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AR_faces'), lower('AR_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_AR_faces_the_geom_gist ON tiger_data.AR_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AR_faces_tfid ON tiger_data.AR_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AR_faces_countyfp ON tiger_data.AR_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.AR_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
	${PSQL} -c "vacuum analyze tiger_data.AR_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_05* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_05*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_05*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AR_featnames(CONSTRAINT pk_AR_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.AR_featnames ALTER COLUMN statefp SET DEFAULT '05';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AR_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AR_featnames'), lower('AR_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_AR_featnames_snd_name ON tiger_data.AR_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_AR_featnames_lname ON tiger_data.AR_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_AR_featnames_tlid_statefp ON tiger_data.AR_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.AR_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
${PSQL} -c "vacuum analyze tiger_data.AR_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_05* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_05*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_05*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AR_edges(CONSTRAINT pk_AR_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AR_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AR_edges'), lower('AR_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AR_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
${PSQL} -c "CREATE INDEX idx_tiger_data_AR_edges_tlid ON tiger_data.AR_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AR_edgestfidr ON tiger_data.AR_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AR_edges_tfidl ON tiger_data.AR_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AR_edges_countyfp ON tiger_data.AR_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_AR_edges_the_geom_gist ON tiger_data.AR_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_AR_edges_zipl ON tiger_data.AR_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.AR_zip_state_loc(CONSTRAINT pk_AR_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.AR_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'AR', '05', p.name FROM tiger_data.AR_edges AS e INNER JOIN tiger_data.AR_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.AR_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_AR_zip_state_loc_place ON tiger_data.AR_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.AR_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
${PSQL} -c "vacuum analyze tiger_data.AR_edges;"
${PSQL} -c "vacuum analyze tiger_data.AR_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.AR_zip_lookup_base(CONSTRAINT pk_AR_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.AR_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'AR', c.name,p.name,'05'  FROM tiger_data.AR_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '05') INNER JOIN tiger_data.AR_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.AR_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.AR_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
${PSQL} -c "CREATE INDEX idx_tiger_data_AR_zip_lookup_base_citysnd ON tiger_data.AR_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_05* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_05*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_05*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.AR_addr(CONSTRAINT pk_AR_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.AR_addr ALTER COLUMN statefp SET DEFAULT '05';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.AR_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('AR_addr'), lower('AR_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.AR_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AR_addr_least_address ON tiger_data.AR_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AR_addr_tlid_statefp ON tiger_data.AR_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_AR_addr_zip ON tiger_data.AR_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.AR_zip_state(CONSTRAINT pk_AR_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.AR_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'AR', '05' FROM tiger_data.AR_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.AR_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '05');"
	${PSQL} -c "vacuum analyze tiger_data.AR_addr;"
cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_06_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_06*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_06*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CA_place(CONSTRAINT pk_CA_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_06_place.dbf tiger_staging.ca_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CA_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('CA_place'), lower('CA_place')); ALTER TABLE tiger_data.CA_place ADD CONSTRAINT uidx_CA_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_CA_place_soundex_name ON tiger_data.CA_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_CA_place_the_geom_gist ON tiger_data.CA_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.CA_place ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_06_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_06*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_06*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CA_cousub(CONSTRAINT pk_CA_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_CA_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_06_cousub.dbf tiger_staging.ca_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CA_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('CA_cousub'), lower('CA_cousub')); ALTER TABLE tiger_data.CA_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
${PSQL} -c "CREATE INDEX tiger_data_CA_cousub_the_geom_gist ON tiger_data.CA_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CA_cousub_countyfp ON tiger_data.CA_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_06_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_06*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_06*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CA_tract(CONSTRAINT pk_CA_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_06_tract.dbf tiger_staging.ca_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CA_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('CA_tract'), lower('CA_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_CA_tract_the_geom_gist ON tiger_data.CA_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.CA_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.CA_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_06_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_06*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_06*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CA_tabblock(CONSTRAINT pk_CA_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_06_tabblock.dbf tiger_staging.ca_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CA_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('CA_tabblock'), lower('CA_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.CA_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
${PSQL} -c "CREATE INDEX tiger_data_CA_tabblock_the_geom_gist ON tiger_data.CA_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.CA_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_06_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_06*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_06*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CA_bg(CONSTRAINT pk_CA_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_06_bg.dbf tiger_staging.ca_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CA_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('CA_bg'), lower('CA_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.CA_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
${PSQL} -c "CREATE INDEX tiger_data_CA_bg_the_geom_gist ON tiger_data.CA_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.CA_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_06* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_06*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_06*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CA_zcta5(CONSTRAINT pk_CA_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_CA_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CA_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CA_zcta510'), lower('CA_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.CA_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
${PSQL} -c "CREATE INDEX tiger_data_CA_zcta5_the_geom_gist ON tiger_data.CA_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_06* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_06*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_06*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CA_faces(CONSTRAINT pk_CA_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CA_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CA_faces'), lower('CA_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_CA_faces_the_geom_gist ON tiger_data.CA_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CA_faces_tfid ON tiger_data.CA_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CA_faces_countyfp ON tiger_data.CA_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.CA_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
	${PSQL} -c "vacuum analyze tiger_data.CA_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_06* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_06*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_06*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CA_featnames(CONSTRAINT pk_CA_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.CA_featnames ALTER COLUMN statefp SET DEFAULT '06';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CA_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CA_featnames'), lower('CA_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_CA_featnames_snd_name ON tiger_data.CA_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_CA_featnames_lname ON tiger_data.CA_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_CA_featnames_tlid_statefp ON tiger_data.CA_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.CA_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
${PSQL} -c "vacuum analyze tiger_data.CA_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_06* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_06*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_06*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CA_edges(CONSTRAINT pk_CA_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CA_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CA_edges'), lower('CA_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.CA_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
${PSQL} -c "CREATE INDEX idx_tiger_data_CA_edges_tlid ON tiger_data.CA_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CA_edgestfidr ON tiger_data.CA_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CA_edges_tfidl ON tiger_data.CA_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CA_edges_countyfp ON tiger_data.CA_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_CA_edges_the_geom_gist ON tiger_data.CA_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CA_edges_zipl ON tiger_data.CA_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.CA_zip_state_loc(CONSTRAINT pk_CA_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.CA_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'CA', '06', p.name FROM tiger_data.CA_edges AS e INNER JOIN tiger_data.CA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.CA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_CA_zip_state_loc_place ON tiger_data.CA_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.CA_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
${PSQL} -c "vacuum analyze tiger_data.CA_edges;"
${PSQL} -c "vacuum analyze tiger_data.CA_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.CA_zip_lookup_base(CONSTRAINT pk_CA_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.CA_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'CA', c.name,p.name,'06'  FROM tiger_data.CA_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '06') INNER JOIN tiger_data.CA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.CA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.CA_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
${PSQL} -c "CREATE INDEX idx_tiger_data_CA_zip_lookup_base_citysnd ON tiger_data.CA_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_06* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_06*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_06*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CA_addr(CONSTRAINT pk_CA_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.CA_addr ALTER COLUMN statefp SET DEFAULT '06';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CA_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CA_addr'), lower('CA_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.CA_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CA_addr_least_address ON tiger_data.CA_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CA_addr_tlid_statefp ON tiger_data.CA_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CA_addr_zip ON tiger_data.CA_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.CA_zip_state(CONSTRAINT pk_CA_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.CA_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'CA', '06' FROM tiger_data.CA_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.CA_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '06');"
	${PSQL} -c "vacuum analyze tiger_data.CA_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_08_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_08*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_08*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CO_place(CONSTRAINT pk_CO_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_08_place.dbf tiger_staging.co_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CO_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('CO_place'), lower('CO_place')); ALTER TABLE tiger_data.CO_place ADD CONSTRAINT uidx_CO_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_CO_place_soundex_name ON tiger_data.CO_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_CO_place_the_geom_gist ON tiger_data.CO_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.CO_place ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_08_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_08*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_08*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CO_cousub(CONSTRAINT pk_CO_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_CO_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_08_cousub.dbf tiger_staging.co_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CO_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('CO_cousub'), lower('CO_cousub')); ALTER TABLE tiger_data.CO_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
${PSQL} -c "CREATE INDEX tiger_data_CO_cousub_the_geom_gist ON tiger_data.CO_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CO_cousub_countyfp ON tiger_data.CO_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_08_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_08*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_08*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CO_tract(CONSTRAINT pk_CO_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_08_tract.dbf tiger_staging.co_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CO_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('CO_tract'), lower('CO_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_CO_tract_the_geom_gist ON tiger_data.CO_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.CO_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.CO_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_08_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_08*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_08*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CO_tabblock(CONSTRAINT pk_CO_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_08_tabblock.dbf tiger_staging.co_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CO_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('CO_tabblock'), lower('CO_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.CO_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
${PSQL} -c "CREATE INDEX tiger_data_CO_tabblock_the_geom_gist ON tiger_data.CO_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.CO_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_08_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_08*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_08*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CO_bg(CONSTRAINT pk_CO_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_08_bg.dbf tiger_staging.co_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CO_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('CO_bg'), lower('CO_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.CO_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
${PSQL} -c "CREATE INDEX tiger_data_CO_bg_the_geom_gist ON tiger_data.CO_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.CO_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_08* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_08*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_08*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CO_zcta5(CONSTRAINT pk_CO_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_CO_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CO_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CO_zcta510'), lower('CO_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.CO_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
${PSQL} -c "CREATE INDEX tiger_data_CO_zcta5_the_geom_gist ON tiger_data.CO_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_08* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_08*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_08*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CO_faces(CONSTRAINT pk_CO_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CO_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CO_faces'), lower('CO_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_CO_faces_the_geom_gist ON tiger_data.CO_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CO_faces_tfid ON tiger_data.CO_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CO_faces_countyfp ON tiger_data.CO_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.CO_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
	${PSQL} -c "vacuum analyze tiger_data.CO_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_08* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_08*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_08*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CO_featnames(CONSTRAINT pk_CO_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.CO_featnames ALTER COLUMN statefp SET DEFAULT '08';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CO_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CO_featnames'), lower('CO_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_CO_featnames_snd_name ON tiger_data.CO_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_CO_featnames_lname ON tiger_data.CO_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_CO_featnames_tlid_statefp ON tiger_data.CO_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.CO_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
${PSQL} -c "vacuum analyze tiger_data.CO_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_08* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_08*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_08*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CO_edges(CONSTRAINT pk_CO_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CO_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CO_edges'), lower('CO_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.CO_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
${PSQL} -c "CREATE INDEX idx_tiger_data_CO_edges_tlid ON tiger_data.CO_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CO_edgestfidr ON tiger_data.CO_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CO_edges_tfidl ON tiger_data.CO_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CO_edges_countyfp ON tiger_data.CO_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_CO_edges_the_geom_gist ON tiger_data.CO_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CO_edges_zipl ON tiger_data.CO_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.CO_zip_state_loc(CONSTRAINT pk_CO_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.CO_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'CO', '08', p.name FROM tiger_data.CO_edges AS e INNER JOIN tiger_data.CO_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.CO_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_CO_zip_state_loc_place ON tiger_data.CO_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.CO_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
${PSQL} -c "vacuum analyze tiger_data.CO_edges;"
${PSQL} -c "vacuum analyze tiger_data.CO_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.CO_zip_lookup_base(CONSTRAINT pk_CO_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.CO_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'CO', c.name,p.name,'08'  FROM tiger_data.CO_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '08') INNER JOIN tiger_data.CO_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.CO_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.CO_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
${PSQL} -c "CREATE INDEX idx_tiger_data_CO_zip_lookup_base_citysnd ON tiger_data.CO_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_08* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_08*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_08*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CO_addr(CONSTRAINT pk_CO_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.CO_addr ALTER COLUMN statefp SET DEFAULT '08';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CO_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CO_addr'), lower('CO_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.CO_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CO_addr_least_address ON tiger_data.CO_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CO_addr_tlid_statefp ON tiger_data.CO_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CO_addr_zip ON tiger_data.CO_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.CO_zip_state(CONSTRAINT pk_CO_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.CO_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'CO', '08' FROM tiger_data.CO_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.CO_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '08');"
	${PSQL} -c "vacuum analyze tiger_data.CO_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_09_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_09*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_09*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CT_place(CONSTRAINT pk_CT_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_09_place.dbf tiger_staging.ct_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CT_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('CT_place'), lower('CT_place')); ALTER TABLE tiger_data.CT_place ADD CONSTRAINT uidx_CT_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_CT_place_soundex_name ON tiger_data.CT_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_CT_place_the_geom_gist ON tiger_data.CT_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.CT_place ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_09_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_09*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_09*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CT_cousub(CONSTRAINT pk_CT_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_CT_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_09_cousub.dbf tiger_staging.ct_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CT_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('CT_cousub'), lower('CT_cousub')); ALTER TABLE tiger_data.CT_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
${PSQL} -c "CREATE INDEX tiger_data_CT_cousub_the_geom_gist ON tiger_data.CT_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CT_cousub_countyfp ON tiger_data.CT_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_09_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_09*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_09*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CT_tract(CONSTRAINT pk_CT_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_09_tract.dbf tiger_staging.ct_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CT_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('CT_tract'), lower('CT_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_CT_tract_the_geom_gist ON tiger_data.CT_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.CT_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.CT_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_09_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_09*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_09*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CT_tabblock(CONSTRAINT pk_CT_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_09_tabblock.dbf tiger_staging.ct_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CT_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('CT_tabblock'), lower('CT_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.CT_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
${PSQL} -c "CREATE INDEX tiger_data_CT_tabblock_the_geom_gist ON tiger_data.CT_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.CT_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_09_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_09*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_09*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CT_bg(CONSTRAINT pk_CT_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_09_bg.dbf tiger_staging.ct_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.CT_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('CT_bg'), lower('CT_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.CT_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
${PSQL} -c "CREATE INDEX tiger_data_CT_bg_the_geom_gist ON tiger_data.CT_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.CT_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_09* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_09*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_09*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CT_zcta5(CONSTRAINT pk_CT_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_CT_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CT_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CT_zcta510'), lower('CT_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.CT_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
${PSQL} -c "CREATE INDEX tiger_data_CT_zcta5_the_geom_gist ON tiger_data.CT_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_09* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_09*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_09*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CT_faces(CONSTRAINT pk_CT_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CT_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CT_faces'), lower('CT_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_CT_faces_the_geom_gist ON tiger_data.CT_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CT_faces_tfid ON tiger_data.CT_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CT_faces_countyfp ON tiger_data.CT_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.CT_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
	${PSQL} -c "vacuum analyze tiger_data.CT_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_09* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_09*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_09*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CT_featnames(CONSTRAINT pk_CT_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.CT_featnames ALTER COLUMN statefp SET DEFAULT '09';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CT_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CT_featnames'), lower('CT_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_CT_featnames_snd_name ON tiger_data.CT_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_CT_featnames_lname ON tiger_data.CT_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_CT_featnames_tlid_statefp ON tiger_data.CT_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.CT_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
${PSQL} -c "vacuum analyze tiger_data.CT_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_09* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_09*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_09*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CT_edges(CONSTRAINT pk_CT_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CT_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CT_edges'), lower('CT_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.CT_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
${PSQL} -c "CREATE INDEX idx_tiger_data_CT_edges_tlid ON tiger_data.CT_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CT_edgestfidr ON tiger_data.CT_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CT_edges_tfidl ON tiger_data.CT_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CT_edges_countyfp ON tiger_data.CT_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_CT_edges_the_geom_gist ON tiger_data.CT_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_CT_edges_zipl ON tiger_data.CT_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.CT_zip_state_loc(CONSTRAINT pk_CT_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.CT_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'CT', '09', p.name FROM tiger_data.CT_edges AS e INNER JOIN tiger_data.CT_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.CT_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_CT_zip_state_loc_place ON tiger_data.CT_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.CT_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
${PSQL} -c "vacuum analyze tiger_data.CT_edges;"
${PSQL} -c "vacuum analyze tiger_data.CT_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.CT_zip_lookup_base(CONSTRAINT pk_CT_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.CT_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'CT', c.name,p.name,'09'  FROM tiger_data.CT_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '09') INNER JOIN tiger_data.CT_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.CT_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.CT_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
${PSQL} -c "CREATE INDEX idx_tiger_data_CT_zip_lookup_base_citysnd ON tiger_data.CT_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_09* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_09*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_09*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.CT_addr(CONSTRAINT pk_CT_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.CT_addr ALTER COLUMN statefp SET DEFAULT '09';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.CT_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('CT_addr'), lower('CT_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.CT_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CT_addr_least_address ON tiger_data.CT_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CT_addr_tlid_statefp ON tiger_data.CT_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_CT_addr_zip ON tiger_data.CT_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.CT_zip_state(CONSTRAINT pk_CT_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.CT_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'CT', '09' FROM tiger_data.CT_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.CT_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '09');"
	${PSQL} -c "vacuum analyze tiger_data.CT_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_10_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_10*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_10*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DE_place(CONSTRAINT pk_DE_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_10_place.dbf tiger_staging.de_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.DE_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('DE_place'), lower('DE_place')); ALTER TABLE tiger_data.DE_place ADD CONSTRAINT uidx_DE_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_DE_place_soundex_name ON tiger_data.DE_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_DE_place_the_geom_gist ON tiger_data.DE_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.DE_place ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_10_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_10*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_10*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DE_cousub(CONSTRAINT pk_DE_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_DE_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_10_cousub.dbf tiger_staging.de_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.DE_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('DE_cousub'), lower('DE_cousub')); ALTER TABLE tiger_data.DE_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
${PSQL} -c "CREATE INDEX tiger_data_DE_cousub_the_geom_gist ON tiger_data.DE_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_DE_cousub_countyfp ON tiger_data.DE_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_10_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_10*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_10*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DE_tract(CONSTRAINT pk_DE_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_10_tract.dbf tiger_staging.de_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.DE_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('DE_tract'), lower('DE_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_DE_tract_the_geom_gist ON tiger_data.DE_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.DE_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.DE_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_10_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_10*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_10*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DE_tabblock(CONSTRAINT pk_DE_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_10_tabblock.dbf tiger_staging.de_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.DE_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('DE_tabblock'), lower('DE_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.DE_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
${PSQL} -c "CREATE INDEX tiger_data_DE_tabblock_the_geom_gist ON tiger_data.DE_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.DE_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_10_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_10*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_10*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DE_bg(CONSTRAINT pk_DE_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_10_bg.dbf tiger_staging.de_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.DE_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('DE_bg'), lower('DE_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.DE_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
${PSQL} -c "CREATE INDEX tiger_data_DE_bg_the_geom_gist ON tiger_data.DE_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.DE_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_10* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_10*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_10*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DE_zcta5(CONSTRAINT pk_DE_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_DE_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.DE_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('DE_zcta510'), lower('DE_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.DE_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
${PSQL} -c "CREATE INDEX tiger_data_DE_zcta5_the_geom_gist ON tiger_data.DE_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_10* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_10*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_10*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DE_faces(CONSTRAINT pk_DE_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.DE_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('DE_faces'), lower('DE_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_DE_faces_the_geom_gist ON tiger_data.DE_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_DE_faces_tfid ON tiger_data.DE_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_DE_faces_countyfp ON tiger_data.DE_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.DE_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
	${PSQL} -c "vacuum analyze tiger_data.DE_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_10* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_10*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_10*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DE_featnames(CONSTRAINT pk_DE_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.DE_featnames ALTER COLUMN statefp SET DEFAULT '10';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.DE_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('DE_featnames'), lower('DE_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_DE_featnames_snd_name ON tiger_data.DE_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_DE_featnames_lname ON tiger_data.DE_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_DE_featnames_tlid_statefp ON tiger_data.DE_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.DE_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
${PSQL} -c "vacuum analyze tiger_data.DE_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_10* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_10*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_10*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DE_edges(CONSTRAINT pk_DE_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.DE_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('DE_edges'), lower('DE_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.DE_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
${PSQL} -c "CREATE INDEX idx_tiger_data_DE_edges_tlid ON tiger_data.DE_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_DE_edgestfidr ON tiger_data.DE_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_DE_edges_tfidl ON tiger_data.DE_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_DE_edges_countyfp ON tiger_data.DE_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_DE_edges_the_geom_gist ON tiger_data.DE_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_DE_edges_zipl ON tiger_data.DE_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.DE_zip_state_loc(CONSTRAINT pk_DE_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.DE_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'DE', '10', p.name FROM tiger_data.DE_edges AS e INNER JOIN tiger_data.DE_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.DE_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_DE_zip_state_loc_place ON tiger_data.DE_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.DE_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
${PSQL} -c "vacuum analyze tiger_data.DE_edges;"
${PSQL} -c "vacuum analyze tiger_data.DE_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.DE_zip_lookup_base(CONSTRAINT pk_DE_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.DE_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'DE', c.name,p.name,'10'  FROM tiger_data.DE_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '10') INNER JOIN tiger_data.DE_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.DE_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.DE_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
${PSQL} -c "CREATE INDEX idx_tiger_data_DE_zip_lookup_base_citysnd ON tiger_data.DE_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_10* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_10*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_10*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DE_addr(CONSTRAINT pk_DE_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.DE_addr ALTER COLUMN statefp SET DEFAULT '10';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.DE_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('DE_addr'), lower('DE_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.DE_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_DE_addr_least_address ON tiger_data.DE_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_DE_addr_tlid_statefp ON tiger_data.DE_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_DE_addr_zip ON tiger_data.DE_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.DE_zip_state(CONSTRAINT pk_DE_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.DE_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'DE', '10' FROM tiger_data.DE_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.DE_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '10');"
	${PSQL} -c "vacuum analyze tiger_data.DE_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_11_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_11*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_11*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DC_place(CONSTRAINT pk_DC_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_11_place.dbf tiger_staging.dc_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.DC_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('DC_place'), lower('DC_place')); ALTER TABLE tiger_data.DC_place ADD CONSTRAINT uidx_DC_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_DC_place_soundex_name ON tiger_data.DC_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_DC_place_the_geom_gist ON tiger_data.DC_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.DC_place ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_11_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_11*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_11*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DC_cousub(CONSTRAINT pk_DC_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_DC_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_11_cousub.dbf tiger_staging.dc_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.DC_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('DC_cousub'), lower('DC_cousub')); ALTER TABLE tiger_data.DC_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
${PSQL} -c "CREATE INDEX tiger_data_DC_cousub_the_geom_gist ON tiger_data.DC_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_DC_cousub_countyfp ON tiger_data.DC_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_11_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_11*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_11*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DC_tract(CONSTRAINT pk_DC_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_11_tract.dbf tiger_staging.dc_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.DC_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('DC_tract'), lower('DC_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_DC_tract_the_geom_gist ON tiger_data.DC_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.DC_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.DC_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_11_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_11*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_11*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DC_tabblock(CONSTRAINT pk_DC_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_11_tabblock.dbf tiger_staging.dc_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.DC_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('DC_tabblock'), lower('DC_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.DC_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
${PSQL} -c "CREATE INDEX tiger_data_DC_tabblock_the_geom_gist ON tiger_data.DC_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.DC_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_11_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_11*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_11*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DC_bg(CONSTRAINT pk_DC_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_11_bg.dbf tiger_staging.dc_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.DC_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('DC_bg'), lower('DC_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.DC_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
${PSQL} -c "CREATE INDEX tiger_data_DC_bg_the_geom_gist ON tiger_data.DC_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.DC_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_11* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_11*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_11*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DC_zcta5(CONSTRAINT pk_DC_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_DC_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.DC_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('DC_zcta510'), lower('DC_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.DC_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
${PSQL} -c "CREATE INDEX tiger_data_DC_zcta5_the_geom_gist ON tiger_data.DC_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_11* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_11*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_11*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DC_faces(CONSTRAINT pk_DC_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.DC_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('DC_faces'), lower('DC_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_DC_faces_the_geom_gist ON tiger_data.DC_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_DC_faces_tfid ON tiger_data.DC_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_DC_faces_countyfp ON tiger_data.DC_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.DC_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
	${PSQL} -c "vacuum analyze tiger_data.DC_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_11* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_11*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_11*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DC_featnames(CONSTRAINT pk_DC_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.DC_featnames ALTER COLUMN statefp SET DEFAULT '11';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.DC_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('DC_featnames'), lower('DC_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_DC_featnames_snd_name ON tiger_data.DC_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_DC_featnames_lname ON tiger_data.DC_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_DC_featnames_tlid_statefp ON tiger_data.DC_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.DC_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
${PSQL} -c "vacuum analyze tiger_data.DC_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_11* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_11*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_11*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DC_edges(CONSTRAINT pk_DC_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.DC_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('DC_edges'), lower('DC_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.DC_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
${PSQL} -c "CREATE INDEX idx_tiger_data_DC_edges_tlid ON tiger_data.DC_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_DC_edgestfidr ON tiger_data.DC_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_DC_edges_tfidl ON tiger_data.DC_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_DC_edges_countyfp ON tiger_data.DC_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_DC_edges_the_geom_gist ON tiger_data.DC_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_DC_edges_zipl ON tiger_data.DC_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.DC_zip_state_loc(CONSTRAINT pk_DC_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.DC_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'DC', '11', p.name FROM tiger_data.DC_edges AS e INNER JOIN tiger_data.DC_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.DC_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_DC_zip_state_loc_place ON tiger_data.DC_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.DC_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
${PSQL} -c "vacuum analyze tiger_data.DC_edges;"
${PSQL} -c "vacuum analyze tiger_data.DC_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.DC_zip_lookup_base(CONSTRAINT pk_DC_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.DC_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'DC', c.name,p.name,'11'  FROM tiger_data.DC_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '11') INNER JOIN tiger_data.DC_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.DC_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.DC_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
${PSQL} -c "CREATE INDEX idx_tiger_data_DC_zip_lookup_base_citysnd ON tiger_data.DC_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_11* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_11*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_11*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.DC_addr(CONSTRAINT pk_DC_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.DC_addr ALTER COLUMN statefp SET DEFAULT '11';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.DC_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('DC_addr'), lower('DC_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.DC_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_DC_addr_least_address ON tiger_data.DC_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_DC_addr_tlid_statefp ON tiger_data.DC_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_DC_addr_zip ON tiger_data.DC_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.DC_zip_state(CONSTRAINT pk_DC_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.DC_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'DC', '11' FROM tiger_data.DC_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.DC_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '11');"
	${PSQL} -c "vacuum analyze tiger_data.DC_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_12_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_12*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_12*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.FL_place(CONSTRAINT pk_FL_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_12_place.dbf tiger_staging.fl_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.FL_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('FL_place'), lower('FL_place')); ALTER TABLE tiger_data.FL_place ADD CONSTRAINT uidx_FL_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_FL_place_soundex_name ON tiger_data.FL_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_FL_place_the_geom_gist ON tiger_data.FL_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.FL_place ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_12_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_12*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_12*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.FL_cousub(CONSTRAINT pk_FL_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_FL_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_12_cousub.dbf tiger_staging.fl_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.FL_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('FL_cousub'), lower('FL_cousub')); ALTER TABLE tiger_data.FL_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
${PSQL} -c "CREATE INDEX tiger_data_FL_cousub_the_geom_gist ON tiger_data.FL_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_FL_cousub_countyfp ON tiger_data.FL_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_12_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_12*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_12*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.FL_tract(CONSTRAINT pk_FL_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_12_tract.dbf tiger_staging.fl_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.FL_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('FL_tract'), lower('FL_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_FL_tract_the_geom_gist ON tiger_data.FL_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.FL_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.FL_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_12_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_12*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_12*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.FL_tabblock(CONSTRAINT pk_FL_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_12_tabblock.dbf tiger_staging.fl_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.FL_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('FL_tabblock'), lower('FL_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.FL_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
${PSQL} -c "CREATE INDEX tiger_data_FL_tabblock_the_geom_gist ON tiger_data.FL_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.FL_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_12_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_12*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_12*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.FL_bg(CONSTRAINT pk_FL_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_12_bg.dbf tiger_staging.fl_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.FL_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('FL_bg'), lower('FL_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.FL_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
${PSQL} -c "CREATE INDEX tiger_data_FL_bg_the_geom_gist ON tiger_data.FL_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.FL_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_12* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_12*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_12*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.FL_zcta5(CONSTRAINT pk_FL_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_FL_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.FL_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('FL_zcta510'), lower('FL_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.FL_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
${PSQL} -c "CREATE INDEX tiger_data_FL_zcta5_the_geom_gist ON tiger_data.FL_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_12* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_12*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_12*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.FL_faces(CONSTRAINT pk_FL_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.FL_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('FL_faces'), lower('FL_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_FL_faces_the_geom_gist ON tiger_data.FL_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_FL_faces_tfid ON tiger_data.FL_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_FL_faces_countyfp ON tiger_data.FL_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.FL_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
	${PSQL} -c "vacuum analyze tiger_data.FL_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_12* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_12*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_12*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.FL_featnames(CONSTRAINT pk_FL_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.FL_featnames ALTER COLUMN statefp SET DEFAULT '12';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.FL_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('FL_featnames'), lower('FL_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_FL_featnames_snd_name ON tiger_data.FL_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_FL_featnames_lname ON tiger_data.FL_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_FL_featnames_tlid_statefp ON tiger_data.FL_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.FL_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
${PSQL} -c "vacuum analyze tiger_data.FL_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_12* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_12*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_12*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.FL_edges(CONSTRAINT pk_FL_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.FL_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('FL_edges'), lower('FL_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.FL_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
${PSQL} -c "CREATE INDEX idx_tiger_data_FL_edges_tlid ON tiger_data.FL_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_FL_edgestfidr ON tiger_data.FL_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_FL_edges_tfidl ON tiger_data.FL_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_FL_edges_countyfp ON tiger_data.FL_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_FL_edges_the_geom_gist ON tiger_data.FL_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_FL_edges_zipl ON tiger_data.FL_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.FL_zip_state_loc(CONSTRAINT pk_FL_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.FL_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'FL', '12', p.name FROM tiger_data.FL_edges AS e INNER JOIN tiger_data.FL_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.FL_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_FL_zip_state_loc_place ON tiger_data.FL_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.FL_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
${PSQL} -c "vacuum analyze tiger_data.FL_edges;"
${PSQL} -c "vacuum analyze tiger_data.FL_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.FL_zip_lookup_base(CONSTRAINT pk_FL_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.FL_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'FL', c.name,p.name,'12'  FROM tiger_data.FL_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '12') INNER JOIN tiger_data.FL_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.FL_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.FL_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
${PSQL} -c "CREATE INDEX idx_tiger_data_FL_zip_lookup_base_citysnd ON tiger_data.FL_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_12* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_12*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_12*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.FL_addr(CONSTRAINT pk_FL_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.FL_addr ALTER COLUMN statefp SET DEFAULT '12';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.FL_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('FL_addr'), lower('FL_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.FL_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_FL_addr_least_address ON tiger_data.FL_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_FL_addr_tlid_statefp ON tiger_data.FL_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_FL_addr_zip ON tiger_data.FL_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.FL_zip_state(CONSTRAINT pk_FL_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.FL_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'FL', '12' FROM tiger_data.FL_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.FL_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '12');"
	${PSQL} -c "vacuum analyze tiger_data.FL_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_13_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_13*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_13*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.GA_place(CONSTRAINT pk_GA_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_13_place.dbf tiger_staging.ga_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.GA_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('GA_place'), lower('GA_place')); ALTER TABLE tiger_data.GA_place ADD CONSTRAINT uidx_GA_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_GA_place_soundex_name ON tiger_data.GA_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_GA_place_the_geom_gist ON tiger_data.GA_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.GA_place ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_13_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_13*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_13*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.GA_cousub(CONSTRAINT pk_GA_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_GA_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_13_cousub.dbf tiger_staging.ga_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.GA_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('GA_cousub'), lower('GA_cousub')); ALTER TABLE tiger_data.GA_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
${PSQL} -c "CREATE INDEX tiger_data_GA_cousub_the_geom_gist ON tiger_data.GA_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_GA_cousub_countyfp ON tiger_data.GA_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_13_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_13*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_13*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.GA_tract(CONSTRAINT pk_GA_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_13_tract.dbf tiger_staging.ga_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.GA_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('GA_tract'), lower('GA_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_GA_tract_the_geom_gist ON tiger_data.GA_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.GA_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.GA_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_13_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_13*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_13*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.GA_tabblock(CONSTRAINT pk_GA_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_13_tabblock.dbf tiger_staging.ga_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.GA_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('GA_tabblock'), lower('GA_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.GA_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
${PSQL} -c "CREATE INDEX tiger_data_GA_tabblock_the_geom_gist ON tiger_data.GA_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.GA_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_13_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_13*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_13*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.GA_bg(CONSTRAINT pk_GA_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_13_bg.dbf tiger_staging.ga_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.GA_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('GA_bg'), lower('GA_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.GA_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
${PSQL} -c "CREATE INDEX tiger_data_GA_bg_the_geom_gist ON tiger_data.GA_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.GA_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_13* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_13*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_13*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.GA_zcta5(CONSTRAINT pk_GA_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_GA_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.GA_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('GA_zcta510'), lower('GA_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.GA_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
${PSQL} -c "CREATE INDEX tiger_data_GA_zcta5_the_geom_gist ON tiger_data.GA_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_13* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_13*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_13*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.GA_faces(CONSTRAINT pk_GA_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.GA_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('GA_faces'), lower('GA_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_GA_faces_the_geom_gist ON tiger_data.GA_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_GA_faces_tfid ON tiger_data.GA_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_GA_faces_countyfp ON tiger_data.GA_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.GA_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
	${PSQL} -c "vacuum analyze tiger_data.GA_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_13* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_13*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_13*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.GA_featnames(CONSTRAINT pk_GA_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.GA_featnames ALTER COLUMN statefp SET DEFAULT '13';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.GA_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('GA_featnames'), lower('GA_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_GA_featnames_snd_name ON tiger_data.GA_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_GA_featnames_lname ON tiger_data.GA_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_GA_featnames_tlid_statefp ON tiger_data.GA_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.GA_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
${PSQL} -c "vacuum analyze tiger_data.GA_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_13* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_13*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_13*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.GA_edges(CONSTRAINT pk_GA_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.GA_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('GA_edges'), lower('GA_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.GA_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
${PSQL} -c "CREATE INDEX idx_tiger_data_GA_edges_tlid ON tiger_data.GA_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_GA_edgestfidr ON tiger_data.GA_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_GA_edges_tfidl ON tiger_data.GA_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_GA_edges_countyfp ON tiger_data.GA_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_GA_edges_the_geom_gist ON tiger_data.GA_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_GA_edges_zipl ON tiger_data.GA_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.GA_zip_state_loc(CONSTRAINT pk_GA_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.GA_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'GA', '13', p.name FROM tiger_data.GA_edges AS e INNER JOIN tiger_data.GA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.GA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_GA_zip_state_loc_place ON tiger_data.GA_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.GA_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
${PSQL} -c "vacuum analyze tiger_data.GA_edges;"
${PSQL} -c "vacuum analyze tiger_data.GA_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.GA_zip_lookup_base(CONSTRAINT pk_GA_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.GA_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'GA', c.name,p.name,'13'  FROM tiger_data.GA_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '13') INNER JOIN tiger_data.GA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.GA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.GA_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
${PSQL} -c "CREATE INDEX idx_tiger_data_GA_zip_lookup_base_citysnd ON tiger_data.GA_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_13* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_13*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_13*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.GA_addr(CONSTRAINT pk_GA_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.GA_addr ALTER COLUMN statefp SET DEFAULT '13';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.GA_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('GA_addr'), lower('GA_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.GA_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_GA_addr_least_address ON tiger_data.GA_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_GA_addr_tlid_statefp ON tiger_data.GA_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_GA_addr_zip ON tiger_data.GA_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.GA_zip_state(CONSTRAINT pk_GA_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.GA_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'GA', '13' FROM tiger_data.GA_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.GA_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '13');"
	${PSQL} -c "vacuum analyze tiger_data.GA_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_15_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_15*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_place(CONSTRAINT pk_HI_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_15_place.dbf tiger_staging.hi_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.HI_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('HI_place'), lower('HI_place')); ALTER TABLE tiger_data.HI_place ADD CONSTRAINT uidx_HI_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_HI_place_soundex_name ON tiger_data.HI_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_HI_place_the_geom_gist ON tiger_data.HI_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.HI_place ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_15_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_15*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_cousub(CONSTRAINT pk_HI_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_HI_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_15_cousub.dbf tiger_staging.hi_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.HI_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('HI_cousub'), lower('HI_cousub')); ALTER TABLE tiger_data.HI_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "CREATE INDEX tiger_data_HI_cousub_the_geom_gist ON tiger_data.HI_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_cousub_countyfp ON tiger_data.HI_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_15_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_15*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_tract(CONSTRAINT pk_HI_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_15_tract.dbf tiger_staging.hi_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.HI_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('HI_tract'), lower('HI_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_HI_tract_the_geom_gist ON tiger_data.HI_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.HI_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.HI_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_15_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_15*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_tabblock(CONSTRAINT pk_HI_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_15_tabblock.dbf tiger_staging.hi_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.HI_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('HI_tabblock'), lower('HI_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.HI_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "CREATE INDEX tiger_data_HI_tabblock_the_geom_gist ON tiger_data.HI_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.HI_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_15_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_15*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_bg(CONSTRAINT pk_HI_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_15_bg.dbf tiger_staging.hi_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.HI_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('HI_bg'), lower('HI_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.HI_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "CREATE INDEX tiger_data_HI_bg_the_geom_gist ON tiger_data.HI_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.HI_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_15* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_15*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_zcta5(CONSTRAINT pk_HI_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_HI_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.HI_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('HI_zcta510'), lower('HI_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.HI_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "CREATE INDEX tiger_data_HI_zcta5_the_geom_gist ON tiger_data.HI_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_15* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_15*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_faces(CONSTRAINT pk_HI_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.HI_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('HI_faces'), lower('HI_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_HI_faces_the_geom_gist ON tiger_data.HI_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_HI_faces_tfid ON tiger_data.HI_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_HI_faces_countyfp ON tiger_data.HI_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.HI_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
	${PSQL} -c "vacuum analyze tiger_data.HI_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_15* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_15*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_featnames(CONSTRAINT pk_HI_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.HI_featnames ALTER COLUMN statefp SET DEFAULT '15';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.HI_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('HI_featnames'), lower('HI_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_HI_featnames_snd_name ON tiger_data.HI_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_featnames_lname ON tiger_data.HI_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_featnames_tlid_statefp ON tiger_data.HI_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.HI_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "vacuum analyze tiger_data.HI_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_15* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_15*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_edges(CONSTRAINT pk_HI_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.HI_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('HI_edges'), lower('HI_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.HI_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_edges_tlid ON tiger_data.HI_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_edgestfidr ON tiger_data.HI_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_edges_tfidl ON tiger_data.HI_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_edges_countyfp ON tiger_data.HI_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_HI_edges_the_geom_gist ON tiger_data.HI_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_edges_zipl ON tiger_data.HI_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.HI_zip_state_loc(CONSTRAINT pk_HI_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.HI_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'HI', '15', p.name FROM tiger_data.HI_edges AS e INNER JOIN tiger_data.HI_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.HI_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_zip_state_loc_place ON tiger_data.HI_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.HI_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "vacuum analyze tiger_data.HI_edges;"
${PSQL} -c "vacuum analyze tiger_data.HI_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.HI_zip_lookup_base(CONSTRAINT pk_HI_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.HI_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'HI', c.name,p.name,'15'  FROM tiger_data.HI_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '15') INNER JOIN tiger_data.HI_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.HI_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.HI_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
${PSQL} -c "CREATE INDEX idx_tiger_data_HI_zip_lookup_base_citysnd ON tiger_data.HI_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_15* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_15*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_15*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.HI_addr(CONSTRAINT pk_HI_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.HI_addr ALTER COLUMN statefp SET DEFAULT '15';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.HI_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('HI_addr'), lower('HI_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.HI_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_HI_addr_least_address ON tiger_data.HI_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_HI_addr_tlid_statefp ON tiger_data.HI_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_HI_addr_zip ON tiger_data.HI_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.HI_zip_state(CONSTRAINT pk_HI_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.HI_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'HI', '15' FROM tiger_data.HI_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.HI_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '15');"
	${PSQL} -c "vacuum analyze tiger_data.HI_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_16_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_16*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_16*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ID_place(CONSTRAINT pk_ID_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_16_place.dbf tiger_staging.id_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ID_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('ID_place'), lower('ID_place')); ALTER TABLE tiger_data.ID_place ADD CONSTRAINT uidx_ID_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_ID_place_soundex_name ON tiger_data.ID_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_ID_place_the_geom_gist ON tiger_data.ID_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.ID_place ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_16_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_16*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_16*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ID_cousub(CONSTRAINT pk_ID_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_ID_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_16_cousub.dbf tiger_staging.id_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ID_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('ID_cousub'), lower('ID_cousub')); ALTER TABLE tiger_data.ID_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
${PSQL} -c "CREATE INDEX tiger_data_ID_cousub_the_geom_gist ON tiger_data.ID_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ID_cousub_countyfp ON tiger_data.ID_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_16_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_16*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_16*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ID_tract(CONSTRAINT pk_ID_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_16_tract.dbf tiger_staging.id_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ID_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('ID_tract'), lower('ID_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_ID_tract_the_geom_gist ON tiger_data.ID_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.ID_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.ID_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_16_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_16*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_16*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ID_tabblock(CONSTRAINT pk_ID_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_16_tabblock.dbf tiger_staging.id_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ID_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('ID_tabblock'), lower('ID_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.ID_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
${PSQL} -c "CREATE INDEX tiger_data_ID_tabblock_the_geom_gist ON tiger_data.ID_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.ID_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_16_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_16*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_16*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ID_bg(CONSTRAINT pk_ID_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_16_bg.dbf tiger_staging.id_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ID_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('ID_bg'), lower('ID_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.ID_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
${PSQL} -c "CREATE INDEX tiger_data_ID_bg_the_geom_gist ON tiger_data.ID_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.ID_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_16* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_16*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_16*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ID_zcta5(CONSTRAINT pk_ID_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_ID_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ID_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ID_zcta510'), lower('ID_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.ID_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
${PSQL} -c "CREATE INDEX tiger_data_ID_zcta5_the_geom_gist ON tiger_data.ID_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_16* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_16*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_16*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ID_faces(CONSTRAINT pk_ID_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ID_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ID_faces'), lower('ID_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_ID_faces_the_geom_gist ON tiger_data.ID_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ID_faces_tfid ON tiger_data.ID_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ID_faces_countyfp ON tiger_data.ID_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.ID_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
	${PSQL} -c "vacuum analyze tiger_data.ID_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_16* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_16*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_16*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ID_featnames(CONSTRAINT pk_ID_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.ID_featnames ALTER COLUMN statefp SET DEFAULT '16';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ID_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ID_featnames'), lower('ID_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_ID_featnames_snd_name ON tiger_data.ID_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_ID_featnames_lname ON tiger_data.ID_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_ID_featnames_tlid_statefp ON tiger_data.ID_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.ID_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
${PSQL} -c "vacuum analyze tiger_data.ID_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_16* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_16*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_16*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ID_edges(CONSTRAINT pk_ID_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ID_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ID_edges'), lower('ID_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.ID_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
${PSQL} -c "CREATE INDEX idx_tiger_data_ID_edges_tlid ON tiger_data.ID_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ID_edgestfidr ON tiger_data.ID_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ID_edges_tfidl ON tiger_data.ID_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ID_edges_countyfp ON tiger_data.ID_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_ID_edges_the_geom_gist ON tiger_data.ID_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ID_edges_zipl ON tiger_data.ID_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.ID_zip_state_loc(CONSTRAINT pk_ID_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.ID_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'ID', '16', p.name FROM tiger_data.ID_edges AS e INNER JOIN tiger_data.ID_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.ID_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_ID_zip_state_loc_place ON tiger_data.ID_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.ID_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
${PSQL} -c "vacuum analyze tiger_data.ID_edges;"
${PSQL} -c "vacuum analyze tiger_data.ID_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.ID_zip_lookup_base(CONSTRAINT pk_ID_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.ID_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'ID', c.name,p.name,'16'  FROM tiger_data.ID_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '16') INNER JOIN tiger_data.ID_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.ID_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.ID_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
${PSQL} -c "CREATE INDEX idx_tiger_data_ID_zip_lookup_base_citysnd ON tiger_data.ID_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_16* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_16*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_16*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ID_addr(CONSTRAINT pk_ID_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.ID_addr ALTER COLUMN statefp SET DEFAULT '16';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ID_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ID_addr'), lower('ID_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.ID_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ID_addr_least_address ON tiger_data.ID_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ID_addr_tlid_statefp ON tiger_data.ID_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ID_addr_zip ON tiger_data.ID_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.ID_zip_state(CONSTRAINT pk_ID_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.ID_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'ID', '16' FROM tiger_data.ID_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.ID_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '16');"
	${PSQL} -c "vacuum analyze tiger_data.ID_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_17_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_17*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_17*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IL_place(CONSTRAINT pk_IL_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_17_place.dbf tiger_staging.il_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IL_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('IL_place'), lower('IL_place')); ALTER TABLE tiger_data.IL_place ADD CONSTRAINT uidx_IL_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_IL_place_soundex_name ON tiger_data.IL_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_IL_place_the_geom_gist ON tiger_data.IL_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.IL_place ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_17_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_17*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_17*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IL_cousub(CONSTRAINT pk_IL_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_IL_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_17_cousub.dbf tiger_staging.il_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IL_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('IL_cousub'), lower('IL_cousub')); ALTER TABLE tiger_data.IL_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
${PSQL} -c "CREATE INDEX tiger_data_IL_cousub_the_geom_gist ON tiger_data.IL_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IL_cousub_countyfp ON tiger_data.IL_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_17_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_17*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_17*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IL_tract(CONSTRAINT pk_IL_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_17_tract.dbf tiger_staging.il_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IL_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('IL_tract'), lower('IL_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_IL_tract_the_geom_gist ON tiger_data.IL_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.IL_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.IL_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_17_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_17*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_17*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IL_tabblock(CONSTRAINT pk_IL_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_17_tabblock.dbf tiger_staging.il_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IL_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('IL_tabblock'), lower('IL_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.IL_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
${PSQL} -c "CREATE INDEX tiger_data_IL_tabblock_the_geom_gist ON tiger_data.IL_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.IL_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_17_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_17*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_17*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IL_bg(CONSTRAINT pk_IL_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_17_bg.dbf tiger_staging.il_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IL_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('IL_bg'), lower('IL_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.IL_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
${PSQL} -c "CREATE INDEX tiger_data_IL_bg_the_geom_gist ON tiger_data.IL_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.IL_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_17* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_17*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_17*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IL_zcta5(CONSTRAINT pk_IL_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_IL_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IL_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IL_zcta510'), lower('IL_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.IL_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
${PSQL} -c "CREATE INDEX tiger_data_IL_zcta5_the_geom_gist ON tiger_data.IL_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_17* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_17*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_17*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IL_faces(CONSTRAINT pk_IL_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IL_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IL_faces'), lower('IL_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_IL_faces_the_geom_gist ON tiger_data.IL_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IL_faces_tfid ON tiger_data.IL_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IL_faces_countyfp ON tiger_data.IL_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.IL_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
	${PSQL} -c "vacuum analyze tiger_data.IL_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_17* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_17*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_17*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IL_featnames(CONSTRAINT pk_IL_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.IL_featnames ALTER COLUMN statefp SET DEFAULT '17';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IL_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IL_featnames'), lower('IL_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_IL_featnames_snd_name ON tiger_data.IL_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_IL_featnames_lname ON tiger_data.IL_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_IL_featnames_tlid_statefp ON tiger_data.IL_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.IL_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
${PSQL} -c "vacuum analyze tiger_data.IL_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_17* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_17*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_17*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IL_edges(CONSTRAINT pk_IL_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IL_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IL_edges'), lower('IL_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.IL_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
${PSQL} -c "CREATE INDEX idx_tiger_data_IL_edges_tlid ON tiger_data.IL_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IL_edgestfidr ON tiger_data.IL_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IL_edges_tfidl ON tiger_data.IL_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IL_edges_countyfp ON tiger_data.IL_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_IL_edges_the_geom_gist ON tiger_data.IL_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IL_edges_zipl ON tiger_data.IL_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.IL_zip_state_loc(CONSTRAINT pk_IL_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.IL_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'IL', '17', p.name FROM tiger_data.IL_edges AS e INNER JOIN tiger_data.IL_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.IL_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_IL_zip_state_loc_place ON tiger_data.IL_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.IL_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
${PSQL} -c "vacuum analyze tiger_data.IL_edges;"
${PSQL} -c "vacuum analyze tiger_data.IL_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.IL_zip_lookup_base(CONSTRAINT pk_IL_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.IL_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'IL', c.name,p.name,'17'  FROM tiger_data.IL_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '17') INNER JOIN tiger_data.IL_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.IL_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.IL_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
${PSQL} -c "CREATE INDEX idx_tiger_data_IL_zip_lookup_base_citysnd ON tiger_data.IL_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_17* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_17*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_17*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IL_addr(CONSTRAINT pk_IL_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.IL_addr ALTER COLUMN statefp SET DEFAULT '17';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IL_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IL_addr'), lower('IL_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.IL_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IL_addr_least_address ON tiger_data.IL_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IL_addr_tlid_statefp ON tiger_data.IL_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IL_addr_zip ON tiger_data.IL_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.IL_zip_state(CONSTRAINT pk_IL_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.IL_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'IL', '17' FROM tiger_data.IL_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.IL_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '17');"
	${PSQL} -c "vacuum analyze tiger_data.IL_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_18_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_18*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_18*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IN_place(CONSTRAINT pk_IN_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_18_place.dbf tiger_staging.in_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IN_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('IN_place'), lower('IN_place')); ALTER TABLE tiger_data.IN_place ADD CONSTRAINT uidx_IN_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_IN_place_soundex_name ON tiger_data.IN_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_IN_place_the_geom_gist ON tiger_data.IN_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.IN_place ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_18_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_18*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_18*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IN_cousub(CONSTRAINT pk_IN_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_IN_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_18_cousub.dbf tiger_staging.in_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IN_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('IN_cousub'), lower('IN_cousub')); ALTER TABLE tiger_data.IN_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
${PSQL} -c "CREATE INDEX tiger_data_IN_cousub_the_geom_gist ON tiger_data.IN_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IN_cousub_countyfp ON tiger_data.IN_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_18_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_18*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_18*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IN_tract(CONSTRAINT pk_IN_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_18_tract.dbf tiger_staging.in_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IN_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('IN_tract'), lower('IN_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_IN_tract_the_geom_gist ON tiger_data.IN_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.IN_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.IN_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_18_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_18*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_18*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IN_tabblock(CONSTRAINT pk_IN_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_18_tabblock.dbf tiger_staging.in_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IN_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('IN_tabblock'), lower('IN_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.IN_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
${PSQL} -c "CREATE INDEX tiger_data_IN_tabblock_the_geom_gist ON tiger_data.IN_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.IN_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_18_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_18*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_18*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IN_bg(CONSTRAINT pk_IN_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_18_bg.dbf tiger_staging.in_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IN_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('IN_bg'), lower('IN_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.IN_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
${PSQL} -c "CREATE INDEX tiger_data_IN_bg_the_geom_gist ON tiger_data.IN_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.IN_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_18* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_18*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_18*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IN_zcta5(CONSTRAINT pk_IN_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_IN_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IN_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IN_zcta510'), lower('IN_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.IN_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
${PSQL} -c "CREATE INDEX tiger_data_IN_zcta5_the_geom_gist ON tiger_data.IN_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_18* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_18*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_18*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IN_faces(CONSTRAINT pk_IN_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IN_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IN_faces'), lower('IN_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_IN_faces_the_geom_gist ON tiger_data.IN_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IN_faces_tfid ON tiger_data.IN_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IN_faces_countyfp ON tiger_data.IN_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.IN_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
	${PSQL} -c "vacuum analyze tiger_data.IN_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_18* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_18*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_18*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IN_featnames(CONSTRAINT pk_IN_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.IN_featnames ALTER COLUMN statefp SET DEFAULT '18';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IN_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IN_featnames'), lower('IN_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_IN_featnames_snd_name ON tiger_data.IN_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_IN_featnames_lname ON tiger_data.IN_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_IN_featnames_tlid_statefp ON tiger_data.IN_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.IN_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
${PSQL} -c "vacuum analyze tiger_data.IN_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_18* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_18*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_18*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IN_edges(CONSTRAINT pk_IN_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IN_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IN_edges'), lower('IN_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.IN_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
${PSQL} -c "CREATE INDEX idx_tiger_data_IN_edges_tlid ON tiger_data.IN_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IN_edgestfidr ON tiger_data.IN_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IN_edges_tfidl ON tiger_data.IN_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IN_edges_countyfp ON tiger_data.IN_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_IN_edges_the_geom_gist ON tiger_data.IN_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IN_edges_zipl ON tiger_data.IN_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.IN_zip_state_loc(CONSTRAINT pk_IN_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.IN_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'IN', '18', p.name FROM tiger_data.IN_edges AS e INNER JOIN tiger_data.IN_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.IN_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_IN_zip_state_loc_place ON tiger_data.IN_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.IN_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
${PSQL} -c "vacuum analyze tiger_data.IN_edges;"
${PSQL} -c "vacuum analyze tiger_data.IN_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.IN_zip_lookup_base(CONSTRAINT pk_IN_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.IN_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'IN', c.name,p.name,'18'  FROM tiger_data.IN_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '18') INNER JOIN tiger_data.IN_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.IN_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.IN_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
${PSQL} -c "CREATE INDEX idx_tiger_data_IN_zip_lookup_base_citysnd ON tiger_data.IN_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_18* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_18*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_18*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IN_addr(CONSTRAINT pk_IN_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.IN_addr ALTER COLUMN statefp SET DEFAULT '18';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IN_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IN_addr'), lower('IN_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.IN_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IN_addr_least_address ON tiger_data.IN_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IN_addr_tlid_statefp ON tiger_data.IN_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IN_addr_zip ON tiger_data.IN_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.IN_zip_state(CONSTRAINT pk_IN_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.IN_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'IN', '18' FROM tiger_data.IN_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.IN_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '18');"
	${PSQL} -c "vacuum analyze tiger_data.IN_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_19_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_19*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_19*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IA_place(CONSTRAINT pk_IA_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_19_place.dbf tiger_staging.ia_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IA_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('IA_place'), lower('IA_place')); ALTER TABLE tiger_data.IA_place ADD CONSTRAINT uidx_IA_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_IA_place_soundex_name ON tiger_data.IA_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_IA_place_the_geom_gist ON tiger_data.IA_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.IA_place ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_19_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_19*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_19*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IA_cousub(CONSTRAINT pk_IA_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_IA_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_19_cousub.dbf tiger_staging.ia_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IA_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('IA_cousub'), lower('IA_cousub')); ALTER TABLE tiger_data.IA_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
${PSQL} -c "CREATE INDEX tiger_data_IA_cousub_the_geom_gist ON tiger_data.IA_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IA_cousub_countyfp ON tiger_data.IA_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_19_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_19*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_19*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IA_tract(CONSTRAINT pk_IA_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_19_tract.dbf tiger_staging.ia_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IA_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('IA_tract'), lower('IA_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_IA_tract_the_geom_gist ON tiger_data.IA_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.IA_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.IA_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_19_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_19*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_19*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IA_tabblock(CONSTRAINT pk_IA_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_19_tabblock.dbf tiger_staging.ia_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IA_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('IA_tabblock'), lower('IA_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.IA_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
${PSQL} -c "CREATE INDEX tiger_data_IA_tabblock_the_geom_gist ON tiger_data.IA_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.IA_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_19_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_19*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_19*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IA_bg(CONSTRAINT pk_IA_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_19_bg.dbf tiger_staging.ia_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.IA_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('IA_bg'), lower('IA_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.IA_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
${PSQL} -c "CREATE INDEX tiger_data_IA_bg_the_geom_gist ON tiger_data.IA_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.IA_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_19* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_19*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_19*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IA_zcta5(CONSTRAINT pk_IA_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_IA_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IA_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IA_zcta510'), lower('IA_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.IA_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
${PSQL} -c "CREATE INDEX tiger_data_IA_zcta5_the_geom_gist ON tiger_data.IA_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_19* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_19*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_19*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IA_faces(CONSTRAINT pk_IA_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IA_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IA_faces'), lower('IA_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_IA_faces_the_geom_gist ON tiger_data.IA_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IA_faces_tfid ON tiger_data.IA_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IA_faces_countyfp ON tiger_data.IA_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.IA_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
	${PSQL} -c "vacuum analyze tiger_data.IA_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_19* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_19*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_19*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IA_featnames(CONSTRAINT pk_IA_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.IA_featnames ALTER COLUMN statefp SET DEFAULT '19';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IA_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IA_featnames'), lower('IA_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_IA_featnames_snd_name ON tiger_data.IA_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_IA_featnames_lname ON tiger_data.IA_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_IA_featnames_tlid_statefp ON tiger_data.IA_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.IA_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
${PSQL} -c "vacuum analyze tiger_data.IA_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_19* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_19*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_19*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IA_edges(CONSTRAINT pk_IA_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IA_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IA_edges'), lower('IA_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.IA_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
${PSQL} -c "CREATE INDEX idx_tiger_data_IA_edges_tlid ON tiger_data.IA_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IA_edgestfidr ON tiger_data.IA_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IA_edges_tfidl ON tiger_data.IA_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IA_edges_countyfp ON tiger_data.IA_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_IA_edges_the_geom_gist ON tiger_data.IA_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_IA_edges_zipl ON tiger_data.IA_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.IA_zip_state_loc(CONSTRAINT pk_IA_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.IA_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'IA', '19', p.name FROM tiger_data.IA_edges AS e INNER JOIN tiger_data.IA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.IA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_IA_zip_state_loc_place ON tiger_data.IA_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.IA_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
${PSQL} -c "vacuum analyze tiger_data.IA_edges;"
${PSQL} -c "vacuum analyze tiger_data.IA_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.IA_zip_lookup_base(CONSTRAINT pk_IA_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.IA_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'IA', c.name,p.name,'19'  FROM tiger_data.IA_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '19') INNER JOIN tiger_data.IA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.IA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.IA_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
${PSQL} -c "CREATE INDEX idx_tiger_data_IA_zip_lookup_base_citysnd ON tiger_data.IA_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_19* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_19*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_19*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.IA_addr(CONSTRAINT pk_IA_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.IA_addr ALTER COLUMN statefp SET DEFAULT '19';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.IA_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('IA_addr'), lower('IA_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.IA_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IA_addr_least_address ON tiger_data.IA_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IA_addr_tlid_statefp ON tiger_data.IA_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_IA_addr_zip ON tiger_data.IA_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.IA_zip_state(CONSTRAINT pk_IA_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.IA_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'IA', '19' FROM tiger_data.IA_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.IA_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '19');"
	${PSQL} -c "vacuum analyze tiger_data.IA_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_20_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_20*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_20*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KS_place(CONSTRAINT pk_KS_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_20_place.dbf tiger_staging.ks_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.KS_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('KS_place'), lower('KS_place')); ALTER TABLE tiger_data.KS_place ADD CONSTRAINT uidx_KS_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_KS_place_soundex_name ON tiger_data.KS_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_KS_place_the_geom_gist ON tiger_data.KS_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.KS_place ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_20_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_20*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_20*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KS_cousub(CONSTRAINT pk_KS_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_KS_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_20_cousub.dbf tiger_staging.ks_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.KS_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('KS_cousub'), lower('KS_cousub')); ALTER TABLE tiger_data.KS_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
${PSQL} -c "CREATE INDEX tiger_data_KS_cousub_the_geom_gist ON tiger_data.KS_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_KS_cousub_countyfp ON tiger_data.KS_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_20_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_20*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_20*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KS_tract(CONSTRAINT pk_KS_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_20_tract.dbf tiger_staging.ks_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.KS_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('KS_tract'), lower('KS_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_KS_tract_the_geom_gist ON tiger_data.KS_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.KS_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.KS_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_20_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_20*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_20*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KS_tabblock(CONSTRAINT pk_KS_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_20_tabblock.dbf tiger_staging.ks_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.KS_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('KS_tabblock'), lower('KS_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.KS_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
${PSQL} -c "CREATE INDEX tiger_data_KS_tabblock_the_geom_gist ON tiger_data.KS_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.KS_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_20_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_20*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_20*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KS_bg(CONSTRAINT pk_KS_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_20_bg.dbf tiger_staging.ks_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.KS_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('KS_bg'), lower('KS_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.KS_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
${PSQL} -c "CREATE INDEX tiger_data_KS_bg_the_geom_gist ON tiger_data.KS_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.KS_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_20* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_20*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_20*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KS_zcta5(CONSTRAINT pk_KS_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_KS_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.KS_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('KS_zcta510'), lower('KS_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.KS_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
${PSQL} -c "CREATE INDEX tiger_data_KS_zcta5_the_geom_gist ON tiger_data.KS_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_20* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_20*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_20*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KS_faces(CONSTRAINT pk_KS_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.KS_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('KS_faces'), lower('KS_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_KS_faces_the_geom_gist ON tiger_data.KS_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_KS_faces_tfid ON tiger_data.KS_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_KS_faces_countyfp ON tiger_data.KS_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.KS_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
	${PSQL} -c "vacuum analyze tiger_data.KS_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_20* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_20*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_20*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KS_featnames(CONSTRAINT pk_KS_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.KS_featnames ALTER COLUMN statefp SET DEFAULT '20';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.KS_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('KS_featnames'), lower('KS_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_KS_featnames_snd_name ON tiger_data.KS_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_KS_featnames_lname ON tiger_data.KS_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_KS_featnames_tlid_statefp ON tiger_data.KS_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.KS_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
${PSQL} -c "vacuum analyze tiger_data.KS_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_20* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_20*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_20*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KS_edges(CONSTRAINT pk_KS_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.KS_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('KS_edges'), lower('KS_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.KS_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
${PSQL} -c "CREATE INDEX idx_tiger_data_KS_edges_tlid ON tiger_data.KS_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_KS_edgestfidr ON tiger_data.KS_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_KS_edges_tfidl ON tiger_data.KS_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_KS_edges_countyfp ON tiger_data.KS_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_KS_edges_the_geom_gist ON tiger_data.KS_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_KS_edges_zipl ON tiger_data.KS_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.KS_zip_state_loc(CONSTRAINT pk_KS_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.KS_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'KS', '20', p.name FROM tiger_data.KS_edges AS e INNER JOIN tiger_data.KS_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.KS_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_KS_zip_state_loc_place ON tiger_data.KS_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.KS_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
${PSQL} -c "vacuum analyze tiger_data.KS_edges;"
${PSQL} -c "vacuum analyze tiger_data.KS_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.KS_zip_lookup_base(CONSTRAINT pk_KS_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.KS_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'KS', c.name,p.name,'20'  FROM tiger_data.KS_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '20') INNER JOIN tiger_data.KS_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.KS_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.KS_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
${PSQL} -c "CREATE INDEX idx_tiger_data_KS_zip_lookup_base_citysnd ON tiger_data.KS_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_20* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_20*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_20*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KS_addr(CONSTRAINT pk_KS_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.KS_addr ALTER COLUMN statefp SET DEFAULT '20';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.KS_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('KS_addr'), lower('KS_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.KS_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_KS_addr_least_address ON tiger_data.KS_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_KS_addr_tlid_statefp ON tiger_data.KS_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_KS_addr_zip ON tiger_data.KS_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.KS_zip_state(CONSTRAINT pk_KS_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.KS_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'KS', '20' FROM tiger_data.KS_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.KS_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '20');"
	${PSQL} -c "vacuum analyze tiger_data.KS_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_21_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_21*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_21*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KY_place(CONSTRAINT pk_KY_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_21_place.dbf tiger_staging.ky_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.KY_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('KY_place'), lower('KY_place')); ALTER TABLE tiger_data.KY_place ADD CONSTRAINT uidx_KY_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_KY_place_soundex_name ON tiger_data.KY_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_KY_place_the_geom_gist ON tiger_data.KY_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.KY_place ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_21_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_21*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_21*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KY_cousub(CONSTRAINT pk_KY_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_KY_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_21_cousub.dbf tiger_staging.ky_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.KY_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('KY_cousub'), lower('KY_cousub')); ALTER TABLE tiger_data.KY_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
${PSQL} -c "CREATE INDEX tiger_data_KY_cousub_the_geom_gist ON tiger_data.KY_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_KY_cousub_countyfp ON tiger_data.KY_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_21_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_21*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_21*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KY_tract(CONSTRAINT pk_KY_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_21_tract.dbf tiger_staging.ky_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.KY_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('KY_tract'), lower('KY_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_KY_tract_the_geom_gist ON tiger_data.KY_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.KY_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.KY_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_21_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_21*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_21*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KY_tabblock(CONSTRAINT pk_KY_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_21_tabblock.dbf tiger_staging.ky_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.KY_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('KY_tabblock'), lower('KY_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.KY_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
${PSQL} -c "CREATE INDEX tiger_data_KY_tabblock_the_geom_gist ON tiger_data.KY_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.KY_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_21_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_21*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_21*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KY_bg(CONSTRAINT pk_KY_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_21_bg.dbf tiger_staging.ky_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.KY_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('KY_bg'), lower('KY_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.KY_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
${PSQL} -c "CREATE INDEX tiger_data_KY_bg_the_geom_gist ON tiger_data.KY_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.KY_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_21* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_21*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_21*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KY_zcta5(CONSTRAINT pk_KY_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_KY_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.KY_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('KY_zcta510'), lower('KY_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.KY_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
${PSQL} -c "CREATE INDEX tiger_data_KY_zcta5_the_geom_gist ON tiger_data.KY_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_21* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_21*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_21*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KY_faces(CONSTRAINT pk_KY_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.KY_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('KY_faces'), lower('KY_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_KY_faces_the_geom_gist ON tiger_data.KY_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_KY_faces_tfid ON tiger_data.KY_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_KY_faces_countyfp ON tiger_data.KY_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.KY_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
	${PSQL} -c "vacuum analyze tiger_data.KY_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_21* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_21*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_21*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KY_featnames(CONSTRAINT pk_KY_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.KY_featnames ALTER COLUMN statefp SET DEFAULT '21';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.KY_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('KY_featnames'), lower('KY_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_KY_featnames_snd_name ON tiger_data.KY_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_KY_featnames_lname ON tiger_data.KY_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_KY_featnames_tlid_statefp ON tiger_data.KY_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.KY_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
${PSQL} -c "vacuum analyze tiger_data.KY_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_21* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_21*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_21*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KY_edges(CONSTRAINT pk_KY_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.KY_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('KY_edges'), lower('KY_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.KY_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
${PSQL} -c "CREATE INDEX idx_tiger_data_KY_edges_tlid ON tiger_data.KY_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_KY_edgestfidr ON tiger_data.KY_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_KY_edges_tfidl ON tiger_data.KY_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_KY_edges_countyfp ON tiger_data.KY_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_KY_edges_the_geom_gist ON tiger_data.KY_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_KY_edges_zipl ON tiger_data.KY_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.KY_zip_state_loc(CONSTRAINT pk_KY_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.KY_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'KY', '21', p.name FROM tiger_data.KY_edges AS e INNER JOIN tiger_data.KY_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.KY_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_KY_zip_state_loc_place ON tiger_data.KY_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.KY_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
${PSQL} -c "vacuum analyze tiger_data.KY_edges;"
${PSQL} -c "vacuum analyze tiger_data.KY_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.KY_zip_lookup_base(CONSTRAINT pk_KY_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.KY_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'KY', c.name,p.name,'21'  FROM tiger_data.KY_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '21') INNER JOIN tiger_data.KY_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.KY_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.KY_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
${PSQL} -c "CREATE INDEX idx_tiger_data_KY_zip_lookup_base_citysnd ON tiger_data.KY_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_21* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_21*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_21*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.KY_addr(CONSTRAINT pk_KY_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.KY_addr ALTER COLUMN statefp SET DEFAULT '21';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.KY_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('KY_addr'), lower('KY_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.KY_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_KY_addr_least_address ON tiger_data.KY_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_KY_addr_tlid_statefp ON tiger_data.KY_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_KY_addr_zip ON tiger_data.KY_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.KY_zip_state(CONSTRAINT pk_KY_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.KY_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'KY', '21' FROM tiger_data.KY_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.KY_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '21');"
	${PSQL} -c "vacuum analyze tiger_data.KY_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_22_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_22*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_22*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.LA_place(CONSTRAINT pk_LA_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_22_place.dbf tiger_staging.la_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.LA_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('LA_place'), lower('LA_place')); ALTER TABLE tiger_data.LA_place ADD CONSTRAINT uidx_LA_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_LA_place_soundex_name ON tiger_data.LA_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_LA_place_the_geom_gist ON tiger_data.LA_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.LA_place ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_22_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_22*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_22*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.LA_cousub(CONSTRAINT pk_LA_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_LA_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_22_cousub.dbf tiger_staging.la_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.LA_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('LA_cousub'), lower('LA_cousub')); ALTER TABLE tiger_data.LA_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
${PSQL} -c "CREATE INDEX tiger_data_LA_cousub_the_geom_gist ON tiger_data.LA_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_LA_cousub_countyfp ON tiger_data.LA_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_22_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_22*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_22*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.LA_tract(CONSTRAINT pk_LA_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_22_tract.dbf tiger_staging.la_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.LA_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('LA_tract'), lower('LA_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_LA_tract_the_geom_gist ON tiger_data.LA_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.LA_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.LA_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_22_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_22*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_22*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.LA_tabblock(CONSTRAINT pk_LA_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_22_tabblock.dbf tiger_staging.la_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.LA_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('LA_tabblock'), lower('LA_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.LA_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
${PSQL} -c "CREATE INDEX tiger_data_LA_tabblock_the_geom_gist ON tiger_data.LA_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.LA_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_22_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_22*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_22*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.LA_bg(CONSTRAINT pk_LA_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_22_bg.dbf tiger_staging.la_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.LA_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('LA_bg'), lower('LA_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.LA_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
${PSQL} -c "CREATE INDEX tiger_data_LA_bg_the_geom_gist ON tiger_data.LA_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.LA_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_22* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_22*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_22*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.LA_zcta5(CONSTRAINT pk_LA_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_LA_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.LA_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('LA_zcta510'), lower('LA_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.LA_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
${PSQL} -c "CREATE INDEX tiger_data_LA_zcta5_the_geom_gist ON tiger_data.LA_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_22* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_22*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_22*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.LA_faces(CONSTRAINT pk_LA_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.LA_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('LA_faces'), lower('LA_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_LA_faces_the_geom_gist ON tiger_data.LA_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_LA_faces_tfid ON tiger_data.LA_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_LA_faces_countyfp ON tiger_data.LA_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.LA_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
	${PSQL} -c "vacuum analyze tiger_data.LA_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_22* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_22*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_22*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.LA_featnames(CONSTRAINT pk_LA_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.LA_featnames ALTER COLUMN statefp SET DEFAULT '22';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.LA_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('LA_featnames'), lower('LA_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_LA_featnames_snd_name ON tiger_data.LA_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_LA_featnames_lname ON tiger_data.LA_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_LA_featnames_tlid_statefp ON tiger_data.LA_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.LA_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
${PSQL} -c "vacuum analyze tiger_data.LA_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_22* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_22*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_22*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.LA_edges(CONSTRAINT pk_LA_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.LA_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('LA_edges'), lower('LA_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.LA_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
${PSQL} -c "CREATE INDEX idx_tiger_data_LA_edges_tlid ON tiger_data.LA_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_LA_edgestfidr ON tiger_data.LA_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_LA_edges_tfidl ON tiger_data.LA_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_LA_edges_countyfp ON tiger_data.LA_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_LA_edges_the_geom_gist ON tiger_data.LA_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_LA_edges_zipl ON tiger_data.LA_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.LA_zip_state_loc(CONSTRAINT pk_LA_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.LA_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'LA', '22', p.name FROM tiger_data.LA_edges AS e INNER JOIN tiger_data.LA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.LA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_LA_zip_state_loc_place ON tiger_data.LA_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.LA_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
${PSQL} -c "vacuum analyze tiger_data.LA_edges;"
${PSQL} -c "vacuum analyze tiger_data.LA_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.LA_zip_lookup_base(CONSTRAINT pk_LA_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.LA_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'LA', c.name,p.name,'22'  FROM tiger_data.LA_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '22') INNER JOIN tiger_data.LA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.LA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.LA_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
${PSQL} -c "CREATE INDEX idx_tiger_data_LA_zip_lookup_base_citysnd ON tiger_data.LA_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_22* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_22*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_22*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.LA_addr(CONSTRAINT pk_LA_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.LA_addr ALTER COLUMN statefp SET DEFAULT '22';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.LA_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('LA_addr'), lower('LA_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.LA_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_LA_addr_least_address ON tiger_data.LA_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_LA_addr_tlid_statefp ON tiger_data.LA_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_LA_addr_zip ON tiger_data.LA_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.LA_zip_state(CONSTRAINT pk_LA_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.LA_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'LA', '22' FROM tiger_data.LA_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.LA_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '22');"
	${PSQL} -c "vacuum analyze tiger_data.LA_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_23_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_23*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_23*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ME_place(CONSTRAINT pk_ME_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_23_place.dbf tiger_staging.me_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ME_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('ME_place'), lower('ME_place')); ALTER TABLE tiger_data.ME_place ADD CONSTRAINT uidx_ME_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_ME_place_soundex_name ON tiger_data.ME_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_ME_place_the_geom_gist ON tiger_data.ME_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.ME_place ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_23_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_23*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_23*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ME_cousub(CONSTRAINT pk_ME_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_ME_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_23_cousub.dbf tiger_staging.me_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ME_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('ME_cousub'), lower('ME_cousub')); ALTER TABLE tiger_data.ME_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
${PSQL} -c "CREATE INDEX tiger_data_ME_cousub_the_geom_gist ON tiger_data.ME_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ME_cousub_countyfp ON tiger_data.ME_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_23_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_23*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_23*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ME_tract(CONSTRAINT pk_ME_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_23_tract.dbf tiger_staging.me_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ME_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('ME_tract'), lower('ME_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_ME_tract_the_geom_gist ON tiger_data.ME_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.ME_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.ME_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_23_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_23*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_23*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ME_tabblock(CONSTRAINT pk_ME_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_23_tabblock.dbf tiger_staging.me_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ME_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('ME_tabblock'), lower('ME_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.ME_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
${PSQL} -c "CREATE INDEX tiger_data_ME_tabblock_the_geom_gist ON tiger_data.ME_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.ME_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_23_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_23*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_23*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ME_bg(CONSTRAINT pk_ME_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_23_bg.dbf tiger_staging.me_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ME_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('ME_bg'), lower('ME_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.ME_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
${PSQL} -c "CREATE INDEX tiger_data_ME_bg_the_geom_gist ON tiger_data.ME_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.ME_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_23* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_23*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_23*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ME_zcta5(CONSTRAINT pk_ME_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_ME_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ME_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ME_zcta510'), lower('ME_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.ME_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
${PSQL} -c "CREATE INDEX tiger_data_ME_zcta5_the_geom_gist ON tiger_data.ME_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_23* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_23*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_23*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ME_faces(CONSTRAINT pk_ME_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ME_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ME_faces'), lower('ME_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_ME_faces_the_geom_gist ON tiger_data.ME_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ME_faces_tfid ON tiger_data.ME_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ME_faces_countyfp ON tiger_data.ME_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.ME_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
	${PSQL} -c "vacuum analyze tiger_data.ME_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_23* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_23*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_23*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ME_featnames(CONSTRAINT pk_ME_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.ME_featnames ALTER COLUMN statefp SET DEFAULT '23';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ME_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ME_featnames'), lower('ME_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_ME_featnames_snd_name ON tiger_data.ME_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_ME_featnames_lname ON tiger_data.ME_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_ME_featnames_tlid_statefp ON tiger_data.ME_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.ME_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
${PSQL} -c "vacuum analyze tiger_data.ME_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_23* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_23*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_23*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ME_edges(CONSTRAINT pk_ME_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ME_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ME_edges'), lower('ME_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.ME_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
${PSQL} -c "CREATE INDEX idx_tiger_data_ME_edges_tlid ON tiger_data.ME_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ME_edgestfidr ON tiger_data.ME_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ME_edges_tfidl ON tiger_data.ME_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ME_edges_countyfp ON tiger_data.ME_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_ME_edges_the_geom_gist ON tiger_data.ME_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ME_edges_zipl ON tiger_data.ME_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.ME_zip_state_loc(CONSTRAINT pk_ME_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.ME_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'ME', '23', p.name FROM tiger_data.ME_edges AS e INNER JOIN tiger_data.ME_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.ME_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_ME_zip_state_loc_place ON tiger_data.ME_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.ME_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
${PSQL} -c "vacuum analyze tiger_data.ME_edges;"
${PSQL} -c "vacuum analyze tiger_data.ME_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.ME_zip_lookup_base(CONSTRAINT pk_ME_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.ME_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'ME', c.name,p.name,'23'  FROM tiger_data.ME_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '23') INNER JOIN tiger_data.ME_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.ME_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.ME_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
${PSQL} -c "CREATE INDEX idx_tiger_data_ME_zip_lookup_base_citysnd ON tiger_data.ME_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_23* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_23*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_23*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ME_addr(CONSTRAINT pk_ME_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.ME_addr ALTER COLUMN statefp SET DEFAULT '23';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ME_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ME_addr'), lower('ME_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.ME_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ME_addr_least_address ON tiger_data.ME_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ME_addr_tlid_statefp ON tiger_data.ME_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ME_addr_zip ON tiger_data.ME_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.ME_zip_state(CONSTRAINT pk_ME_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.ME_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'ME', '23' FROM tiger_data.ME_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.ME_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '23');"
	${PSQL} -c "vacuum analyze tiger_data.ME_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_24_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_24*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_24*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MD_place(CONSTRAINT pk_MD_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_24_place.dbf tiger_staging.md_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MD_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('MD_place'), lower('MD_place')); ALTER TABLE tiger_data.MD_place ADD CONSTRAINT uidx_MD_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_MD_place_soundex_name ON tiger_data.MD_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_MD_place_the_geom_gist ON tiger_data.MD_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.MD_place ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_24_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_24*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_24*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MD_cousub(CONSTRAINT pk_MD_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_MD_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_24_cousub.dbf tiger_staging.md_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MD_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('MD_cousub'), lower('MD_cousub')); ALTER TABLE tiger_data.MD_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
${PSQL} -c "CREATE INDEX tiger_data_MD_cousub_the_geom_gist ON tiger_data.MD_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MD_cousub_countyfp ON tiger_data.MD_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_24_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_24*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_24*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MD_tract(CONSTRAINT pk_MD_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_24_tract.dbf tiger_staging.md_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MD_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('MD_tract'), lower('MD_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_MD_tract_the_geom_gist ON tiger_data.MD_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.MD_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.MD_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_24_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_24*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_24*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MD_tabblock(CONSTRAINT pk_MD_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_24_tabblock.dbf tiger_staging.md_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MD_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('MD_tabblock'), lower('MD_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.MD_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
${PSQL} -c "CREATE INDEX tiger_data_MD_tabblock_the_geom_gist ON tiger_data.MD_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MD_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_24_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_24*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_24*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MD_bg(CONSTRAINT pk_MD_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_24_bg.dbf tiger_staging.md_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MD_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('MD_bg'), lower('MD_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.MD_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
${PSQL} -c "CREATE INDEX tiger_data_MD_bg_the_geom_gist ON tiger_data.MD_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MD_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_24* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_24*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_24*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MD_zcta5(CONSTRAINT pk_MD_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_MD_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MD_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MD_zcta510'), lower('MD_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MD_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
${PSQL} -c "CREATE INDEX tiger_data_MD_zcta5_the_geom_gist ON tiger_data.MD_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_24* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_24*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_24*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MD_faces(CONSTRAINT pk_MD_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MD_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MD_faces'), lower('MD_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_MD_faces_the_geom_gist ON tiger_data.MD_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MD_faces_tfid ON tiger_data.MD_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MD_faces_countyfp ON tiger_data.MD_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.MD_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
	${PSQL} -c "vacuum analyze tiger_data.MD_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_24* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_24*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_24*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MD_featnames(CONSTRAINT pk_MD_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.MD_featnames ALTER COLUMN statefp SET DEFAULT '24';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MD_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MD_featnames'), lower('MD_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_MD_featnames_snd_name ON tiger_data.MD_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MD_featnames_lname ON tiger_data.MD_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MD_featnames_tlid_statefp ON tiger_data.MD_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.MD_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
${PSQL} -c "vacuum analyze tiger_data.MD_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_24* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_24*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_24*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MD_edges(CONSTRAINT pk_MD_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MD_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MD_edges'), lower('MD_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MD_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MD_edges_tlid ON tiger_data.MD_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MD_edgestfidr ON tiger_data.MD_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MD_edges_tfidl ON tiger_data.MD_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MD_edges_countyfp ON tiger_data.MD_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_MD_edges_the_geom_gist ON tiger_data.MD_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MD_edges_zipl ON tiger_data.MD_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.MD_zip_state_loc(CONSTRAINT pk_MD_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.MD_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'MD', '24', p.name FROM tiger_data.MD_edges AS e INNER JOIN tiger_data.MD_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MD_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_MD_zip_state_loc_place ON tiger_data.MD_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.MD_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
${PSQL} -c "vacuum analyze tiger_data.MD_edges;"
${PSQL} -c "vacuum analyze tiger_data.MD_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.MD_zip_lookup_base(CONSTRAINT pk_MD_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.MD_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'MD', c.name,p.name,'24'  FROM tiger_data.MD_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '24') INNER JOIN tiger_data.MD_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MD_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.MD_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MD_zip_lookup_base_citysnd ON tiger_data.MD_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_24* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_24*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_24*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MD_addr(CONSTRAINT pk_MD_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.MD_addr ALTER COLUMN statefp SET DEFAULT '24';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MD_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MD_addr'), lower('MD_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MD_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MD_addr_least_address ON tiger_data.MD_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MD_addr_tlid_statefp ON tiger_data.MD_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MD_addr_zip ON tiger_data.MD_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.MD_zip_state(CONSTRAINT pk_MD_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.MD_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'MD', '24' FROM tiger_data.MD_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.MD_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '24');"
	${PSQL} -c "vacuum analyze tiger_data.MD_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_25_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_25*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_25*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MA_place(CONSTRAINT pk_MA_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_25_place.dbf tiger_staging.ma_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MA_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('MA_place'), lower('MA_place')); ALTER TABLE tiger_data.MA_place ADD CONSTRAINT uidx_MA_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_MA_place_soundex_name ON tiger_data.MA_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_MA_place_the_geom_gist ON tiger_data.MA_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.MA_place ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_25_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_25*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_25*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MA_cousub(CONSTRAINT pk_MA_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_MA_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_25_cousub.dbf tiger_staging.ma_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MA_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('MA_cousub'), lower('MA_cousub')); ALTER TABLE tiger_data.MA_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
${PSQL} -c "CREATE INDEX tiger_data_MA_cousub_the_geom_gist ON tiger_data.MA_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MA_cousub_countyfp ON tiger_data.MA_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_25_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_25*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_25*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MA_tract(CONSTRAINT pk_MA_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_25_tract.dbf tiger_staging.ma_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MA_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('MA_tract'), lower('MA_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_MA_tract_the_geom_gist ON tiger_data.MA_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.MA_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.MA_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_25_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_25*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_25*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MA_tabblock(CONSTRAINT pk_MA_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_25_tabblock.dbf tiger_staging.ma_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MA_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('MA_tabblock'), lower('MA_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.MA_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
${PSQL} -c "CREATE INDEX tiger_data_MA_tabblock_the_geom_gist ON tiger_data.MA_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MA_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_25_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_25*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_25*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MA_bg(CONSTRAINT pk_MA_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_25_bg.dbf tiger_staging.ma_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MA_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('MA_bg'), lower('MA_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.MA_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
${PSQL} -c "CREATE INDEX tiger_data_MA_bg_the_geom_gist ON tiger_data.MA_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MA_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_25* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_25*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_25*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MA_zcta5(CONSTRAINT pk_MA_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_MA_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MA_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MA_zcta510'), lower('MA_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MA_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
${PSQL} -c "CREATE INDEX tiger_data_MA_zcta5_the_geom_gist ON tiger_data.MA_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_25* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_25*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_25*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MA_faces(CONSTRAINT pk_MA_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MA_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MA_faces'), lower('MA_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_MA_faces_the_geom_gist ON tiger_data.MA_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MA_faces_tfid ON tiger_data.MA_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MA_faces_countyfp ON tiger_data.MA_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.MA_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
	${PSQL} -c "vacuum analyze tiger_data.MA_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_25* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_25*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_25*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MA_featnames(CONSTRAINT pk_MA_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.MA_featnames ALTER COLUMN statefp SET DEFAULT '25';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MA_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MA_featnames'), lower('MA_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_MA_featnames_snd_name ON tiger_data.MA_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MA_featnames_lname ON tiger_data.MA_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MA_featnames_tlid_statefp ON tiger_data.MA_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.MA_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
${PSQL} -c "vacuum analyze tiger_data.MA_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_25* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_25*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_25*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MA_edges(CONSTRAINT pk_MA_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MA_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MA_edges'), lower('MA_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MA_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MA_edges_tlid ON tiger_data.MA_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MA_edgestfidr ON tiger_data.MA_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MA_edges_tfidl ON tiger_data.MA_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MA_edges_countyfp ON tiger_data.MA_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_MA_edges_the_geom_gist ON tiger_data.MA_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MA_edges_zipl ON tiger_data.MA_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.MA_zip_state_loc(CONSTRAINT pk_MA_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.MA_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'MA', '25', p.name FROM tiger_data.MA_edges AS e INNER JOIN tiger_data.MA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_MA_zip_state_loc_place ON tiger_data.MA_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.MA_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
${PSQL} -c "vacuum analyze tiger_data.MA_edges;"
${PSQL} -c "vacuum analyze tiger_data.MA_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.MA_zip_lookup_base(CONSTRAINT pk_MA_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.MA_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'MA', c.name,p.name,'25'  FROM tiger_data.MA_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '25') INNER JOIN tiger_data.MA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.MA_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MA_zip_lookup_base_citysnd ON tiger_data.MA_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_25* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_25*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_25*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MA_addr(CONSTRAINT pk_MA_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.MA_addr ALTER COLUMN statefp SET DEFAULT '25';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MA_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MA_addr'), lower('MA_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MA_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MA_addr_least_address ON tiger_data.MA_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MA_addr_tlid_statefp ON tiger_data.MA_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MA_addr_zip ON tiger_data.MA_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.MA_zip_state(CONSTRAINT pk_MA_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.MA_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'MA', '25' FROM tiger_data.MA_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.MA_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '25');"
	${PSQL} -c "vacuum analyze tiger_data.MA_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_26_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_26*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_26*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MI_place(CONSTRAINT pk_MI_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_26_place.dbf tiger_staging.mi_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MI_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('MI_place'), lower('MI_place')); ALTER TABLE tiger_data.MI_place ADD CONSTRAINT uidx_MI_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_MI_place_soundex_name ON tiger_data.MI_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_MI_place_the_geom_gist ON tiger_data.MI_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.MI_place ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_26_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_26*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_26*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MI_cousub(CONSTRAINT pk_MI_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_MI_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_26_cousub.dbf tiger_staging.mi_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MI_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('MI_cousub'), lower('MI_cousub')); ALTER TABLE tiger_data.MI_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
${PSQL} -c "CREATE INDEX tiger_data_MI_cousub_the_geom_gist ON tiger_data.MI_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MI_cousub_countyfp ON tiger_data.MI_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_26_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_26*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_26*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MI_tract(CONSTRAINT pk_MI_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_26_tract.dbf tiger_staging.mi_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MI_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('MI_tract'), lower('MI_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_MI_tract_the_geom_gist ON tiger_data.MI_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.MI_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.MI_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_26_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_26*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_26*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MI_tabblock(CONSTRAINT pk_MI_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_26_tabblock.dbf tiger_staging.mi_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MI_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('MI_tabblock'), lower('MI_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.MI_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
${PSQL} -c "CREATE INDEX tiger_data_MI_tabblock_the_geom_gist ON tiger_data.MI_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MI_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_26_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_26*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_26*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MI_bg(CONSTRAINT pk_MI_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_26_bg.dbf tiger_staging.mi_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MI_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('MI_bg'), lower('MI_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.MI_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
${PSQL} -c "CREATE INDEX tiger_data_MI_bg_the_geom_gist ON tiger_data.MI_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MI_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_26* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_26*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_26*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MI_zcta5(CONSTRAINT pk_MI_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_MI_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MI_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MI_zcta510'), lower('MI_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MI_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
${PSQL} -c "CREATE INDEX tiger_data_MI_zcta5_the_geom_gist ON tiger_data.MI_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_26* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_26*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_26*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MI_faces(CONSTRAINT pk_MI_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MI_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MI_faces'), lower('MI_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_MI_faces_the_geom_gist ON tiger_data.MI_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MI_faces_tfid ON tiger_data.MI_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MI_faces_countyfp ON tiger_data.MI_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.MI_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
	${PSQL} -c "vacuum analyze tiger_data.MI_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_26* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_26*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_26*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MI_featnames(CONSTRAINT pk_MI_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.MI_featnames ALTER COLUMN statefp SET DEFAULT '26';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MI_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MI_featnames'), lower('MI_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_MI_featnames_snd_name ON tiger_data.MI_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MI_featnames_lname ON tiger_data.MI_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MI_featnames_tlid_statefp ON tiger_data.MI_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.MI_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
${PSQL} -c "vacuum analyze tiger_data.MI_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_26* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_26*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_26*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MI_edges(CONSTRAINT pk_MI_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MI_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MI_edges'), lower('MI_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MI_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MI_edges_tlid ON tiger_data.MI_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MI_edgestfidr ON tiger_data.MI_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MI_edges_tfidl ON tiger_data.MI_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MI_edges_countyfp ON tiger_data.MI_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_MI_edges_the_geom_gist ON tiger_data.MI_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MI_edges_zipl ON tiger_data.MI_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.MI_zip_state_loc(CONSTRAINT pk_MI_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.MI_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'MI', '26', p.name FROM tiger_data.MI_edges AS e INNER JOIN tiger_data.MI_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MI_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_MI_zip_state_loc_place ON tiger_data.MI_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.MI_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
${PSQL} -c "vacuum analyze tiger_data.MI_edges;"
${PSQL} -c "vacuum analyze tiger_data.MI_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.MI_zip_lookup_base(CONSTRAINT pk_MI_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.MI_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'MI', c.name,p.name,'26'  FROM tiger_data.MI_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '26') INNER JOIN tiger_data.MI_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MI_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.MI_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MI_zip_lookup_base_citysnd ON tiger_data.MI_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_26* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_26*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_26*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MI_addr(CONSTRAINT pk_MI_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.MI_addr ALTER COLUMN statefp SET DEFAULT '26';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MI_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MI_addr'), lower('MI_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MI_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MI_addr_least_address ON tiger_data.MI_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MI_addr_tlid_statefp ON tiger_data.MI_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MI_addr_zip ON tiger_data.MI_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.MI_zip_state(CONSTRAINT pk_MI_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.MI_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'MI', '26' FROM tiger_data.MI_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.MI_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '26');"
	${PSQL} -c "vacuum analyze tiger_data.MI_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_27_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_27*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_27*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MN_place(CONSTRAINT pk_MN_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_27_place.dbf tiger_staging.mn_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MN_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('MN_place'), lower('MN_place')); ALTER TABLE tiger_data.MN_place ADD CONSTRAINT uidx_MN_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_MN_place_soundex_name ON tiger_data.MN_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_MN_place_the_geom_gist ON tiger_data.MN_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.MN_place ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_27_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_27*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_27*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MN_cousub(CONSTRAINT pk_MN_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_MN_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_27_cousub.dbf tiger_staging.mn_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MN_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('MN_cousub'), lower('MN_cousub')); ALTER TABLE tiger_data.MN_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
${PSQL} -c "CREATE INDEX tiger_data_MN_cousub_the_geom_gist ON tiger_data.MN_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MN_cousub_countyfp ON tiger_data.MN_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_27_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_27*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_27*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MN_tract(CONSTRAINT pk_MN_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_27_tract.dbf tiger_staging.mn_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MN_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('MN_tract'), lower('MN_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_MN_tract_the_geom_gist ON tiger_data.MN_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.MN_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.MN_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_27_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_27*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_27*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MN_tabblock(CONSTRAINT pk_MN_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_27_tabblock.dbf tiger_staging.mn_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MN_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('MN_tabblock'), lower('MN_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.MN_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
${PSQL} -c "CREATE INDEX tiger_data_MN_tabblock_the_geom_gist ON tiger_data.MN_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MN_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_27_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_27*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_27*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MN_bg(CONSTRAINT pk_MN_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_27_bg.dbf tiger_staging.mn_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MN_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('MN_bg'), lower('MN_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.MN_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
${PSQL} -c "CREATE INDEX tiger_data_MN_bg_the_geom_gist ON tiger_data.MN_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MN_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_27* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_27*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_27*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MN_zcta5(CONSTRAINT pk_MN_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_MN_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MN_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MN_zcta510'), lower('MN_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MN_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
${PSQL} -c "CREATE INDEX tiger_data_MN_zcta5_the_geom_gist ON tiger_data.MN_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_27* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_27*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_27*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MN_faces(CONSTRAINT pk_MN_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MN_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MN_faces'), lower('MN_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_MN_faces_the_geom_gist ON tiger_data.MN_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MN_faces_tfid ON tiger_data.MN_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MN_faces_countyfp ON tiger_data.MN_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.MN_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
	${PSQL} -c "vacuum analyze tiger_data.MN_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_27* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_27*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_27*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MN_featnames(CONSTRAINT pk_MN_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.MN_featnames ALTER COLUMN statefp SET DEFAULT '27';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MN_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MN_featnames'), lower('MN_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_MN_featnames_snd_name ON tiger_data.MN_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MN_featnames_lname ON tiger_data.MN_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MN_featnames_tlid_statefp ON tiger_data.MN_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.MN_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
${PSQL} -c "vacuum analyze tiger_data.MN_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_27* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_27*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_27*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MN_edges(CONSTRAINT pk_MN_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MN_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MN_edges'), lower('MN_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MN_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MN_edges_tlid ON tiger_data.MN_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MN_edgestfidr ON tiger_data.MN_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MN_edges_tfidl ON tiger_data.MN_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MN_edges_countyfp ON tiger_data.MN_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_MN_edges_the_geom_gist ON tiger_data.MN_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MN_edges_zipl ON tiger_data.MN_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.MN_zip_state_loc(CONSTRAINT pk_MN_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.MN_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'MN', '27', p.name FROM tiger_data.MN_edges AS e INNER JOIN tiger_data.MN_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MN_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_MN_zip_state_loc_place ON tiger_data.MN_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.MN_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
${PSQL} -c "vacuum analyze tiger_data.MN_edges;"
${PSQL} -c "vacuum analyze tiger_data.MN_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.MN_zip_lookup_base(CONSTRAINT pk_MN_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.MN_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'MN', c.name,p.name,'27'  FROM tiger_data.MN_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '27') INNER JOIN tiger_data.MN_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MN_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.MN_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MN_zip_lookup_base_citysnd ON tiger_data.MN_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_27* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_27*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_27*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MN_addr(CONSTRAINT pk_MN_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.MN_addr ALTER COLUMN statefp SET DEFAULT '27';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MN_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MN_addr'), lower('MN_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MN_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MN_addr_least_address ON tiger_data.MN_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MN_addr_tlid_statefp ON tiger_data.MN_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MN_addr_zip ON tiger_data.MN_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.MN_zip_state(CONSTRAINT pk_MN_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.MN_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'MN', '27' FROM tiger_data.MN_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.MN_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '27');"
	${PSQL} -c "vacuum analyze tiger_data.MN_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_28_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_28*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_28*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MS_place(CONSTRAINT pk_MS_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_28_place.dbf tiger_staging.ms_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MS_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('MS_place'), lower('MS_place')); ALTER TABLE tiger_data.MS_place ADD CONSTRAINT uidx_MS_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_MS_place_soundex_name ON tiger_data.MS_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_MS_place_the_geom_gist ON tiger_data.MS_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.MS_place ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_28_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_28*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_28*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MS_cousub(CONSTRAINT pk_MS_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_MS_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_28_cousub.dbf tiger_staging.ms_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MS_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('MS_cousub'), lower('MS_cousub')); ALTER TABLE tiger_data.MS_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
${PSQL} -c "CREATE INDEX tiger_data_MS_cousub_the_geom_gist ON tiger_data.MS_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MS_cousub_countyfp ON tiger_data.MS_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_28_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_28*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_28*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MS_tract(CONSTRAINT pk_MS_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_28_tract.dbf tiger_staging.ms_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MS_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('MS_tract'), lower('MS_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_MS_tract_the_geom_gist ON tiger_data.MS_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.MS_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.MS_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_28_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_28*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_28*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MS_tabblock(CONSTRAINT pk_MS_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_28_tabblock.dbf tiger_staging.ms_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MS_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('MS_tabblock'), lower('MS_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.MS_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
${PSQL} -c "CREATE INDEX tiger_data_MS_tabblock_the_geom_gist ON tiger_data.MS_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MS_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_28_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_28*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_28*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MS_bg(CONSTRAINT pk_MS_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_28_bg.dbf tiger_staging.ms_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MS_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('MS_bg'), lower('MS_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.MS_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
${PSQL} -c "CREATE INDEX tiger_data_MS_bg_the_geom_gist ON tiger_data.MS_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MS_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_28* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_28*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_28*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MS_zcta5(CONSTRAINT pk_MS_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_MS_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MS_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MS_zcta510'), lower('MS_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MS_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
${PSQL} -c "CREATE INDEX tiger_data_MS_zcta5_the_geom_gist ON tiger_data.MS_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_28* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_28*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_28*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MS_faces(CONSTRAINT pk_MS_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MS_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MS_faces'), lower('MS_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_MS_faces_the_geom_gist ON tiger_data.MS_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MS_faces_tfid ON tiger_data.MS_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MS_faces_countyfp ON tiger_data.MS_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.MS_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
	${PSQL} -c "vacuum analyze tiger_data.MS_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_28* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_28*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_28*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MS_featnames(CONSTRAINT pk_MS_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.MS_featnames ALTER COLUMN statefp SET DEFAULT '28';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MS_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MS_featnames'), lower('MS_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_MS_featnames_snd_name ON tiger_data.MS_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MS_featnames_lname ON tiger_data.MS_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MS_featnames_tlid_statefp ON tiger_data.MS_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.MS_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
${PSQL} -c "vacuum analyze tiger_data.MS_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_28* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_28*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_28*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MS_edges(CONSTRAINT pk_MS_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MS_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MS_edges'), lower('MS_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MS_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MS_edges_tlid ON tiger_data.MS_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MS_edgestfidr ON tiger_data.MS_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MS_edges_tfidl ON tiger_data.MS_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MS_edges_countyfp ON tiger_data.MS_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_MS_edges_the_geom_gist ON tiger_data.MS_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MS_edges_zipl ON tiger_data.MS_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.MS_zip_state_loc(CONSTRAINT pk_MS_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.MS_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'MS', '28', p.name FROM tiger_data.MS_edges AS e INNER JOIN tiger_data.MS_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MS_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_MS_zip_state_loc_place ON tiger_data.MS_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.MS_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
${PSQL} -c "vacuum analyze tiger_data.MS_edges;"
${PSQL} -c "vacuum analyze tiger_data.MS_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.MS_zip_lookup_base(CONSTRAINT pk_MS_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.MS_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'MS', c.name,p.name,'28'  FROM tiger_data.MS_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '28') INNER JOIN tiger_data.MS_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MS_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.MS_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MS_zip_lookup_base_citysnd ON tiger_data.MS_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_28* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_28*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_28*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MS_addr(CONSTRAINT pk_MS_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.MS_addr ALTER COLUMN statefp SET DEFAULT '28';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MS_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MS_addr'), lower('MS_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MS_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MS_addr_least_address ON tiger_data.MS_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MS_addr_tlid_statefp ON tiger_data.MS_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MS_addr_zip ON tiger_data.MS_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.MS_zip_state(CONSTRAINT pk_MS_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.MS_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'MS', '28' FROM tiger_data.MS_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.MS_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '28');"
	${PSQL} -c "vacuum analyze tiger_data.MS_addr;"











cd /gisdata

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_29_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_29*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_29*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MO_place(CONSTRAINT pk_MO_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_29_place.dbf tiger_staging.mo_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MO_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('MO_place'), lower('MO_place')); ALTER TABLE tiger_data.MO_place ADD CONSTRAINT uidx_MO_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_MO_place_soundex_name ON tiger_data.MO_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_MO_place_the_geom_gist ON tiger_data.MO_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.MO_place ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_29_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_29*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_29*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MO_cousub(CONSTRAINT pk_MO_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_MO_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_29_cousub.dbf tiger_staging.mo_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MO_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('MO_cousub'), lower('MO_cousub')); ALTER TABLE tiger_data.MO_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
${PSQL} -c "CREATE INDEX tiger_data_MO_cousub_the_geom_gist ON tiger_data.MO_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MO_cousub_countyfp ON tiger_data.MO_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_29_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_29*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_29*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MO_tract(CONSTRAINT pk_MO_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_29_tract.dbf tiger_staging.mo_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MO_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('MO_tract'), lower('MO_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_MO_tract_the_geom_gist ON tiger_data.MO_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.MO_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.MO_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_29_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_29*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_29*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MO_tabblock(CONSTRAINT pk_MO_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_29_tabblock.dbf tiger_staging.mo_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MO_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('MO_tabblock'), lower('MO_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.MO_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
${PSQL} -c "CREATE INDEX tiger_data_MO_tabblock_the_geom_gist ON tiger_data.MO_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MO_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_29_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_29*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_29*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MO_bg(CONSTRAINT pk_MO_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_29_bg.dbf tiger_staging.mo_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MO_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('MO_bg'), lower('MO_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.MO_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
${PSQL} -c "CREATE INDEX tiger_data_MO_bg_the_geom_gist ON tiger_data.MO_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MO_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_29* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_29*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_29*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MO_zcta5(CONSTRAINT pk_MO_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_MO_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MO_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MO_zcta510'), lower('MO_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MO_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
${PSQL} -c "CREATE INDEX tiger_data_MO_zcta5_the_geom_gist ON tiger_data.MO_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_29* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_29*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_29*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MO_faces(CONSTRAINT pk_MO_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MO_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MO_faces'), lower('MO_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_MO_faces_the_geom_gist ON tiger_data.MO_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MO_faces_tfid ON tiger_data.MO_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MO_faces_countyfp ON tiger_data.MO_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.MO_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
	${PSQL} -c "vacuum analyze tiger_data.MO_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_29* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_29*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_29*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MO_featnames(CONSTRAINT pk_MO_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.MO_featnames ALTER COLUMN statefp SET DEFAULT '29';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MO_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MO_featnames'), lower('MO_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_MO_featnames_snd_name ON tiger_data.MO_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MO_featnames_lname ON tiger_data.MO_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MO_featnames_tlid_statefp ON tiger_data.MO_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.MO_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
${PSQL} -c "vacuum analyze tiger_data.MO_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_29* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_29*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_29*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MO_edges(CONSTRAINT pk_MO_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MO_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MO_edges'), lower('MO_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MO_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MO_edges_tlid ON tiger_data.MO_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MO_edgestfidr ON tiger_data.MO_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MO_edges_tfidl ON tiger_data.MO_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MO_edges_countyfp ON tiger_data.MO_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_MO_edges_the_geom_gist ON tiger_data.MO_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MO_edges_zipl ON tiger_data.MO_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.MO_zip_state_loc(CONSTRAINT pk_MO_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.MO_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'MO', '29', p.name FROM tiger_data.MO_edges AS e INNER JOIN tiger_data.MO_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MO_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_MO_zip_state_loc_place ON tiger_data.MO_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.MO_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
${PSQL} -c "vacuum analyze tiger_data.MO_edges;"
${PSQL} -c "vacuum analyze tiger_data.MO_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.MO_zip_lookup_base(CONSTRAINT pk_MO_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.MO_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'MO', c.name,p.name,'29'  FROM tiger_data.MO_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '29') INNER JOIN tiger_data.MO_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MO_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.MO_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MO_zip_lookup_base_citysnd ON tiger_data.MO_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_29* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_29*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_29*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MO_addr(CONSTRAINT pk_MO_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.MO_addr ALTER COLUMN statefp SET DEFAULT '29';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MO_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MO_addr'), lower('MO_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MO_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MO_addr_least_address ON tiger_data.MO_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MO_addr_tlid_statefp ON tiger_data.MO_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MO_addr_zip ON tiger_data.MO_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.MO_zip_state(CONSTRAINT pk_MO_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.MO_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'MO', '29' FROM tiger_data.MO_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.MO_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '29');"
	${PSQL} -c "vacuum analyze tiger_data.MO_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_30_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_30*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_30*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MT_place(CONSTRAINT pk_MT_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_30_place.dbf tiger_staging.mt_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MT_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('MT_place'), lower('MT_place')); ALTER TABLE tiger_data.MT_place ADD CONSTRAINT uidx_MT_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_MT_place_soundex_name ON tiger_data.MT_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_MT_place_the_geom_gist ON tiger_data.MT_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.MT_place ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_30_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_30*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_30*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MT_cousub(CONSTRAINT pk_MT_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_MT_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_30_cousub.dbf tiger_staging.mt_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MT_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('MT_cousub'), lower('MT_cousub')); ALTER TABLE tiger_data.MT_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
${PSQL} -c "CREATE INDEX tiger_data_MT_cousub_the_geom_gist ON tiger_data.MT_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MT_cousub_countyfp ON tiger_data.MT_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_30_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_30*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_30*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MT_tract(CONSTRAINT pk_MT_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_30_tract.dbf tiger_staging.mt_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MT_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('MT_tract'), lower('MT_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_MT_tract_the_geom_gist ON tiger_data.MT_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.MT_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.MT_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_30_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_30*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_30*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MT_tabblock(CONSTRAINT pk_MT_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_30_tabblock.dbf tiger_staging.mt_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MT_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('MT_tabblock'), lower('MT_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.MT_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
${PSQL} -c "CREATE INDEX tiger_data_MT_tabblock_the_geom_gist ON tiger_data.MT_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MT_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_30_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_30*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_30*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MT_bg(CONSTRAINT pk_MT_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_30_bg.dbf tiger_staging.mt_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.MT_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('MT_bg'), lower('MT_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.MT_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
${PSQL} -c "CREATE INDEX tiger_data_MT_bg_the_geom_gist ON tiger_data.MT_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.MT_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_30* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_30*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_30*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MT_zcta5(CONSTRAINT pk_MT_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_MT_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MT_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MT_zcta510'), lower('MT_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MT_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
${PSQL} -c "CREATE INDEX tiger_data_MT_zcta5_the_geom_gist ON tiger_data.MT_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_30* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_30*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_30*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MT_faces(CONSTRAINT pk_MT_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MT_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MT_faces'), lower('MT_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_MT_faces_the_geom_gist ON tiger_data.MT_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MT_faces_tfid ON tiger_data.MT_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MT_faces_countyfp ON tiger_data.MT_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.MT_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
	${PSQL} -c "vacuum analyze tiger_data.MT_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_30* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_30*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_30*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MT_featnames(CONSTRAINT pk_MT_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.MT_featnames ALTER COLUMN statefp SET DEFAULT '30';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MT_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MT_featnames'), lower('MT_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_MT_featnames_snd_name ON tiger_data.MT_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MT_featnames_lname ON tiger_data.MT_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_MT_featnames_tlid_statefp ON tiger_data.MT_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.MT_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
${PSQL} -c "vacuum analyze tiger_data.MT_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_30* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_30*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_30*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MT_edges(CONSTRAINT pk_MT_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MT_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MT_edges'), lower('MT_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MT_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MT_edges_tlid ON tiger_data.MT_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MT_edgestfidr ON tiger_data.MT_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MT_edges_tfidl ON tiger_data.MT_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MT_edges_countyfp ON tiger_data.MT_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_MT_edges_the_geom_gist ON tiger_data.MT_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_MT_edges_zipl ON tiger_data.MT_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.MT_zip_state_loc(CONSTRAINT pk_MT_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.MT_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'MT', '30', p.name FROM tiger_data.MT_edges AS e INNER JOIN tiger_data.MT_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MT_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_MT_zip_state_loc_place ON tiger_data.MT_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.MT_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
${PSQL} -c "vacuum analyze tiger_data.MT_edges;"
${PSQL} -c "vacuum analyze tiger_data.MT_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.MT_zip_lookup_base(CONSTRAINT pk_MT_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.MT_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'MT', c.name,p.name,'30'  FROM tiger_data.MT_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '30') INNER JOIN tiger_data.MT_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.MT_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.MT_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
${PSQL} -c "CREATE INDEX idx_tiger_data_MT_zip_lookup_base_citysnd ON tiger_data.MT_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_30* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_30*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_30*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.MT_addr(CONSTRAINT pk_MT_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.MT_addr ALTER COLUMN statefp SET DEFAULT '30';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.MT_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('MT_addr'), lower('MT_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.MT_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MT_addr_least_address ON tiger_data.MT_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MT_addr_tlid_statefp ON tiger_data.MT_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_MT_addr_zip ON tiger_data.MT_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.MT_zip_state(CONSTRAINT pk_MT_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.MT_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'MT', '30' FROM tiger_data.MT_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.MT_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '30');"
	${PSQL} -c "vacuum analyze tiger_data.MT_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_31_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_31*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_31*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NE_place(CONSTRAINT pk_NE_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_31_place.dbf tiger_staging.ne_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NE_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('NE_place'), lower('NE_place')); ALTER TABLE tiger_data.NE_place ADD CONSTRAINT uidx_NE_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_NE_place_soundex_name ON tiger_data.NE_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_NE_place_the_geom_gist ON tiger_data.NE_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.NE_place ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_31_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_31*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_31*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NE_cousub(CONSTRAINT pk_NE_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_NE_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_31_cousub.dbf tiger_staging.ne_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NE_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('NE_cousub'), lower('NE_cousub')); ALTER TABLE tiger_data.NE_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
${PSQL} -c "CREATE INDEX tiger_data_NE_cousub_the_geom_gist ON tiger_data.NE_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NE_cousub_countyfp ON tiger_data.NE_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_31_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_31*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_31*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NE_tract(CONSTRAINT pk_NE_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_31_tract.dbf tiger_staging.ne_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NE_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('NE_tract'), lower('NE_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_NE_tract_the_geom_gist ON tiger_data.NE_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.NE_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.NE_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_31_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_31*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_31*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NE_tabblock(CONSTRAINT pk_NE_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_31_tabblock.dbf tiger_staging.ne_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NE_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('NE_tabblock'), lower('NE_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.NE_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
${PSQL} -c "CREATE INDEX tiger_data_NE_tabblock_the_geom_gist ON tiger_data.NE_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NE_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_31_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_31*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_31*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NE_bg(CONSTRAINT pk_NE_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_31_bg.dbf tiger_staging.ne_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NE_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('NE_bg'), lower('NE_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.NE_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
${PSQL} -c "CREATE INDEX tiger_data_NE_bg_the_geom_gist ON tiger_data.NE_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NE_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_31* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_31*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_31*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NE_zcta5(CONSTRAINT pk_NE_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_NE_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NE_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NE_zcta510'), lower('NE_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NE_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
${PSQL} -c "CREATE INDEX tiger_data_NE_zcta5_the_geom_gist ON tiger_data.NE_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_31* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_31*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_31*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NE_faces(CONSTRAINT pk_NE_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NE_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NE_faces'), lower('NE_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_NE_faces_the_geom_gist ON tiger_data.NE_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NE_faces_tfid ON tiger_data.NE_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NE_faces_countyfp ON tiger_data.NE_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.NE_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
	${PSQL} -c "vacuum analyze tiger_data.NE_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_31* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_31*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_31*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NE_featnames(CONSTRAINT pk_NE_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.NE_featnames ALTER COLUMN statefp SET DEFAULT '31';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NE_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NE_featnames'), lower('NE_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_NE_featnames_snd_name ON tiger_data.NE_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NE_featnames_lname ON tiger_data.NE_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NE_featnames_tlid_statefp ON tiger_data.NE_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.NE_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
${PSQL} -c "vacuum analyze tiger_data.NE_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_31* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_31*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_31*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NE_edges(CONSTRAINT pk_NE_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NE_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NE_edges'), lower('NE_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NE_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NE_edges_tlid ON tiger_data.NE_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NE_edgestfidr ON tiger_data.NE_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NE_edges_tfidl ON tiger_data.NE_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NE_edges_countyfp ON tiger_data.NE_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_NE_edges_the_geom_gist ON tiger_data.NE_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NE_edges_zipl ON tiger_data.NE_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.NE_zip_state_loc(CONSTRAINT pk_NE_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.NE_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'NE', '31', p.name FROM tiger_data.NE_edges AS e INNER JOIN tiger_data.NE_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NE_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_NE_zip_state_loc_place ON tiger_data.NE_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.NE_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
${PSQL} -c "vacuum analyze tiger_data.NE_edges;"
${PSQL} -c "vacuum analyze tiger_data.NE_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.NE_zip_lookup_base(CONSTRAINT pk_NE_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.NE_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'NE', c.name,p.name,'31'  FROM tiger_data.NE_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '31') INNER JOIN tiger_data.NE_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NE_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.NE_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NE_zip_lookup_base_citysnd ON tiger_data.NE_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_31* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_31*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_31*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NE_addr(CONSTRAINT pk_NE_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.NE_addr ALTER COLUMN statefp SET DEFAULT '31';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NE_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NE_addr'), lower('NE_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NE_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NE_addr_least_address ON tiger_data.NE_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NE_addr_tlid_statefp ON tiger_data.NE_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NE_addr_zip ON tiger_data.NE_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.NE_zip_state(CONSTRAINT pk_NE_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.NE_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'NE', '31' FROM tiger_data.NE_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.NE_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '31');"
	${PSQL} -c "vacuum analyze tiger_data.NE_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_32_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_32*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_32*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NV_place(CONSTRAINT pk_NV_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_32_place.dbf tiger_staging.nv_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NV_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('NV_place'), lower('NV_place')); ALTER TABLE tiger_data.NV_place ADD CONSTRAINT uidx_NV_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_NV_place_soundex_name ON tiger_data.NV_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_NV_place_the_geom_gist ON tiger_data.NV_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.NV_place ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_32_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_32*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_32*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NV_cousub(CONSTRAINT pk_NV_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_NV_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_32_cousub.dbf tiger_staging.nv_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NV_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('NV_cousub'), lower('NV_cousub')); ALTER TABLE tiger_data.NV_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
${PSQL} -c "CREATE INDEX tiger_data_NV_cousub_the_geom_gist ON tiger_data.NV_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NV_cousub_countyfp ON tiger_data.NV_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_32_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_32*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_32*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NV_tract(CONSTRAINT pk_NV_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_32_tract.dbf tiger_staging.nv_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NV_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('NV_tract'), lower('NV_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_NV_tract_the_geom_gist ON tiger_data.NV_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.NV_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.NV_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_32_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_32*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_32*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NV_tabblock(CONSTRAINT pk_NV_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_32_tabblock.dbf tiger_staging.nv_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NV_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('NV_tabblock'), lower('NV_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.NV_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
${PSQL} -c "CREATE INDEX tiger_data_NV_tabblock_the_geom_gist ON tiger_data.NV_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NV_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_32_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_32*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_32*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NV_bg(CONSTRAINT pk_NV_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_32_bg.dbf tiger_staging.nv_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NV_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('NV_bg'), lower('NV_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.NV_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
${PSQL} -c "CREATE INDEX tiger_data_NV_bg_the_geom_gist ON tiger_data.NV_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NV_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_32* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_32*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_32*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NV_zcta5(CONSTRAINT pk_NV_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_NV_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NV_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NV_zcta510'), lower('NV_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NV_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
${PSQL} -c "CREATE INDEX tiger_data_NV_zcta5_the_geom_gist ON tiger_data.NV_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_32* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_32*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_32*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NV_faces(CONSTRAINT pk_NV_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NV_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NV_faces'), lower('NV_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_NV_faces_the_geom_gist ON tiger_data.NV_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NV_faces_tfid ON tiger_data.NV_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NV_faces_countyfp ON tiger_data.NV_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.NV_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
	${PSQL} -c "vacuum analyze tiger_data.NV_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_32* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_32*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_32*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NV_featnames(CONSTRAINT pk_NV_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.NV_featnames ALTER COLUMN statefp SET DEFAULT '32';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NV_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NV_featnames'), lower('NV_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_NV_featnames_snd_name ON tiger_data.NV_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NV_featnames_lname ON tiger_data.NV_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NV_featnames_tlid_statefp ON tiger_data.NV_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.NV_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
${PSQL} -c "vacuum analyze tiger_data.NV_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_32* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_32*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_32*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NV_edges(CONSTRAINT pk_NV_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NV_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NV_edges'), lower('NV_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NV_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NV_edges_tlid ON tiger_data.NV_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NV_edgestfidr ON tiger_data.NV_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NV_edges_tfidl ON tiger_data.NV_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NV_edges_countyfp ON tiger_data.NV_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_NV_edges_the_geom_gist ON tiger_data.NV_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NV_edges_zipl ON tiger_data.NV_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.NV_zip_state_loc(CONSTRAINT pk_NV_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.NV_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'NV', '32', p.name FROM tiger_data.NV_edges AS e INNER JOIN tiger_data.NV_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NV_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_NV_zip_state_loc_place ON tiger_data.NV_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.NV_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
${PSQL} -c "vacuum analyze tiger_data.NV_edges;"
${PSQL} -c "vacuum analyze tiger_data.NV_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.NV_zip_lookup_base(CONSTRAINT pk_NV_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.NV_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'NV', c.name,p.name,'32'  FROM tiger_data.NV_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '32') INNER JOIN tiger_data.NV_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NV_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.NV_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NV_zip_lookup_base_citysnd ON tiger_data.NV_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_32* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_32*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_32*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NV_addr(CONSTRAINT pk_NV_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.NV_addr ALTER COLUMN statefp SET DEFAULT '32';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NV_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NV_addr'), lower('NV_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NV_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NV_addr_least_address ON tiger_data.NV_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NV_addr_tlid_statefp ON tiger_data.NV_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NV_addr_zip ON tiger_data.NV_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.NV_zip_state(CONSTRAINT pk_NV_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.NV_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'NV', '32' FROM tiger_data.NV_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.NV_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '32');"
	${PSQL} -c "vacuum analyze tiger_data.NV_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_33_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_33*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_33*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NH_place(CONSTRAINT pk_NH_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_33_place.dbf tiger_staging.nh_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NH_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('NH_place'), lower('NH_place')); ALTER TABLE tiger_data.NH_place ADD CONSTRAINT uidx_NH_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_NH_place_soundex_name ON tiger_data.NH_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_NH_place_the_geom_gist ON tiger_data.NH_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.NH_place ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_33_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_33*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_33*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NH_cousub(CONSTRAINT pk_NH_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_NH_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_33_cousub.dbf tiger_staging.nh_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NH_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('NH_cousub'), lower('NH_cousub')); ALTER TABLE tiger_data.NH_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
${PSQL} -c "CREATE INDEX tiger_data_NH_cousub_the_geom_gist ON tiger_data.NH_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NH_cousub_countyfp ON tiger_data.NH_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_33_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_33*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_33*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NH_tract(CONSTRAINT pk_NH_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_33_tract.dbf tiger_staging.nh_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NH_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('NH_tract'), lower('NH_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_NH_tract_the_geom_gist ON tiger_data.NH_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.NH_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.NH_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_33_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_33*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_33*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NH_tabblock(CONSTRAINT pk_NH_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_33_tabblock.dbf tiger_staging.nh_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NH_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('NH_tabblock'), lower('NH_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.NH_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
${PSQL} -c "CREATE INDEX tiger_data_NH_tabblock_the_geom_gist ON tiger_data.NH_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NH_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_33_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_33*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_33*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NH_bg(CONSTRAINT pk_NH_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_33_bg.dbf tiger_staging.nh_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NH_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('NH_bg'), lower('NH_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.NH_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
${PSQL} -c "CREATE INDEX tiger_data_NH_bg_the_geom_gist ON tiger_data.NH_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NH_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_33* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_33*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_33*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NH_zcta5(CONSTRAINT pk_NH_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_NH_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NH_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NH_zcta510'), lower('NH_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NH_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
${PSQL} -c "CREATE INDEX tiger_data_NH_zcta5_the_geom_gist ON tiger_data.NH_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_33* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_33*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_33*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NH_faces(CONSTRAINT pk_NH_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NH_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NH_faces'), lower('NH_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_NH_faces_the_geom_gist ON tiger_data.NH_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NH_faces_tfid ON tiger_data.NH_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NH_faces_countyfp ON tiger_data.NH_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.NH_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
	${PSQL} -c "vacuum analyze tiger_data.NH_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_33* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_33*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_33*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NH_featnames(CONSTRAINT pk_NH_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.NH_featnames ALTER COLUMN statefp SET DEFAULT '33';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NH_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NH_featnames'), lower('NH_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_NH_featnames_snd_name ON tiger_data.NH_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NH_featnames_lname ON tiger_data.NH_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NH_featnames_tlid_statefp ON tiger_data.NH_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.NH_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
${PSQL} -c "vacuum analyze tiger_data.NH_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_33* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_33*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_33*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NH_edges(CONSTRAINT pk_NH_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NH_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NH_edges'), lower('NH_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NH_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NH_edges_tlid ON tiger_data.NH_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NH_edgestfidr ON tiger_data.NH_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NH_edges_tfidl ON tiger_data.NH_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NH_edges_countyfp ON tiger_data.NH_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_NH_edges_the_geom_gist ON tiger_data.NH_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NH_edges_zipl ON tiger_data.NH_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.NH_zip_state_loc(CONSTRAINT pk_NH_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.NH_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'NH', '33', p.name FROM tiger_data.NH_edges AS e INNER JOIN tiger_data.NH_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NH_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_NH_zip_state_loc_place ON tiger_data.NH_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.NH_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
${PSQL} -c "vacuum analyze tiger_data.NH_edges;"
${PSQL} -c "vacuum analyze tiger_data.NH_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.NH_zip_lookup_base(CONSTRAINT pk_NH_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.NH_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'NH', c.name,p.name,'33'  FROM tiger_data.NH_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '33') INNER JOIN tiger_data.NH_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NH_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.NH_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NH_zip_lookup_base_citysnd ON tiger_data.NH_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_33* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_33*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_33*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NH_addr(CONSTRAINT pk_NH_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.NH_addr ALTER COLUMN statefp SET DEFAULT '33';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NH_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NH_addr'), lower('NH_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NH_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NH_addr_least_address ON tiger_data.NH_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NH_addr_tlid_statefp ON tiger_data.NH_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NH_addr_zip ON tiger_data.NH_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.NH_zip_state(CONSTRAINT pk_NH_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.NH_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'NH', '33' FROM tiger_data.NH_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.NH_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '33');"
	${PSQL} -c "vacuum analyze tiger_data.NH_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_34_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_34*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_34*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NJ_place(CONSTRAINT pk_NJ_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_34_place.dbf tiger_staging.nj_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NJ_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('NJ_place'), lower('NJ_place')); ALTER TABLE tiger_data.NJ_place ADD CONSTRAINT uidx_NJ_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_NJ_place_soundex_name ON tiger_data.NJ_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_NJ_place_the_geom_gist ON tiger_data.NJ_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.NJ_place ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_34_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_34*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_34*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NJ_cousub(CONSTRAINT pk_NJ_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_NJ_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_34_cousub.dbf tiger_staging.nj_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NJ_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('NJ_cousub'), lower('NJ_cousub')); ALTER TABLE tiger_data.NJ_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
${PSQL} -c "CREATE INDEX tiger_data_NJ_cousub_the_geom_gist ON tiger_data.NJ_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_cousub_countyfp ON tiger_data.NJ_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_34_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_34*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_34*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NJ_tract(CONSTRAINT pk_NJ_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_34_tract.dbf tiger_staging.nj_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NJ_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('NJ_tract'), lower('NJ_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_NJ_tract_the_geom_gist ON tiger_data.NJ_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.NJ_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.NJ_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_34_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_34*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_34*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NJ_tabblock(CONSTRAINT pk_NJ_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_34_tabblock.dbf tiger_staging.nj_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NJ_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('NJ_tabblock'), lower('NJ_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.NJ_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
${PSQL} -c "CREATE INDEX tiger_data_NJ_tabblock_the_geom_gist ON tiger_data.NJ_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NJ_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_34_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_34*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_34*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NJ_bg(CONSTRAINT pk_NJ_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_34_bg.dbf tiger_staging.nj_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NJ_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('NJ_bg'), lower('NJ_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.NJ_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
${PSQL} -c "CREATE INDEX tiger_data_NJ_bg_the_geom_gist ON tiger_data.NJ_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NJ_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_34* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_34*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_34*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NJ_zcta5(CONSTRAINT pk_NJ_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_NJ_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NJ_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NJ_zcta510'), lower('NJ_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NJ_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
${PSQL} -c "CREATE INDEX tiger_data_NJ_zcta5_the_geom_gist ON tiger_data.NJ_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_34* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_34*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_34*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NJ_faces(CONSTRAINT pk_NJ_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NJ_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NJ_faces'), lower('NJ_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_NJ_faces_the_geom_gist ON tiger_data.NJ_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_faces_tfid ON tiger_data.NJ_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_faces_countyfp ON tiger_data.NJ_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.NJ_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
	${PSQL} -c "vacuum analyze tiger_data.NJ_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_34* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_34*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_34*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NJ_featnames(CONSTRAINT pk_NJ_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.NJ_featnames ALTER COLUMN statefp SET DEFAULT '34';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NJ_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NJ_featnames'), lower('NJ_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_featnames_snd_name ON tiger_data.NJ_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_featnames_lname ON tiger_data.NJ_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_featnames_tlid_statefp ON tiger_data.NJ_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.NJ_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
${PSQL} -c "vacuum analyze tiger_data.NJ_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_34* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_34*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_34*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NJ_edges(CONSTRAINT pk_NJ_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NJ_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NJ_edges'), lower('NJ_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NJ_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_edges_tlid ON tiger_data.NJ_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_edgestfidr ON tiger_data.NJ_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_edges_tfidl ON tiger_data.NJ_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_edges_countyfp ON tiger_data.NJ_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_NJ_edges_the_geom_gist ON tiger_data.NJ_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_edges_zipl ON tiger_data.NJ_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.NJ_zip_state_loc(CONSTRAINT pk_NJ_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.NJ_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'NJ', '34', p.name FROM tiger_data.NJ_edges AS e INNER JOIN tiger_data.NJ_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NJ_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_zip_state_loc_place ON tiger_data.NJ_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.NJ_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
${PSQL} -c "vacuum analyze tiger_data.NJ_edges;"
${PSQL} -c "vacuum analyze tiger_data.NJ_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.NJ_zip_lookup_base(CONSTRAINT pk_NJ_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.NJ_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'NJ', c.name,p.name,'34'  FROM tiger_data.NJ_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '34') INNER JOIN tiger_data.NJ_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NJ_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.NJ_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_zip_lookup_base_citysnd ON tiger_data.NJ_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_34* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_34*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_34*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NJ_addr(CONSTRAINT pk_NJ_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.NJ_addr ALTER COLUMN statefp SET DEFAULT '34';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NJ_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NJ_addr'), lower('NJ_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NJ_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_addr_least_address ON tiger_data.NJ_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_addr_tlid_statefp ON tiger_data.NJ_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NJ_addr_zip ON tiger_data.NJ_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.NJ_zip_state(CONSTRAINT pk_NJ_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.NJ_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'NJ', '34' FROM tiger_data.NJ_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.NJ_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
	${PSQL} -c "vacuum analyze tiger_data.NJ_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_35_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_35*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_35*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NM_place(CONSTRAINT pk_NM_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_35_place.dbf tiger_staging.nm_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NM_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('NM_place'), lower('NM_place')); ALTER TABLE tiger_data.NM_place ADD CONSTRAINT uidx_NM_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_NM_place_soundex_name ON tiger_data.NM_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_NM_place_the_geom_gist ON tiger_data.NM_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.NM_place ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_35_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_35*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_35*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NM_cousub(CONSTRAINT pk_NM_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_NM_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_35_cousub.dbf tiger_staging.nm_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NM_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('NM_cousub'), lower('NM_cousub')); ALTER TABLE tiger_data.NM_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
${PSQL} -c "CREATE INDEX tiger_data_NM_cousub_the_geom_gist ON tiger_data.NM_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NM_cousub_countyfp ON tiger_data.NM_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_35_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_35*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_35*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NM_tract(CONSTRAINT pk_NM_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_35_tract.dbf tiger_staging.nm_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NM_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('NM_tract'), lower('NM_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_NM_tract_the_geom_gist ON tiger_data.NM_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.NM_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.NM_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_35_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_35*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_35*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NM_tabblock(CONSTRAINT pk_NM_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_35_tabblock.dbf tiger_staging.nm_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NM_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('NM_tabblock'), lower('NM_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.NM_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
${PSQL} -c "CREATE INDEX tiger_data_NM_tabblock_the_geom_gist ON tiger_data.NM_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NM_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_35_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_35*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_35*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NM_bg(CONSTRAINT pk_NM_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_35_bg.dbf tiger_staging.nm_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NM_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('NM_bg'), lower('NM_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.NM_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
${PSQL} -c "CREATE INDEX tiger_data_NM_bg_the_geom_gist ON tiger_data.NM_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NM_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_35* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_35*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_35*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NM_zcta5(CONSTRAINT pk_NM_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_NM_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NM_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NM_zcta510'), lower('NM_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NM_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
${PSQL} -c "CREATE INDEX tiger_data_NM_zcta5_the_geom_gist ON tiger_data.NM_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_35* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_35*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_35*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NM_faces(CONSTRAINT pk_NM_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NM_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NM_faces'), lower('NM_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_NM_faces_the_geom_gist ON tiger_data.NM_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NM_faces_tfid ON tiger_data.NM_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NM_faces_countyfp ON tiger_data.NM_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.NM_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
	${PSQL} -c "vacuum analyze tiger_data.NM_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_35* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_35*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_35*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NM_featnames(CONSTRAINT pk_NM_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.NM_featnames ALTER COLUMN statefp SET DEFAULT '35';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NM_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NM_featnames'), lower('NM_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_NM_featnames_snd_name ON tiger_data.NM_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NM_featnames_lname ON tiger_data.NM_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NM_featnames_tlid_statefp ON tiger_data.NM_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.NM_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
${PSQL} -c "vacuum analyze tiger_data.NM_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_35* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_35*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_35*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NM_edges(CONSTRAINT pk_NM_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NM_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NM_edges'), lower('NM_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NM_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NM_edges_tlid ON tiger_data.NM_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NM_edgestfidr ON tiger_data.NM_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NM_edges_tfidl ON tiger_data.NM_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NM_edges_countyfp ON tiger_data.NM_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_NM_edges_the_geom_gist ON tiger_data.NM_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NM_edges_zipl ON tiger_data.NM_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.NM_zip_state_loc(CONSTRAINT pk_NM_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.NM_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'NM', '35', p.name FROM tiger_data.NM_edges AS e INNER JOIN tiger_data.NM_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NM_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_NM_zip_state_loc_place ON tiger_data.NM_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.NM_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
${PSQL} -c "vacuum analyze tiger_data.NM_edges;"
${PSQL} -c "vacuum analyze tiger_data.NM_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.NM_zip_lookup_base(CONSTRAINT pk_NM_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.NM_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'NM', c.name,p.name,'35'  FROM tiger_data.NM_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '35') INNER JOIN tiger_data.NM_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NM_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.NM_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NM_zip_lookup_base_citysnd ON tiger_data.NM_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_35* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_35*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_35*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NM_addr(CONSTRAINT pk_NM_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.NM_addr ALTER COLUMN statefp SET DEFAULT '35';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NM_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NM_addr'), lower('NM_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NM_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NM_addr_least_address ON tiger_data.NM_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NM_addr_tlid_statefp ON tiger_data.NM_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NM_addr_zip ON tiger_data.NM_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.NM_zip_state(CONSTRAINT pk_NM_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.NM_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'NM', '35' FROM tiger_data.NM_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.NM_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '35');"
	${PSQL} -c "vacuum analyze tiger_data.NM_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_36_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_36*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_36*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NY_place(CONSTRAINT pk_NY_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_36_place.dbf tiger_staging.ny_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NY_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('NY_place'), lower('NY_place')); ALTER TABLE tiger_data.NY_place ADD CONSTRAINT uidx_NY_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_NY_place_soundex_name ON tiger_data.NY_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_NY_place_the_geom_gist ON tiger_data.NY_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.NY_place ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_36_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_36*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_36*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NY_cousub(CONSTRAINT pk_NY_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_NY_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_36_cousub.dbf tiger_staging.ny_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NY_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('NY_cousub'), lower('NY_cousub')); ALTER TABLE tiger_data.NY_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
${PSQL} -c "CREATE INDEX tiger_data_NY_cousub_the_geom_gist ON tiger_data.NY_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NY_cousub_countyfp ON tiger_data.NY_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_36_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_36*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_36*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NY_tract(CONSTRAINT pk_NY_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_36_tract.dbf tiger_staging.ny_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NY_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('NY_tract'), lower('NY_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_NY_tract_the_geom_gist ON tiger_data.NY_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.NY_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.NY_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_36_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_36*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_36*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NY_tabblock(CONSTRAINT pk_NY_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_36_tabblock.dbf tiger_staging.ny_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NY_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('NY_tabblock'), lower('NY_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.NY_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
${PSQL} -c "CREATE INDEX tiger_data_NY_tabblock_the_geom_gist ON tiger_data.NY_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NY_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_36_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_36*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_36*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NY_bg(CONSTRAINT pk_NY_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_36_bg.dbf tiger_staging.ny_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NY_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('NY_bg'), lower('NY_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.NY_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
${PSQL} -c "CREATE INDEX tiger_data_NY_bg_the_geom_gist ON tiger_data.NY_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NY_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_36* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_36*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_36*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NY_zcta5(CONSTRAINT pk_NY_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_NY_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NY_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NY_zcta510'), lower('NY_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NY_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
${PSQL} -c "CREATE INDEX tiger_data_NY_zcta5_the_geom_gist ON tiger_data.NY_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_36* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_36*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_36*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NY_faces(CONSTRAINT pk_NY_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NY_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NY_faces'), lower('NY_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_NY_faces_the_geom_gist ON tiger_data.NY_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NY_faces_tfid ON tiger_data.NY_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NY_faces_countyfp ON tiger_data.NY_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.NY_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
	${PSQL} -c "vacuum analyze tiger_data.NY_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_36* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_36*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_36*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NY_featnames(CONSTRAINT pk_NY_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.NY_featnames ALTER COLUMN statefp SET DEFAULT '36';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NY_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NY_featnames'), lower('NY_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_NY_featnames_snd_name ON tiger_data.NY_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NY_featnames_lname ON tiger_data.NY_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NY_featnames_tlid_statefp ON tiger_data.NY_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.NY_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
${PSQL} -c "vacuum analyze tiger_data.NY_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_36* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_36*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_36*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NY_edges(CONSTRAINT pk_NY_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NY_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NY_edges'), lower('NY_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NY_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NY_edges_tlid ON tiger_data.NY_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NY_edgestfidr ON tiger_data.NY_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NY_edges_tfidl ON tiger_data.NY_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NY_edges_countyfp ON tiger_data.NY_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_NY_edges_the_geom_gist ON tiger_data.NY_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NY_edges_zipl ON tiger_data.NY_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.NY_zip_state_loc(CONSTRAINT pk_NY_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.NY_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'NY', '36', p.name FROM tiger_data.NY_edges AS e INNER JOIN tiger_data.NY_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NY_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_NY_zip_state_loc_place ON tiger_data.NY_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.NY_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
${PSQL} -c "vacuum analyze tiger_data.NY_edges;"
${PSQL} -c "vacuum analyze tiger_data.NY_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.NY_zip_lookup_base(CONSTRAINT pk_NY_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.NY_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'NY', c.name,p.name,'36'  FROM tiger_data.NY_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '36') INNER JOIN tiger_data.NY_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NY_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.NY_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NY_zip_lookup_base_citysnd ON tiger_data.NY_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_36* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_36*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_36*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NY_addr(CONSTRAINT pk_NY_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.NY_addr ALTER COLUMN statefp SET DEFAULT '36';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NY_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NY_addr'), lower('NY_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NY_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NY_addr_least_address ON tiger_data.NY_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NY_addr_tlid_statefp ON tiger_data.NY_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NY_addr_zip ON tiger_data.NY_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.NY_zip_state(CONSTRAINT pk_NY_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.NY_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'NY', '36' FROM tiger_data.NY_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.NY_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '36');"
	${PSQL} -c "vacuum analyze tiger_data.NY_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_37_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_37*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_37*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NC_place(CONSTRAINT pk_NC_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_37_place.dbf tiger_staging.nc_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NC_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('NC_place'), lower('NC_place')); ALTER TABLE tiger_data.NC_place ADD CONSTRAINT uidx_NC_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_NC_place_soundex_name ON tiger_data.NC_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_NC_place_the_geom_gist ON tiger_data.NC_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.NC_place ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_37_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_37*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_37*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NC_cousub(CONSTRAINT pk_NC_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_NC_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_37_cousub.dbf tiger_staging.nc_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NC_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('NC_cousub'), lower('NC_cousub')); ALTER TABLE tiger_data.NC_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
${PSQL} -c "CREATE INDEX tiger_data_NC_cousub_the_geom_gist ON tiger_data.NC_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NC_cousub_countyfp ON tiger_data.NC_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_37_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_37*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_37*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NC_tract(CONSTRAINT pk_NC_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_37_tract.dbf tiger_staging.nc_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NC_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('NC_tract'), lower('NC_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_NC_tract_the_geom_gist ON tiger_data.NC_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.NC_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.NC_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_37_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_37*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_37*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NC_tabblock(CONSTRAINT pk_NC_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_37_tabblock.dbf tiger_staging.nc_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NC_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('NC_tabblock'), lower('NC_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.NC_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
${PSQL} -c "CREATE INDEX tiger_data_NC_tabblock_the_geom_gist ON tiger_data.NC_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NC_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_37_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_37*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_37*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NC_bg(CONSTRAINT pk_NC_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_37_bg.dbf tiger_staging.nc_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.NC_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('NC_bg'), lower('NC_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.NC_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
${PSQL} -c "CREATE INDEX tiger_data_NC_bg_the_geom_gist ON tiger_data.NC_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.NC_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_37* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_37*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_37*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NC_zcta5(CONSTRAINT pk_NC_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_NC_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NC_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NC_zcta510'), lower('NC_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NC_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
${PSQL} -c "CREATE INDEX tiger_data_NC_zcta5_the_geom_gist ON tiger_data.NC_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_37* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_37*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_37*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NC_faces(CONSTRAINT pk_NC_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NC_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NC_faces'), lower('NC_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_NC_faces_the_geom_gist ON tiger_data.NC_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NC_faces_tfid ON tiger_data.NC_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NC_faces_countyfp ON tiger_data.NC_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.NC_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
	${PSQL} -c "vacuum analyze tiger_data.NC_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_37* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_37*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_37*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NC_featnames(CONSTRAINT pk_NC_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.NC_featnames ALTER COLUMN statefp SET DEFAULT '37';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NC_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NC_featnames'), lower('NC_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_NC_featnames_snd_name ON tiger_data.NC_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NC_featnames_lname ON tiger_data.NC_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_NC_featnames_tlid_statefp ON tiger_data.NC_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.NC_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
${PSQL} -c "vacuum analyze tiger_data.NC_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_37* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_37*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_37*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NC_edges(CONSTRAINT pk_NC_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NC_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NC_edges'), lower('NC_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NC_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NC_edges_tlid ON tiger_data.NC_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NC_edgestfidr ON tiger_data.NC_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NC_edges_tfidl ON tiger_data.NC_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NC_edges_countyfp ON tiger_data.NC_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_NC_edges_the_geom_gist ON tiger_data.NC_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_NC_edges_zipl ON tiger_data.NC_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.NC_zip_state_loc(CONSTRAINT pk_NC_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.NC_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'NC', '37', p.name FROM tiger_data.NC_edges AS e INNER JOIN tiger_data.NC_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NC_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_NC_zip_state_loc_place ON tiger_data.NC_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.NC_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
${PSQL} -c "vacuum analyze tiger_data.NC_edges;"
${PSQL} -c "vacuum analyze tiger_data.NC_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.NC_zip_lookup_base(CONSTRAINT pk_NC_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.NC_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'NC', c.name,p.name,'37'  FROM tiger_data.NC_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '37') INNER JOIN tiger_data.NC_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NC_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.NC_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
${PSQL} -c "CREATE INDEX idx_tiger_data_NC_zip_lookup_base_citysnd ON tiger_data.NC_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_37* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_37*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_37*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.NC_addr(CONSTRAINT pk_NC_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.NC_addr ALTER COLUMN statefp SET DEFAULT '37';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.NC_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('NC_addr'), lower('NC_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.NC_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NC_addr_least_address ON tiger_data.NC_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NC_addr_tlid_statefp ON tiger_data.NC_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_NC_addr_zip ON tiger_data.NC_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.NC_zip_state(CONSTRAINT pk_NC_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.NC_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'NC', '37' FROM tiger_data.NC_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.NC_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '37');"
	${PSQL} -c "vacuum analyze tiger_data.NC_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_38_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_38*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_38*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ND_place(CONSTRAINT pk_ND_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_38_place.dbf tiger_staging.nd_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ND_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('ND_place'), lower('ND_place')); ALTER TABLE tiger_data.ND_place ADD CONSTRAINT uidx_ND_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_ND_place_soundex_name ON tiger_data.ND_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_ND_place_the_geom_gist ON tiger_data.ND_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.ND_place ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_38_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_38*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_38*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ND_cousub(CONSTRAINT pk_ND_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_ND_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_38_cousub.dbf tiger_staging.nd_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ND_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('ND_cousub'), lower('ND_cousub')); ALTER TABLE tiger_data.ND_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
${PSQL} -c "CREATE INDEX tiger_data_ND_cousub_the_geom_gist ON tiger_data.ND_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ND_cousub_countyfp ON tiger_data.ND_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_38_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_38*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_38*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ND_tract(CONSTRAINT pk_ND_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_38_tract.dbf tiger_staging.nd_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ND_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('ND_tract'), lower('ND_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_ND_tract_the_geom_gist ON tiger_data.ND_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.ND_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.ND_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_38_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_38*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_38*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ND_tabblock(CONSTRAINT pk_ND_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_38_tabblock.dbf tiger_staging.nd_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ND_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('ND_tabblock'), lower('ND_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.ND_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
${PSQL} -c "CREATE INDEX tiger_data_ND_tabblock_the_geom_gist ON tiger_data.ND_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.ND_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_38_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_38*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_38*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ND_bg(CONSTRAINT pk_ND_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_38_bg.dbf tiger_staging.nd_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.ND_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('ND_bg'), lower('ND_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.ND_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
${PSQL} -c "CREATE INDEX tiger_data_ND_bg_the_geom_gist ON tiger_data.ND_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.ND_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_38* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_38*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_38*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ND_zcta5(CONSTRAINT pk_ND_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_ND_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ND_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ND_zcta510'), lower('ND_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.ND_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
${PSQL} -c "CREATE INDEX tiger_data_ND_zcta5_the_geom_gist ON tiger_data.ND_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_38* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_38*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_38*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ND_faces(CONSTRAINT pk_ND_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ND_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ND_faces'), lower('ND_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_ND_faces_the_geom_gist ON tiger_data.ND_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ND_faces_tfid ON tiger_data.ND_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ND_faces_countyfp ON tiger_data.ND_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.ND_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
	${PSQL} -c "vacuum analyze tiger_data.ND_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_38* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_38*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_38*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ND_featnames(CONSTRAINT pk_ND_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.ND_featnames ALTER COLUMN statefp SET DEFAULT '38';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ND_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ND_featnames'), lower('ND_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_ND_featnames_snd_name ON tiger_data.ND_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_ND_featnames_lname ON tiger_data.ND_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_ND_featnames_tlid_statefp ON tiger_data.ND_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.ND_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
${PSQL} -c "vacuum analyze tiger_data.ND_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_38* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_38*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_38*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ND_edges(CONSTRAINT pk_ND_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ND_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ND_edges'), lower('ND_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.ND_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
${PSQL} -c "CREATE INDEX idx_tiger_data_ND_edges_tlid ON tiger_data.ND_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ND_edgestfidr ON tiger_data.ND_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ND_edges_tfidl ON tiger_data.ND_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ND_edges_countyfp ON tiger_data.ND_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_ND_edges_the_geom_gist ON tiger_data.ND_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_ND_edges_zipl ON tiger_data.ND_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.ND_zip_state_loc(CONSTRAINT pk_ND_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.ND_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'ND', '38', p.name FROM tiger_data.ND_edges AS e INNER JOIN tiger_data.ND_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.ND_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_ND_zip_state_loc_place ON tiger_data.ND_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.ND_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
${PSQL} -c "vacuum analyze tiger_data.ND_edges;"
${PSQL} -c "vacuum analyze tiger_data.ND_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.ND_zip_lookup_base(CONSTRAINT pk_ND_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.ND_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'ND', c.name,p.name,'38'  FROM tiger_data.ND_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '38') INNER JOIN tiger_data.ND_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.ND_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.ND_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
${PSQL} -c "CREATE INDEX idx_tiger_data_ND_zip_lookup_base_citysnd ON tiger_data.ND_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_38* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_38*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_38*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.ND_addr(CONSTRAINT pk_ND_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.ND_addr ALTER COLUMN statefp SET DEFAULT '38';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.ND_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('ND_addr'), lower('ND_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.ND_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ND_addr_least_address ON tiger_data.ND_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ND_addr_tlid_statefp ON tiger_data.ND_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_ND_addr_zip ON tiger_data.ND_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.ND_zip_state(CONSTRAINT pk_ND_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.ND_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'ND', '38' FROM tiger_data.ND_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.ND_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '38');"
	${PSQL} -c "vacuum analyze tiger_data.ND_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_39_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_39*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_39*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OH_place(CONSTRAINT pk_OH_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_39_place.dbf tiger_staging.oh_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OH_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('OH_place'), lower('OH_place')); ALTER TABLE tiger_data.OH_place ADD CONSTRAINT uidx_OH_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_OH_place_soundex_name ON tiger_data.OH_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_OH_place_the_geom_gist ON tiger_data.OH_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.OH_place ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_39_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_39*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_39*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OH_cousub(CONSTRAINT pk_OH_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_OH_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_39_cousub.dbf tiger_staging.oh_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OH_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('OH_cousub'), lower('OH_cousub')); ALTER TABLE tiger_data.OH_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
${PSQL} -c "CREATE INDEX tiger_data_OH_cousub_the_geom_gist ON tiger_data.OH_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OH_cousub_countyfp ON tiger_data.OH_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_39_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_39*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_39*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OH_tract(CONSTRAINT pk_OH_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_39_tract.dbf tiger_staging.oh_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OH_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('OH_tract'), lower('OH_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_OH_tract_the_geom_gist ON tiger_data.OH_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.OH_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.OH_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_39_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_39*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_39*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OH_tabblock(CONSTRAINT pk_OH_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_39_tabblock.dbf tiger_staging.oh_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OH_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('OH_tabblock'), lower('OH_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.OH_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
${PSQL} -c "CREATE INDEX tiger_data_OH_tabblock_the_geom_gist ON tiger_data.OH_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.OH_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_39_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_39*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_39*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OH_bg(CONSTRAINT pk_OH_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_39_bg.dbf tiger_staging.oh_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OH_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('OH_bg'), lower('OH_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.OH_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
${PSQL} -c "CREATE INDEX tiger_data_OH_bg_the_geom_gist ON tiger_data.OH_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.OH_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_39* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_39*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_39*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OH_zcta5(CONSTRAINT pk_OH_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_OH_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OH_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OH_zcta510'), lower('OH_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.OH_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
${PSQL} -c "CREATE INDEX tiger_data_OH_zcta5_the_geom_gist ON tiger_data.OH_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_39* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_39*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_39*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OH_faces(CONSTRAINT pk_OH_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OH_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OH_faces'), lower('OH_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_OH_faces_the_geom_gist ON tiger_data.OH_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OH_faces_tfid ON tiger_data.OH_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OH_faces_countyfp ON tiger_data.OH_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.OH_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
	${PSQL} -c "vacuum analyze tiger_data.OH_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_39* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_39*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_39*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OH_featnames(CONSTRAINT pk_OH_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.OH_featnames ALTER COLUMN statefp SET DEFAULT '39';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OH_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OH_featnames'), lower('OH_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_OH_featnames_snd_name ON tiger_data.OH_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_OH_featnames_lname ON tiger_data.OH_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_OH_featnames_tlid_statefp ON tiger_data.OH_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.OH_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
${PSQL} -c "vacuum analyze tiger_data.OH_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_39* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_39*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_39*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OH_edges(CONSTRAINT pk_OH_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OH_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OH_edges'), lower('OH_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.OH_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
${PSQL} -c "CREATE INDEX idx_tiger_data_OH_edges_tlid ON tiger_data.OH_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OH_edgestfidr ON tiger_data.OH_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OH_edges_tfidl ON tiger_data.OH_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OH_edges_countyfp ON tiger_data.OH_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_OH_edges_the_geom_gist ON tiger_data.OH_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OH_edges_zipl ON tiger_data.OH_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.OH_zip_state_loc(CONSTRAINT pk_OH_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.OH_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'OH', '39', p.name FROM tiger_data.OH_edges AS e INNER JOIN tiger_data.OH_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.OH_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_OH_zip_state_loc_place ON tiger_data.OH_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.OH_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
${PSQL} -c "vacuum analyze tiger_data.OH_edges;"
${PSQL} -c "vacuum analyze tiger_data.OH_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.OH_zip_lookup_base(CONSTRAINT pk_OH_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.OH_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'OH', c.name,p.name,'39'  FROM tiger_data.OH_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '39') INNER JOIN tiger_data.OH_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.OH_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.OH_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
${PSQL} -c "CREATE INDEX idx_tiger_data_OH_zip_lookup_base_citysnd ON tiger_data.OH_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_39* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_39*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_39*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OH_addr(CONSTRAINT pk_OH_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.OH_addr ALTER COLUMN statefp SET DEFAULT '39';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OH_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OH_addr'), lower('OH_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.OH_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OH_addr_least_address ON tiger_data.OH_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OH_addr_tlid_statefp ON tiger_data.OH_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OH_addr_zip ON tiger_data.OH_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.OH_zip_state(CONSTRAINT pk_OH_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.OH_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'OH', '39' FROM tiger_data.OH_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.OH_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '39');"
	${PSQL} -c "vacuum analyze tiger_data.OH_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_40_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_40*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_40*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OK_place(CONSTRAINT pk_OK_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_40_place.dbf tiger_staging.ok_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OK_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('OK_place'), lower('OK_place')); ALTER TABLE tiger_data.OK_place ADD CONSTRAINT uidx_OK_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_OK_place_soundex_name ON tiger_data.OK_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_OK_place_the_geom_gist ON tiger_data.OK_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.OK_place ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_40_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_40*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_40*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OK_cousub(CONSTRAINT pk_OK_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_OK_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_40_cousub.dbf tiger_staging.ok_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OK_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('OK_cousub'), lower('OK_cousub')); ALTER TABLE tiger_data.OK_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
${PSQL} -c "CREATE INDEX tiger_data_OK_cousub_the_geom_gist ON tiger_data.OK_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OK_cousub_countyfp ON tiger_data.OK_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_40_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_40*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_40*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OK_tract(CONSTRAINT pk_OK_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_40_tract.dbf tiger_staging.ok_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OK_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('OK_tract'), lower('OK_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_OK_tract_the_geom_gist ON tiger_data.OK_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.OK_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.OK_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_40_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_40*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_40*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OK_tabblock(CONSTRAINT pk_OK_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_40_tabblock.dbf tiger_staging.ok_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OK_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('OK_tabblock'), lower('OK_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.OK_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
${PSQL} -c "CREATE INDEX tiger_data_OK_tabblock_the_geom_gist ON tiger_data.OK_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.OK_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_40_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_40*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_40*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OK_bg(CONSTRAINT pk_OK_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_40_bg.dbf tiger_staging.ok_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OK_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('OK_bg'), lower('OK_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.OK_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
${PSQL} -c "CREATE INDEX tiger_data_OK_bg_the_geom_gist ON tiger_data.OK_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.OK_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_40* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_40*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_40*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OK_zcta5(CONSTRAINT pk_OK_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_OK_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OK_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OK_zcta510'), lower('OK_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.OK_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
${PSQL} -c "CREATE INDEX tiger_data_OK_zcta5_the_geom_gist ON tiger_data.OK_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_40* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_40*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_40*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OK_faces(CONSTRAINT pk_OK_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OK_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OK_faces'), lower('OK_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_OK_faces_the_geom_gist ON tiger_data.OK_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OK_faces_tfid ON tiger_data.OK_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OK_faces_countyfp ON tiger_data.OK_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.OK_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
	${PSQL} -c "vacuum analyze tiger_data.OK_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_40* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_40*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_40*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OK_featnames(CONSTRAINT pk_OK_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.OK_featnames ALTER COLUMN statefp SET DEFAULT '40';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OK_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OK_featnames'), lower('OK_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_OK_featnames_snd_name ON tiger_data.OK_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_OK_featnames_lname ON tiger_data.OK_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_OK_featnames_tlid_statefp ON tiger_data.OK_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.OK_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
${PSQL} -c "vacuum analyze tiger_data.OK_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_40* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_40*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_40*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OK_edges(CONSTRAINT pk_OK_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OK_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OK_edges'), lower('OK_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.OK_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
${PSQL} -c "CREATE INDEX idx_tiger_data_OK_edges_tlid ON tiger_data.OK_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OK_edgestfidr ON tiger_data.OK_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OK_edges_tfidl ON tiger_data.OK_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OK_edges_countyfp ON tiger_data.OK_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_OK_edges_the_geom_gist ON tiger_data.OK_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OK_edges_zipl ON tiger_data.OK_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.OK_zip_state_loc(CONSTRAINT pk_OK_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.OK_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'OK', '40', p.name FROM tiger_data.OK_edges AS e INNER JOIN tiger_data.OK_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.OK_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_OK_zip_state_loc_place ON tiger_data.OK_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.OK_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
${PSQL} -c "vacuum analyze tiger_data.OK_edges;"
${PSQL} -c "vacuum analyze tiger_data.OK_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.OK_zip_lookup_base(CONSTRAINT pk_OK_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.OK_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'OK', c.name,p.name,'40'  FROM tiger_data.OK_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '40') INNER JOIN tiger_data.OK_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.OK_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.OK_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
${PSQL} -c "CREATE INDEX idx_tiger_data_OK_zip_lookup_base_citysnd ON tiger_data.OK_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_40* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_40*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_40*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OK_addr(CONSTRAINT pk_OK_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.OK_addr ALTER COLUMN statefp SET DEFAULT '40';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OK_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OK_addr'), lower('OK_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.OK_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OK_addr_least_address ON tiger_data.OK_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OK_addr_tlid_statefp ON tiger_data.OK_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OK_addr_zip ON tiger_data.OK_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.OK_zip_state(CONSTRAINT pk_OK_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.OK_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'OK', '40' FROM tiger_data.OK_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.OK_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '40');"
	${PSQL} -c "vacuum analyze tiger_data.OK_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_41_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_41*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_41*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OR_place(CONSTRAINT pk_OR_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_41_place.dbf tiger_staging.or_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OR_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('OR_place'), lower('OR_place')); ALTER TABLE tiger_data.OR_place ADD CONSTRAINT uidx_OR_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_OR_place_soundex_name ON tiger_data.OR_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_OR_place_the_geom_gist ON tiger_data.OR_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.OR_place ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_41_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_41*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_41*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OR_cousub(CONSTRAINT pk_OR_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_OR_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_41_cousub.dbf tiger_staging.or_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OR_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('OR_cousub'), lower('OR_cousub')); ALTER TABLE tiger_data.OR_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
${PSQL} -c "CREATE INDEX tiger_data_OR_cousub_the_geom_gist ON tiger_data.OR_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OR_cousub_countyfp ON tiger_data.OR_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_41_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_41*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_41*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OR_tract(CONSTRAINT pk_OR_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_41_tract.dbf tiger_staging.or_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OR_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('OR_tract'), lower('OR_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_OR_tract_the_geom_gist ON tiger_data.OR_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.OR_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.OR_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_41_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_41*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_41*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OR_tabblock(CONSTRAINT pk_OR_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_41_tabblock.dbf tiger_staging.or_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OR_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('OR_tabblock'), lower('OR_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.OR_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
${PSQL} -c "CREATE INDEX tiger_data_OR_tabblock_the_geom_gist ON tiger_data.OR_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.OR_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_41_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_41*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_41*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OR_bg(CONSTRAINT pk_OR_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_41_bg.dbf tiger_staging.or_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.OR_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('OR_bg'), lower('OR_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.OR_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
${PSQL} -c "CREATE INDEX tiger_data_OR_bg_the_geom_gist ON tiger_data.OR_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.OR_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_41* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_41*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_41*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OR_zcta5(CONSTRAINT pk_OR_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_OR_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OR_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OR_zcta510'), lower('OR_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.OR_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
${PSQL} -c "CREATE INDEX tiger_data_OR_zcta5_the_geom_gist ON tiger_data.OR_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_41* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_41*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_41*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OR_faces(CONSTRAINT pk_OR_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OR_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OR_faces'), lower('OR_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_OR_faces_the_geom_gist ON tiger_data.OR_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OR_faces_tfid ON tiger_data.OR_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OR_faces_countyfp ON tiger_data.OR_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.OR_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
	${PSQL} -c "vacuum analyze tiger_data.OR_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_41* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_41*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_41*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OR_featnames(CONSTRAINT pk_OR_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.OR_featnames ALTER COLUMN statefp SET DEFAULT '41';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OR_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OR_featnames'), lower('OR_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_OR_featnames_snd_name ON tiger_data.OR_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_OR_featnames_lname ON tiger_data.OR_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_OR_featnames_tlid_statefp ON tiger_data.OR_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.OR_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
${PSQL} -c "vacuum analyze tiger_data.OR_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_41* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_41*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_41*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OR_edges(CONSTRAINT pk_OR_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OR_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OR_edges'), lower('OR_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.OR_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
${PSQL} -c "CREATE INDEX idx_tiger_data_OR_edges_tlid ON tiger_data.OR_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OR_edgestfidr ON tiger_data.OR_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OR_edges_tfidl ON tiger_data.OR_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OR_edges_countyfp ON tiger_data.OR_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_OR_edges_the_geom_gist ON tiger_data.OR_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_OR_edges_zipl ON tiger_data.OR_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.OR_zip_state_loc(CONSTRAINT pk_OR_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.OR_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'OR', '41', p.name FROM tiger_data.OR_edges AS e INNER JOIN tiger_data.OR_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.OR_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_OR_zip_state_loc_place ON tiger_data.OR_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.OR_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
${PSQL} -c "vacuum analyze tiger_data.OR_edges;"
${PSQL} -c "vacuum analyze tiger_data.OR_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.OR_zip_lookup_base(CONSTRAINT pk_OR_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.OR_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'OR', c.name,p.name,'41'  FROM tiger_data.OR_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '41') INNER JOIN tiger_data.OR_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.OR_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.OR_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
${PSQL} -c "CREATE INDEX idx_tiger_data_OR_zip_lookup_base_citysnd ON tiger_data.OR_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_41* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_41*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_41*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.OR_addr(CONSTRAINT pk_OR_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.OR_addr ALTER COLUMN statefp SET DEFAULT '41';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.OR_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('OR_addr'), lower('OR_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.OR_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OR_addr_least_address ON tiger_data.OR_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OR_addr_tlid_statefp ON tiger_data.OR_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_OR_addr_zip ON tiger_data.OR_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.OR_zip_state(CONSTRAINT pk_OR_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.OR_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'OR', '41' FROM tiger_data.OR_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.OR_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '41');"
	${PSQL} -c "vacuum analyze tiger_data.OR_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_42_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_42*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_42*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.PA_place(CONSTRAINT pk_PA_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_42_place.dbf tiger_staging.pa_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.PA_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('PA_place'), lower('PA_place')); ALTER TABLE tiger_data.PA_place ADD CONSTRAINT uidx_PA_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_PA_place_soundex_name ON tiger_data.PA_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_PA_place_the_geom_gist ON tiger_data.PA_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.PA_place ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_42_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_42*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_42*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.PA_cousub(CONSTRAINT pk_PA_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_PA_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_42_cousub.dbf tiger_staging.pa_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.PA_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('PA_cousub'), lower('PA_cousub')); ALTER TABLE tiger_data.PA_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
${PSQL} -c "CREATE INDEX tiger_data_PA_cousub_the_geom_gist ON tiger_data.PA_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_PA_cousub_countyfp ON tiger_data.PA_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_42_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_42*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_42*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.PA_tract(CONSTRAINT pk_PA_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_42_tract.dbf tiger_staging.pa_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.PA_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('PA_tract'), lower('PA_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_PA_tract_the_geom_gist ON tiger_data.PA_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.PA_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.PA_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_42_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_42*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_42*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.PA_tabblock(CONSTRAINT pk_PA_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_42_tabblock.dbf tiger_staging.pa_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.PA_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('PA_tabblock'), lower('PA_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.PA_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
${PSQL} -c "CREATE INDEX tiger_data_PA_tabblock_the_geom_gist ON tiger_data.PA_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.PA_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_42_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_42*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_42*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.PA_bg(CONSTRAINT pk_PA_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_42_bg.dbf tiger_staging.pa_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.PA_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('PA_bg'), lower('PA_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.PA_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
${PSQL} -c "CREATE INDEX tiger_data_PA_bg_the_geom_gist ON tiger_data.PA_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.PA_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_42* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_42*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_42*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.PA_zcta5(CONSTRAINT pk_PA_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_PA_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.PA_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('PA_zcta510'), lower('PA_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.PA_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
${PSQL} -c "CREATE INDEX tiger_data_PA_zcta5_the_geom_gist ON tiger_data.PA_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_42* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_42*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_42*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.PA_faces(CONSTRAINT pk_PA_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.PA_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('PA_faces'), lower('PA_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_PA_faces_the_geom_gist ON tiger_data.PA_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_PA_faces_tfid ON tiger_data.PA_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_PA_faces_countyfp ON tiger_data.PA_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.PA_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
	${PSQL} -c "vacuum analyze tiger_data.PA_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_42* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_42*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_42*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.PA_featnames(CONSTRAINT pk_PA_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.PA_featnames ALTER COLUMN statefp SET DEFAULT '42';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.PA_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('PA_featnames'), lower('PA_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_PA_featnames_snd_name ON tiger_data.PA_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_PA_featnames_lname ON tiger_data.PA_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_PA_featnames_tlid_statefp ON tiger_data.PA_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.PA_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
${PSQL} -c "vacuum analyze tiger_data.PA_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_42* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_42*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_42*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.PA_edges(CONSTRAINT pk_PA_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.PA_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('PA_edges'), lower('PA_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.PA_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
${PSQL} -c "CREATE INDEX idx_tiger_data_PA_edges_tlid ON tiger_data.PA_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_PA_edgestfidr ON tiger_data.PA_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_PA_edges_tfidl ON tiger_data.PA_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_PA_edges_countyfp ON tiger_data.PA_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_PA_edges_the_geom_gist ON tiger_data.PA_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_PA_edges_zipl ON tiger_data.PA_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.PA_zip_state_loc(CONSTRAINT pk_PA_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.PA_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'PA', '42', p.name FROM tiger_data.PA_edges AS e INNER JOIN tiger_data.PA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.PA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_PA_zip_state_loc_place ON tiger_data.PA_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.PA_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
${PSQL} -c "vacuum analyze tiger_data.PA_edges;"
${PSQL} -c "vacuum analyze tiger_data.PA_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.PA_zip_lookup_base(CONSTRAINT pk_PA_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.PA_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'PA', c.name,p.name,'42'  FROM tiger_data.PA_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '42') INNER JOIN tiger_data.PA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.PA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.PA_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
${PSQL} -c "CREATE INDEX idx_tiger_data_PA_zip_lookup_base_citysnd ON tiger_data.PA_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_42* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_42*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_42*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.PA_addr(CONSTRAINT pk_PA_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.PA_addr ALTER COLUMN statefp SET DEFAULT '42';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.PA_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('PA_addr'), lower('PA_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.PA_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_PA_addr_least_address ON tiger_data.PA_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_PA_addr_tlid_statefp ON tiger_data.PA_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_PA_addr_zip ON tiger_data.PA_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.PA_zip_state(CONSTRAINT pk_PA_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.PA_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'PA', '42' FROM tiger_data.PA_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.PA_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '42');"
	${PSQL} -c "vacuum analyze tiger_data.PA_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_44_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_44*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_44*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.RI_place(CONSTRAINT pk_RI_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_44_place.dbf tiger_staging.ri_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.RI_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('RI_place'), lower('RI_place')); ALTER TABLE tiger_data.RI_place ADD CONSTRAINT uidx_RI_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_RI_place_soundex_name ON tiger_data.RI_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_RI_place_the_geom_gist ON tiger_data.RI_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.RI_place ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_44_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_44*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_44*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.RI_cousub(CONSTRAINT pk_RI_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_RI_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_44_cousub.dbf tiger_staging.ri_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.RI_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('RI_cousub'), lower('RI_cousub')); ALTER TABLE tiger_data.RI_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
${PSQL} -c "CREATE INDEX tiger_data_RI_cousub_the_geom_gist ON tiger_data.RI_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_RI_cousub_countyfp ON tiger_data.RI_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_44_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_44*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_44*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.RI_tract(CONSTRAINT pk_RI_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_44_tract.dbf tiger_staging.ri_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.RI_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('RI_tract'), lower('RI_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_RI_tract_the_geom_gist ON tiger_data.RI_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.RI_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.RI_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_44_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_44*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_44*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.RI_tabblock(CONSTRAINT pk_RI_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_44_tabblock.dbf tiger_staging.ri_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.RI_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('RI_tabblock'), lower('RI_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.RI_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
${PSQL} -c "CREATE INDEX tiger_data_RI_tabblock_the_geom_gist ON tiger_data.RI_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.RI_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_44_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_44*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_44*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.RI_bg(CONSTRAINT pk_RI_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_44_bg.dbf tiger_staging.ri_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.RI_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('RI_bg'), lower('RI_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.RI_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
${PSQL} -c "CREATE INDEX tiger_data_RI_bg_the_geom_gist ON tiger_data.RI_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.RI_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_44* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_44*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_44*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.RI_zcta5(CONSTRAINT pk_RI_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_RI_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.RI_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('RI_zcta510'), lower('RI_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.RI_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
${PSQL} -c "CREATE INDEX tiger_data_RI_zcta5_the_geom_gist ON tiger_data.RI_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_44* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_44*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_44*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.RI_faces(CONSTRAINT pk_RI_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.RI_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('RI_faces'), lower('RI_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_RI_faces_the_geom_gist ON tiger_data.RI_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_RI_faces_tfid ON tiger_data.RI_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_RI_faces_countyfp ON tiger_data.RI_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.RI_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
	${PSQL} -c "vacuum analyze tiger_data.RI_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_44* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_44*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_44*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.RI_featnames(CONSTRAINT pk_RI_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.RI_featnames ALTER COLUMN statefp SET DEFAULT '44';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.RI_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('RI_featnames'), lower('RI_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_RI_featnames_snd_name ON tiger_data.RI_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_RI_featnames_lname ON tiger_data.RI_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_RI_featnames_tlid_statefp ON tiger_data.RI_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.RI_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
${PSQL} -c "vacuum analyze tiger_data.RI_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_44* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_44*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_44*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.RI_edges(CONSTRAINT pk_RI_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.RI_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('RI_edges'), lower('RI_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.RI_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
${PSQL} -c "CREATE INDEX idx_tiger_data_RI_edges_tlid ON tiger_data.RI_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_RI_edgestfidr ON tiger_data.RI_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_RI_edges_tfidl ON tiger_data.RI_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_RI_edges_countyfp ON tiger_data.RI_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_RI_edges_the_geom_gist ON tiger_data.RI_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_RI_edges_zipl ON tiger_data.RI_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.RI_zip_state_loc(CONSTRAINT pk_RI_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.RI_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'RI', '44', p.name FROM tiger_data.RI_edges AS e INNER JOIN tiger_data.RI_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.RI_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_RI_zip_state_loc_place ON tiger_data.RI_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.RI_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
${PSQL} -c "vacuum analyze tiger_data.RI_edges;"
${PSQL} -c "vacuum analyze tiger_data.RI_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.RI_zip_lookup_base(CONSTRAINT pk_RI_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.RI_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'RI', c.name,p.name,'44'  FROM tiger_data.RI_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '44') INNER JOIN tiger_data.RI_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.RI_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.RI_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
${PSQL} -c "CREATE INDEX idx_tiger_data_RI_zip_lookup_base_citysnd ON tiger_data.RI_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_44* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_44*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_44*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.RI_addr(CONSTRAINT pk_RI_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.RI_addr ALTER COLUMN statefp SET DEFAULT '44';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.RI_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('RI_addr'), lower('RI_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.RI_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_RI_addr_least_address ON tiger_data.RI_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_RI_addr_tlid_statefp ON tiger_data.RI_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_RI_addr_zip ON tiger_data.RI_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.RI_zip_state(CONSTRAINT pk_RI_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.RI_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'RI', '44' FROM tiger_data.RI_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.RI_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '44');"
	${PSQL} -c "vacuum analyze tiger_data.RI_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_45_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_45*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_45*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SC_place(CONSTRAINT pk_SC_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_45_place.dbf tiger_staging.sc_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.SC_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('SC_place'), lower('SC_place')); ALTER TABLE tiger_data.SC_place ADD CONSTRAINT uidx_SC_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_SC_place_soundex_name ON tiger_data.SC_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_SC_place_the_geom_gist ON tiger_data.SC_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.SC_place ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_45_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_45*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_45*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SC_cousub(CONSTRAINT pk_SC_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_SC_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_45_cousub.dbf tiger_staging.sc_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.SC_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('SC_cousub'), lower('SC_cousub')); ALTER TABLE tiger_data.SC_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
${PSQL} -c "CREATE INDEX tiger_data_SC_cousub_the_geom_gist ON tiger_data.SC_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_SC_cousub_countyfp ON tiger_data.SC_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_45_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_45*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_45*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SC_tract(CONSTRAINT pk_SC_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_45_tract.dbf tiger_staging.sc_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.SC_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('SC_tract'), lower('SC_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_SC_tract_the_geom_gist ON tiger_data.SC_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.SC_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.SC_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_45_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_45*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_45*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SC_tabblock(CONSTRAINT pk_SC_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_45_tabblock.dbf tiger_staging.sc_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.SC_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('SC_tabblock'), lower('SC_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.SC_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
${PSQL} -c "CREATE INDEX tiger_data_SC_tabblock_the_geom_gist ON tiger_data.SC_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.SC_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_45_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_45*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_45*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SC_bg(CONSTRAINT pk_SC_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_45_bg.dbf tiger_staging.sc_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.SC_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('SC_bg'), lower('SC_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.SC_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
${PSQL} -c "CREATE INDEX tiger_data_SC_bg_the_geom_gist ON tiger_data.SC_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.SC_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_45* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_45*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_45*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SC_zcta5(CONSTRAINT pk_SC_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_SC_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.SC_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('SC_zcta510'), lower('SC_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.SC_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
${PSQL} -c "CREATE INDEX tiger_data_SC_zcta5_the_geom_gist ON tiger_data.SC_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_45* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_45*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_45*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SC_faces(CONSTRAINT pk_SC_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.SC_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('SC_faces'), lower('SC_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_SC_faces_the_geom_gist ON tiger_data.SC_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_SC_faces_tfid ON tiger_data.SC_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_SC_faces_countyfp ON tiger_data.SC_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.SC_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
	${PSQL} -c "vacuum analyze tiger_data.SC_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_45* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_45*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_45*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SC_featnames(CONSTRAINT pk_SC_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.SC_featnames ALTER COLUMN statefp SET DEFAULT '45';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.SC_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('SC_featnames'), lower('SC_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_SC_featnames_snd_name ON tiger_data.SC_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_SC_featnames_lname ON tiger_data.SC_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_SC_featnames_tlid_statefp ON tiger_data.SC_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.SC_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
${PSQL} -c "vacuum analyze tiger_data.SC_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_45* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_45*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_45*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SC_edges(CONSTRAINT pk_SC_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.SC_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('SC_edges'), lower('SC_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.SC_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
${PSQL} -c "CREATE INDEX idx_tiger_data_SC_edges_tlid ON tiger_data.SC_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_SC_edgestfidr ON tiger_data.SC_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_SC_edges_tfidl ON tiger_data.SC_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_SC_edges_countyfp ON tiger_data.SC_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_SC_edges_the_geom_gist ON tiger_data.SC_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_SC_edges_zipl ON tiger_data.SC_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.SC_zip_state_loc(CONSTRAINT pk_SC_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.SC_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'SC', '45', p.name FROM tiger_data.SC_edges AS e INNER JOIN tiger_data.SC_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.SC_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_SC_zip_state_loc_place ON tiger_data.SC_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.SC_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
${PSQL} -c "vacuum analyze tiger_data.SC_edges;"
${PSQL} -c "vacuum analyze tiger_data.SC_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.SC_zip_lookup_base(CONSTRAINT pk_SC_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.SC_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'SC', c.name,p.name,'45'  FROM tiger_data.SC_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '45') INNER JOIN tiger_data.SC_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.SC_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.SC_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
${PSQL} -c "CREATE INDEX idx_tiger_data_SC_zip_lookup_base_citysnd ON tiger_data.SC_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_45* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_45*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_45*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SC_addr(CONSTRAINT pk_SC_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.SC_addr ALTER COLUMN statefp SET DEFAULT '45';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.SC_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('SC_addr'), lower('SC_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.SC_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_SC_addr_least_address ON tiger_data.SC_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_SC_addr_tlid_statefp ON tiger_data.SC_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_SC_addr_zip ON tiger_data.SC_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.SC_zip_state(CONSTRAINT pk_SC_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.SC_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'SC', '45' FROM tiger_data.SC_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.SC_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '45');"
	${PSQL} -c "vacuum analyze tiger_data.SC_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_46_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_46*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_46*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SD_place(CONSTRAINT pk_SD_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_46_place.dbf tiger_staging.sd_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.SD_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('SD_place'), lower('SD_place')); ALTER TABLE tiger_data.SD_place ADD CONSTRAINT uidx_SD_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_SD_place_soundex_name ON tiger_data.SD_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_SD_place_the_geom_gist ON tiger_data.SD_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.SD_place ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_46_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_46*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_46*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SD_cousub(CONSTRAINT pk_SD_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_SD_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_46_cousub.dbf tiger_staging.sd_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.SD_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('SD_cousub'), lower('SD_cousub')); ALTER TABLE tiger_data.SD_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
${PSQL} -c "CREATE INDEX tiger_data_SD_cousub_the_geom_gist ON tiger_data.SD_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_SD_cousub_countyfp ON tiger_data.SD_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_46_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_46*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_46*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SD_tract(CONSTRAINT pk_SD_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_46_tract.dbf tiger_staging.sd_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.SD_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('SD_tract'), lower('SD_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_SD_tract_the_geom_gist ON tiger_data.SD_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.SD_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.SD_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_46_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_46*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_46*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SD_tabblock(CONSTRAINT pk_SD_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_46_tabblock.dbf tiger_staging.sd_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.SD_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('SD_tabblock'), lower('SD_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.SD_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
${PSQL} -c "CREATE INDEX tiger_data_SD_tabblock_the_geom_gist ON tiger_data.SD_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.SD_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_46_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_46*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_46*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SD_bg(CONSTRAINT pk_SD_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_46_bg.dbf tiger_staging.sd_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.SD_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('SD_bg'), lower('SD_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.SD_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
${PSQL} -c "CREATE INDEX tiger_data_SD_bg_the_geom_gist ON tiger_data.SD_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.SD_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_46* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_46*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_46*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SD_zcta5(CONSTRAINT pk_SD_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_SD_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.SD_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('SD_zcta510'), lower('SD_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.SD_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
${PSQL} -c "CREATE INDEX tiger_data_SD_zcta5_the_geom_gist ON tiger_data.SD_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_46* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_46*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_46*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SD_faces(CONSTRAINT pk_SD_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.SD_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('SD_faces'), lower('SD_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_SD_faces_the_geom_gist ON tiger_data.SD_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_SD_faces_tfid ON tiger_data.SD_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_SD_faces_countyfp ON tiger_data.SD_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.SD_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
	${PSQL} -c "vacuum analyze tiger_data.SD_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_46* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_46*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_46*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SD_featnames(CONSTRAINT pk_SD_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.SD_featnames ALTER COLUMN statefp SET DEFAULT '46';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.SD_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('SD_featnames'), lower('SD_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_SD_featnames_snd_name ON tiger_data.SD_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_SD_featnames_lname ON tiger_data.SD_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_SD_featnames_tlid_statefp ON tiger_data.SD_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.SD_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
${PSQL} -c "vacuum analyze tiger_data.SD_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_46* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_46*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_46*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SD_edges(CONSTRAINT pk_SD_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.SD_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('SD_edges'), lower('SD_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.SD_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
${PSQL} -c "CREATE INDEX idx_tiger_data_SD_edges_tlid ON tiger_data.SD_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_SD_edgestfidr ON tiger_data.SD_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_SD_edges_tfidl ON tiger_data.SD_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_SD_edges_countyfp ON tiger_data.SD_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_SD_edges_the_geom_gist ON tiger_data.SD_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_SD_edges_zipl ON tiger_data.SD_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.SD_zip_state_loc(CONSTRAINT pk_SD_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.SD_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'SD', '46', p.name FROM tiger_data.SD_edges AS e INNER JOIN tiger_data.SD_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.SD_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_SD_zip_state_loc_place ON tiger_data.SD_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.SD_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
${PSQL} -c "vacuum analyze tiger_data.SD_edges;"
${PSQL} -c "vacuum analyze tiger_data.SD_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.SD_zip_lookup_base(CONSTRAINT pk_SD_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.SD_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'SD', c.name,p.name,'46'  FROM tiger_data.SD_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '46') INNER JOIN tiger_data.SD_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.SD_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.SD_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
${PSQL} -c "CREATE INDEX idx_tiger_data_SD_zip_lookup_base_citysnd ON tiger_data.SD_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_46* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_46*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_46*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.SD_addr(CONSTRAINT pk_SD_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.SD_addr ALTER COLUMN statefp SET DEFAULT '46';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.SD_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('SD_addr'), lower('SD_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.SD_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_SD_addr_least_address ON tiger_data.SD_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_SD_addr_tlid_statefp ON tiger_data.SD_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_SD_addr_zip ON tiger_data.SD_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.SD_zip_state(CONSTRAINT pk_SD_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.SD_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'SD', '46' FROM tiger_data.SD_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.SD_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '46');"
	${PSQL} -c "vacuum analyze tiger_data.SD_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_47_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_47*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_47*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TN_place(CONSTRAINT pk_TN_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_47_place.dbf tiger_staging.tn_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.TN_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('TN_place'), lower('TN_place')); ALTER TABLE tiger_data.TN_place ADD CONSTRAINT uidx_TN_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_TN_place_soundex_name ON tiger_data.TN_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_TN_place_the_geom_gist ON tiger_data.TN_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.TN_place ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_47_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_47*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_47*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TN_cousub(CONSTRAINT pk_TN_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_TN_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_47_cousub.dbf tiger_staging.tn_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.TN_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('TN_cousub'), lower('TN_cousub')); ALTER TABLE tiger_data.TN_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
${PSQL} -c "CREATE INDEX tiger_data_TN_cousub_the_geom_gist ON tiger_data.TN_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_TN_cousub_countyfp ON tiger_data.TN_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_47_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_47*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_47*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TN_tract(CONSTRAINT pk_TN_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_47_tract.dbf tiger_staging.tn_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.TN_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('TN_tract'), lower('TN_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_TN_tract_the_geom_gist ON tiger_data.TN_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.TN_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.TN_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_47_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_47*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_47*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TN_tabblock(CONSTRAINT pk_TN_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_47_tabblock.dbf tiger_staging.tn_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.TN_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('TN_tabblock'), lower('TN_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.TN_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
${PSQL} -c "CREATE INDEX tiger_data_TN_tabblock_the_geom_gist ON tiger_data.TN_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.TN_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_47_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_47*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_47*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TN_bg(CONSTRAINT pk_TN_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_47_bg.dbf tiger_staging.tn_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.TN_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('TN_bg'), lower('TN_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.TN_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
${PSQL} -c "CREATE INDEX tiger_data_TN_bg_the_geom_gist ON tiger_data.TN_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.TN_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_47* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_47*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_47*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TN_zcta5(CONSTRAINT pk_TN_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_TN_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.TN_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('TN_zcta510'), lower('TN_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.TN_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
${PSQL} -c "CREATE INDEX tiger_data_TN_zcta5_the_geom_gist ON tiger_data.TN_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_47* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_47*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_47*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TN_faces(CONSTRAINT pk_TN_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.TN_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('TN_faces'), lower('TN_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_TN_faces_the_geom_gist ON tiger_data.TN_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_TN_faces_tfid ON tiger_data.TN_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_TN_faces_countyfp ON tiger_data.TN_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.TN_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
	${PSQL} -c "vacuum analyze tiger_data.TN_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_47* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_47*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_47*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TN_featnames(CONSTRAINT pk_TN_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.TN_featnames ALTER COLUMN statefp SET DEFAULT '47';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.TN_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('TN_featnames'), lower('TN_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_TN_featnames_snd_name ON tiger_data.TN_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_TN_featnames_lname ON tiger_data.TN_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_TN_featnames_tlid_statefp ON tiger_data.TN_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.TN_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
${PSQL} -c "vacuum analyze tiger_data.TN_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_47* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_47*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_47*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TN_edges(CONSTRAINT pk_TN_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.TN_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('TN_edges'), lower('TN_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.TN_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
${PSQL} -c "CREATE INDEX idx_tiger_data_TN_edges_tlid ON tiger_data.TN_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_TN_edgestfidr ON tiger_data.TN_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_TN_edges_tfidl ON tiger_data.TN_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_TN_edges_countyfp ON tiger_data.TN_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_TN_edges_the_geom_gist ON tiger_data.TN_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_TN_edges_zipl ON tiger_data.TN_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.TN_zip_state_loc(CONSTRAINT pk_TN_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.TN_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'TN', '47', p.name FROM tiger_data.TN_edges AS e INNER JOIN tiger_data.TN_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.TN_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_TN_zip_state_loc_place ON tiger_data.TN_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.TN_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
${PSQL} -c "vacuum analyze tiger_data.TN_edges;"
${PSQL} -c "vacuum analyze tiger_data.TN_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.TN_zip_lookup_base(CONSTRAINT pk_TN_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.TN_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'TN', c.name,p.name,'47'  FROM tiger_data.TN_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '47') INNER JOIN tiger_data.TN_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.TN_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.TN_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
${PSQL} -c "CREATE INDEX idx_tiger_data_TN_zip_lookup_base_citysnd ON tiger_data.TN_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_47* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_47*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_47*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TN_addr(CONSTRAINT pk_TN_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.TN_addr ALTER COLUMN statefp SET DEFAULT '47';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.TN_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('TN_addr'), lower('TN_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.TN_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_TN_addr_least_address ON tiger_data.TN_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_TN_addr_tlid_statefp ON tiger_data.TN_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_TN_addr_zip ON tiger_data.TN_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.TN_zip_state(CONSTRAINT pk_TN_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.TN_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'TN', '47' FROM tiger_data.TN_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.TN_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '47');"
	${PSQL} -c "vacuum analyze tiger_data.TN_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_48_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_48*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_48*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TX_place(CONSTRAINT pk_TX_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_48_place.dbf tiger_staging.tx_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.TX_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('TX_place'), lower('TX_place')); ALTER TABLE tiger_data.TX_place ADD CONSTRAINT uidx_TX_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_TX_place_soundex_name ON tiger_data.TX_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_TX_place_the_geom_gist ON tiger_data.TX_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.TX_place ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_48_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_48*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_48*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TX_cousub(CONSTRAINT pk_TX_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_TX_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_48_cousub.dbf tiger_staging.tx_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.TX_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('TX_cousub'), lower('TX_cousub')); ALTER TABLE tiger_data.TX_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
${PSQL} -c "CREATE INDEX tiger_data_TX_cousub_the_geom_gist ON tiger_data.TX_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_TX_cousub_countyfp ON tiger_data.TX_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_48_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_48*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_48*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TX_tract(CONSTRAINT pk_TX_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_48_tract.dbf tiger_staging.tx_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.TX_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('TX_tract'), lower('TX_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_TX_tract_the_geom_gist ON tiger_data.TX_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.TX_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.TX_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_48_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_48*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_48*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TX_tabblock(CONSTRAINT pk_TX_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_48_tabblock.dbf tiger_staging.tx_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.TX_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('TX_tabblock'), lower('TX_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.TX_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
${PSQL} -c "CREATE INDEX tiger_data_TX_tabblock_the_geom_gist ON tiger_data.TX_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.TX_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_48_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_48*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_48*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TX_bg(CONSTRAINT pk_TX_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_48_bg.dbf tiger_staging.tx_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.TX_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('TX_bg'), lower('TX_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.TX_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
${PSQL} -c "CREATE INDEX tiger_data_TX_bg_the_geom_gist ON tiger_data.TX_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.TX_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_48* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_48*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_48*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TX_zcta5(CONSTRAINT pk_TX_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_TX_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.TX_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('TX_zcta510'), lower('TX_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.TX_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
${PSQL} -c "CREATE INDEX tiger_data_TX_zcta5_the_geom_gist ON tiger_data.TX_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_48* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_48*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_48*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TX_faces(CONSTRAINT pk_TX_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.TX_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('TX_faces'), lower('TX_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_TX_faces_the_geom_gist ON tiger_data.TX_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_TX_faces_tfid ON tiger_data.TX_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_TX_faces_countyfp ON tiger_data.TX_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.TX_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
	${PSQL} -c "vacuum analyze tiger_data.TX_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_48* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_48*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_48*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TX_featnames(CONSTRAINT pk_TX_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.TX_featnames ALTER COLUMN statefp SET DEFAULT '48';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.TX_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('TX_featnames'), lower('TX_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_TX_featnames_snd_name ON tiger_data.TX_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_TX_featnames_lname ON tiger_data.TX_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_TX_featnames_tlid_statefp ON tiger_data.TX_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.TX_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
${PSQL} -c "vacuum analyze tiger_data.TX_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_48* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_48*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_48*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TX_edges(CONSTRAINT pk_TX_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.TX_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('TX_edges'), lower('TX_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.TX_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
${PSQL} -c "CREATE INDEX idx_tiger_data_TX_edges_tlid ON tiger_data.TX_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_TX_edgestfidr ON tiger_data.TX_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_TX_edges_tfidl ON tiger_data.TX_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_TX_edges_countyfp ON tiger_data.TX_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_TX_edges_the_geom_gist ON tiger_data.TX_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_TX_edges_zipl ON tiger_data.TX_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.TX_zip_state_loc(CONSTRAINT pk_TX_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.TX_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'TX', '48', p.name FROM tiger_data.TX_edges AS e INNER JOIN tiger_data.TX_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.TX_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_TX_zip_state_loc_place ON tiger_data.TX_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.TX_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
${PSQL} -c "vacuum analyze tiger_data.TX_edges;"
${PSQL} -c "vacuum analyze tiger_data.TX_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.TX_zip_lookup_base(CONSTRAINT pk_TX_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.TX_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'TX', c.name,p.name,'48'  FROM tiger_data.TX_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '48') INNER JOIN tiger_data.TX_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.TX_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.TX_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
${PSQL} -c "CREATE INDEX idx_tiger_data_TX_zip_lookup_base_citysnd ON tiger_data.TX_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_48* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_48*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_48*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.TX_addr(CONSTRAINT pk_TX_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.TX_addr ALTER COLUMN statefp SET DEFAULT '48';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.TX_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('TX_addr'), lower('TX_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.TX_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_TX_addr_least_address ON tiger_data.TX_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_TX_addr_tlid_statefp ON tiger_data.TX_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_TX_addr_zip ON tiger_data.TX_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.TX_zip_state(CONSTRAINT pk_TX_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.TX_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'TX', '48' FROM tiger_data.TX_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.TX_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '48');"
	${PSQL} -c "vacuum analyze tiger_data.TX_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_49_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_49*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_49*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.UT_place(CONSTRAINT pk_UT_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_49_place.dbf tiger_staging.ut_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.UT_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('UT_place'), lower('UT_place')); ALTER TABLE tiger_data.UT_place ADD CONSTRAINT uidx_UT_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_UT_place_soundex_name ON tiger_data.UT_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_UT_place_the_geom_gist ON tiger_data.UT_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.UT_place ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_49_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_49*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_49*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.UT_cousub(CONSTRAINT pk_UT_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_UT_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_49_cousub.dbf tiger_staging.ut_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.UT_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('UT_cousub'), lower('UT_cousub')); ALTER TABLE tiger_data.UT_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
${PSQL} -c "CREATE INDEX tiger_data_UT_cousub_the_geom_gist ON tiger_data.UT_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_UT_cousub_countyfp ON tiger_data.UT_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_49_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_49*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_49*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.UT_tract(CONSTRAINT pk_UT_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_49_tract.dbf tiger_staging.ut_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.UT_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('UT_tract'), lower('UT_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_UT_tract_the_geom_gist ON tiger_data.UT_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.UT_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.UT_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_49_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_49*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_49*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.UT_tabblock(CONSTRAINT pk_UT_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_49_tabblock.dbf tiger_staging.ut_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.UT_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('UT_tabblock'), lower('UT_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.UT_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
${PSQL} -c "CREATE INDEX tiger_data_UT_tabblock_the_geom_gist ON tiger_data.UT_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.UT_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_49_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_49*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_49*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.UT_bg(CONSTRAINT pk_UT_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_49_bg.dbf tiger_staging.ut_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.UT_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('UT_bg'), lower('UT_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.UT_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
${PSQL} -c "CREATE INDEX tiger_data_UT_bg_the_geom_gist ON tiger_data.UT_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.UT_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_49* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_49*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_49*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.UT_zcta5(CONSTRAINT pk_UT_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_UT_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.UT_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('UT_zcta510'), lower('UT_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.UT_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
${PSQL} -c "CREATE INDEX tiger_data_UT_zcta5_the_geom_gist ON tiger_data.UT_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_49* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_49*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_49*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.UT_faces(CONSTRAINT pk_UT_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.UT_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('UT_faces'), lower('UT_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_UT_faces_the_geom_gist ON tiger_data.UT_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_UT_faces_tfid ON tiger_data.UT_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_UT_faces_countyfp ON tiger_data.UT_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.UT_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
	${PSQL} -c "vacuum analyze tiger_data.UT_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_49* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_49*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_49*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.UT_featnames(CONSTRAINT pk_UT_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.UT_featnames ALTER COLUMN statefp SET DEFAULT '49';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.UT_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('UT_featnames'), lower('UT_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_UT_featnames_snd_name ON tiger_data.UT_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_UT_featnames_lname ON tiger_data.UT_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_UT_featnames_tlid_statefp ON tiger_data.UT_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.UT_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
${PSQL} -c "vacuum analyze tiger_data.UT_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_49* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_49*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_49*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.UT_edges(CONSTRAINT pk_UT_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.UT_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('UT_edges'), lower('UT_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.UT_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
${PSQL} -c "CREATE INDEX idx_tiger_data_UT_edges_tlid ON tiger_data.UT_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_UT_edgestfidr ON tiger_data.UT_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_UT_edges_tfidl ON tiger_data.UT_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_UT_edges_countyfp ON tiger_data.UT_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_UT_edges_the_geom_gist ON tiger_data.UT_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_UT_edges_zipl ON tiger_data.UT_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.UT_zip_state_loc(CONSTRAINT pk_UT_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.UT_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'UT', '49', p.name FROM tiger_data.UT_edges AS e INNER JOIN tiger_data.UT_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.UT_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_UT_zip_state_loc_place ON tiger_data.UT_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.UT_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
${PSQL} -c "vacuum analyze tiger_data.UT_edges;"
${PSQL} -c "vacuum analyze tiger_data.UT_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.UT_zip_lookup_base(CONSTRAINT pk_UT_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.UT_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'UT', c.name,p.name,'49'  FROM tiger_data.UT_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '49') INNER JOIN tiger_data.UT_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.UT_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.UT_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
${PSQL} -c "CREATE INDEX idx_tiger_data_UT_zip_lookup_base_citysnd ON tiger_data.UT_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_49* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_49*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_49*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.UT_addr(CONSTRAINT pk_UT_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.UT_addr ALTER COLUMN statefp SET DEFAULT '49';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.UT_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('UT_addr'), lower('UT_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.UT_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_UT_addr_least_address ON tiger_data.UT_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_UT_addr_tlid_statefp ON tiger_data.UT_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_UT_addr_zip ON tiger_data.UT_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.UT_zip_state(CONSTRAINT pk_UT_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.UT_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'UT', '49' FROM tiger_data.UT_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.UT_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '49');"
	${PSQL} -c "vacuum analyze tiger_data.UT_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_50_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_50*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_50*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VT_place(CONSTRAINT pk_VT_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_50_place.dbf tiger_staging.vt_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.VT_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('VT_place'), lower('VT_place')); ALTER TABLE tiger_data.VT_place ADD CONSTRAINT uidx_VT_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_VT_place_soundex_name ON tiger_data.VT_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_VT_place_the_geom_gist ON tiger_data.VT_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.VT_place ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_50_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_50*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_50*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VT_cousub(CONSTRAINT pk_VT_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_VT_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_50_cousub.dbf tiger_staging.vt_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.VT_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('VT_cousub'), lower('VT_cousub')); ALTER TABLE tiger_data.VT_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
${PSQL} -c "CREATE INDEX tiger_data_VT_cousub_the_geom_gist ON tiger_data.VT_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_VT_cousub_countyfp ON tiger_data.VT_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_50_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_50*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_50*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VT_tract(CONSTRAINT pk_VT_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_50_tract.dbf tiger_staging.vt_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.VT_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('VT_tract'), lower('VT_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_VT_tract_the_geom_gist ON tiger_data.VT_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.VT_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.VT_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_50_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_50*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_50*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VT_tabblock(CONSTRAINT pk_VT_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_50_tabblock.dbf tiger_staging.vt_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.VT_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('VT_tabblock'), lower('VT_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.VT_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
${PSQL} -c "CREATE INDEX tiger_data_VT_tabblock_the_geom_gist ON tiger_data.VT_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.VT_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_50_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_50*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_50*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VT_bg(CONSTRAINT pk_VT_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_50_bg.dbf tiger_staging.vt_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.VT_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('VT_bg'), lower('VT_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.VT_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
${PSQL} -c "CREATE INDEX tiger_data_VT_bg_the_geom_gist ON tiger_data.VT_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.VT_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_50* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_50*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_50*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VT_zcta5(CONSTRAINT pk_VT_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_VT_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.VT_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('VT_zcta510'), lower('VT_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.VT_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
${PSQL} -c "CREATE INDEX tiger_data_VT_zcta5_the_geom_gist ON tiger_data.VT_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_50* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_50*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_50*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VT_faces(CONSTRAINT pk_VT_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.VT_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('VT_faces'), lower('VT_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_VT_faces_the_geom_gist ON tiger_data.VT_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_VT_faces_tfid ON tiger_data.VT_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_VT_faces_countyfp ON tiger_data.VT_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.VT_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
	${PSQL} -c "vacuum analyze tiger_data.VT_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_50* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_50*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_50*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VT_featnames(CONSTRAINT pk_VT_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.VT_featnames ALTER COLUMN statefp SET DEFAULT '50';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.VT_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('VT_featnames'), lower('VT_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_VT_featnames_snd_name ON tiger_data.VT_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_VT_featnames_lname ON tiger_data.VT_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_VT_featnames_tlid_statefp ON tiger_data.VT_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.VT_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
${PSQL} -c "vacuum analyze tiger_data.VT_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_50* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_50*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_50*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VT_edges(CONSTRAINT pk_VT_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.VT_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('VT_edges'), lower('VT_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.VT_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
${PSQL} -c "CREATE INDEX idx_tiger_data_VT_edges_tlid ON tiger_data.VT_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_VT_edgestfidr ON tiger_data.VT_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_VT_edges_tfidl ON tiger_data.VT_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_VT_edges_countyfp ON tiger_data.VT_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_VT_edges_the_geom_gist ON tiger_data.VT_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_VT_edges_zipl ON tiger_data.VT_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.VT_zip_state_loc(CONSTRAINT pk_VT_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.VT_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'VT', '50', p.name FROM tiger_data.VT_edges AS e INNER JOIN tiger_data.VT_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.VT_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_VT_zip_state_loc_place ON tiger_data.VT_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.VT_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
${PSQL} -c "vacuum analyze tiger_data.VT_edges;"
${PSQL} -c "vacuum analyze tiger_data.VT_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.VT_zip_lookup_base(CONSTRAINT pk_VT_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.VT_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'VT', c.name,p.name,'50'  FROM tiger_data.VT_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '50') INNER JOIN tiger_data.VT_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.VT_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.VT_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
${PSQL} -c "CREATE INDEX idx_tiger_data_VT_zip_lookup_base_citysnd ON tiger_data.VT_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_50* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_50*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_50*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VT_addr(CONSTRAINT pk_VT_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.VT_addr ALTER COLUMN statefp SET DEFAULT '50';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.VT_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('VT_addr'), lower('VT_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.VT_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_VT_addr_least_address ON tiger_data.VT_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_VT_addr_tlid_statefp ON tiger_data.VT_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_VT_addr_zip ON tiger_data.VT_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.VT_zip_state(CONSTRAINT pk_VT_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.VT_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'VT', '50' FROM tiger_data.VT_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.VT_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '50');"
	${PSQL} -c "vacuum analyze tiger_data.VT_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_51_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_51*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_51*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VA_place(CONSTRAINT pk_VA_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_51_place.dbf tiger_staging.va_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.VA_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('VA_place'), lower('VA_place')); ALTER TABLE tiger_data.VA_place ADD CONSTRAINT uidx_VA_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_VA_place_soundex_name ON tiger_data.VA_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_VA_place_the_geom_gist ON tiger_data.VA_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.VA_place ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_51_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_51*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_51*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VA_cousub(CONSTRAINT pk_VA_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_VA_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_51_cousub.dbf tiger_staging.va_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.VA_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('VA_cousub'), lower('VA_cousub')); ALTER TABLE tiger_data.VA_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
${PSQL} -c "CREATE INDEX tiger_data_VA_cousub_the_geom_gist ON tiger_data.VA_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_VA_cousub_countyfp ON tiger_data.VA_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_51_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_51*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_51*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VA_tract(CONSTRAINT pk_VA_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_51_tract.dbf tiger_staging.va_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.VA_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('VA_tract'), lower('VA_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_VA_tract_the_geom_gist ON tiger_data.VA_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.VA_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.VA_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_51_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_51*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_51*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VA_tabblock(CONSTRAINT pk_VA_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_51_tabblock.dbf tiger_staging.va_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.VA_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('VA_tabblock'), lower('VA_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.VA_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
${PSQL} -c "CREATE INDEX tiger_data_VA_tabblock_the_geom_gist ON tiger_data.VA_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.VA_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_51_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_51*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_51*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VA_bg(CONSTRAINT pk_VA_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_51_bg.dbf tiger_staging.va_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.VA_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('VA_bg'), lower('VA_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.VA_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
${PSQL} -c "CREATE INDEX tiger_data_VA_bg_the_geom_gist ON tiger_data.VA_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.VA_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_51* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_51*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_51*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VA_zcta5(CONSTRAINT pk_VA_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_VA_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.VA_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('VA_zcta510'), lower('VA_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.VA_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
${PSQL} -c "CREATE INDEX tiger_data_VA_zcta5_the_geom_gist ON tiger_data.VA_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_51* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_51*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_51*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VA_faces(CONSTRAINT pk_VA_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.VA_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('VA_faces'), lower('VA_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_VA_faces_the_geom_gist ON tiger_data.VA_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_VA_faces_tfid ON tiger_data.VA_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_VA_faces_countyfp ON tiger_data.VA_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.VA_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
	${PSQL} -c "vacuum analyze tiger_data.VA_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_51* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_51*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_51*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VA_featnames(CONSTRAINT pk_VA_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.VA_featnames ALTER COLUMN statefp SET DEFAULT '51';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.VA_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('VA_featnames'), lower('VA_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_VA_featnames_snd_name ON tiger_data.VA_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_VA_featnames_lname ON tiger_data.VA_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_VA_featnames_tlid_statefp ON tiger_data.VA_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.VA_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
${PSQL} -c "vacuum analyze tiger_data.VA_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_51* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_51*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_51*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VA_edges(CONSTRAINT pk_VA_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.VA_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('VA_edges'), lower('VA_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.VA_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
${PSQL} -c "CREATE INDEX idx_tiger_data_VA_edges_tlid ON tiger_data.VA_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_VA_edgestfidr ON tiger_data.VA_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_VA_edges_tfidl ON tiger_data.VA_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_VA_edges_countyfp ON tiger_data.VA_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_VA_edges_the_geom_gist ON tiger_data.VA_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_VA_edges_zipl ON tiger_data.VA_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.VA_zip_state_loc(CONSTRAINT pk_VA_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.VA_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'VA', '51', p.name FROM tiger_data.VA_edges AS e INNER JOIN tiger_data.VA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.VA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_VA_zip_state_loc_place ON tiger_data.VA_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.VA_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
${PSQL} -c "vacuum analyze tiger_data.VA_edges;"
${PSQL} -c "vacuum analyze tiger_data.VA_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.VA_zip_lookup_base(CONSTRAINT pk_VA_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.VA_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'VA', c.name,p.name,'51'  FROM tiger_data.VA_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '51') INNER JOIN tiger_data.VA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.VA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.VA_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
${PSQL} -c "CREATE INDEX idx_tiger_data_VA_zip_lookup_base_citysnd ON tiger_data.VA_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_51* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_51*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_51*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.VA_addr(CONSTRAINT pk_VA_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.VA_addr ALTER COLUMN statefp SET DEFAULT '51';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.VA_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('VA_addr'), lower('VA_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.VA_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_VA_addr_least_address ON tiger_data.VA_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_VA_addr_tlid_statefp ON tiger_data.VA_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_VA_addr_zip ON tiger_data.VA_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.VA_zip_state(CONSTRAINT pk_VA_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.VA_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'VA', '51' FROM tiger_data.VA_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.VA_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '51');"
	${PSQL} -c "vacuum analyze tiger_data.VA_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_53_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_53*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_place(CONSTRAINT pk_WA_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_53_place.dbf tiger_staging.wa_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('WA_place'), lower('WA_place')); ALTER TABLE tiger_data.WA_place ADD CONSTRAINT uidx_WA_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_WA_place_soundex_name ON tiger_data.WA_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_WA_place_the_geom_gist ON tiger_data.WA_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.WA_place ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_53_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_53*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_cousub(CONSTRAINT pk_WA_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_WA_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_53_cousub.dbf tiger_staging.wa_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('WA_cousub'), lower('WA_cousub')); ALTER TABLE tiger_data.WA_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX tiger_data_WA_cousub_the_geom_gist ON tiger_data.WA_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_cousub_countyfp ON tiger_data.WA_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_53_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_53*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_tract(CONSTRAINT pk_WA_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_53_tract.dbf tiger_staging.wa_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('WA_tract'), lower('WA_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_WA_tract_the_geom_gist ON tiger_data.WA_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.WA_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.WA_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_53_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_53*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_tabblock(CONSTRAINT pk_WA_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_53_tabblock.dbf tiger_staging.wa_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('WA_tabblock'), lower('WA_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.WA_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX tiger_data_WA_tabblock_the_geom_gist ON tiger_data.WA_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.WA_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_53_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_53*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_bg(CONSTRAINT pk_WA_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_53_bg.dbf tiger_staging.wa_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('WA_bg'), lower('WA_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.WA_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX tiger_data_WA_bg_the_geom_gist ON tiger_data.WA_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.WA_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_53* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_53*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_zcta5(CONSTRAINT pk_WA_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_WA_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WA_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WA_zcta510'), lower('WA_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WA_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX tiger_data_WA_zcta5_the_geom_gist ON tiger_data.WA_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_53* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_53*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_faces(CONSTRAINT pk_WA_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WA_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WA_faces'), lower('WA_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_WA_faces_the_geom_gist ON tiger_data.WA_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WA_faces_tfid ON tiger_data.WA_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WA_faces_countyfp ON tiger_data.WA_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.WA_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
	${PSQL} -c "vacuum analyze tiger_data.WA_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_53* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_53*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_featnames(CONSTRAINT pk_WA_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.WA_featnames ALTER COLUMN statefp SET DEFAULT '53';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WA_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WA_featnames'), lower('WA_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_WA_featnames_snd_name ON tiger_data.WA_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_featnames_lname ON tiger_data.WA_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_featnames_tlid_statefp ON tiger_data.WA_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.WA_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "vacuum analyze tiger_data.WA_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_53* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_53*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_edges(CONSTRAINT pk_WA_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WA_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WA_edges'), lower('WA_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WA_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_edges_tlid ON tiger_data.WA_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_edgestfidr ON tiger_data.WA_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_edges_tfidl ON tiger_data.WA_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_edges_countyfp ON tiger_data.WA_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_WA_edges_the_geom_gist ON tiger_data.WA_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_edges_zipl ON tiger_data.WA_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.WA_zip_state_loc(CONSTRAINT pk_WA_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.WA_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'WA', '53', p.name FROM tiger_data.WA_edges AS e INNER JOIN tiger_data.WA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.WA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_zip_state_loc_place ON tiger_data.WA_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.WA_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "vacuum analyze tiger_data.WA_edges;"
${PSQL} -c "vacuum analyze tiger_data.WA_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.WA_zip_lookup_base(CONSTRAINT pk_WA_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.WA_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'WA', c.name,p.name,'53'  FROM tiger_data.WA_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '53') INNER JOIN tiger_data.WA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.WA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.WA_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_zip_lookup_base_citysnd ON tiger_data.WA_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_53* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_53*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_addr(CONSTRAINT pk_WA_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.WA_addr ALTER COLUMN statefp SET DEFAULT '53';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WA_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WA_addr'), lower('WA_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WA_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WA_addr_least_address ON tiger_data.WA_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WA_addr_tlid_statefp ON tiger_data.WA_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WA_addr_zip ON tiger_data.WA_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.WA_zip_state(CONSTRAINT pk_WA_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.WA_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'WA', '53' FROM tiger_data.WA_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.WA_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
	${PSQL} -c "vacuum analyze tiger_data.WA_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_54_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_54*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_54*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WV_place(CONSTRAINT pk_WV_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_54_place.dbf tiger_staging.wv_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WV_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('WV_place'), lower('WV_place')); ALTER TABLE tiger_data.WV_place ADD CONSTRAINT uidx_WV_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_WV_place_soundex_name ON tiger_data.WV_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_WV_place_the_geom_gist ON tiger_data.WV_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.WV_place ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_54_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_54*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_54*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WV_cousub(CONSTRAINT pk_WV_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_WV_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_54_cousub.dbf tiger_staging.wv_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WV_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('WV_cousub'), lower('WV_cousub')); ALTER TABLE tiger_data.WV_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
${PSQL} -c "CREATE INDEX tiger_data_WV_cousub_the_geom_gist ON tiger_data.WV_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WV_cousub_countyfp ON tiger_data.WV_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_54_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_54*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_54*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WV_tract(CONSTRAINT pk_WV_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_54_tract.dbf tiger_staging.wv_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WV_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('WV_tract'), lower('WV_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_WV_tract_the_geom_gist ON tiger_data.WV_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.WV_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.WV_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_54_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_54*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_54*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WV_tabblock(CONSTRAINT pk_WV_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_54_tabblock.dbf tiger_staging.wv_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WV_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('WV_tabblock'), lower('WV_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.WV_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
${PSQL} -c "CREATE INDEX tiger_data_WV_tabblock_the_geom_gist ON tiger_data.WV_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.WV_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_54_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_54*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_54*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WV_bg(CONSTRAINT pk_WV_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_54_bg.dbf tiger_staging.wv_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WV_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('WV_bg'), lower('WV_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.WV_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
${PSQL} -c "CREATE INDEX tiger_data_WV_bg_the_geom_gist ON tiger_data.WV_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.WV_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_54* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_54*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_54*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WV_zcta5(CONSTRAINT pk_WV_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_WV_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WV_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WV_zcta510'), lower('WV_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WV_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
${PSQL} -c "CREATE INDEX tiger_data_WV_zcta5_the_geom_gist ON tiger_data.WV_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_54* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_54*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_54*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WV_faces(CONSTRAINT pk_WV_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WV_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WV_faces'), lower('WV_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_WV_faces_the_geom_gist ON tiger_data.WV_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WV_faces_tfid ON tiger_data.WV_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WV_faces_countyfp ON tiger_data.WV_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.WV_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
	${PSQL} -c "vacuum analyze tiger_data.WV_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_54* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_54*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_54*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WV_featnames(CONSTRAINT pk_WV_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.WV_featnames ALTER COLUMN statefp SET DEFAULT '54';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WV_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WV_featnames'), lower('WV_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_WV_featnames_snd_name ON tiger_data.WV_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_WV_featnames_lname ON tiger_data.WV_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_WV_featnames_tlid_statefp ON tiger_data.WV_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.WV_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
${PSQL} -c "vacuum analyze tiger_data.WV_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_54* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_54*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_54*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WV_edges(CONSTRAINT pk_WV_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WV_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WV_edges'), lower('WV_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WV_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
${PSQL} -c "CREATE INDEX idx_tiger_data_WV_edges_tlid ON tiger_data.WV_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WV_edgestfidr ON tiger_data.WV_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WV_edges_tfidl ON tiger_data.WV_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WV_edges_countyfp ON tiger_data.WV_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_WV_edges_the_geom_gist ON tiger_data.WV_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WV_edges_zipl ON tiger_data.WV_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.WV_zip_state_loc(CONSTRAINT pk_WV_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.WV_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'WV', '54', p.name FROM tiger_data.WV_edges AS e INNER JOIN tiger_data.WV_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.WV_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_WV_zip_state_loc_place ON tiger_data.WV_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.WV_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
${PSQL} -c "vacuum analyze tiger_data.WV_edges;"
${PSQL} -c "vacuum analyze tiger_data.WV_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.WV_zip_lookup_base(CONSTRAINT pk_WV_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.WV_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'WV', c.name,p.name,'54'  FROM tiger_data.WV_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '54') INNER JOIN tiger_data.WV_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.WV_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.WV_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
${PSQL} -c "CREATE INDEX idx_tiger_data_WV_zip_lookup_base_citysnd ON tiger_data.WV_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_54* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_54*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_54*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WV_addr(CONSTRAINT pk_WV_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.WV_addr ALTER COLUMN statefp SET DEFAULT '54';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WV_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WV_addr'), lower('WV_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WV_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WV_addr_least_address ON tiger_data.WV_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WV_addr_tlid_statefp ON tiger_data.WV_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WV_addr_zip ON tiger_data.WV_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.WV_zip_state(CONSTRAINT pk_WV_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.WV_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'WV', '54' FROM tiger_data.WV_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.WV_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '54');"
	${PSQL} -c "vacuum analyze tiger_data.WV_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_55_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_55*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_55*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WI_place(CONSTRAINT pk_WI_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_55_place.dbf tiger_staging.wi_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WI_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('WI_place'), lower('WI_place')); ALTER TABLE tiger_data.WI_place ADD CONSTRAINT uidx_WI_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_WI_place_soundex_name ON tiger_data.WI_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_WI_place_the_geom_gist ON tiger_data.WI_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.WI_place ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_55_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_55*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_55*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WI_cousub(CONSTRAINT pk_WI_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_WI_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_55_cousub.dbf tiger_staging.wi_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WI_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('WI_cousub'), lower('WI_cousub')); ALTER TABLE tiger_data.WI_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
${PSQL} -c "CREATE INDEX tiger_data_WI_cousub_the_geom_gist ON tiger_data.WI_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WI_cousub_countyfp ON tiger_data.WI_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_55_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_55*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_55*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WI_tract(CONSTRAINT pk_WI_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_55_tract.dbf tiger_staging.wi_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WI_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('WI_tract'), lower('WI_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_WI_tract_the_geom_gist ON tiger_data.WI_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.WI_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.WI_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_55_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_55*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_55*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WI_tabblock(CONSTRAINT pk_WI_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_55_tabblock.dbf tiger_staging.wi_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WI_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('WI_tabblock'), lower('WI_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.WI_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
${PSQL} -c "CREATE INDEX tiger_data_WI_tabblock_the_geom_gist ON tiger_data.WI_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.WI_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_55_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_55*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_55*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WI_bg(CONSTRAINT pk_WI_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_55_bg.dbf tiger_staging.wi_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WI_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('WI_bg'), lower('WI_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.WI_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
${PSQL} -c "CREATE INDEX tiger_data_WI_bg_the_geom_gist ON tiger_data.WI_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.WI_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_55* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_55*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_55*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WI_zcta5(CONSTRAINT pk_WI_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_WI_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WI_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WI_zcta510'), lower('WI_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WI_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
${PSQL} -c "CREATE INDEX tiger_data_WI_zcta5_the_geom_gist ON tiger_data.WI_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_55* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_55*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_55*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WI_faces(CONSTRAINT pk_WI_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WI_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WI_faces'), lower('WI_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_WI_faces_the_geom_gist ON tiger_data.WI_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WI_faces_tfid ON tiger_data.WI_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WI_faces_countyfp ON tiger_data.WI_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.WI_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
	${PSQL} -c "vacuum analyze tiger_data.WI_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_55* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_55*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_55*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WI_featnames(CONSTRAINT pk_WI_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.WI_featnames ALTER COLUMN statefp SET DEFAULT '55';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WI_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WI_featnames'), lower('WI_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_WI_featnames_snd_name ON tiger_data.WI_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_WI_featnames_lname ON tiger_data.WI_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_WI_featnames_tlid_statefp ON tiger_data.WI_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.WI_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
${PSQL} -c "vacuum analyze tiger_data.WI_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_55* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_55*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_55*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WI_edges(CONSTRAINT pk_WI_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WI_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WI_edges'), lower('WI_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WI_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
${PSQL} -c "CREATE INDEX idx_tiger_data_WI_edges_tlid ON tiger_data.WI_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WI_edgestfidr ON tiger_data.WI_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WI_edges_tfidl ON tiger_data.WI_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WI_edges_countyfp ON tiger_data.WI_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_WI_edges_the_geom_gist ON tiger_data.WI_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WI_edges_zipl ON tiger_data.WI_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.WI_zip_state_loc(CONSTRAINT pk_WI_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.WI_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'WI', '55', p.name FROM tiger_data.WI_edges AS e INNER JOIN tiger_data.WI_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.WI_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_WI_zip_state_loc_place ON tiger_data.WI_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.WI_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
${PSQL} -c "vacuum analyze tiger_data.WI_edges;"
${PSQL} -c "vacuum analyze tiger_data.WI_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.WI_zip_lookup_base(CONSTRAINT pk_WI_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.WI_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'WI', c.name,p.name,'55'  FROM tiger_data.WI_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '55') INNER JOIN tiger_data.WI_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.WI_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.WI_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
${PSQL} -c "CREATE INDEX idx_tiger_data_WI_zip_lookup_base_citysnd ON tiger_data.WI_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_55* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_55*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_55*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WI_addr(CONSTRAINT pk_WI_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.WI_addr ALTER COLUMN statefp SET DEFAULT '55';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WI_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WI_addr'), lower('WI_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WI_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WI_addr_least_address ON tiger_data.WI_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WI_addr_tlid_statefp ON tiger_data.WI_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WI_addr_zip ON tiger_data.WI_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.WI_zip_state(CONSTRAINT pk_WI_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.WI_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'WI', '55' FROM tiger_data.WI_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.WI_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '55');"
	${PSQL} -c "vacuum analyze tiger_data.WI_addr;"

cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/PLACE/tl_*_56_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_56*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_56*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WY_place(CONSTRAINT pk_WY_place PRIMARY KEY (plcidfp) ) INHERITS(place);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_56_place.dbf tiger_staging.wy_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WY_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('WY_place'), lower('WY_place')); ALTER TABLE tiger_data.WY_place ADD CONSTRAINT uidx_WY_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_WY_place_soundex_name ON tiger_data.WY_place USING btree (soundex(name));" 
${PSQL} -c "CREATE INDEX tiger_data_WY_place_the_geom_gist ON tiger_data.WY_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.WY_place ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/COUSUB/tl_*_56_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_56*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_56*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WY_cousub(CONSTRAINT pk_WY_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_WY_cousub_gid UNIQUE (gid)) INHERITS(cousub);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_56_cousub.dbf tiger_staging.wy_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WY_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('WY_cousub'), lower('WY_cousub')); ALTER TABLE tiger_data.WY_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
${PSQL} -c "CREATE INDEX tiger_data_WY_cousub_the_geom_gist ON tiger_data.WY_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WY_cousub_countyfp ON tiger_data.WY_cousub USING btree(countyfp);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TRACT/tl_*_56_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_56*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_56*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WY_tract(CONSTRAINT pk_WY_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_56_tract.dbf tiger_staging.wy_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WY_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('WY_tract'), lower('WY_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_WY_tract_the_geom_gist ON tiger_data.WY_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.WY_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.WY_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK/tl_*_56_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_56*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_56*_tabblock.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WY_tabblock(CONSTRAINT pk_WY_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_56_tabblock.dbf tiger_staging.wy_tabblock | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WY_tabblock RENAME geoid TO tabblock_id;  SELECT loader_load_staged_data(lower('WY_tabblock'), lower('WY_tabblock'), '{gid, statefp10, countyfp10, tractce10, blockce10,suffix1ce,blockce,tractce}'::text[]); "
${PSQL} -c "ALTER TABLE tiger_data.WY_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
${PSQL} -c "CREATE INDEX tiger_data_WY_tabblock_the_geom_gist ON tiger_data.WY_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.WY_tabblock;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/BG/tl_*_56_* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_56*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_56*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WY_bg(CONSTRAINT pk_WY_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);" 
${SHP2PGSQL} -c -s 4269 -g the_geom   -W "latin1" tl_2013_56_bg.dbf tiger_staging.wy_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WY_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('WY_bg'), lower('WY_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.WY_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
${PSQL} -c "CREATE INDEX tiger_data_WY_bg_the_geom_gist ON tiger_data.WY_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.WY_bg;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010/*_56* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2010/ZCTA5/2010
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_56*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_56*_zcta510.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WY_zcta5(CONSTRAINT pk_WY_zcta5 PRIMARY KEY (zcta5ce,statefp), CONSTRAINT uidx_WY_zcta5_gid UNIQUE (gid)) INHERITS(zcta5);" 
for z in *zcta510.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WY_zcta510 | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WY_zcta510'), lower('WY_zcta5'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WY_zcta5 ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
${PSQL} -c "CREATE INDEX tiger_data_WY_zcta5_the_geom_gist ON tiger_data.WY_zcta5 USING gist(the_geom);"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FACES/*_56* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_56*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_56*_faces.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WY_faces(CONSTRAINT pk_WY_faces PRIMARY KEY (gid)) INHERITS(faces);" 
for z in *faces.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WY_faces | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WY_faces'), lower('WY_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_WY_faces_the_geom_gist ON tiger_data.WY_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WY_faces_tfid ON tiger_data.WY_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WY_faces_countyfp ON tiger_data.WY_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.WY_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
	${PSQL} -c "vacuum analyze tiger_data.WY_faces;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/*_56* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_56*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_56*_featnames.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WY_featnames(CONSTRAINT pk_WY_featnames PRIMARY KEY (gid)) INHERITS(featnames);ALTER TABLE tiger_data.WY_featnames ALTER COLUMN statefp SET DEFAULT '56';" 
for z in *featnames.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WY_featnames | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WY_featnames'), lower('WY_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_WY_featnames_snd_name ON tiger_data.WY_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_WY_featnames_lname ON tiger_data.WY_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_WY_featnames_tlid_statefp ON tiger_data.WY_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.WY_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
${PSQL} -c "vacuum analyze tiger_data.WY_featnames;"
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/EDGES/*_56* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_56*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_56*_edges.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WY_edges(CONSTRAINT pk_WY_edges PRIMARY KEY (gid)) INHERITS(edges);" 
for z in *edges.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WY_edges | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WY_edges'), lower('WY_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WY_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
${PSQL} -c "CREATE INDEX idx_tiger_data_WY_edges_tlid ON tiger_data.WY_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WY_edgestfidr ON tiger_data.WY_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WY_edges_tfidl ON tiger_data.WY_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WY_edges_countyfp ON tiger_data.WY_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_WY_edges_the_geom_gist ON tiger_data.WY_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WY_edges_zipl ON tiger_data.WY_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.WY_zip_state_loc(CONSTRAINT pk_WY_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.WY_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'WY', '56', p.name FROM tiger_data.WY_edges AS e INNER JOIN tiger_data.WY_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.WY_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_WY_zip_state_loc_place ON tiger_data.WY_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.WY_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
${PSQL} -c "vacuum analyze tiger_data.WY_edges;"
${PSQL} -c "vacuum analyze tiger_data.WY_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.WY_zip_lookup_base(CONSTRAINT pk_WY_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.WY_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'WY', c.name,p.name,'56'  FROM tiger_data.WY_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '56') INNER JOIN tiger_data.WY_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.WY_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.WY_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
${PSQL} -c "CREATE INDEX idx_tiger_data_WY_zip_lookup_base_citysnd ON tiger_data.WY_zip_lookup_base USING btree(soundex(city));" 
cd /gisdata
wget ftp://ftp2.census.gov/geo/tiger/TIGER2013/ADDR/*_56* --no-parent --relative --recursive --level=2 --accept=zip --mirror --reject=html 
cd /gisdata/ftp2.census.gov/geo/tiger/TIGER2013/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_56*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
for z in */tl_*_56*_addr.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WY_addr(CONSTRAINT pk_WY_addr PRIMARY KEY (gid)) INHERITS(addr);ALTER TABLE tiger_data.WY_addr ALTER COLUMN statefp SET DEFAULT '56';" 
for z in *addr.dbf; do 
${SHP2PGSQL}  -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WY_addr | ${PSQL} 
${PSQL} -c "SELECT loader_load_staged_data(lower('WY_addr'), lower('WY_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WY_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WY_addr_least_address ON tiger_data.WY_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WY_addr_tlid_statefp ON tiger_data.WY_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WY_addr_zip ON tiger_data.WY_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.WY_zip_state(CONSTRAINT pk_WY_zip_state PRIMARY KEY(zip,stusps)) INHERITS(zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.WY_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'WY', '56' FROM tiger_data.WY_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.WY_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '56');"
	${PSQL} -c "vacuum analyze tiger_data.WY_addr;"