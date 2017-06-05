#!/bin/bash
set -euf -o pipefail

OFFSET="$(($(sed -r 's/[^0-9]+//' <<< "${2:-0}")))"
if [[ "${3:-}" == "test" ]]; then DRY=1; else DRY=0; fi
if [[ "${3:-}" == "graph" ]]; then GRAPH=1; else GRAPH=0; fi

case ${1:-} in

	"day")
		START=`date -d "- $OFFSET days - 1 day 00:00:01" '+%s'`
		END=`date -d "- $OFFSET days - 1 day 23:59:59" '+%s'`
		TITLE="($(date -d @$START '+%d.%m.%Y'))"
		COLOR="0066B3"

		if [[ $OFFSET -eq 0 ]]
		then MESSAGE="Der gestrige Tag im Überblick…"
		else MESSAGE="Der $(date -d @$START '+%d.%m.%Y') im Überblick…"
		fi
		;;

	"week")
		START=`date -d "- $OFFSET weeks last week monday 00:00:01" '+%s'`
		END=`date -d "- $OFFSET weeks last week sunday 23:59:59" '+%s'`
		TITLE="(Woche $(date -d @$START '+%V / %Y'))"
		COLOR="00CC00"

		if [[ $OFFSET -eq 0 ]]
		then MESSAGE="Die vergangene Woche im Überblick…"
		else MESSAGE="Die $(date -d @$START '+%V'). Woche vom Jahr $(date -d @$START '+%Y') im Überblick…"
		fi
		;;

	"month")
		START=`date -d "$(date -d "- $OFFSET months - 1 month" +%Y-%m-01) 00:00:01" '+%s'`
		END=`date -d "- $OFFSET months - $(date +%d) days - 0 month 23:59:59" '+%s'`
		TITLE="($(date -d @$START '+%B %Y'))"
		COLOR="B30000"

		if [[ $OFFSET -eq 0 ]]
		then MESSAGE="Der letzte Monat im Überblick…"
		else MESSAGE="$(date -d @$START '+%B %Y') im Überblick…"
		fi
		;;

	"year")
		START=`date -d "$(date -d "- $OFFSET years - 1 year" +%Y-01-01) 00:00:01" '+%s'`
		END=`date -d "$(date -d "- $OFFSET years - 1 year" +%Y-12-31) 23:59:59" '+%s'`
		TITLE="($(date -d @$START '+%Y'))"
		COLOR="FF8000"

		if [[ $OFFSET -eq 0 ]]
		then MESSAGE="Das letzte Jahr im Überblick…"
		else MESSAGE="Das Jahr $(date -d @$START '+%Y') im Überblick…"
		fi
		;;

	*)
		echo "Usage: $0 {day|week|month|year} [<OFFSET> [{graph|test}]]" >&2
		exit 3
		;;

esac

WIDTH=720; HEIGHT=405
ACCOUNT="__EXAMPLE__"
FIELD="Name des Außensensors"
HEADER="Temperaturverlauf $TITLE"
FOOTER="Twitter @${ACCOUNT}"

if [[ $DRY -eq 1 ]]
then
	echo "Titel: $HEADER"
	echo "Tweet: $MESSAGE"
	echo "Start: $(date -d @$START +%c)"
	echo "Ende:  $(date -d @$END +%c)"
	exit
fi

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

if [[ $GRAPH -eq 1 ]]
then
	mv -f "$TMPFILE" "$TMPFILE.png"
	echo "$TMPFILE.png"
	exit
fi

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
