#!/bin/bash
export PATH=/data/apps/bin:$PATH
cd /home/keno/ka-server/bin
memcached -d -u nobody -m 1024

