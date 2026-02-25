#!/usr/bin/env bash
set -e

MYINSTANTS="https://www.myinstants.com/media/sounds"
PORING_RACE="https://raw.githubusercontent.com/llegomark/poring-race/main/src/sounds"
REPO_RAW="https://raw.githubusercontent.com/0xNasa/ragnarok-sound-claude-code/main"
SOUNDS_DIR="$HOME/.claude/sounds"
HOOKS_DIR="$HOME/.claude/hooks"
COMMANDS_DIR="$HOME/.claude/commands"
HOOK_SCRIPT="$HOOKS_DIR/ragnarok-levelup.sh"
CONFIG="$SOUNDS_DIR/.ro_active"

echo "🗡️  Ragnarok Sound for Claude Code — installer"
echo "──────────────────────────────────────────────"

# 1. Create directories
mkdir -p "$SOUNDS_DIR" "$HOOKS_DIR" "$COMMANDS_DIR"

# 2. Download sound pack
echo "→ Downloading sound pack..."

download() {
  local url="$1" dest="$2" label="$3"
  printf "  %-32s" "$label"
  if curl -sSL "$url" -o "$dest" 2>/dev/null && [ -s "$dest" ]; then
    echo "✓"
  else
    echo "✗ (skipped)"
    rm -f "$dest"
  fi
}

download "$MYINSTANTS/ragnarok-online-level-up-sound.mp3" "$SOUNDS_DIR/ragnarok_levelup.mp3" "ragnarok_levelup.mp3"
download "$MYINSTANTS/blacksmith_refine.mp3"              "$SOUNDS_DIR/ro_refine.mp3"        "ro_refine.mp3"
download "$REPO_RAW/ro_login.mp3"                         "$SOUNDS_DIR/ro_login.mp3"         "ro_login.mp3"
download "$PORING_RACE/poi1.mp3"                          "$SOUNDS_DIR/_poi1_raw.mp3"        "_poi1_raw.mp3 (temp)"
download "$PORING_RACE/poi2.mp3"                          "$SOUNDS_DIR/_poi2_raw.mp3"        "_poi2_raw.mp3 (temp)"

# 3. Build double-bounce poring sounds
echo "→ Building poring bounce sounds..."
if command -v afconvert &>/dev/null && command -v python3 &>/dev/null; then
  afconvert "$SOUNDS_DIR/_poi1_raw.mp3" "$SOUNDS_DIR/_poi1.wav" -f WAVE -d LEI16 2>/dev/null
  afconvert "$SOUNDS_DIR/_poi2_raw.mp3" "$SOUNDS_DIR/_poi2.wav" -f WAVE -d LEI16 2>/dev/null

  python3 - << 'PYEOF'
import wave, os

def bounce_double(src, dst, gap_ms):
    with wave.open(src, 'rb') as w:
        params = w.getparams()
        frames = w.readframes(w.getnframes())
    gap = b'\x00' * int(params.framerate * gap_ms / 1000) * params.sampwidth * params.nchannels
    with wave.open(dst, 'wb') as out:
        out.setparams(params)
        out.writeframes(frames + gap + frames)

d = os.path.expanduser("~/.claude/sounds")
bounce_double(f"{d}/_poi1.wav", f"{d}/ro_poring_bounce.wav",  gap_ms=180)
bounce_double(f"{d}/_poi2.wav", f"{d}/ro_poring_bounce2.wav", gap_ms=200)
print("  ro_poring_bounce.wav           ✓")
print("  ro_poring_bounce2.wav          ✓")
PYEOF

  rm -f "$SOUNDS_DIR/_poi1_raw.mp3" "$SOUNDS_DIR/_poi2_raw.mp3" \
        "$SOUNDS_DIR/_poi1.wav"     "$SOUNDS_DIR/_poi2.wav"
else
  echo "  afconvert or python3 not found — poring bounce sounds skipped"
  rm -f "$SOUNDS_DIR/_poi1_raw.mp3" "$SOUNDS_DIR/_poi2_raw.mp3"
fi

# 4. Write hook script
echo "→ Installing hook script..."
cat > "$HOOK_SCRIPT" << 'HOOKEOF'
#!/bin/bash
SOUNDS_DIR="$HOME/.claude/sounds"
CONFIG="$SOUNDS_DIR/.ro_active"

