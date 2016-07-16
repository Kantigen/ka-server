# Introduction

This document attempts to describe the process through which one would set up their own Keno Antigen server for themselves to develop on.

# Docker

Docker documentation can be found [here](https://docs.docker.com).

Docker works with `containers` which you can think of as lightweight
virtual machines. They can be built once, and deployed in many places.

A docker image has been created to allow Keno Antigen to be run from
linux, in OS X or in Windows.

By comparison, if you were to set up a server from scratch, you would
need to do so either on a Linux server, or a virtual machine running
Centos. You would need to install all the packages, including building
Perl and loading all the support libraries and CPAN modules. From
experience this can take up to 16 hours to do and to resolve any issues.

By comparison you can download the docker image (perhaps 10 to 20
minutes) and run up the server in just a few seconds in Docker.

# Containers

This implementation follows the general docker principle of having
one function for each docker container. The containers currently are

  - `ka-mysql-data` - A data only container to persist MySQL data
  - `ka-captcha-data` - A data only container to hold Captcha images
  - `ka-memcached` - Memcache Daemon
  - `ka-redis` - Redis Database
  - `ka-beanstalkd` - Beanstalk Job Queue
  - `ka-mysql-server` - The MySQL Database
  - `ka-server` - The Perl server code
  - `ka-nginx` - The NGINX process that pulls it all together
  - `ka-api-docs` - The Web Socket documentation using Jekyll
  - `ka-web` - The Javascript client code

These docker containers run an a Docker network

  - `ka-network`

# Install Docker

Installation on various systems can be found at [here](https://docs.docker.com/engine/installation/).

Please check the requirements. In particular on Windows you need to
ensure that your PC supports virtualization technology and that it
is enabled in the BIOS.


## Special considerations for OS X

Docker cannot run natively on OS X so it runs in VirtualBox.

By default, the 'default' image created has a base memory of 1024 MB.

You should delete the image created during the installation process and
recreate it with a base memory of 8192 MB.

```bash
docker-machine create --driver virtualbox --virtualbox_memory 8192 default
```

# Creating the Docker Images

The git repository, [ka-server](https://github.com/Kantigen/ka-server), includes a number of scripts to run most of the
docker containers (a further docker container is held in ka-client)

There are also a number of scripts and Dockerfiles which can be used to
create the docker images. Normally you would not need to create a docker image
locally you would download it automatically from dockerhub when you 'run' the
image.


## 1. Create a data-only container for mysql

Normally when you stop or close a container any data within it will be
destroyed. However by using a separate data-only container it is possible
to keep the data even if you stop/kill/rebuild any container using it.

There are two data containers, one for the mysql database and one for
captcha files. These can be created as follows.

```bash
cd ka-server/docker
./create-data.sh
```

## 2. Create the docker network

The Docker network allows the various containers to communicate between
themselves without having to expose ports to the host.

```bash
cd ka-server/docker
./create-network.sh
```

## 3. Run up the various background docker containers

```bash
cd ka-server/docker
./run-beanstalk.sh
./run-memcached.sh
./run-redis.sh
./run-mysql-server.sh
./run-nginx.sh
```

## 4. Run up the main server code

Whereas the other docker containers will run in the background, during
development it is best to run the server code in the foreground (i.e. it
drops you into the container at the command prompt) so that you can run
different server tasks within the container.

**Note**: this won't work if you have not completed the first-use database initialization and config file setup processes documented below.

```bash
cd ka-server/docker
./run-server.sh
```

Once you are at the command prompt you can do various things, e.g.
run all tests:

```
[root@123 ka-server]# prove
```

Or run the server code:

```
[root@123 ka-server]# cd bin
[root@123 bin]# ./startdev.sh
```

# Setup config files

Copy the config files from `ka-server/etc-templates` to `ka-server/etc`. In this guide, we're only iterested in the config files for a docker-based setup. Therefore, the `.template` files can be deleted and `.docker` removed from each file's name.

# Initializing the database

The very first time you try to run Keno Antigen, some database initialization needs to take place.

```bash
cd ka-server/docker
./run-server.sh
```

And do the following:

```
[root@123 ka-server]# cd /home/keno/ka-server/bin
[root@123 bin]# mysql -h ka-mysql-server --password=keno
mysql> source docker.sql
mysql> exit
```

This should create an empty keno database. Then you should populate the starmap:
```
[root@123 ka-server]# cd /home/keno/ka-server/bin/setup
[root@123 setup]# perl init-keno.pl
```

# Connecting to the database

Once setup you can use another terminal to connect using a mysql client.

```
$ cd ka-server/docker
$ ./connect-mysql-server.sh
mysql>
```

Once connected you can do all your normal databasey type stuff.


# Making code changes to the Keno application code

The container running the web application is mapping the directories
`lib`, `bin`, `etc` and `var` from the host. This means that you can make
changes to those files using your normal host environment/editors etc.
You can also use git commands to change branches, commit etc. in your host.
There should be no need to edit files from within your docker container.

However, as normal, if you change your code you will need to restart your
web server (that should still be running in your session where you did the
`./docker_run.sh` command. (ctrl-c, then run `./startdev.sh`).

(It is a common mistake to change your code, and forget to restart your
server and wonder why your changes are not working!)

If you *do* need to make changes in your container (for example to
do SQL queries) then you can use the `./docker_exec.sh` script to open
another session.
