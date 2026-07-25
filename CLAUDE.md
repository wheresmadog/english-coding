# english-coding

A Claude Code plugin that ships four composable workflow skills around **code ↔ conv/plan ↔ issue**. Skills are plain markdown files — no compilation. A separate session-start hook, unscoped to any skill, fires once per session and requires `jq`.

## Model

```
code ──code-to-conv──► conv/plan ──conv-to-issue──► issue
code ◄──plan-to-code── conv/plan ◄──issue-to-plan── issue
```

- Capture: **code → conv → issue**
- Execute: **issue → plan → code**
- Middle phase is **conv** on capture, **plan** (in-session only) on execute
- No orchestrator skill — compose the four skills explicitly

## Skills

All skills set `disable-model-invocation: true` — they run only on explicit `/…` triggers, never auto-invoked mid-conversation.

### code-to-conv (`/code-to-conv`)
Structured exploration from the working tree into a discussion-ready briefing. Does not create issues or edit code. Suggests `/conv-to-issue` when ready to freeze work.

On the first turn a conversation invokes the skill, fills in `templates/conv.md`: a numbered, one-sentence-per-item "Current behavior" list, then a "Future directions" section grouped by candidate key change (`### <name>: <one sentence>`, same naming style `/conv-to-issue` later freezes). Later turns in the same conversation continue as normal discussion instead of re-rendering the template.

### conv-to-issue (`/conv-to-issue`)
Interview → draft from `templates/issue.md` → approval loop → `gh issue create`. Stops after the issue exists (no worktree, no plan mode).

Issue body is exactly four sections, keyed by shared key-change names:

- **Key Takeaways** — `- <name>: <one sentence>`
- **Expected Results** — per key change, numbered plain-English logic (no code refs)
- **Manual Verifications** — per key change, hands-on behavior guidelines (not a test-suite checklist)
- **Additional Context** — free form

When editing an existing issue, writes the complete final state — no changelog prose.

### issue-to-plan (`/issue-to-plan <issue>`)
`$ARGUMENTS` = issue number or URL (required). `git worktree add ../issue-<N>` → `EnterWorktree` → suggest `/rename issue-<N>` → `EnterPlanMode` → `gh issue view` → extract key changes → targeted exploration → draft plan by key-change section → `ExitPlanMode`. Stops after plan approval.

Plan shape: one `## <key change name>` section per issue key change; numbered implementation logic (1–2 sentences each); file/symbol refs live here. Plan is **in-session only** — tell the user to run `/plan-to-code` in the same chat.

### plan-to-code (`/plan-to-code`)
Requires same session as a completed `/issue-to-plan`, cwd already in the issue worktree, and an approved plan. Walks key-change sections in order; after each, verifies against that change's Manual Verifications (behavior guidelines). Refuses and points back to `/issue-to-plan` if preconditions fail.

## Plugin structure

```
.claude-plugin/plugin.json              # name, version, author, keywords
.claude-plugin/marketplace.json         # local marketplace catalog (source: "./")
.cursor-plugin/plugin.json              # Cursor plugin manifest (name, version, author)
skills/code-to-conv/SKILL.md
skills/code-to-conv/templates/conv.md
skills/conv-to-issue/SKILL.md
skills/conv-to-issue/templates/issue.md
skills/issue-to-plan/SKILL.md
skills/plan-to-code/SKILL.md
hooks/hooks.json                        # plugin-level hook registry, auto-discovered
hooks/doc-scoping-context.sh            # SessionStart hook (requires jq)
```

`doc-scoping-context.sh` is registered under `SessionStart` in `hooks/hooks.json` with no `matcher`, so it fires once per session (startup/resume/clear) regardless of which skill, if any, is invoked.

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

- `conv-to-issue` and `issue-to-plan` interact with GitHub and require `gh` CLI authenticated (`gh auth status`).
- `disable-model-invocation: true` means each skill runs as a direct instruction set, not a sub-model call — keep the instructions self-contained and deterministic.
- Plan mode is entered only inside `issue-to-plan` via `EnterPlanMode` — not forced upfront by a hook, so `conv-to-issue`'s `gh issue create` and `issue-to-plan`'s `git worktree add` are not blocked.
- Session rename has no programmatic path — `issue-to-plan` suggests `/rename issue-<N>`. Hooks can only set a title at `SessionStart`, which `EnterWorktree` does not trigger.
- `.claude/settings.local.json` contains a local `ANTHROPIC_BASE_URL` override — do not commit this file to a public repo.
- `hooks/doc-scoping-context.sh` requires `jq`; it degrades to a no-op (exit 1, stderr note) if `jq` is missing, meaning the session simply starts without the doc-scoping context.
