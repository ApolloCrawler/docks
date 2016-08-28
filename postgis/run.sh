#!/usr/bin/env bash

docker run -d --name postgis -e POSTGRES_PASSWORD=postgres -d korczis/postgis