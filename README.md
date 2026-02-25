# Ragnarok Sound for Claude Code

Plays a Ragnarok Online sound every time Claude Code finishes a task. Choose from a pack of classic RO sounds.

Inspired by the popular [WoW "Work, Work" orc hook](https://x.com/JorgeCastilloPr/status/2023779881113579776).

---

## Install

One command:

```bash
curl -sSL https://raw.githubusercontent.com/0xNasa/ragnarok-sound-claude-code/main/install.sh | bash
```

The installer downloads all sounds and asks which one to use. Open a new Claude Code session and complete any task.

---

## Sound pack

| Sound | Description |
|-------|-------------|
| `ragnarok_levelup.mp3` | Base Level Up (classic) |
| `ro_login.mp3` | Login sound |
| `ro_refine.mp3` | Blacksmith Refine |
| `ro_poring_bounce.wav` | Poring bounce (poi1 x2) |
| `ro_poring_bounce2.wav` | Poring bounce (poi2 x2) |

---

## Switching sounds

Use the `/ro-sound` slash command inside any Claude Code session:

```
/ro-sound
```

Claude will list available sounds, let you preview them, and set your choice.

You can also switch manually:

```bash
echo "ro_refine.mp3" > ~/.claude/sounds/.ro_active
```

---

## From within Claude Code

Two global slash commands are available after install:

- `/ro-levelup` — verify or repair the installation
- `/ro-sound` — preview and switch your active sound

Or just tell your agent:

> Install the Ragnarok level-up sound hook from github.com/0xNasa/ragnarok-sound-claude-code

---

## How it works

Uses the Claude Code [Stop hook](https://docs.anthropic.com/en/docs/claude-code/hooks) — fires every time Claude finishes a response.

**Files installed:**
| File | Purpose |
|------|---------|
| `~/.claude/sounds/*.mp3` | Sound pack |
| `~/.claude/sounds/.ro_active` | Active sound config |
| `~/.claude/hooks/ragnarok-levelup.sh` | Plays the active sound |
| `~/.claude/commands/ro-levelup.md` | `/ro-levelup` slash command |
| `~/.claude/commands/ro-sound.md` | `/ro-sound` slash command |
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

Sounds sourced from [myinstants.com](https://www.myinstants.com/en/search/?name=ragnarok). Original audio © Gravity Co., Ltd.
