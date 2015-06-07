#!/usr/bin/env bash

# see https://github.com/coreos/etcd/blob/master/Documentation/docker_guide.md

docker run -d -p 2379:2379 -p 2380:2380 -p 4001:4001 -p 7001:7001 --name etcd korczis/etcd
