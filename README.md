# english-coding

## Features

| Skill | Invocation | Purpose |
|-------|-----------|---------|
| **gh-issue-create** | `/gh-issue-create [issue]` | End to end: turn an implementation discussion into a GitHub issue (with approval), create a worktree, `cd` into it, enter plan mode, then plan and implement. Pass an existing issue number (`42`) or URL to skip creation and jump straight to implementation. |

## Prerequisite

`gh-issue-create` shells out to the GitHub CLI (`gh`). Verify it is installed and authenticated before use:

```bash
gh auth status
```

## Install

### Claude Code

Once published to GitHub, anyone can install it directly:

```bash
/plugin marketplace add https://github.com/wheresmadog/english-coding
/plugin install english-coding@english-coding
```

### Cursor

Clone (or symlink, for local development) the repo directly into Cursor's local plugins directory — this repo's layout already has `.cursor-plugin/plugin.json` at its root, matching what Cursor expects:

```bash
git clone https://github.com/wheresmadog/english-coding ~/.cursor/plugins/local/english-coding
```

```bash
ln -s /path/to/english-coding ~/.cursor/plugins/local/english-coding
```

Then restart Cursor, or run **Developer: Reload Window**.

## Platform notes

### Claude Code

Fully supported, including a session-start hook that reminds Claude to keep `README.md`/`CLAUDE.md` documentation scoped and up to date.

### Cursor

Runs the skill too, but the session-start documentation reminder never fires — the same graceful fallback that happens when `jq` is missing.

See `CLAUDE.md` for the plugin's internal structure and how to add or modify a skill.
