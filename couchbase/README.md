[![Join the chat at https://gitter.im/tleyden/couchbase-cluster-go](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/tleyden/couchbase-cluster-go?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Run Couchbase Server under Docker + CoreOS.

## Usage

*Usage with VirtualBox (boot2docker-vm)*

```
VBoxManage modifyvm "boot2docker-vm" --natpf1 "couchbase-8091,tcp,127.0.0.1,8091,,8091"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "couchbase-8092,tcp,127.0.0.1,8092,,8092"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "couchbase-11210,tcp,127.0.0.1,11210,,11210"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "couchbase-11211,tcp,127.0.0.1,11211,,11211"
```

### Run couchbase

    ./run.sh

## Instructions 

* [Couchbase Server](http://tleyden.github.io/blog/2014/11/01/running-couchbase-cluster-under-coreos-on-aws/)

* [Couchbase Server + Sync Gateway](http://tleyden.github.io/blog/2014/12/15/running-a-sync-gateway-cluster-under-coreos-on-aws/)

