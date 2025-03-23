# check if command exists
# $1: command
# example:
# if ! check_command_exists "ls"; then
# 	echo "ls command not found"
# fi
function check_command_exists {
	local cmd=$1
	if ! command -v "$cmd" >/dev/null 2>&1; then
		return 1
	fi
	return 0
}

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

function select_ui_termenu {
	if [ $# -lt 2 ]; then
		echo_stderr "Usage: select_ui <title> <item1> <item2> ..." >&2
		exit 1
	fi

	local title=$1
	shift
	local args=("$@")

	local items=$(printf "%s\n" "${args[@]}")

	echo "$items" | termenu --name "$title" --color always
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

# stop and wait for any key
function press_any_key {
	read -p "Press any key to continue"
}

# echo to stderr
# $@: echo args
function echo_stderr {
	echo "$@" >&2
}

# change color to red foreground
# $@: text
function red_fg {
	echo -e "\033[31m$@\033[0m"
}

# change color to red background and black foreground
# $@: text
function red_bg_black_fg {
	echo -e "\033[41;30m$@\033[0m"
}

# cut prefix
# $1: str
# $2: prefix
# WARN: if $str has blank, use "" to wrap it like: cut_prefix "$str" "$prefix"
function cut_prefix {
	local str=$1
	local prefix=$2
	echo ${str#$prefix}
}

# cut suffix
# $1: str
# $2: suffix
# WARN: if $str has blank, use "" to wrap it like: cut_prefix "$str" "$prefix"
function cut_suffix {
	local str=$1
	local suffix=$2
	echo ${str%$suffix}
}

# format json for http
# $1: text
function fmt_json_for_http {
	if [ -z "$1" ]; then
		echo "null"
	elif check_command_exists 'jq'; then
		echo $(jq -n --arg msg "$1" '$msg')
	else
		echo_stderr "[fmt_json_for_http] jq not found, use raw text"
		echo "$1"
	fi
}
