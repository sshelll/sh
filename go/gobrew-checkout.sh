#!/usr/bin/env bash

# for running everywhere once this dir is in $PATH
source $HOME/sh/utils.sh

function main {
	local target_ver=$1
	if [[ -z $target_ver ]]; then
		target_ver=$(read_or_default "version(1.18, 1.20, latest .e.g)" "latest")
	fi
	local cur_ver=$(go version | awk '{print $3}')
	cur_ver=$(echo $cur_ver | awk -F '[go.]+' '{print $2"."$3}')

	if [[ $target_ver == $cur_ver ]]; then
		echo "already at $target_ver"
		exit 0
	fi

	local to_go="go"
	if [[ $target_ver != "latest" ]]; then
		to_go="go@$target_ver"
	fi
	local cmd="brew unlink go@$cur_ver && brew link $to_go"
	eval $cmd

	go version
}

main "$@"
