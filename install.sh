#!/bin/bash
# One-line installer for claude-context-warning
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/cyberpunkbeatgeneration/claude-context-warning/main/install.sh | bash
#
# Or manually:
#   bash install.sh

set -e

SCRIPT_URL="https://raw.githubusercontent.com/cyberpunkbeatgeneration/claude-context-warning/main/context_warning.sh"
INSTALL_DIR="$HOME/.claude"
INSTALL_PATH="$INSTALL_DIR/context_warning.sh"
SETTINGS_FILE="$INSTALL_DIR/settings.json"

echo "📦 Installing claude-context-warning..."

# Ensure .claude directory exists
mkdir -p "$INSTALL_DIR"

# Download the script
if command -v curl &> /dev/null; then
  curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH"
elif command -v wget &> /dev/null; then
  wget -q "$SCRIPT_URL" -O "$INSTALL_PATH"
else
  echo "❌ Error: curl or wget required"
  exit 1
fi

chmod +x "$INSTALL_PATH"
echo "✅ Script installed to $INSTALL_PATH"

# Update settings.json
if [ -f "$SETTINGS_FILE" ]; then
  # Check if statusLine already configured
  if python3 -c "
import json, sys
with open('$SETTINGS_FILE') as f:
    data = json.load(f)
if 'statusLine' in data:
    sys.exit(1)
" 2>/dev/null; then
    # Add statusLine to existing settings
    python3 -c "
import json
with open('$SETTINGS_FILE') as f:
    data = json.load(f)
data['statusLine'] = {
    'type': 'command',
    'command': '$INSTALL_PATH'
}
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
print('✅ settings.json updated')
"
  else
    echo "⚠️  statusLine already configured in settings.json — skipping"
    echo "   To use this script, manually set:"
    echo "   \"statusLine\": {\"type\": \"command\", \"command\": \"$INSTALL_PATH\"}"
  fi
else
  # Create new settings.json
  cat > "$SETTINGS_FILE" << EOF
{
  "statusLine": {
    "type": "command",
    "command": "$INSTALL_PATH"
  }
}
EOF
  echo "✅ Created settings.json"
fi

echo ""
echo "🎉 Done! Restart Claude Code to see the context indicator."
echo ""
echo "   ✓ Context: 12%    — normal (green)"
echo "   ⚡ Context: 65%   — getting full (yellow)"
echo "   ⚠ Context: 85%    — almost full (red)"
echo "   🔴 CONTEXT 96%    — critical (flashing red)"
