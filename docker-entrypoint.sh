#!/usr/bin/env ash
set -euxo pipefail

function _prepare() {
	# Ensure that the bot can write to the storage
	chown --recursive free-stuff-matrixbot:free-stuff-matrixbot "$( dirname -- "${STORAGE_FILE}" )"
}

function _run() {
	# Run the bot not as root
	su-exec free-stuff-matrixbot:free-stuff-matrixbot /usr/local/bin/python free-stuff-bot.py
}

function _main() {
	case ${1} in
		run)
			_prepare
			_run
		;;
		*)
			echo "Sub command required: run"
			exit 1
		;;
	esac
}

_main "${@}"
