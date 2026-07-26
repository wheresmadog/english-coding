---
name: conv-to-code
description: "Same-session execute after /conv-to-issue: enter the issue worktree, plan from conversation context, then implement and verify by key change. Requires a frozen issue — does not create one."
disable-model-invocation: true
---

You are an advanced software engineer executing the `/conv-to-code` skill. Move from a live **conv** (already frozen as an issue in this session) through an in-session **plan** to **code**.

## Preconditions (issue before code)

All of the following must hold; otherwise refuse and stop:

1. **This session already completed `/conv-to-issue`** and produced a GitHub issue. Set `N` to that issue number from the conversation (the URL/number reported after `gh issue create`).
2. Coding always requires that frozen issue — **do not** create an issue, and **do not** proceed from an unfrozen conv.
3. Worktree naming is always `issue-<N>` (no slug-only worktree path).

If preconditions fail, point the user to `/conv-to-issue` (to freeze) or `/issue-to-code <N>` (cold start from an existing issue), and stop. Do not ask a long follow-up interview.

Plan mode blocks `git worktree add` and related setup, so complete worktree setup **before** entering plan mode. Plan is an internal phase of this skill — do not hand off to another skill to start coding.

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

## 5. Analyze from conversation context

Use the live conversation as the primary source of truth for planning — the freeze from `/conv-to-issue` is already in context (Key Takeaways, Expected Results, Manual Verifications, Additional Context).

Extract:

1. The key-change names (same set across Key Takeaways / Expected Results / Manual Verifications).
2. Expected Results and Manual Verifications for each key change.
3. Additional Context and any rigid constraints.

**Do not** re-fetch and re-parse the issue body via `gh issue view` as the primary planning source. You may use the known issue number `N` only for worktree/reporting. If material details are missing from the conversation, stop and point the user to clarify or use `/issue-to-code <N>` instead of inventing them.

## 6. Targeted codebase exploration

Search the local codebase (Grep, Glob, Read) for the symbols, files, and modules needed to implement each key change. Read until you understand:

- The current implementation and what specifically must change per key change.
- Active architectural patterns, styling conventions, and testing setup to follow.
- Precise code entry points.

Stop exploring as soon as you have enough context to assemble a concrete plan.

## 7. Draft the plan (required shape)

Organize the plan around the key changes. Every key change must appear, with the **same names**.

For each key change, include a section that demonstrates the implementation logic as a numbered list (**1–2 sentences** per item). Include file paths, symbols, and entry points here — they belong in the plan, not in the issue's Expected Results.

```markdown
## <key change name>
1. ...
2. ...
```

The plan's key-change sections are the source of truth for the implement phase below.

## 8. Approve the plan

Call `ExitPlanMode` to get approval. Do not implement until the plan is approved.

## 9. Confirm the plan

Briefly restate the key-change sections you will execute, in order, using the same names as the approved plan.

Do not re-enter plan mode or re-draft the plan unless the user explicitly asks to replan.

## 10. Execute by key-change section

Walk the plan **by key-change section**, in order.

For each key change:

1. Implement the numbered logic steps for that section.
2. Stay within the scope of that key change before moving on.
3. After the section's code is in place, verify against that change's **Manual Verifications** (behavior guidelines — not a generic test-suite dump). Prefer observable behavior checks aligned with those guidelines; run automated tests only when they directly support verifying the behavior change.

Do not skip ahead to later key changes while an earlier one is unfinished.

## 11. Finish

When every key-change section is done and verified:

- Summarize what changed, keyed by key-change name.
- Note any leftover risks or follow-ups.
- Do not create a PR unless the user asks.
