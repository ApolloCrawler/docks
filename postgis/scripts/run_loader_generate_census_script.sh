#! /usr/bin/env bash

source ./loader_states.sh

su - postgres -c "psql gis -c \"SELECT loader_generate_census_script(ARRAY[$STATES], 'sh');\" -A" | head -n -1 | tail -n +2 > sql/loader_genarate_census_script.sh
