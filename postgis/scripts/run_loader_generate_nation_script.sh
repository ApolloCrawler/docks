#! /usr/bin/env bash

source ./loader_states.sh

su - postgres -c "psql gis -c \"SELECT loader_generate_nation_script('sh');\" -A" | head -n -1 | tail -n +2 > sql/loader_genarate_nation_script.sh
