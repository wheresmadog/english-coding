---
name: issue-to-plan
description: "Load a GitHub issue into a worktree, enter plan mode, and draft an approved in-session plan organized by key change. Does not implement — run /plan-to-code next in the same session."
disable-model-invocation: true
---

You are an advanced software engineer executing the `/issue-to-plan` skill. Move from **issue** to an in-session **plan**. Do not implement code in this skill.

## 0. Validate the issue number

`$ARGUMENTS` must contain an issue number (e.g. `42`) or a full issue URL. Set `N` to that issue number.

If `$ARGUMENTS` is missing, empty, or not parseable as a bare issue number or a GitHub issue URL, output a brief note (e.g. "No issue number provided — nothing to do.") and stop immediately. Do not ask a follow-up question, and do not proceed to Section 1 (worktree creation), Section 2 (`EnterWorktree`), Section 3 (rename suggestion), Section 4 (`EnterPlanMode`), or Section 5 (`gh issue view`) — none of those steps run.

Plan mode blocks `git worktree add` and related setup, so complete worktree setup **before** entering plan mode.

## 1. Create the worktree

```bash
git worktree add ../issue-<N> -b issue-<N>
```

If a branch/worktree for this issue already exists, reuse it instead of failing.

Report the issue URL, branch name, and worktree path.

## 2. Enter the worktree

Call the `EnterWorktree` tool with `path: "../issue-<N>"`. This switches the session's working directory into the worktree.

- If `EnterWorktree` rejects the sibling path, do **not** silently fall back. Report the error to the user and ask whether to instead create the worktree under `.claude/worktrees/` via `EnterWorktree` with `name: "issue-<N>"` (this changes the path convention).

## 3. Suggest renaming the session

There is no programmatic way to rename the current session (hooks can only set a title at session start, and no rename tool is exposed). Tell the user to run this themselves:

```
/rename issue-<N>
```

## 4. Enter plan mode

Call the `EnterPlanMode` tool. Do not explore, plan, or edit until plan mode is active and the user approves the transition.

## 5. Fetch and analyze the issue

```bash
gh issue view <N> --json number,title,body,labels,comments,state
```

Extract:

1. The key-change names from Key Takeaways / Expected Results / Manual Verifications (same set of names).
2. Expected Results and Manual Verifications for each key change.
3. Additional Context and any rigid constraints.

If the issue body does not follow the four-section key-change shape, infer a stable set of key-change names from the body and state them explicitly before planning.

## 6. Targeted codebase exploration

Search the local codebase (Grep, Glob, Read) for the symbols, files, and modules needed to implement each key change. Read until you understand:

- The current implementation and what specifically must change per key change.
- Active architectural patterns, styling conventions, and testing setup to follow.
- Precise code entry points.

Stop exploring as soon as you have enough context to assemble a concrete plan.

## 7. Draft the plan (required shape)

Organize the plan around the issue's key changes. Every key change from the issue must appear, with the **same names**.

For each key change, include a section that demonstrates the implementation logic as a numbered list (**1–2 sentences** per item). Include file paths, symbols, and entry points here — they belong in the plan, not in the issue's Expected Results.

```markdown
## <key change name>
1. ...
2. ...
```

The plan's key-change sections are the source of truth that `/plan-to-code` will walk.

## 8. Approve the plan

Call `ExitPlanMode` to get approval. **Stop after the plan is approved.** Do not implement.

## 9. Hand off (same session)

The plan is **in-session only** — no plan file, no issue comment. Tell the user to run the next skill **in this same chat**:

```
/plan-to-code
```

If they start a new session, the plan is gone and they must re-run `/issue-to-plan <N>`.
