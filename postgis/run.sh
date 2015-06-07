#!/usr/bin/env bash

docker run -d -p 5432:5432 -v /data/postgres_data:/var/lib/postgresql --name postgis korczis/postgis
