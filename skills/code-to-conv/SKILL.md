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

- Current behavior: what the code does today, as a numbered list of one-sentence items
- Candidate key changes (short names + one-sentence intent each), each with its problem/motivation and how it works

## 3. Present a briefing

On the first turn a conversation invokes `/code-to-conv`, fill in the template at `templates/conv.md`. On later turns in the same conversation, continue the discussion in normal prose — do not re-render the full template.

## 4. Stop

Do not create an issue and do not implement. When the discussion is ready to freeze as work, suggest:

```
/conv-to-issue
```
