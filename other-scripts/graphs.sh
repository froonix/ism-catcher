#!/bin/bash
set -euf -o pipefail

case ${1:-} in
	"day")
		START=`date -d '- 1 day 00:00:01' '+%s'`
		END=`date -d '- 1 day 23:59:59' '+%s'`
		MESSAGE="Der gestrige Tag im Überblick…"
		TITLE="($(date -d @$START '+%d.%m.%Y'))"
		COLOR="0066B3"
		;;
	"week")
		START=`date -d 'last monday - 1 week 00:00:01' '+%s'`
		END=`date -d 'last monday - 1 day 23:59:59' '+%s'`
		MESSAGE="Die vergangene Woche im Überblick…"
		TITLE="(Woche $(date -d @$START '+%V / %Y'))"
		COLOR="00CC00"
		;;
	"month")
		START=`date -d "$(date -d "- 1 month" +%Y-%m-01) 00:00:01" '+%s'`
		END=`date -d "- $(date +%d) days - 0 month 23:59:59" '+%s'`
		MESSAGE="Der letzte Monat im Überblick…"
		TITLE="($(date -d @$START '+%B %Y'))"
		COLOR="B30000"
		;;
	"year")
		START=`date -d "$(date -d "- 1 year" +%Y-01-01) 00:00:01" '+%s'`
		END=`date -d "$(date -d "- 1 year" +%Y-12-31) 23:59:59" '+%s'`
		MESSAGE="Das letzte Jahr im Überblick…"
		TITLE="($(date -d @$START '+%Y'))"
		COLOR="FF8000"
		;;
	*)
		echo "Usage: $0 {day|week|month|year}" >&2
		exit 3
		;;
esac

WIDTH=720; HEIGHT=405
ACCOUNT="__EXAMPLE__"
FIELD="Name des Außensensors"
HEADER="Temperaturverlauf $TITLE"
FOOTER="Twitter @${ACCOUNT}"

TMPFILE=`tempfile`
rrdtool graph "$TMPFILE" --imgformat PNG --width "$WIDTH" --height "$HEIGHT" \
  --start "$START" --end "$END" --title "$HEADER" -W "$FOOTER" --vertical-label '°C' --border 0 \
  --disable-rrdtool-tag --full-size-mode --slope-mode --base 1000 -l -15 -u 45 \
  --font 'DEFAULT:0:DejaVuSans,DejaVu Sans,DejaVu LGC Sans,Bitstream Vera Sans' \
  --font 'LEGEND:7:DejaVuSansMono,DejaVu Sans Mono,DejaVu LGC Sans Mono,Bitstream Vera Sans Mono,monospace' \
  --color 'BACK#F0F0F0' --color 'FRAME#F0F0F0' --color 'CANVAS#FFFFFF' --color 'FONT#666666' --color 'AXIS#CFD6F8' --color 'ARROW#CFD6F8' \
    'COMMENT:\r' 'COMMENT:                   ' 'COMMENT:Minimum' 'COMMENT:Durchschnitt' 'COMMENT:Maximum\j' \
    'DEF:max=/var/lib/munin/CATEGORY/HOSTNAME-PLUGIN-FIELD-g.rrd:42:MAX' \
    'DEF:min=/var/lib/munin/CATEGORY/HOSTNAME-PLUGIN-FIELD-g.rrd:42:MIN' \
    'DEF:avg=/var/lib/munin/CATEGORY/HOSTNAME-PLUGIN-FIELD-g.rrd:42:AVERAGE' \
    'LINE1:0#BEBEBE' "LINE3:avg#${COLOR}:${FIELD}" \
    'GPRINT:min:MIN:%.2lf%s' \
    'GPRINT:avg:AVERAGE:%.2lf%s' \
    'GPRINT:max:MAX:%.2lf%s\j' \
    'COMMENT:\r' >/dev/null

twurl set default "$ACCOUNT"
MEDIA_ID=`twurl -H "upload.twitter.com" -X POST "/1.1/media/upload.json" --file "$TMPFILE" --file-field "media" | jq -r '.media_id_string'`

if [[ ! "$MEDIA_ID" =~ ^[0-9]+$ ]]
then
	echo "Failed to upload image!" 1>&2
	exit 1
fi

twurl set default "$ACCOUNT"
TWEET_ID=`twurl "/1.1/statuses/update.json" -d "media_ids=${MEDIA_ID}&status=${MESSAGE}"  | jq -r '.id'`

if [[ ! "$TWEET_ID" =~ ^[0-9]+$ ]]
then
	echo "Failed to send tweet!" 1>&2
	exit 1
fi

rm -f "$TMPFILE"
