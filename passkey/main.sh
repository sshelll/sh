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
        if [ -z "$PASSKEY_HOME" ]; then
            passkey store "$SERVICE" "$ACCOUNT" "$SECRET"
        else
            passkey --keychain "$PASSKEY_HOME" store "$SERVICE" "$ACCOUNT" "$SECRET"
        fi
        unset SECRET
        ;;
    fetch)
        read -p "service: " SERVICE
        read -p "account: " ACCOUNT
        if [ -z "$PASSKEY_HOME" ]; then
            passkey fetch "$SERVICE" "$ACCOUNT"
        else
            passkey --keychain "$PASSKEY_HOME" fetch "$SERVICE" "$ACCOUNT"
        fi
        ;;
    delete)
        read -p "service: " SERVICE
        read -p "account: " ACCOUNT
        if [ -z "$PASSKEY_HOME" ]; then
            passkey delete "$SERVICE" "$ACCOUNT"
        else
            passkey --keychain "$PASSKEY_HOME" delete "$SERVICE" "$ACCOUNT"
        fi
        ;;
    *)
        echo "unknown command: $subcommand"
        ;;
    esac
}

main "$@"
