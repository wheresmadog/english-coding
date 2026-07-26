# english-coding

Workflow skills around **code ↔ conv/plan ↔ issue**.

## Features

| Skill | Invocation | Purpose |
|-------|-----------|---------|
| **code-to-conv** | `/code-to-conv` | Explain a module's architecture and mechanisms, then suggest quality/feature directions. Does not create issues or edit code. |
| **conv-to-issue** | `/conv-to-issue` | Freeze a discussion into an approved GitHub issue (four-section body). Stops after the issue exists. |
| **conv-to-code** | `/conv-to-code` | Same-session execute after `/conv-to-issue`: worktree, plan from conversation context, implement and verify. Requires a frozen issue. |
| **issue-to-code** | `/issue-to-code <issue>` | Cold-start execute: load an issue into a worktree, plan, implement and verify by key change. |

Capture path: **code → conv → issue**. Happy-path execute (same session): **conv → code** via `/conv-to-code` after `/conv-to-issue`. Cold start: **issue → code** via `/issue-to-code <N>`. Plan is an in-skill phase of the two `*-to-code` skills (in-session only). Coding always requires a frozen GitHub issue; worktrees are always `issue-<N>`.

## Prerequisite

Skills that talk to GitHub (`conv-to-issue`, `issue-to-code`) shell out to the GitHub CLI (`gh`). Verify it is installed and authenticated before use:

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
