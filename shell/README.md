# Shell Configuration

Fish is the default shell for this dotfiles repo.

## Reference Files

```text
shell/config.fish            -> ~/.config/fish/config.fish
shell/bashrc-fish-switch.sh  -> appended to ~/.bashrc
```

The repo used to be zsh-centered. Those settings have been migrated into
`shell/config.fish`; new Linux setups should install fish and copy that file.

## Fish Features

The fish config includes:

- PATH entries for `~/.local/bin`, Cargo, and Go
- `EDITOR=nvim`
- Rose Pine bat theme
- fzf defaults based on `fd`
- vi-style command editing with modal cursor shapes
- Starship prompt
- zoxide smart directory jumping
- old zsh-style `cd` muscle memory via `alias cd z`
- fzf keybindings
- atuin history, with selected commands returned to the prompt for editing
- direnv
- mise
- Yazi `y` wrapper for changing cwd on exit

Vi mode starts in normal mode. It uses a block cursor in normal/visual mode, a
line cursor in insert mode, and `jk` as an insert-mode escape chord.

## Common Aliases

```fish
alias v nvim
alias vim nvim
alias cat bat
alias ls eza
alias ll 'eza -la --icons --git'
alias lt 'eza --tree --level=2 --icons'
alias find fd
alias yz yazi
alias cd z
alias lg lazygit
alias g git
alias gs 'git status -sb'
alias ga 'git add'
alias gc 'git commit'
alias gp 'git push'
alias gl 'git pull'
alias gd 'git diff'
alias b btop
```

## Tool Integrations

```fish
starship init fish | source
zoxide init fish | source
fzf --fish | source
atuin init fish | source
direnv hook fish | source
mise activate fish | source
```

## Yazi Wrapper

```fish
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if set -l cwd (cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
```

## Bash Handoff

Fish is the interactive shell, but it is **not** the login shell. Do not `chsh`
to fish. The shell in `/etc/passwd` stays `/bin/bash`, and `~/.bashrc` hands over
to fish only for a plain interactive terminal.

This is a bug that has already been hit once: VSCode Remote-SSH bootstraps the
connection by running a bash script over `ssh host bash -c '...'`. Fish cannot
parse it, and the failure surfaces as `Connecting with SSH timed out` with
nothing useful in the log. Agents that drive a shell (Claude Code's Bash tool)
assume bash too.

`shell/bashrc-fish-switch.sh` is the block that gets appended to `~/.bashrc`.
Append it, do not overwrite the file — `~/.bashrc` is distro-provided and the
rest of it belongs to the machine:

```bash
grep -q 'dotfiles: interactive bash -> fish' ~/.bashrc ||
  cat ~/.dotfiles/shell/bashrc-fish-switch.sh >> ~/.bashrc
```

It stays in bash whenever the session is not a human at a terminal:

| Condition | Covers |
|---|---|
| `BASH_EXECUTION_STRING` non-empty | `ssh host 'cmd'`, the VSCode bootstrap |
| `stdin` or `stdout` not a tty | pipes, scripts, Claude Code's Bash tool |
| `VSCODE_AGENT_FOLDER` set | processes inside the VSCode server |
| `CLAUDECODE` set | anything under Claude Code, even with a pty |
| `NO_FISH` set | manual escape hatch: `NO_FISH=1 ssh host` |

The `CLAUDECODE` check is belt-and-braces. Claude Code's Bash tool has no tty
today, so the tty check already catches it; the explicit check means a future
version that allocates a pty does not silently land the agent in fish.

To land in bash for one session without editing anything:

```bash
NO_FISH=1 ssh host      # or, once connected: bash --norc
```

### The invariant that actually matters

The `~/.bashrc` block is the second line of defence, not the first. The first is
`$SHELL`, which login sets from `/etc/passwd` and which `exec fish` does **not**
rewrite — so `$SHELL` stays `/bin/bash` even inside a fish session. Tools that
ask the system for "the shell" therefore get bash.

Claude Code is the case worth spelling out. Its process chain here is:

```text
zellij -> fish -> claude -> /bin/bash -c source ~/.claude/shell-snapshots/snapshot-bash-*.sh
```

It selected bash (the snapshot is named `snapshot-bash-*`, and contains no fish
traces), and it invokes it with `-c`, which satisfies the `~/.bashrc` guard a
second time.

Two things break that invariant, and nothing else does:

- `chsh -s $(which fish)` — changes `/etc/passwd`, so `$SHELL` becomes fish
- setting `SHELL` by hand in `shell/config.fish` or zellij's `env` block

Neither is done here, and neither should be. `shell/config.fish` deliberately
never assigns `SHELL`.

Uncommenting `default_shell "fish"` in `zellij/config.kdl` is a different matter
and is safe for this purpose: it changes what a pane launches, not `$SHELL`. The
cost is that panes stop running `~/.bashrc`, so the handoff block no longer
applies there.

## Notes

- Fish has built-in autosuggestions and syntax highlighting.
- Keep machine-specific proxy settings out of this repo.
- Fish is the interactive shell only. The login shell stays bash — see
  "Bash Handoff".
