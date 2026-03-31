#!/usr/bin/env bash
#
# Setup Claude Code settings (.claude/settings.local.json or global settings.json).
# This script merges the desired settings into the existing file
# without modifying other settings that are already present.
#
# Usage:
#   cd <project-root>
#   bash /path/to/sh/claude/init.sh       # local project settings
#   bash /path/to/sh/claude/init.sh -g    # global settings
#

set -euo pipefail

source $HOME/sh/utils.sh
source $HOME/sh/logger.sh

# Parse options
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

# Set settings file path based on mode
if [[ "$GLOBAL_MODE" == true ]]; then
    SETTINGS_DIR="$HOME/.claude"
    SETTINGS_FILE="${SETTINGS_DIR}/settings.json"
else
    SETTINGS_DIR=".claude"
    SETTINGS_FILE="${SETTINGS_DIR}/settings.local.json"
fi

# Ensure jq is available
if ! command -v jq &>/dev/null; then
    log_error "jq is required but not installed. Install it with: brew install jq"
    exit 1
fi

# The settings to merge
read -r -d '' NEW_SETTINGS <<'EOF' || true
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  },
  "model": "opus[1m]",
  "statusLine": {
    "type": "command",
    "command": "bash $HOME/.claude/statusline-command.sh"
  }
}
EOF

# Create the directory if it doesn't exist
if [[ ! -d "${SETTINGS_DIR}" ]]; then
    mkdir -p "${SETTINGS_DIR}"
    log_info "Created ${SETTINGS_DIR}/ directory"
fi

# Merge settings: existing file * new settings (new settings win on conflict)
if [[ -f "${SETTINGS_FILE}" ]]; then
    EXISTING=$(jq '.' "${SETTINGS_FILE}" 2>/dev/null || echo '{}')
    # Deep merge: use `*` so new settings overwrite existing keys,
    # while preserving keys only present in the existing file.
    MERGED=$(echo "${EXISTING}" | jq --argjson new "${NEW_SETTINGS}" '. * $new')
    log_info "Merging settings into existing ${SETTINGS_FILE}"
else
    MERGED="${NEW_SETTINGS}"
    log_info "Creating new ${SETTINGS_FILE}"
fi

# Write the merged settings back (pretty-printed)
echo "${MERGED}" | jq '.' >"${SETTINGS_FILE}"

log_success "Claude settings have been configured in ${SETTINGS_FILE}"
