#!/usr/bin/env bash
# Stop hook. Sends an opt-in Telegram summary after Claude finishes a response.
set -uo pipefail

input=$(cat)

token=${TELEGRAM_BOT_TOKEN:-}
chat_id=${TELEGRAM_CHAT_ID:-}
if [[ -z "$token" || -z "$chat_id" ]]; then
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "telegram-notify hook: jq not found, skipping" >&2
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "telegram-notify hook: curl not found, skipping" >&2
  exit 0
fi

session_id=$(printf '%s' "$input" | jq -r '.session_id // "unknown"' 2>/dev/null)
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
if [[ -z "$session_id" ]]; then
  session_id=unknown
fi

context_info=n/a
context_window=${CLAUDE_CONTEXT_WINDOW:-200000}
if ! [[ "$context_window" =~ ^[1-9][0-9]*$ ]]; then
  context_window=200000
fi

if [[ -n "$transcript" && -f "$transcript" ]]; then
  last_usage=$(
    jq -c 'select(.message.usage? != null) | .message.usage' "$transcript" 2>/dev/null |
      tail -n 1
  )

  if [[ -n "$last_usage" ]]; then
    total_tokens=$(
      printf '%s' "$last_usage" |
        jq -r '[
          (.input_tokens // 0),
          (.cache_creation_input_tokens // 0),
          (.cache_read_input_tokens // 0)
        ] | map(if type == "number" then . else 0 end) | add' 2>/dev/null
    )

    if [[ "$total_tokens" =~ ^[0-9]+$ ]]; then
      percent_left=$((100 - (total_tokens * 100 / context_window)))
      if ((percent_left < 0)); then
        percent_left=0
      elif ((percent_left > 100)); then
        percent_left=100
      fi
      context_info="${percent_left}% left (~${total_tokens} tok)"
    fi
  fi
fi

usage_percent=n/a
reset_in=n/a
if command -v ccusage >/dev/null 2>&1; then
  usage_json=$(ccusage blocks --json 2>/dev/null || true)
  usage_block=$(
    printf '%s' "$usage_json" |
      jq -c '
        (if (.blocks | type) == "array" then .blocks
         elif (.data | type) == "array" then .data
         else [] end) as $blocks
        | (($blocks | map(select(.isActive == true)) | last) // ($blocks | last) // empty)
      ' 2>/dev/null
  )

  if [[ -n "$usage_block" ]]; then
    parsed_percent=$(
      printf '%s' "$usage_block" |
        jq -r '.usage.percentUsed // .tokenLimitStatus.percentUsed // .percentUsed // empty' 2>/dev/null
    )
    if [[ -n "$parsed_percent" && "$parsed_percent" != "null" ]]; then
      usage_percent=${parsed_percent%\%}
    fi

    reset_timestamp=$(
      printf '%s' "$usage_block" |
        jq -r '.endTime // .usageLimitResetTime // .blockEnd // empty' 2>/dev/null
    )
    if [[ -n "$reset_timestamp" && "$reset_timestamp" != "null" ]] &&
      command -v node >/dev/null 2>&1; then
      reset_minutes=$(
        node -e '
          const reset = Date.parse(process.argv[1]);
          if (Number.isFinite(reset)) {
            process.stdout.write(String(Math.floor((reset - Date.now()) / 60000)));
          }
        ' "$reset_timestamp" 2>/dev/null
      )
      if [[ "$reset_minutes" =~ ^[0-9]+$ ]]; then
        reset_in="${reset_minutes}m"
      fi
    fi
  fi
fi

message="Session: Claude Code (${session_id:0:8})
Context: $context_info
Usage: ${usage_percent}% (reset in $reset_in)"

if ! curl --silent --show-error --fail --max-time 10 \
  -X POST "https://api.telegram.org/bot${token}/sendMessage" \
  --data-urlencode "chat_id=${chat_id}" \
  --data-urlencode "text=${message}" \
  >/dev/null; then
  echo "telegram-notify hook: Telegram request failed" >&2
fi

exit 0
