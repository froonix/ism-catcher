#!/bin/bash
set -euf -o pipefail
LC_ALL=C; LANG=C

START=`date -d "$(date -d '- 1 hour' '+%Y-%m-%d %H:00:00')" '+%s'`
END=`date -d "$(date -d '- 1 hour' '+%Y-%m-%d %H:59:59')" '+%s'`

cd /var/lib/munin/CATEGORY

max=$(rrdtool graph /dev/null -s "$START" -e "$END" DEF:v1=HOSTNAME-PLUGIN-FIELD-g.rrd:42:MAX PRINT:v1:MAX:%lf | tail -n +2)
min=$(rrdtool graph /dev/null -s "$START" -e "$END" DEF:v1=HOSTNAME-PLUGIN-FIELD-g.rrd:42:MIN PRINT:v1:MIN:%lf | tail -n +2)
avg=$(rrdtool graph /dev/null -s "$START" -e "$END" DEF:v1=HOSTNAME-PLUGIN-FIELD-g.rrd:42:AVERAGE PRINT:v1:AVERAGE:%lf | tail -n +2)

max=$(printf "%.2f" "$max" | sed 's/\./,/')
min=$(printf "%.2f" "$min" | sed 's/\./,/')
avg=$(printf "%.2f" "$avg" | sed 's/\./,/')

if [[ "$max" =~ ^-?[0-9]+(,[0-9]+)?$ && "$min" =~ ^-?[0-9]+(,[0-9]+)?$ && "$avg" =~ ^-?[0-9]+(,[0-9]+)?$ ]]
then
	ttytter -ssl -keyf="<...>" -status="Temperaturwerte der letzten Stunde: $min / $avg / $max °C (min/avg/max)" &> /dev/null && exit 0
else
	echo "Invalid data from RRD!"; exit 2
fi
