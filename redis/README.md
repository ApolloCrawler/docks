# Redis Dockerfile


This repository contains **Dockerfile** of [Redis](http://redis.io/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/korczis/redis/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).


## Base Docker Image

* [dockerfile/ubuntu](http://dockerfile.github.io/#/ubuntu)


## Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/korczis/redis/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull korczis/redis`

   (alternatively, you can build an image from Dockerfile: `docker build -t="dockerfile/redis" github.com/korczis/redis`)


## Usage

*Usage with VirtualBox (boot2docker-vm)*

```
VBoxManage modifyvm "boot2docker-vm" --natpf1 "guestredis,tcp,127.0.0.1,6379,,6379"
```

### Run `redis-server`

    docker run -d --name redis -p 6379:6379 korczis/redis

### Run `redis-server` with persistent data directory. (creates `dump.rdb`)

    docker run -d -p 6379:6379 -v <data-dir>:/data --name redis korczis/redis

### Run `redis-server` with persistent data directory and password.

    docker run -d -p 6379:6379 -v <data-dir>:/data --name redis korczis/redis redis-server /etc/redis/redis.conf --requirepass <password>

### Run `redis-cli`

    docker run -it --rm --link redis:redis korczis/redis bash -c 'redis-cli -h redis'
