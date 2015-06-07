#!/usr/bin/env bash

docker run -d -p 6379:6379 -v /data --name redis korczis/redis
