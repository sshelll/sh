#!/usr/bin/env bash

# for running everywhere once this dir is in $PATH
source $HOME/sh/utils.sh

# for lsp
source ../utils.sh

function main {
	local host=$(must_read_if_empty "host(localhost:8080 .e.g)" $1)
	if [ -z $host ]; then
		echo "no host"
		exit 1
	fi

	local opts=("allocs" "block" "cmdline" "goroutine" "heap" "mutex" "profile" "threadcreate")
	local target=$(select_ui "pprof opts" ${opts[@]})

	local cmd=$(echo "curl http://$host/debug/pprof/$target >$target.pprof")
	echo "CMD: $cmd"
	confirm

	eval $cmd
}

main "$@"
