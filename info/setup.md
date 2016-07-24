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

  1. In the root of the repo, run `docker-compose pull`.

This command may take quite a while. It depends on the speed of your internet connection.

## 5. Start Everything

This next command starts up the entire server and its dependencies.

  1. In the root of the repository run `docker-compose up`.

## 6. Setup Database

Now that we've got things started, we alomost have a working server. What remains is to initialize the database and to populate the starmap.

  1. Leave `docker-compose up` running and in another terminal window `cd` into the repo root.
  2. `docker-compose exec ka-websocket /bin/bash`
  3. `cd /home/keno/ka-server/bin`
  4. `mysql -h ka-mysql-server --password=keno`
  5. `source docker.sql`
  6. `exit`
  7. `cd /home/keno/ka-server/bin/setup`
  8. `perl init-keno.pl`

This process will take a while depending on the speed of your machine, but once it's done, it's done! Congratulations on setting up a Keno Antigen server.

## Connecting to the Database

Once you have `docker-compose up` running, connecting to the server and doing whatever database manipulation you desire is simple.

  1. Open another terminal and `cd` into the repo root.
  2. Run `./connect-mysql.sh`.

You should now be logged into the database. To test, you can run `select name from empire;` which will output a list of empire's names.

## Connecting to the Server

If there's something you need to run on the server, here's how you do it...

Once you have `docker-compose up` running do the following:

  1. Open another terminal and `cd` into the repo root.
  2. Run `./connect-server.sh`.

## Making Changes to the Code

Code changes should be made outside the Docker containers (aka, on the host machine). The `lib`, `bin`, `etc`, and `var` are all made accessible inside the server container for them to work. To make changes work, restart the `docker-compose up` command.

And don't worry, it's a common mistake to make a code change and be unable to figure out why it's not taking effect. Everyone forgets from time to time. Just restart `docker-compose up`.
