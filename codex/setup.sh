#!/usr/bin/env bash
#
# Setup Codex settings (.codex files or global ~/.codex files).
# Existing settings and unrelated hooks are preserved.
#
# Usage:
#   cd <project-root>
#   bash /path/to/sh/codex/setup.sh       # local project settings
#   bash /path/to/sh/codex/setup.sh -g    # global settings
#

set -euo pipefail

SCRIPT_SOURCE=${BASH_SOURCE[0]}
while [[ -h "$SCRIPT_SOURCE" ]]; do
    SOURCE_DIR=$(cd -P -- "$(dirname -- "$SCRIPT_SOURCE")" && pwd)
    SCRIPT_SOURCE=$(readlink "$SCRIPT_SOURCE")
    if [[ "$SCRIPT_SOURCE" != /* ]]; then
        SCRIPT_SOURCE="${SOURCE_DIR}/${SCRIPT_SOURCE}"
    fi
done

SCRIPT_DIR=$(cd -P -- "$(dirname -- "$SCRIPT_SOURCE")" && pwd)
REPO_DIR=$(cd -- "${SCRIPT_DIR}/.." && pwd)

source "${REPO_DIR}/utils.sh"
source "${REPO_DIR}/logger.sh"

GLOBAL_MODE=false
while getopts "g" opt; do
    case $opt in
    g) GLOBAL_MODE=true ;;
    *)
        echo "Usage: $0 [-g]" >&2
        exit 1
        ;;
    esac
done

if [[ "$GLOBAL_MODE" == true ]]; then
    SETTINGS_DIR="${CODEX_HOME:-$HOME/.codex}"
else
    SETTINGS_DIR=".codex"
fi

CONFIG_FILE="${SETTINGS_DIR}/config.toml"
HOOKS_FILE="${SETTINGS_DIR}/hooks.json"
NOTIFY_COMMAND="bash \"${SCRIPT_DIR}/notify.sh\""

if ! command -v jq &>/dev/null; then
    log_error "jq is required but not installed. Install it with: brew install jq"
    exit 1
fi

NEW_HOOKS=$(jq -n --arg command "$NOTIFY_COMMAND" '
{
  "hooks": {
    "PermissionRequest": [
      {
        "hooks": [
          {
            "type": "command",
            "command": $command,
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": $command,
            "timeout": 5
          }
        ]
      }
    ]
  }
}')

if [[ ! -d "$SETTINGS_DIR" ]]; then
    mkdir -p "$SETTINGS_DIR"
    log_info "Created ${SETTINGS_DIR}/ directory"
fi

merge_config() {
    local temp_file

    if [[ ! -f "$CONFIG_FILE" ]]; then
        printf '%s\n' 'model_reasoning_effort = "xhigh"' >"$CONFIG_FILE"
        log_info "Created ${CONFIG_FILE}"
        return
    fi

    temp_file=$(mktemp "${CONFIG_FILE}.tmp.XXXXXX")
    if ! awk '
        BEGIN {
            inserted = 0
            in_root = 1
        }
        in_root && /^[[:space:]]*\[/ {
            if (!inserted) {
                print "model_reasoning_effort = \"xhigh\""
                print ""
                inserted = 1
            }
            in_root = 0
        }
        in_root && /^[[:space:]]*model_reasoning_effort[[:space:]]*=/ {
            if (!inserted) {
                print "model_reasoning_effort = \"xhigh\""
                inserted = 1
            }
            next
        }
        { print }
        END {
            if (!inserted) {
                if (NR > 0) {
                    print ""
                }
                print "model_reasoning_effort = \"xhigh\""
            }
        }
    ' "$CONFIG_FILE" >"$temp_file"; then
        rm -f "$temp_file"
        log_error "Failed to merge ${CONFIG_FILE}"
        exit 1
    fi

    mv "$temp_file" "$CONFIG_FILE"
    log_info "Merged settings into existing ${CONFIG_FILE}"
}

merge_hooks() {
    local existing
    local merged
    local temp_file

    if [[ -f "$HOOKS_FILE" ]]; then
        if ! existing=$(jq '.' "$HOOKS_FILE" 2>/dev/null); then
            log_error "${HOOKS_FILE} is not valid JSON; leaving it unchanged"
            exit 1
        fi

        merged=$(jq --argjson new "$NEW_HOOKS" --arg command "$NOTIFY_COMMAND" '
            .hooks //= {} |
            reduce ["PermissionRequest", "Stop"][] as $event (.;
                .hooks[$event] = (
                    [(.hooks[$event] // [])[] |
                        select(any(.hooks[]?; .command == $command) | not)]
                    + $new.hooks[$event]
                )
            )
        ' <<<"$existing")
        log_info "Merged hooks into existing ${HOOKS_FILE}"
    else
        merged="$NEW_HOOKS"
        log_info "Created ${HOOKS_FILE}"
    fi

    temp_file=$(mktemp "${HOOKS_FILE}.tmp.XXXXXX")
    printf '%s\n' "$merged" | jq '.' >"$temp_file"
    mv "$temp_file" "$HOOKS_FILE"
}

merge_config
merge_hooks

log_warn "Open /hooks in Codex to review and trust the new command hooks"
log_success "Codex settings have been configured in ${SETTINGS_DIR}"
