#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# OS/platform
# -----------------------------------------------------------------------------
os() {
	local name=$(uname -s)
	if [[ $name =~ MINGW ]] || [[ $os =~ MSYS ]]; then
		echo windows
	elif [[ $name =~ FreeBSD ]]; then
		echo bsd
	elif [[ $name =~ Darwin ]]; then
		echo darwin
	else
		echo $name
	fi
}

platform() {
	if [ -f /etc/debian_version ]; then
		echo debian
	elif [ -f /etc/os-release ]; then
		local id=$(egrep ^ID= /etc/os-release | sed 's/.*=//; s/"//g')
		local version=$(egrep ^VERSION_ID= /etc/os-release | sed 's/.*=//; s/"//g' | cut -d. -f1)
		echo $id$version
	elif [[ $(os) == "darwin" ]]; then
		local id="macos"
		local version=$(sw_vers | egrep ^ProductVersion | sed 's/.*://; s/ //g' | cut -d. -f1)
		echo $id$version
	else
		echo win64
	fi
}

is_windows() {
  [ ${$(platform):0:3} = win ]
}

is_wsl() {
  [[ -n $WSL_DISTO_NAME ]]
}

is_linux() {
  [ $(os) = linux ]
}

is_debian() {
  [ $(platform) = debian ]
}

is_darwin() {
  [ $(os) = darwin ]
}


# -----------------------------------------------------------------------------
# date/time utils
# -----------------------------------------------------------------------------
isodate() {
  date +%Y-%m-%dT%H-%M:%Sz
}

isodate_utc() {
  date -u +%Y-%m-%dT%H-%M:%SZ
}

unixstamp() {
  date +%s
}
