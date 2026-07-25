# english-coding

A Claude Code plugin that ships one workflow skill. Skills are plain markdown files — no compilation. A separate session-start hook, unscoped to the skill, fires once per session and requires `jq`.

## Skills

### gh-issue-create (`/gh-issue-create [issue]`)
The single end-to-end orchestrator: turns a free-form implementation discussion into a formal GitHub issue and then drives the implementation from an isolated worktree in plan mode.

**Workflow (Phase A — create, normal mode):** interview user → draft spec from `templates/issue.md` → approval loop → `gh issue create`.
**Workflow (Phase B — implement):** `git worktree add ../issue-<N>` → `EnterWorktree` into it → suggest `/rename issue-<N>` → `EnterPlanMode` → `gh issue view` → extract acceptance criteria → targeted exploration → plan (`ExitPlanMode`) → execute + verify each step.

Accepts an optional `$ARGUMENTS`: a bare issue number (`42`) or full URL skips Phase A and jumps straight to Phase B for that existing issue (this replaces the former standalone `gh-issue-implement`).

Key invariants:
- `disable-model-invocation: true` — runs only on the explicit `/gh-issue-create` trigger, never auto-invoked mid-conversation, so the create+worktree+plan sequence is deterministic.
- Never creates an issue without explicit user approval.
- Never creates a worktree if issue creation fails.
- Plan mode is entered in Phase B via `EnterPlanMode` from within the skill body — NOT forced upfront by a hook, because a plan-mode gate would block the Phase A `gh issue create` / `git worktree add`.
- Session rename (step b of the intended flow) has no programmatic path — the skill suggests the user run `/rename issue-<N>` themselves. Hooks can only set a title at `SessionStart`, which `EnterWorktree` does not trigger, and no rename tool is exposed.
- When editing an existing issue, writes the complete final state — no changelog prose.

## Plugin structure

```
.claude-plugin/plugin.json       # name, version, author, keywords
.claude-plugin/marketplace.json  # local marketplace catalog (source: "./")
.cursor-plugin/plugin.json       # Cursor plugin manifest (name, version, author)
skills/gh-issue-create/SKILL.md  # one file per skill, auto-discovered
hooks/hooks.json                 # plugin-level hook registry, auto-discovered
hooks/doc-scoping-context.sh       # SessionStart hook injecting documentation-scoping principles once per session (requires jq)
```

`doc-scoping-context.sh` is registered under `SessionStart` in `hooks/hooks.json` with no `matcher`, so it fires once per session (startup/resume/clear) regardless of which skill, if any, is invoked — unlike the other three hooks, which are `UserPromptExpansion`/`PreToolUse` and scoped to a specific skill's trigger.

`hooks/` is intentionally not mirrored under `.cursor-plugin/` — Cursor has no confirmed per-prompt hook equivalent to `UserPromptExpansion`/`PreToolUse`/`SessionStart` (its confirmed hook surface is a `workspaceOpen` hook, firing once per workspace rather than per-prompt). Under Cursor, the doc-scoping context never gets injected — the same fallback path the hook already exercises when `jq` is missing (see Constraints below).

Manifest format references: [Claude Code plugins](https://code.claude.com/docs/en/plugins) for `.claude-plugin/plugin.json`, [Cursor plugins](https://cursor.com/docs/plugins) (field reference: [cursor.com/docs/reference/plugins](https://cursor.com/docs/reference/plugins)) for `.cursor-plugin/plugin.json`.

## Adding a skill

1. `mkdir skills/<name> && touch skills/<name>/SKILL.md`
2. Add YAML front-matter:
   ```yaml
   ---
   name: <name>
   description: One line shown in /skills.
   ---
   ```
3. Write the skill body in markdown below the front-matter.
4. No changes to `plugin.json` or `marketplace.json` needed.

## Repository

Public: https://github.com/wheresmadog/english-coding

## Constraints

- `gh-issue-create` interacts with GitHub and requires `gh` CLI authenticated (`gh auth status`).
- `disable-model-invocation: true` in gh-issue-create's front-matter means it runs as a direct instruction set, not a sub-model call — keep the instructions self-contained and deterministic.
- `.claude/settings.local.json` contains a local `ANTHROPIC_BASE_URL` override — do not commit this file to a public repo.
- `hooks/doc-scoping-context.sh` requires `jq`; it degrades to a no-op (exit 1, stderr note) if `jq` is missing, meaning the session simply starts without the doc-scoping context.
