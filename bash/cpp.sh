#!/usr/bin/env bash

export VCPKG_ROOT="$HOME/vcpkg"

setup_vcpkg() {
	if [ -d $VCPKG_ROOT ]; then
		export PATH="$VCPKG_ROOT:$PATH"
		# TODO: source vcpkg completion for bash or zsh
	fi
}

setup_cmake() {
	export CMAKE_COLOR_DIAGNOSTICS="ON"
	if [ -x "$(command -v ninja)" ]; then
		export CMAKE_GENERATOR="Ninja"
		export CONAN_CMAKE_GENERATOR="Ninja"
	fi
}

setup_cpp() {
	setup_vcpkg
	setup_cmake

	# default to llvm from homebrew over xcode
	if [[ $(uname) = "Darwin" ]]; then
		export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
	fi
}
