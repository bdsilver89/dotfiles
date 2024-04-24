#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Retrieves the current git branch
# -----------------------------------------------------------------------------
git_branch() {
	git symbolic-ref -q --short HEAD
}
