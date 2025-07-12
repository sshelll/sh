#!/usr/bin/env bash

main() {
	local otp_home=${OTP_TOOL_HOME:-$HOME/.otp_secrets}
	local selection=$(ls $otp_home | grep -E '.enc$' | termenu --color=always --name=otps_files)
	if [ -z "$selection" ]; then
		echo -e "\033[36mno target file selected\033[0m" >&2
		return 1
	fi

	local abs_file=$otp_home/$selection

	if [ ! -f "$abs_file" ]; then
		echo -e "\033[31mfile not found: $abs_file\033[0m" >&2
		return 1
	fi

	echo -e "\033[33mDeleting OTP file: $abs_file\033[0m"
	rm -i "$abs_file"
}

main "$@"
