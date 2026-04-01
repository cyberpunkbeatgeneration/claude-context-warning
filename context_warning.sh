#!/bin/bash
# Claude Code Status Line — Context Window Usage Monitor
#
# Shows real-time context window usage percentage with color-coded warnings.
# Designed for Claude Code's statusLine feature.
#
# Thresholds:
#   Green ✓    — < 60%
#   Yellow ⚡  — 60-80%
#   Red ⚠     — 80-95%
#   Red blink 🔴 — ≥ 95% (critical, shows exact percentage)
#
# After /compact or /clear, the indicator updates automatically
# on the next assistant response.

input=$(cat)

PCT=$(echo "$input" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    pct = data.get('context_window', {}).get('used_percentage', 0)
    print(int(pct))
except:
    print(0)
")

RESET='\033[0m'

if [ "$PCT" -ge 95 ]; then
  COLOR='\033[1;5;31m'
  echo -e "${COLOR}🔴 CONTEXT ${PCT}% — /compact or /clear now${RESET}"
elif [ "$PCT" -ge 80 ]; then
  COLOR='\033[31m'
  echo -e "${COLOR}⚠ Context: ${PCT}%${RESET}"
elif [ "$PCT" -ge 60 ]; then
  COLOR='\033[33m'
  echo -e "${COLOR}⚡ Context: ${PCT}%${RESET}"
else
  COLOR='\033[32m'
  echo -e "${COLOR}✓ Context: ${PCT}%${RESET}"
fi
