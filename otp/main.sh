#!/usr/bin/env bash

main() {
	if [[ $# -lt 1 ]]; then
		echo "Usage: $0 {register|gen}"
		exit 1
	fi
	subcommand="$1"
	shift
	case "$subcommand" in
	gen)
		gen_otp
		;;
	register)
		register_otp
		;;
	delete)
		delete_otp
		;;
	*)
		echo "unknown command: $subcommand"
		;;
	esac
}

main "$@"