if [ -f "$CONFIG" ]; then
  SOUND=$(cat "$CONFIG" | tr -d '[:space:]')
  SOUND_FILE="$SOUNDS_DIR/$SOUND"
else
  SOUND_FILE="$SOUNDS_DIR/ragnarok_levelup.mp3"
fi

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

# 5. Merge hook into ~/.claude/settings.json
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

hook_command = os.path.expanduser("~/.claude/hooks/ragnarok-levelup.sh")
new_hook = {"hooks": [{"type": "command", "command": hook_command, "async": True}]}

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

# 6. Sound selection
echo ""
echo "Available sounds:"
echo "  1) ragnarok_levelup.mp3    — Base Level Up (classic)"
echo "  2) ro_login.mp3            — Login sound"
echo "  3) ro_refine.mp3           — Blacksmith Refine"
echo "  4) ro_poring_bounce.wav    — Poring bounce (poi1 x2)"
echo "  5) ro_poring_bounce2.wav   — Poring bounce (poi2 x2)"
echo ""

if [ -t 0 ]; then
  read -rp "Pick a sound [1-5, default=1]: " CHOICE
  case "$CHOICE" in
    2) ACTIVE="ro_login.mp3" ;;
    3) ACTIVE="ro_refine.mp3" ;;
    4) ACTIVE="ro_poring_bounce.wav" ;;
    5) ACTIVE="ro_poring_bounce2.wav" ;;
    *) ACTIVE="ragnarok_levelup.mp3" ;;
  esac
else
  ACTIVE="ragnarok_levelup.mp3"
fi

echo "$ACTIVE" > "$CONFIG"
echo "→ Active sound set to: $ACTIVE"

if [[ "$OSTYPE" == "darwin"* ]] && [ -f "$SOUNDS_DIR/$ACTIVE" ]; then
  afplay "$SOUNDS_DIR/$ACTIVE"
fi

# 7. Install global slash commands
echo "→ Installing /ro-levelup and /ro-sound slash commands..."
cat > "$COMMANDS_DIR/ro-levelup.md" << 'CMDEOF'
Check if the Ragnarok Online level-up sound hook for Claude Code is installed on this machine.

Run these checks in order:
1. Does `~/.claude/sounds/ragnarok_levelup.mp3` exist?
2. Does `~/.claude/hooks/ragnarok-levelup.sh` exist and is it executable?
3. Does `~/.claude/settings.json` contain a Stop hook pointing to `ragnarok-levelup.sh`?

If anything is missing, run the installer:
```
curl -sSL https://raw.githubusercontent.com/0xNasa/ragnarok-sound-claude-code/main/install.sh | bash
```

Then confirm everything is set up correctly and tell the user.
CMDEOF

cat > "$COMMANDS_DIR/ro-sound.md" << 'CMDEOF'
Help the user pick their Ragnarok Online notification sound for Claude Code.

Do the following steps:

1. List the available sounds in `~/.claude/sounds/`. For each, show a friendly label:
   - `ragnarok_levelup.mp3` → "Base Level Up (classic)"
   - `ro_login.mp3` → "Login sound"
   - `ro_refine.mp3` → "Blacksmith Refine"
   - `ro_poring_bounce.wav` → "Poring bounce (poi1 x2)"
   - `ro_poring_bounce2.wav` → "Poring bounce (poi2 x2)"

2. Show which one is currently active by reading `~/.claude/sounds/.ro_active`.

3. Ask the user which sound they want. Offer to preview any of them by playing it with `afplay` (macOS) or `paplay`/`aplay` (Linux).

4. Once the user picks one, write just the filename (e.g. `ro_refine.mp3`) to `~/.claude/sounds/.ro_active` and confirm it's set.

If any sounds are missing, tell the user to re-run the installer:
```
curl -sSL https://raw.githubusercontent.com/0xNasa/ragnarok-sound-claude-code/main/install.sh | bash
```
CMDEOF

echo "  /ro-levelup and /ro-sound commands available globally."

echo ""
echo "✅ Done! Claude Code will play your chosen RO sound on task completion."
echo "   Switch sounds anytime with: /ro-sound"
