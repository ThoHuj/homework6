#!/usr/bin/env bash
# Blocks git commands that rewrite history without explicit user approval.
set -euo pipefail

input=$(cat)
command=$(python3 -c "import sys, json; print(json.load(sys.stdin).get('command', ''))" <<<"$input")

# Normalize whitespace for matching.
normalized=$(echo "$command" | tr -s ' ')

if [[ "$normalized" =~ git[[:space:]]+push[[:space:]]+(-f|--force) ]] ||
   [[ "$normalized" =~ git[[:space:]]+push[[:space:]]+[^[:space:]]+[[:space:]]+(-f|--force) ]] ||
   [[ "$normalized" =~ git[[:space:]]+reset[[:space:]]+(--hard|-[^[:space:]]*h[^[:space:]]*) ]] ||
   [[ "$normalized" =~ git[[:space:]]+rebase ]] ||
   [[ "$normalized" =~ git[[:space:]]+filter-(branch|repo) ]]; then
  cat <<EOF
{
  "permission": "deny",
  "user_message": "Blocked: this git command rewrites history. Run it yourself if you really mean it.",
  "agent_message": "This command was blocked by a safety hook. Git history rewrites (force push, hard reset, rebase, filter-branch/repo) require explicit user action. Do not retry — ask the user to run it manually."
}
EOF
  exit 0
fi

echo '{"permission": "allow"}'
exit 0
