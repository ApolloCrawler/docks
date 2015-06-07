#!/usr/bin/env bash

git clone https://github.com/coreos/etcd.git src
cp Dockerfile src/

docker build -t korczis/etcd src
