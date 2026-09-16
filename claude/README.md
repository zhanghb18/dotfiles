# Claude Code

Reference for the Claude Code CLI configuration that belongs to this repo.

- Reference file: `claude/settings.json`
- Target path: `~/.claude/settings.json`

## Merge, do not copy

`claude/settings.json` holds only the portable part of the real settings file.
**Do not `cp` it over `~/.claude/settings.json`** — the live file also carries
values that must never live in this repo:

- `env` — API base URL and auth token of the local gateway
- `model` — a gateway-specific model id that does not resolve on other machines
- `hooks` — injected by the platform a given machine runs on

Merge so those survive:

```bash
jq -s '.[0] * .[1]' ~/.claude/settings.json ~/.dotfiles/claude/settings.json \
  > /tmp/claude-settings.json && mv /tmp/claude-settings.json ~/.claude/settings.json
```

On a machine that has no `~/.claude/settings.json` yet, a plain copy is fine.

## Permission mode

```json
"permissions": { "defaultMode": "auto" }
```

`auto` lets Claude Code decide per action and still stop to ask for anything it
classifies as destructive or as reaching outside the working directory. Bypass
(`--dangerously-skip-permissions`) skips every prompt, so it is deliberately not
the default here.

Bypass stays reachable on purpose, just never silently:

- `shell/config.fish` exports `IS_SANDBOX=1`, which is what lets bypass run as
  root, and `zellij/config.kdl` exports the same through its `env` block.
- Pass `claude --dangerously-skip-permissions` by hand for a session that needs
  it. No shell alias adds the flag anymore.

Two related keys are intentionally left out of this repo, so a new machine shows
each dialog once instead of silently inheriting an answer:

- `skipDangerousModePermissionPrompt` — the bypass-mode warning was accepted
- `skipAutoPermissionPrompt` — the auto-mode opt-in was accepted
