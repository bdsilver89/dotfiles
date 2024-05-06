#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# Logging
# ----------------------------------------------------------------------------
LOG_VERBOSITY=${LOG_VERBOSITY:-2}
LOG_DATE=${LOG_DATE:-true}
LOG_CONSOLE=${LOG_CONSOLE:-false}
LOG_FORCE_COLORS=${LOG_FORCE_COLORS:-false}

LOG_BG=${1:-1}
LOG_COLOR_DEFAULT="\e[0;39m"
LOG_COLOR_GREY="\e[$BG;30m"
LOG_COLOR_RED="\e[$BG;31m"
LOG_COLOR_GREEN="\e[$BG;32m"
LOG_COLOR_YELLOW="\e[$BG;33m"
LOG_COLOR_BLUE="\e[$BG;34m"
LOG_COLOR_PURPLE="\e[$BG;35m"
LOG_COLOR_CYAN="\e[$BG;36m"

log() {
	if [ -t 1 ]; then
		printf "${@}"
		printf "\n"
	fi
}

log_err() {
	log "${LOG_COLOR_RED}$*${LOG_COLORDEFAULT}"
}

log_warn() {
	log "${LOG_COLOR_YELLOW}$*${LOG_COLOR_DEFAULT}"
}

log_info() {
	log "${LOG_COLOR_GREEN}$*${LOG_COLOR_DEFAULT}"
}

log_status() {
	log "${LOG_COLOR_BLUE}$*${LOG_COLOR_DEFAULT}"
}

log_success() {
	log "${LOG_COLOR_GREEN}\nSuccess${LOG_COLOR_DEFAULT}!"
}

log_failure() {
	log "${LOG_COLOR_RED}\nFailure${LOG_COLOR_DEFAULT}!"
}

log_and_die() {
	local rc=$?
	local msg=${*:-"unknown error"}
	if [ $rc -ne 0 ]; then
		log_err "Aborting - command failed with rc=$rc - $msg"
		exit $rc
	else
		log_err "Aborting - $msg"
		exit $rc
	fi
}
