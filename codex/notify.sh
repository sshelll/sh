#!/usr/bin/env bash

if command -v osascript >/dev/null 2>&1; then
    osascript -e 'display notification "Codex needs your attention" with title "Codex"' >/dev/null 2>&1 || true
fi

if command -v afplay >/dev/null 2>&1; then
    afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 || true
fi

printf '{}\n'
