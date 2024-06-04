#!/usr/bin/env bash

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

main() {
	# enter your file name, just name without suffix or path!
	local enc_file=$(must_read "Target enc file name(name only, no suffix or path)")

	# WARN: choose your own path
	enc_file=~/.otp_secrets/$enc_file.otp.enc
	if [ -f $enc_file ]; then
		echo -e "\033[31mfile exist: $enc_file\033[0m" >&2
		exit 1
	fi

	# enter your secret key
	local raw_key=$(must_read "Enter secret key")

	# generate enc file
	# WARN: choose your own path
	local tmp_file=~/.otp_secrets/$(date +%s).enc.tmp
	echo -n $raw_key >$tmp_file
	openssl enc -aes-256-cbc -salt -pbkdf2 -in $tmp_file -out $enc_file

	# remove tmp file for safe
	rm $tmp_file
	echo -e "\033[32m$enc_file created\033[0m"
}

main "$@"
