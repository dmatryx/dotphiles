#!/bin/sh
# Cofigurations for tmux-powerline.

if [ -z "$DEBUG_MODE" ]; then
	# Disable debug mode by default
	export DEBUG_MODE="false"
fi

if [ -z "$PLATFORM" ]; then
	# You platform \in {linux,bsd,mac}.
  if [[ $(uname) == "Darwin" ]] ; then
    export PLATFORM="mac"
  else
    export PLATFORM="linux"
  fi
fi

if [ -z "$USE_PATCHED_FONT" ]; then
	# Useage of patched font for symbols. true or false.
	export USE_PATCHED_FONT="true"
fi
