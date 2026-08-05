# AGENTS.md

Project agent instructions live in [`CLAUDE.md`](CLAUDE.md). Read and follow that file.

## Cursor Cloud specific instructions

This repo is a **Claude Code / Cursor plugin** (`english-coding`) made of markdown skills plus a
bash `SessionStart` hook, an opt-in Telegram `Stop` hook, and a CI-only Python summarizer. There is
**no build system, no test suite, no lint config, and no package manager** (no `package.json` /
`requirements.txt`). See `README.md` for install/usage and `CLAUDE.md` for internal structure and
how to add skills.

### Toolchain
All required development tools ship pre-installed on the VM: `jq`, `curl`, `gh` (required by the
`conv-to-issue` / `issue-to-code` skills, and already authenticated), plus `python3`, `bash`, and
`node`. `ccusage` is optional and may be stubbed for Telegram hook verification. Nothing needs
installing for local development, so the startup update script is a no-op.

### Runnable components: Claude Code hooks
For `SessionStart`, the host resolves the command from
`hooks/hooks.json` (`${CLAUDE_PLUGIN_ROOT}/hooks/doc-scoping-context.sh`) and reads the JSON's
`.hookSpecificOutput.additionalContext`. Run/verify it directly:

```bash
CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/doc-scoping-context.sh | jq -r '.hookSpecificOutput.additionalContext'
```

Gotcha: the hook **requires `jq`** and intentionally exits `1` (no-op) when `jq` is absent — that
non-zero exit is a graceful skip, not a failure. It also relies on `CLAUDE_PLUGIN_ROOT`, but the
script itself does not read that variable; the host only uses it to locate the file.

`hooks/telegram-notify.sh` runs asynchronously on `Stop`. It is a no-op unless
`TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` are set. Never use real Telegram credentials in local
verification; stub `curl` and, when exercising usage parsing, `ccusage`.

### "Lint" / validation for this repo
There is no configured linter. The meaningful checks are JSON validity and shell syntax:

```bash
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json .cursor-plugin/plugin.json hooks/hooks.json; do jq empty "$f"; done
for f in hooks/*.sh; do bash -n "$f"; done
```

### CI summarizer (not needed for local dev)
`.github/scripts/summarize_branch.py` runs only in the `Open Draft PR` GitHub Action via
`uv run --with litellm` and needs `OPENROUTER_API_KEY`. `uv` is not installed locally and is not
required; the script is designed to exit non-zero and let the workflow fall back to a commit-list
PR body when the key or dependency is missing.
