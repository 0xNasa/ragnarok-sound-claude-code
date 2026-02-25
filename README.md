# Ragnarok Sound for Claude Code

Plays the Ragnarok Online level-up sound every time Claude Code finishes a task.

Inspired by the popular [WoW "Work, Work" orc hook](https://x.com/JorgeCastilloPr/status/2023779881113579776).

---

## Install

One command:

```bash
curl -sSL https://raw.githubusercontent.com/0xNasa/ragnarok-sound-claude-code/main/install.sh | bash
```

That's it. Open a new Claude Code session and complete any task.

---

## From within Claude Code

Once installed, you have a `/ro-levelup` slash command available globally. Run it in any Claude Code session to verify or repair the setup.

Alternatively, just tell your agent:

> Install the Ragnarok level-up sound hook from github.com/0xNasa/ragnarok-sound-claude-code

---

## How it works

Uses the Claude Code [Stop hook](https://docs.anthropic.com/en/docs/claude-code/hooks) — fires every time Claude finishes a response.

**Files installed:**
| File | Purpose |
|------|---------|
| `~/.claude/sounds/ragnarok_levelup.mp3` | The sound |
| `~/.claude/hooks/ragnarok-levelup.sh` | Plays it |
| `~/.claude/commands/ro-levelup.md` | Global slash command |
| `~/.claude/settings.json` | Registers the Stop hook |

**Platform support:** macOS (`afplay`), Linux (`paplay` / `aplay`)

---

## Uninstall

```bash
# Remove sound + hook script
rm ~/.claude/sounds/ragnarok_levelup.mp3
rm ~/.claude/hooks/ragnarok-levelup.sh
rm ~/.claude/commands/ro-levelup.md
```

Then remove the Stop hook entry from `~/.claude/settings.json`.

---

## Credit

Sound sourced from [myinstants.com](https://www.myinstants.com/en/instant/level-up-ragnarok/). Original audio © Gravity Co., Ltd.
