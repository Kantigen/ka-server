## A quick start to running KA Expanse Server in Docker

Docker is a quick and easy way (well, compared to trying to build a server from 
scratch!) of getting a development system up and running so you can experiment
and modify the KA Expanse server code.

Please read the documents at ![Install Docker Engine](https://docs.docker.com/engine/installation/)
for your specific system.

(There are a few additional notes below based on our experience of installing Docker)

### Installing on OS X.

On OS X Docker runs in a Virtual Box, the default base memory is 1024 MB but
it might be too little, in which case you need to set higher, say 8196 as 
follows. (Note this will blow-away your current docker containers if you have
any!)

    $ docker-machine rm default
    $ docker-machine create --driver virtualbox --virtualbox-memory 8096 default
    $ eval "$(docker-machine env default)"

### Installing on Windows

To install on Windows follow the instructions at ![Docker Toolbox](https://www.docker.com/products/docker-toolbox)

It is all explained on the above link, but because Docker runs in Linux, it will
install a small Linux Virtual Machine on your windows computer. This VM then hosts 
Docker Engine for you on your Windows system.

Once completed you will have a terminal displaying the $ symbol, this is where
most of the following commands will be run.

Note, by default on Windows the directory that is shown in the console will be
referred to as /c/Users/micro, this is your 'home' directory or ~/

Mostly, you will run the commands in the Linux VM but you can edit the files in
your Windows environment using a suitable editor (notepad for example), the
home directory is at C:\\Users\micro

## Setting up your dev environment

You need to checkout the code from github into a local directory as normal, I
will assume you are checking out to 

    ~/KA-Server-Open

using the commands

    git clone https://github.com/plainblack/KA-Server-Open.git

You need to create some config files for the docker config,

    $ cd ~/KA-Server-Open/etc-templates
    $ cp lacuna.conf.docker ../etc/lacuna.conf
    $ cp log4perl.conf.docker ../etc/log4perl.conf
    $ cp nginx.conf.docker ../etc/nginx.conf

It is unlikely that you will need to change these config files from their
defaults.

### Starting up the docker containers.

In KA-Server-Open there is a sub-directory 'docker'

Setting up a server is as simple as running the following scripts, in this
order

    $ ./create-network.sh
    $ ./create-data.sh
    $ ./run-ka-beanstalk
    $ ./run-ka-memcached.sh
    $ ./run-ka-mysql-server.sh
    $ ./run-ka-nginx
    $ ./run-ka-redis
    $ ./run-ka-websocket

If this has worked, you can now do the following to see what is running.

    $ docker ps -a

This should show you have several docker containers running (i.e. Status
of 'Up xx minutes').

These containers are fairly self-explanatory.

### ka-beanstalk

This runs the beanstalk message queue. It is a standard Docker container.
It is used to run job queues for building upgrade completion, ship arrival
and captcha generation.

### ka-memcached

Again a standard Docker container with default ports.

### ka-mysql-server

This is a standard Docker MySql server. You can also connect to this
container to run a mysql client to inspect and modify your database.

### ka-mysql-data

This is a container, but it is data-only. It is never run. This allows you
to have a persistent database for mysql. You can start/stop other containers
but your mysql data will remain.

If you ever want to 'blow-away' your database and start again then you
should first stop and remove all containers that refer to it (ka-mysql)
and then do the following.

    $ docker rm -v ka-mysql-data
    $ ./create-data.sh

### ka-nginx

This is your web server which exposes the docker port to the outside world.
By default this will run the web server on localhost port 8000 (but this can
be configured).

### ka-server

This is slightly different to the above, when it runs it puts you into
a bash shell to allow you to run commands.

    $ ./run-ka-server.sh

This puts you into the container, at directory

    /home/keno/ka-server/bin

You can start and restart your development web server from within this container. 
There are a number of commands you have to run the first time (see below)
but normally to start and stop your server code you just do the following.

    $ ./startdev.sh

NOTE: On a Windows environment, this can give the following error

    : syntax error at (eval 11) line 1, near "package Plack::Sandbox::2fdata_2fKA_2dServer_2fbin_2flacuna_2epsgi

I have no idea why! If so then just type the contents of the startdev.sh script
and run it directly from the command line. e.g.

    plackup --env development --server Plack::Handler::Standalone --app keno.psgi

But, as I said, the first time there are some setup things to do first. (see below)

## Initial configuration

There are a few things you need to do to set up your development system.

If you have just created your ka-mysql-data container then it will be empty.

The first time you run up the ka-server you need to run a few commands.

    $ cd /home/keno/ka-server/bin
    $ mysql --host=ka-mysql-server -uroot -pkeno
    mysql> source docker.sql
    mysql> exit

This sets up the mysql user account 'keno' which is used by the web application.

(Note that the root mysql account has been given the password 'keno').

You now need to initialize the database. (this will take a few minutes).

    $ cd /home/keno/ka-server/bin/setup
    $ perl init-keno.pl


Captchas no longer need to be generated up-front. They will be generated
on demand (so long as the schedule_captcha.pl script is running).

However, if you don't bother running this script then, although no captcha
will be displayed, the answer is always 1. So there is no need to run the
schedule_captcha.pl script unless you are doing something with the captcha
code itself (unlikely).

You may want to generate the html version of the documentation so you
can view it in your web browser.

    $ cd /home/keno/ka-server/bin
    $ perl generate_docs.pl


## Running schedulers

There are some processes which run as daemons on the server, these control
the arrival of ships or the completion of a building upgrade. These take
their jobs off the beanstalk queue at the time when the task is to be
completed.

Normally you would run these as a daemon as follows.

    $ perl schedule_building.pl --noquiet
    $ perl schedule_ship_arrival.pl --noquiet
    $ perl schedule_captcha.pl --noquiet

The --noquiet argument ensures that their actions are logged into log files
which you can choose to tail in another terminal session.

    /tmp/schedule_building.log
    /tmp/schedule_ship_arrival.log
    /tmp/schedule_captcha.log

## Running the server (finally!)

You can now run the development server

    $ cd /data/KA-Server/bin
    $ ./startdev.sh

This will run in the current terminal session, type ctrl-c to terminate
the script at any time.

If you want to make changes to the code, it is best to do so from your host
environment (simply because you will have better tools and editors).

When you are ready to test, just stop this script with ctrl-c and restart it.

Type 'exit' to exit the docker container and return to the host and stop the container.

