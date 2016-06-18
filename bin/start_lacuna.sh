#!/bin/bash
export PATH=/data/apps/bin:$PATH
cd /home/keno/ka-server/bin
start_server --port 80 -- starman --workers 7 --user nobody --group nobody --preload-app lacuna.psgi &

