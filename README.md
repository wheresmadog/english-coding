# english-coding

Workflow skills around **code ↔ conv/plan ↔ issue**.

## Features

| Skill | Invocation | Purpose |
|-------|-----------|---------|
| **code-to-conv** | `/code-to-conv` | Explain a module's architecture and mechanisms, then suggest quality/feature directions. Does not create issues or edit code. |
| **conv-to-issue** | `/conv-to-issue` | Freeze a discussion into an approved GitHub issue (four-section body). Stops after the issue exists. |
| **conv-to-code** | `/conv-to-code` | Same-session execute after `/conv-to-issue`: worktree, plan from conversation context, implement and verify. Requires a frozen issue. |
| **issue-to-code** | `/issue-to-code <issue>` | Cold-start execute: load an issue into a worktree, plan, implement and verify by key change. |

Capture path: **code → conv → issue**. Happy-path execute (same session): **conv → code** via `/conv-to-code` after `/conv-to-issue`. Cold start: **issue → code** via `/issue-to-code <N>`. Plan is an in-skill phase of the two `*-to-code` skills (in-session only). Coding always requires a frozen GitHub issue; worktrees are always `issue-<N>`.

## Prerequisite

Skills that talk to GitHub (`conv-to-issue`, `issue-to-code`) shell out to the GitHub CLI (`gh`). Verify it is installed and authenticated before use:

```bash
gh auth status
```

The optional Telegram notification hook also uses `jq`, `curl`, and
[`ccusage`](https://www.npmjs.com/package/ccusage). Install `ccusage` globally if you want plan
usage in notifications:

```bash
npm install --global ccusage
```

## Install

### Claude Code

Once published to GitHub, anyone can install it directly:

```bash
/plugin marketplace add https://github.com/wheresmadog/english-coding
/plugin install english-coding@english-coding
```

### Cursor

Clone (or symlink, for local development) the repo directly into Cursor's local plugins directory — this repo's layout already has `.cursor-plugin/plugin.json` at its root, matching what Cursor expects:

```bash
git clone https://github.com/wheresmadog/english-coding ~/.cursor/plugins/local/english-coding
```

```bash
ln -s /path/to/english-coding ~/.cursor/plugins/local/english-coding
```

Then restart Cursor, or run **Developer: Reload Window**.

## Telegram notifications

The plugin includes an opt-in Claude Code `Stop` hook. A `Stop` event occurs after every completed
Claude response, not only when the Claude Code process exits. When configured, the hook sends the
short session ID, estimated context remaining, and the current `ccusage` block percentage and reset
time to Telegram.

1. Message [`@BotFather`](https://t.me/BotFather), run `/newbot`, and copy the bot token.
2. Send a message to the new bot, then open
   `https://api.telegram.org/bot<TOKEN>/getUpdates` and copy `result[0].message.chat.id`.
3. Export the credentials in the environment that launches Claude Code:

   ```bash
   export TELEGRAM_BOT_TOKEN="your_bot_token"
   export TELEGRAM_CHAT_ID="your_chat_id"
   ```

Add those exports to your shell profile if they should persist. Never commit either value. Restart
Claude Code after changing its environment. Users who do not set both variables are unaffected; the
hook exits without making a request.

Context remaining defaults to a 200,000-token window. Override it for a different model:

```bash
export CLAUDE_CONTEXT_WINDOW=1000000
```

`ccusage` has changed its JSON schema across releases. The hook recognizes current and legacy block
layouts. Some releases do not report a percentage unless a token limit is configured; in that case
the notification displays `Usage: n/a%`. Missing `ccusage` also degrades to `n/a` without preventing
the Telegram message.

To test the installed plugin hook directly, substitute the plugin's installation path:

```bash
echo '{"session_id":"test-session","transcript_path":""}' |
  "/path/to/english-coding/hooks/telegram-notify.sh"
```

If no message arrives, confirm that the token and chat ID belong to the same bot conversation and
that `jq`, `curl`, and `ccusage` are on the `PATH` visible to Claude Code.

## Platform notes

### Claude Code

Fully supported, including a session-start documentation reminder and the opt-in Telegram `Stop`
notification hook.

### Cursor

Runs the skills too, but the Claude Code hooks do not fire.

See `CLAUDE.md` for the plugin's internal structure and how to add or modify a skill.
