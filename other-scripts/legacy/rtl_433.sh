#!/bin/bash
while true
do
	# Only a simple example. Adjust to your needs...
	rtl_433 -F json -g 20 -Y autolevel | ism-catcher --live
	[[ ${PIPESTATUS[0]} -ne 0 ]] && sleep 30 || sleep 10
done

# Copy everything to a logfile: (don't forget to setup logrotate if required!)
# rtl_433 -F json -g 20 -Y autolevel -M level 2>> ./error.log | tee -a ./archive.json | ism-catcher --live

# Copy each line to STDERR for debugging purposes:
# rtl_433 -F json -g 20 -Y autolevel -M level | tee >(cat >&2) | ism-catcher --live
