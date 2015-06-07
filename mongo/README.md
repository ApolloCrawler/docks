# mongo

## Prerequisites

*Usage with VirtualBox (boot2docker-vm)*

```
VBoxManage modifyvm "boot2docker-vm" --natpf1 "guestmongodb,tcp,127.0.0.1,27017,,27017"
```

## Usage

## Run mongod

```
docker run -d -p 27017:27017 --name mongodb korczis/mongo
```

## Run mongod w/ persistent/shared directory

```
docker run -d -p 27017:27017 -v <db-dir>:/data/db --name mongodb korczis/mongo
```


## Run mongod w/ HTTP support

```
docker run -d -p 27017:27017 -p 28017:28017 --name mongodb korczis/mongo mongod --rest --httpinterface
```

## Run mongod w/ Smaller default file size

docker run -d -p 27017:27017 --name mongodb korczis/mongo mongod --smallfiles