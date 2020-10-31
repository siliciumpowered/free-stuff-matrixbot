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

function _dump_storage() {
	cat "${STORAGE_FILE}"
}

function _main() {
	case ${1} in
		run)
			_prepare
			_run
		;;
		dump_storage)
			_prepare
			_dump_storage
		;;
		*)
			echo "Sub command required: run, dump_storage"
			exit 1
		;;
	esac
}

_main "${@}"
