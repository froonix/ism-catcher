#!/bin/sh
while true
do
	# Only a simple example. Adjust to your needs...
	#
	# Timeout is required as workround for issue #136:
	# https://github.com/merbanan/rtl_433/issues/136
	timeout 1000 \
	rtl_433 -R 50 -l 1 -g 50 -F json -T 900 -q 2>/dev/null \
		| ism-catcher --live; sleep 10
done

# Copy everything to a logfile: (don't forget to setup logrotate if required!)
# rtl_433 […] 2>/dev/null | tee -a ~/path/to/archive.json | ism-catcher --live

# Copy each line to STDERR for debugging purposes:
# rtl_433 […] | tee >(cat >&2) | ism-catcher --live
