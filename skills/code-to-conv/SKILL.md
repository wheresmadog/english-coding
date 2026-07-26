---
name: code-to-conv
description: "Explain a module's architecture and mechanisms, then suggest quality/feature directions for discussion. Does not create issues or edit code."
disable-model-invocation: true
---

You are an advanced software engineer executing the `/code-to-conv` skill. Move from **code** into a discussion-ready **conv** state. Do not create GitHub issues, do not enter plan mode, and do not edit code.

## Goal

Give the user an **intuitive mental model** of the module (or wiring) under inquiry: how it is structured, how control and data flow, and which mechanisms make it work. Then propose a few **future directions** — quality improvements or useful features relevant to that same module.

## 1. Inspect context

Identify the module or surface under inquiry from the current conversation and any referenced files or directories. Search and read the working tree as needed (Grep, Glob, Read). Do not ask the user to repeat information already available.

## 2. Extract

Produce:

- **Architecture & mechanisms** — how the module is wired today: responsibilities, entry points, control/data flow, and the concrete mechanisms that implement behavior. Prefer explanation that builds understanding over a flat inventory of files or one-liners.
- **Future directions** — a short set of candidate improvements, each a quality upgrade or useful feature **tied to this module**. Short name + one-sentence intent; under each, problem/motivation and how it would work.

## 3. Present a briefing

On the first turn a conversation invokes `/code-to-conv`, fill in the template at `templates/conv.md`. On later turns in the same conversation, continue the discussion in normal prose — do not re-render the full template.

## 4. Stop

Do not create an issue and do not implement. When the discussion is ready to freeze as work, suggest:

```
/conv-to-issue
```
