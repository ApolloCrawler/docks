# etcd

## Prerequisites

*Usage with VirtualBox (boot2docker-vm)*

```
VBoxManage modifyvm "boot2docker-vm" --natpf1 "etcd0,tcp,127.0.0.1,2379,,2379"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "etcd1,tcp,127.0.0.1,4001,,4001"
```

## Usage

## Run etcd

```
docker run -p 4001:4001 korczis/etcd:latest -name etcd
```
