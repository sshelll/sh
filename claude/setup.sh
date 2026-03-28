#!/usr/bin/env bash
#
# Setup local project Claude Code settings (.claude/settings.local.json).
# This script merges the desired settings into the existing file
# without modifying other settings that are already present.
#
# Usage:
#   cd <project-root>
#   bash /path/to/sh/claude/init.sh
#

set -euo pipefail

# for running everywhere once this dir is in $PATH
source $HOME/sh/utils.sh
source $HOME/sh/logger.sh

# The settings file lives in the current working directory's .claude/ directory
SETTINGS_DIR=".claude"
SETTINGS_FILE="${SETTINGS_DIR}/settings.local.json"

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

# Create the .claude directory if it doesn't exist
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

log_success "Local project Claude settings have been configured in ${SETTINGS_FILE}"
