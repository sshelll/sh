# read or default, if input is empty, use default
# $1: prompt
# $2: default
function read_or_default {
	local prompt=$1
	local default=$2
	local input=''
	read -p "> $prompt: " input
	if [[ -z "$input" && -n "$default" ]]; then
		input=$default
	fi
	echo "$input"
}

# read until not empty when input is empty
# $1: prompt
# $2: default
function must_read_if_empty {
	local prompt=$1
	local input=$2
	if [[ -z "$input" ]]; then
		input=$(must_read "$prompt")
	fi
	echo "$input"
}

# read until not empty
# $1: prompt
function must_read {
	local prompt=$1
	local input=''
	read -p "> $prompt: " input
	while [[ -z "$input" ]]; do
		read -p "> $prompt: " input
	done
	echo "$input"
}

# confirm, exit if not confirmed
# $1: 1 treat empty as confirmed
function confirm {
	local input=""
	read -p "> confirm(y/N): " input
	if [ -z "$input" ]; then
		if [ "$1" = 1 ]; then
			return
		fi
	fi
	if [ "$input" != "y" ]; then
		echo_stderr "exit..."
		exit 0
	fi
}

function press_any_key {
	read -p "Press any key to continue"
}

function echo_stderr {
	echo "$@" >&2
}

function red_fg {
	echo -e "\033[31m$@\033[0m"
}

function red_bg_black_fg {
	echo -e "\033[41;30m$@\033[0m"
}
