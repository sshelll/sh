#!/usr/bin/env bash

main() {
	# get target enc file
	# WARN: choose your own path and suffix
	local enc_files=$(ls ~/.otp_secrets | grep -E '.enc$')

	# perphaps you should use fzf to select the file if you don't have echoselect installed?
	# echoselect is a rust tool built by me, you can find it in my github repo
	local selection=$(echo $enc_files | echoselect)
	if [ -z "$selection" ]; then
		echo -e "\033[36mno target file selected\033[0m" >&2
		return 1
	fi

	# WARN: choose your own path
	local abs_file=~/.otp_secrets/$selection

	# decrypt the enc file
	local secret_key
	secret_key=$(openssl enc -d -aes-256-cbc -pbkdf2 -in $abs_file 2>/dev/null) && exit_status=0 || exit_status=$?
	if [ $exit_status -ne 0 ]; then
		echo -e "\033[31mfailed to decrypt $abs_file\033[0m" >&2
		return 1
	fi

	# gen otp and copy to clipboard
 	# use `brew install oath-toolkit` on macOS to install this tool
	local otp=$(oathtool --totp --base32 $secret_key)
	echo -e "\033[33motp: $otp, copied to clipboard...\033[0m" >&2
	echo -n $otp | pbcopy
}

main "$@"
