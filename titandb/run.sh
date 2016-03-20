#!/usr/bin/env bash

docker run -d --name titandb -p 8184:8184 -p 8183:8183 -p 8182:8182 korczis/titandb
