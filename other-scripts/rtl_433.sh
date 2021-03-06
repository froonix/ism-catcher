#!/bin/bash
while true
do
	# Only a simple example. Adjust to your needs...
	rtl_433 -R 50 -l 1 -g 50 -F json -T 500 -q \
		| ism-catcher --live

	if [[ ${PIPESTATUS[0]} -ne 0 ]]
	then sleep 30; else sleep 10; fi
done

# Copy everything to a logfile: (don't forget to setup logrotate if required!)
# rtl_433 […] 2>> ./error.log | tee -a ./archive.json | ism-catcher --live

# Copy each line to STDERR for debugging purposes:
# rtl_433 […] | tee >(cat >&2) | ism-catcher --live
