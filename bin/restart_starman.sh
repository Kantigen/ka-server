#!/bin/bash
export PATH=/data/apps/bin:$PATH
cd /home/keno/ka-server/bin
perl generate_docs.pl > /dev/null
killall -HUP start_server
