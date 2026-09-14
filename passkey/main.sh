#!/usr/bin/env bash

main() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 {store|fetch|delete}"
        exit 1
    fi
    subcommand="$1"
    shift
    case "$subcommand" in
    store)
        read -p "service: " SERVICE
        read -p "account: " ACCOUNT
        read -s -p "secret: " SECRET
        passkey store "$SERVICE" "$ACCOUNT" "$SECRET"
        unset SECRET
        ;;
    fetch)
        read -p "service: " SERVICE
        read -p "account: " ACCOUNT
        passkey fetch "$SERVICE" "$ACCOUNT"
        ;;
    delete)
        read -p "service: " SERVICE
        read -p "account: " ACCOUNT
        passkey delete "$SERVICE" "$ACCOUNT"
        ;;
    *)
        echo "unknown command: $subcommand"
        ;;
    esac
}

main "$@"
