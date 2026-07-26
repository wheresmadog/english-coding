---
name: conv-to-issue
description: "Freeze an implementation discussion into an approved GitHub issue. Stops after the issue exists — no worktree, no plan, no implementation."
disable-model-invocation: true
---

You are an advanced software engineer executing the `/conv-to-issue` skill. Move from **conv** to a durable **issue**. Stay in normal mode — do not enter plan mode, do not create a worktree, and do not implement.

## 1. Analyze existing context

Review the current conversation and any referenced files. Extract:

- Goals
- Candidate key changes
- Constraints
- Decisions already made
- Rejected alternatives

Do not ask the user to repeat information already available.

## 2. Resolve remaining ambiguities

If material details remain unclear, interview the user. Focus on what each key change must achieve and how behavior should be verified. Continue until the draft can contain no unresolved questions.

## 3. Draft specification

Fill in the template at `templates/issue.md`. Follow the shapes below exactly.

### Key Takeaways

Bullet list of named key changes, one sentence each:

```markdown
## Key Takeaways
- <name>: <one sentence describing the key change>
- <name>: <one sentence describing the key change>
```

### Expected Results

One subsection per key change (same `<name>` values). Under each, a numbered list that demonstrates the logic in plain English. **No** file paths, symbols, or code snippets.

```markdown
## Expected Results
### <key change 1>
1. ...
2. ...

### <key change 2>
1. ...
2. ...
```

### Manual Verifications

Same grouping by key change. Under each, a numbered hands-on guideline list for verifying **behavior changes** — not a list of tests to run. Following the steps must be enough to check that the Expected Results for that change hold in product/UX/system behavior. No vague "check that it works."

```markdown
## Manual Verifications
### <key change 1>
1. ...
2. ...

### <key change 2>
1. ...
2. ...
```

### Additional Context

Free form.

```markdown
## Additional Context
```

**Drafting invariants:**

- Key-change `<name>` values are shared across Key Takeaways, Expected Results, and Manual Verifications (same set, same names).
- Expected Results: concise logic in plain English only.
- Manual Verifications: executable, observable behavior guidelines — not unit/integration test commands or "run the test suite."

## 4. Approval loop (mandatory)

Present:

1. Proposed issue title
2. Full specification

Ask for approval.

If the user requests changes:

- Gather missing information
- Update the specification
- Present it again

**Do not create the issue until explicit approval is received.**

## 5. Create GitHub Issue

After approval:

```bash
gh issue create \
  --title "$TITLE" \
  --body "$SPEC"
```

Report the issue URL and number.

If issue creation fails:

- Explain the failure
- Preserve the generated specification
- **Stop.**

## 6. Stop

Do not create a worktree, do not enter plan mode, and do not implement. Suggest next steps when relevant:

Same session (preferred after this freeze):

```
/conv-to-code
```

Cold start later / in a new session:

```
/issue-to-code <N>
```

## Editing an existing issue

When asked to edit an issue (rather than create), write the issue's final, intended state:

- Use `gh issue edit <number> --title ... --body ...`.
- The body is the complete, current specification — not a changelog of the conversation.
- Do not append "we discussed X then changed to Y" history; replace stale content with what the issue should now say.
- Keep the four-section shape and shared key-change names.
