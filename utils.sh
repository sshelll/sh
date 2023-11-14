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

function must_read_if_empty {
    local prompt=$1
    local input=$2
    if [[ -z "$input" ]]; then
        input=$(must_read "$prompt")
    fi
    echo "$input"
}

function must_read {
    local prompt=$1
    local input=''
    read -p "> $prompt: " input
    while [[ -z "$input" ]]; do
        read -p "> $prompt: " input
    done
    echo "$input"
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
