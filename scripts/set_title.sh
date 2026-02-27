#!/bin/bash
# set_title.sh — Set the terminal window/tab title
#
# Part of the amplifier-bundle-terminal-title package.
# https://github.com/microsoft/amplifier-bundle-terminal-title
#
# Usage:
#   ./scripts/set_title.sh "Your Title Here"
#
# The script automatically prefixes the title with the current directory name
# (usually the repo/project name) for easy identification across terminals.
#
# Optional: Set CLAUDE_TITLE_PREFIX for a custom prefix (emoji, team name, etc.)
#   export CLAUDE_TITLE_PREFIX="🤖"
#   → Results in: "🤖 my-project | Your Title"

# Exit silently if no title provided (fail-safe)
if [ -z "$1" ]; then
    exit 0
fi

# Sanitize input: remove control characters (0x00-0x1F), limit to 80 chars
TITLE=$(echo "$1" | tr -d '\000-\037' | head -c 80)

if [ -z "$TITLE" ]; then
    exit 0
fi

# Get the current directory name (usually the repo/project name)
DIR_NAME=$(basename "$PWD")

# Build the final title with directory prefix and optional custom prefix
if [ -n "$CLAUDE_TITLE_PREFIX" ]; then
    PREFIX=$(echo "$CLAUDE_TITLE_PREFIX" | tr -d '\000-\037' | head -c 20)
    if [ -n "$PREFIX" ]; then
        FINAL_TITLE="${PREFIX} ${DIR_NAME} | ${TITLE}"
    else
        FINAL_TITLE="${DIR_NAME} | ${TITLE}"
    fi
else
    FINAL_TITLE="${DIR_NAME} | ${TITLE}"
fi

# Set the terminal title using ANSI OSC escape sequences
# Compatible with: macOS Terminal, iTerm2, Alacritty, xterm, rxvt, tmux, screen
case "$TERM" in
    xterm*|rxvt*|screen*|tmux*)
        printf '\033]0;%s\007' "$FINAL_TITLE"
        ;;
    *)
        # Fallback: try anyway, suppress errors (works for iTerm2 and most modern terminals)
        printf '\033]0;%s\007' "$FINAL_TITLE" 2>/dev/null
        ;;
esac
