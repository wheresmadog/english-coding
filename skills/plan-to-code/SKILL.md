---
name: plan-to-code
description: "Execute an already-approved in-session plan from /issue-to-plan, walking key-change sections in order. Same session only — no plan file."
disable-model-invocation: true
---

You are an advanced software engineer executing the `/plan-to-code` skill. Move from an approved in-session **plan** to **code**.

## Preconditions

All of the following must hold; otherwise refuse and point the user back to `/issue-to-plan <N>`:

1. **Same session** as a completed `/issue-to-plan` that produced an approved plan (plan is in-session only — not a file, not an issue comment).
2. Working directory is already the issue worktree from that `/issue-to-plan` run.
3. An approved plan organized by key-change sections exists in this conversation.

Do not re-enter plan mode or re-draft the plan unless the user explicitly asks to replan.

## 1. Confirm the plan

Briefly restate the key-change sections you will execute, in order, using the same names as the approved plan / issue.

## 2. Execute by key-change section

Walk the plan **by key-change section**, in order.

For each key change:

1. Implement the numbered logic steps for that section.
2. Stay within the scope of that key change before moving on.
3. After the section's code is in place, verify against that change's **Manual Verifications** from the issue (behavior guidelines — not a generic test-suite dump). Prefer observable behavior checks aligned with those guidelines; run automated tests only when they directly support verifying the behavior change.

Do not skip ahead to later key changes while an earlier one is unfinished.

## 3. Finish

When every key-change section is done and verified:

- Summarize what changed, keyed by key-change name.
- Note any leftover risks or follow-ups.
- Do not create a PR unless the user asks.
