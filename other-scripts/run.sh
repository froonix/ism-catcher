#!/bin/bash
args=(-M level -g 20 -Y autolevel)
devices=(0)

mode=${1:-}
shift

case "$mode" in
	restart)
		"$0" kill "$@"
		"$0" init "$@"
		;;

	kill)
			for dev in "${devices[@]}"
			do
				[[ -z "$*" || " $* " == *" $dev "* ]] && \
				screen -S "ism-$dev" -X quit
			done
		;;

	init)
		for dev in "${devices[@]}"
		do
			[[ -z "$*" || " $* " == *" $dev "* ]] && \
			screen -S "ism-$dev" -d -m -- "$0" run "$dev"
		done
		;;

	run)
		while true
		do
			rtl_433 -d "${1:-0}" -F json "${args[@]}" | tee >(cat >&2) | ism-catcher --live
			[[ ${PIPESTATUS[0]} -ne 0 ]] && sleep 30 || sleep 10
		done
		;;

	*)
		echo "Usage: $0 init|restart|kill [DEV ...]" >&2
		echo "       $0 run [DEV]" >&2
		exit 1
		;;
esac
