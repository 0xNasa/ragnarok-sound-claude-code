#!/usr/bin/env bash
set -e

REPO_RAW="https://raw.githubusercontent.com/joejosue/ragnarok-sound-claude-code/main"
SOUNDS_DIR="$HOME/.claude/sounds"
HOOKS_DIR="$HOME/.claude/hooks"
COMMANDS_DIR="$HOME/.claude/commands"
SOUND_FILE="$SOUNDS_DIR/ragnarok_levelup.mp3"
HOOK_SCRIPT="$HOOKS_DIR/ragnarok-levelup.sh"

echo "🗡️  Ragnarok Sound for Claude Code — installer"
echo "──────────────────────────────────────────────"

# 1. Create directories
mkdir -p "$SOUNDS_DIR" "$HOOKS_DIR" "$COMMANDS_DIR"

# 2. Download sound file
echo "→ Downloading level-up sound..."
curl -sSL "$REPO_RAW/ragnarok_levelup.mp3" -o "$SOUND_FILE"
echo "  Saved to $SOUND_FILE"

# 3. Write hook script
echo "→ Installing hook script..."
cat > "$HOOK_SCRIPT" << 'HOOKEOF'
#!/bin/bash
SOUND_FILE="$HOME/.claude/sounds/ragnarok_levelup.mp3"
[ -f "$SOUND_FILE" ] || exit 0
if [[ "$OSTYPE" == "darwin"* ]]; then
  afplay "$SOUND_FILE" &
elif command -v paplay &>/dev/null; then
  paplay "$SOUND_FILE" &
elif command -v aplay &>/dev/null; then
  aplay "$SOUND_FILE" &
fi
exit 0
HOOKEOF
chmod +x "$HOOK_SCRIPT"
echo "  Saved to $HOOK_SCRIPT"

# 4. Merge hook into ~/.claude/settings.json
echo "→ Updating Claude Code settings..."
python3 - << 'PYEOF'
import json, os

settings_path = os.path.expanduser("~/.claude/settings.json")

try:
    with open(settings_path) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

settings.setdefault("hooks", {})

new_hook = {"hooks": [{"type": "command", "command": "~/.claude/hooks/ragnarok-levelup.sh", "async": True}]}

already_installed = any(
    any("ragnarok-levelup.sh" in h.get("command", "") for h in entry.get("hooks", []))
    for entry in settings["hooks"].get("Stop", [])
)

if not already_installed:
    settings["hooks"].setdefault("Stop", []).append(new_hook)
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    print("  Hook registered under Stop event.")
else:
    print("  Hook already present, skipping.")
PYEOF

# 5. Install global slash command
echo "→ Installing /ro-levelup slash command..."
cat > "$COMMANDS_DIR/ro-levelup.md" << 'CMDEOF'
Check if the Ragnarok Online level-up sound hook for Claude Code is installed on this machine.

Run these checks in order:
1. Does `~/.claude/sounds/ragnarok_levelup.mp3` exist?
2. Does `~/.claude/hooks/ragnarok-levelup.sh` exist and is it executable?
3. Does `~/.claude/settings.json` contain a Stop hook pointing to `ragnarok-levelup.sh`?

If anything is missing, run the installer:
```
curl -sSL https://raw.githubusercontent.com/joejosue/ragnarok-sound-claude-code/main/install.sh | bash
```

Then confirm everything is set up correctly and tell the user.
CMDEOF
echo "  /ro-levelup command available globally."

echo ""
echo "✅ Done! Claude Code will now play the Ragnarok level-up sound on task completion."
echo "   Test it by running: afplay ~/.claude/sounds/ragnarok_levelup.mp3"
