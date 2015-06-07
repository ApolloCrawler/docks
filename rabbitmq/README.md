## RabbitMQ Dockerfile


This repository contains **Dockerfile** of [RabbitMQ](http://www.rabbitmq.com/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/dockerfile/rabbitmq/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).


### Base Docker Image

* [dockerfile/ubuntu](http://dockerfile.github.io/#/ubuntu)


### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/dockerfile/rabbitmq/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull dockerfile/rabbitmq`

   (alternatively, you can build an image from Dockerfile: `docker build -t="dockerfile/rabbitmq" github.com/dockerfile/rabbitmq`)


## Prerequisites

*Usage with VirtualBox (boot2docker-vm)*

```
VBoxManage modifyvm "boot2docker-vm" --natpf1 "guestrabbitmq,tcp,127.0.0.1,5672,,5672"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "guestrabbitmqui,tcp,127.0.0.1,15672,,15672"
```

### Usage

#### Run `rabbitmq-server`

    docker run -d -p 5672:5672 -p 15672:15672 korczis/rabbitmq

#### Run `rabbitmq-server` w/ persistent shared directories.

    docker run -d -p 5672:5672 -p 15672:15672 -v <log-dir>:/data/log -v <data-dir>:/data/mnesia korczis/rabbitmq
