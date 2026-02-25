# Ragnarok Sound for Claude Code

Plays a classic Ragnarok Online sound every time Claude Code finishes a task. Comes with a pack of 5 sounds — pick your favorite during install or switch anytime with a slash command.

Inspired by the popular [WoW "Work, Work" orc hook](https://x.com/JorgeCastilloPr/status/2023779881113579776).

---

## Install

```bash
curl -sSL https://raw.githubusercontent.com/0xNasa/ragnarok-sound-claude-code/main/install.sh | bash
```

The installer downloads all sounds, lets you pick one, and plays a preview. Open a new Claude Code session and complete any task to hear it fire.

---

## Sound pack

| # | File | Description |
|---|------|-------------|
| 1 | `ragnarok_levelup.mp3` | Base level up |
| 2 | `ro_login.mp3` | Login screen chime |
| 3 | `ro_refine.mp3` | Blacksmith refine |
| 4 | `ro_poring_bounce.wav` | Poring bounce × 2 |
| 5 | `ro_poring_bounce2.wav` | Poring bounce × 2 (alt) |

---

## Switching sounds

Use `/ro-sound` inside any Claude Code session to preview and switch:

```
/ro-sound
```

Or set one manually:

```bash
echo "ro_login.mp3" > ~/.claude/sounds/.ro_active
```

---

## Slash commands

Two global commands are installed:

- `/ro-sound` — preview and switch your active sound
- `/ro-levelup` — verify or repair the installation

---

## How it works

Uses the Claude Code [Stop hook](https://docs.anthropic.com/en/docs/claude-code/hooks), which fires every time Claude finishes a response.

**Files installed:**
| File | Purpose |
|------|---------|
| `~/.claude/sounds/` | Sound pack |
| `~/.claude/sounds/.ro_active` | Stores your active sound choice |
| `~/.claude/hooks/ragnarok-levelup.sh` | Plays the active sound |
| `~/.claude/commands/ro-sound.md` | `/ro-sound` slash command |
| `~/.claude/commands/ro-levelup.md` | `/ro-levelup` slash command |
| `~/.claude/settings.json` | Registers the Stop hook |

**Platform support:** macOS (`afplay`), Linux (`paplay` / `aplay`)

---

## Uninstall

```bash
rm -rf ~/.claude/sounds
rm ~/.claude/hooks/ragnarok-levelup.sh
rm ~/.claude/commands/ro-levelup.md
rm ~/.claude/commands/ro-sound.md
```

Then remove the Stop hook entry from `~/.claude/settings.json`.

---

## Credit

Sounds sourced from [myinstants.com](https://www.myinstants.com/en/search/?name=ragnarok) and the Ragnarok Online community. Original audio © Gravity Co., Ltd.
