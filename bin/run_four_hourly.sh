#!/bin/bash
export PATH=/data/apps/bin:$PATH
cd /home/keno/ka-server/bin
perl summarize_spies.pl >>/var/log/four_hourly.log 2>>/var/log/four_hourly.log

