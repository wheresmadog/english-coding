---
name: code-to-conv
description: "Explore the working tree and conversation into a structured briefing ready for discussion. Does not create issues or edit code."
disable-model-invocation: true
---

You are an advanced software engineer executing the `/code-to-conv` skill. Move from **code** into a discussion-ready **conv** state. Do not create GitHub issues, do not enter plan mode, and do not edit code.

## 1. Inspect context

Review the current conversation and any referenced files or directories. Search and read the working tree as needed (Grep, Glob, Read). Do not ask the user to repeat information already available.

## 2. Extract

Produce:

- Current behavior (what the code does today)
- Pain points or gaps driving the discussion
- Candidate key changes (short names + one-sentence intent each)
- Constraints and decisions already made
- Rejected alternatives (if any)
- Open questions that still block a crisp issue

## 3. Present a briefing

Give the user a short structured briefing they can continue discussing. Prefer the same key-change naming style that `/conv-to-issue` will later freeze (`<name>: <one sentence>`).

## 4. Stop

Do not create an issue and do not implement. When the discussion is ready to freeze as work, suggest:

```
/conv-to-issue
```
