#!/bin/sh

# configure the timeouts you want here
# NOTE: --timer is additive rather than absolute
TIMEOUT_LOWBRIGHT=300  # 5min
TIMEOUT_LOCKSCREEN=300 # 10min (15min)
TIMEOUT_DPMS=300       # 15min (30min)
TIMEOUT_SUSPEND=900    # 45min (75min)

# run xrandr command for all active outputs
xrandr_cmd() {
	echo "for out in \`xrandr | awk '/ connected/{print \$1}'\`;" \
		"do xrandr --output \"\$out\" $@; done"
}

# generate a dbus-send method call command
dbus_cmd() {
	system=0
	while getopts "o:m:s" opt; do
		case "$opt" in
			'o')object="$OPTARG";;
			'm')method="$OPTARG";;
			's')system=1;;
		esac
	done
	shift `expr "$OPTIND" - 1`

	[ -z "$object" -o -z "$method" ] && return 1

	# --print-reply is necessary or the method won't be run (bug?)
	echo "dbus-send `[ "$system" -gt 0 ] && echo '--system '`--print-reply" \
		"--dest=\"$object\" \"/`echo \"$object\" | tr '.' '/'`\"" \
		"\"$object.$method\" $@ >/dev/null"
}

PIDFILE='/tmp/xidlehook.pid'
pid() {
	[ -f "$PIDFILE" ] && PID=`cat "$PIDFILE"` \
		|| PID=`pidof xidlehook`
	echo "$PID"
}

running() {
	kill -0 `pid` 2>/dev/null
	return "$?"
}

start() {

	if running; then
		echo "Already running."
		return 1
	else
		if ! command -v xidlehook 2>&1 >/dev/null; then
			echo "xidlehook not in PATH (is it installed?)"
			return 1
		fi

		echo "Starting xidlehook..."

		# daemonize xidlehook
		nohup setsid xidlehook \
			--detect-sleep \
			--not-when-fullscreen \
			--not-when-audio \
			--timer "$TIMEOUT_LOWBRIGHT" \
				"`xrandr_cmd --brightness .5`" \
				"`xrandr_cmd --brightness 1`" \
			--timer "$TIMEOUT_LOCKSCREEN" \
				"`xrandr_cmd --brightness .1`;`dbus_cmd -oorg.freedesktop.ScreenSaver -mLock`" \
				"`xrandr_cmd --brightness 1`" \
			--timer "$TIMEOUT_DPMS" \
				"xset dpms force standby" \
				"`xrandr_cmd --brightness 1`" \
			--timer "$TIMEOUT_SUSPEND" \
				"`dbus_cmd -s -oorg.freedesktop.login1 -mManager.Suspend boolean:true`" \
				"`xrandr_cmd --brightness 1`; xset s noblank s noexpose -dpms" \
			</dev/null >&/dev/null & \

		[ "$?" -eq 0 ] && echo "$!" > "$PIDFILE" \
			|| (echo "Failed to start xidlehook." && return 1)

		# disable the default X11 behavior
		xset s noblank s noexpose -dpms
	fi

	return 0
}

stop() {
	# attempt to kill the xidlehook process that we
	# forked into the background in start()
	if running; then
		echo "Stopping xidlehook..."
		kill -sTERM `pid` \
			|| (echo "Failed to kill xidlehook." && return 1)

		# make sure the pidfile is gone
		rm "$PIDFILE" 2>/dev/null

		# restore the default X11 behavior
		xset s default +dpms
	else
		echo "Already stopped." && return 1
	fi

	return 0
}

restart() {
	echo "Restarting xidlehook."
	stop || return 1
	start || return 1
}

[ -z "$DISPLAY" ] && echo "No display. Is X11 running?" && exit 1

case "$1" in
	'start') start;;
	'stop') stop;;
	'restart') restart;;
	*) echo "Unknown verb '$1'." && exit 1;;
esac

exit "$?"
