#!/usr/bin/env ash
set -euxo pipefail

function _prepare() {
	# Ensure that the bot can write to the storage
	chown --recursive free-stuff-matrixbot:free-stuff-matrixbot "$( dirname -- "${STORAGE_FILE}" )"
}

function _run() {
	# Run the bot not as root
	su-exec free-stuff-matrixbot:free-stuff-matrixbot /usr/local/bin/python free-stuff-matrixbot.py
}

function _shell() {
	if [ -n "${*}" ]; then
		su-exec free-stuff-matrixbot:free-stuff-matrixbot /bin/ash -c "${*}"
	else
		su-exec free-stuff-matrixbot:free-stuff-matrixbot /bin/ash
	fi
}

function _sleep() {
	trap : TERM INT
	sleep infinity & wait
}

function _main() {
	case ${1} in
		run)
			_prepare
			_run
		;;
		shell)
			_prepare
			shift
			_shell "${@}"
		;;
		sleep)
			_sleep
		;;
		*)
			echo "Sub command required: run, shell, sleep"
			exit 1
		;;
	esac
}

_main "${@}"
