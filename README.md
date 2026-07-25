# english-coding

Workflow skills around **code ↔ conv/plan ↔ issue**.

## Features

| Skill | Invocation | Purpose |
|-------|-----------|---------|
| **code-to-conv** | `/code-to-conv` | Explore the working tree into a structured briefing for discussion. Does not create issues or edit code. |
| **conv-to-issue** | `/conv-to-issue` | Freeze a discussion into an approved GitHub issue (four-section body). Stops after the issue exists. |
| **issue-to-plan** | `/issue-to-plan <issue>` | Load an issue into a worktree, enter plan mode, and approve an in-session plan organized by key change. Does not implement. |
| **plan-to-code** | `/plan-to-code` | Execute the approved in-session plan from `/issue-to-plan` (same session only). |

Capture path: **code → conv → issue**. Execute path: **issue → plan → code**. Plan is in-session only — run `/plan-to-code` in the same chat as `/issue-to-plan`.

## Prerequisite

Skills that talk to GitHub (`conv-to-issue`, `issue-to-plan`) shell out to the GitHub CLI (`gh`). Verify it is installed and authenticated before use:

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

Runs the skills too, but the session-start documentation reminder never fires — the same graceful fallback that happens when `jq` is missing.

See `CLAUDE.md` for the plugin's internal structure and how to add or modify a skill.
