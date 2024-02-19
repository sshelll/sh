TRACE=1
DEBUG=2
INFO=3
WARN=4
ERROR=5

function log_trace {
	log $TRACE "$1"
}

function log_debug {
	log $DEBUG "$1"
}

function log_info {
	log $INFO "$1"
}

function log_warn {
	log $WARN "$1"
}

function log_error {
	log $ERROR "$1"
}

# log
# $1: level
# $2: message
function log {
	if [ $# -lt 2 ]; then
		echo "Usage: log <level> <message>"
		return
	fi

	local level=$1
	local message=$2
	local date=$(date +"%Y-%m-%d %H:%M:%S:%3N %Z%z")

	if [ $level -eq $TRACE ]; then
		echo -e "$date \033[34mTRACE: $message\033[0m"
	elif [ $level -eq $DEBUG ]; then
		echo -e "$date \033[32mDEBUG: $message\033[0m"
	elif [ $level -eq $INFO ]; then
		echo -e "$date \033[36mINFO: $message\033[0m"
	elif [ $level -eq $WARN ]; then
		echo -e "$date \033[33mWARN: $message\033[0m"
	elif [ $level -eq $ERROR ]; then
		echo -e "$date \033[31mERROR: $message\033[0m"
	else
		echo -e "$date \033[31mUNKNOWN: $message\033[0m"
	fi
}
