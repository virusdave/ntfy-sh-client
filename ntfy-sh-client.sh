#!/usr/bin/env bash

set -euo pipefail

# ntfy.sh CLI client
# Usage: ntfy-sh-client [OPTIONS] [MESSAGE_TEXT...]
#   MESSAGE_TEXT can be passed as arguments or via stdin

NTFY_URL="${NTFY_URL:-https://ntfy.sh}"
TOPIC="${NTFY_SH_TOPIC:-}"

# Initialize curl headers and parameters
declare -a curl_headers=()
message=""
title=""
priority=""
badge=""
declare -a attachments=()

# Display usage
usage() {
  cat << 'EOF'
Usage: ntfy-sh-client [OPTIONS] [MESSAGE...]

Send a notification to ntfy.sh. If MESSAGE is not provided, reads from stdin.

ENVIRONMENT VARIABLES:
  NTFY_SH_TOPIC    Required. The topic to publish to.
  NTFY_URL         Optional. Base URL (default: https://ntfy.sh)

OPTIONS:
  -t, --title TEXT       Notification title
  -p, --priority LEVEL   Priority: min, low, default, high, max (or 1-5)
  -b, --badge EMOJI      Badge/emoji for notification
  -a, --attach URL       Attachment URL (can be used multiple times)
  -h, --help             Show this help message

EXAMPLES:
  NTFY_SH_TOPIC=alerts ntfy-sh-client 'System down!'

  NTFY_SH_TOPIC=backup ntfy-sh-client -t "Backup Complete" -p high "Full backup finished"

  echo "Database migration successful" | NTFY_SH_TOPIC=db ntfy-sh-client -t "Migration"

  NTFY_SH_TOPIC=alerts ntfy-sh-client -b ⚠️ -p high "Warning message"
EOF
  exit "${1:-0}"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage 0
      ;;
    -t|--title)
      title="$2"
      shift 2
      ;;
    -p|--priority)
      priority="$2"
      shift 2
      ;;
    -b|--badge)
      badge="$2"
      shift 2
      ;;
    -a|--attach)
      attachments+=("$2")
      shift 2
      ;;
    --)
      shift
      message="$*"
      break
      ;;
    -*)
      echo "Error: Unknown option $1" >&2
      usage 1
      ;;
    *)
      message="$message${message:+ }$1"
      shift
      ;;
  esac
done

# Check required environment variable
if [[ -z "$TOPIC" ]]; then
  echo "Error: NTFY_SH_TOPIC environment variable is not set" >&2
  exit 1
fi

# If no message provided via arguments, read from stdin
if [[ -z "$message" ]]; then
  if ! tty -s; then
    message="$(cat)"
  else
    echo "Error: No message provided and stdin is not available" >&2
    usage 1
  fi
fi

# Build curl command
curl_cmd=(curl -X POST)

# Add headers
if [[ -n "$title" ]]; then
  curl_headers+=("-H" "Title: $title")
fi

if [[ -n "$priority" ]]; then
  # Convert priority names to numeric values if needed
  case "$priority" in
    min|1) priority="1" ;;
    low|2) priority="2" ;;
    default|3) priority="3" ;;
    high|4) priority="4" ;;
    max|urgent|5) priority="5" ;;
    *)
      if ! [[ "$priority" =~ ^[1-5]$ ]]; then
        echo "Error: Invalid priority '$priority'. Use: min, low, default, high, max (or 1-5)" >&2
        exit 1
      fi
      ;;
  esac
  curl_headers+=("-H" "Priority: $priority")
fi

if [[ -n "$badge" ]]; then
  curl_headers+=("-H" "Tags: $badge")
fi

for attachment in "${attachments[@]}"; do
  curl_headers+=("-H" "Attach: $attachment")
done

# Build the URL with topic
url="${NTFY_URL}/${TOPIC}"

# Send the notification
"${curl_cmd[@]}" \
  "${curl_headers[@]}" \
  -d "$message" \
  "$url"

echo >&2  # newline after curl output
