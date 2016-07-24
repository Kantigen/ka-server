# Kenó Antigen Setup

## Docker

Docker documentation can be found [here](https://docs.docker.com).

Docker works with `containers` which you can think of as lightweight
virtual machines. They can be built once, and deployed in many places.

A docker image has been created to allow Kenó Antigen to be run from
Linux, in OS X or Windows.

To provide some context: if you were to set up a server from scratch, you would
need to do so either on a Linux server, or a virtual machine running
Centos. You would need to install all the packages, including building
Perl and loading all the support libraries and CPAN modules. From
experience this can take up to 16 hours to do and to resolve any issues. By comparison, setting up the Docker stuff takes far less time and energy - I estimate maybe an hour or two.

## 1. Install Docker

Installation on various systems can be found [here](https://docs.docker.com/engine/installation/).

Please check the requirements. In particular on Windows you need to
ensure that your PC supports virtualization technology and that it
is enabled in the BIOS.

### Special considerations for OS X

Docker cannot run natively on OS X so it runs in VirtualBox.

By default, the 'default' image created has a base memory of 1024 MB.

You should delete the image created during the installation process and
recreate it with a base memory of 8192 MB.

```bash
docker-machine create --driver virtualbox --virtualbox_memory 8192 default
```

## 2. Install Docker Compose

Ususally, Docker Compose is much simpler to install than Docker itself. Simply follow the [install instructions](https://docs.docker.com/compose/install/) and you should be good to go.

## 3. Setup Configuration Files

  1. In the root of the repo, create a folder called `etc`
  2. Copy all the files from `etc-docker-templates` into this newly craeted `etc` directory.

## 4. Pull Containers

The next step is to download a bunch of stuff. This next command will download all the Docker images that are needed to run the server.

```bash
# In the root of the repo:
docker-compose pull
```

This command may take quite a while. It depends on the speed of your internet connection.

## 5. Start Everything

This next step starts up the entire server and its dependencies. When doing development work, this is the command to use.

```bash
# In the root of the repo:
docker-compose up
```

As this is your first time running the whole mess, you may see some errors about `ka-server` being unable to connect to the database. We're going to fix that next. For now, leave this running and perform the next step in a new terminal window.

## 6. Setup Database

We're almost there. What remains is to initialize the database and to generate the starmap.

```bash
# Make sure you have `docker-compose up` running in another
# terminal window before continuing on.

# In the repo root:
docker-compose exec ka-websocket /bin/bash

cd /home/keno/ka-server/bin
TERM=xterm mysql -h ka-mysql-server --password=keno

source docker.sql
exit

cd /home/keno/ka-server/bin/setup
perl init-keno.pl
```

This process will take a while depending on the speed of your machine.

## 7. Finishing Up

Once you have the database setup, close that terminal window and go back to where you had `docker-compose up` running. Restart that command and the whole server mess should start up.

## Connecting to the Database

Once you have `docker-compose up` running, connecting to the server and doing whatever database manipulation you desire is simple.

```bash
# Open another terminal and `cd` into the repo root.
./connect-mysql.sh
```

You should now be logged into the database. To test, you can run `select name from empire;` which will output a list of empire's names.

## Connecting to the Server

If there's something you need to run on the server, here's how you do it...

Once you have `docker-compose up` running do the following:

```bash
# Open another terminal and `cd` into the repo root.
./connect-server.sh
```

## Making Changes to the Code

Code changes should be made outside the Docker containers (aka, on the host machine). The `lib`, `bin`, `etc`, and `var` are all made accessible inside the server container for them to work. When making code changes, make sure to restart the `docker-compose up` command.
