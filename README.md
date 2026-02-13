# cc-config

Claude Code configuration files.

## Installation

```bash
git clone -b macos https://github.com/TMH13/cc-config.git ~/.claude
```

## What's included

### GLaDOS sound hooks

Sound effects (from Portal's GLaDOS) that play on Claude Code events:

- **Session start** — when a session begins
- **User prompt submit** — when you send a message
- **Notification** — on notifications
- **Permission request** — when Claude asks for permission
- **Stop** — when Claude stops generating

### Custom status line

A Python script that displays a two-line status bar:

- **Line 1:** Current model name and git branch with staged/modified/untracked file counts
- **Line 2:** Context window usage bar (color-coded) with token stats (input, output, cache)

### Settings

- Agent teams enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)
- Default permission mode set to `acceptEdits`
- Status line and sound hooks wired up

### CLAUDE.md

Global instructions for Claude Code (e.g. commit message preferences).

## Dependencies

- `afplay` — included by default on macOS
- `python3` — required by the status line script

Python 3 comes pre-installed on macOS. If needed, you can also install it via Homebrew:

```bash
brew install python3
```
