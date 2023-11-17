# select with ui
# $1: title
# $2..n: items
function select_ui {
	if [ $# -lt 2 ]; then
		echo_stderr "Usage: select_ui <title> <item1> <item2> ..."
		exit 1
	fi

	local title=$1
	shift 1
	local args=("$@")

	echo_stderr "$title"
	local idx=0
	for item in "${args[@]}"; do
		echo_stderr "$idx) $item"
		idx=$((idx + 1))
	done

	local input=$(must_read "select")
	while [[ $input -lt 0 || $input -ge $# ]]; do
		input=$(must_read "select")
	done

	echo "${args[$input]}"
}

# unwrap or default, if arg is empty, use default
# $1: arg
# $2: default
function unwrap_or_default {
	local input=$1
	local default=$2
	if [[ -z "$input" ]]; then
		echo "$default"
	else
		echo "$input"
	fi
}

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
