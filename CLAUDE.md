# Linux Terminal Configuration

Personal Linux-side development environment. This file is the entry point for an
agent setting up the dotfiles on a Linux machine or inside WSL.

## Scope

Manage only Linux user configuration:

- fish shell configuration
- Linux CLI tools and language toolchains
- Neovim, Yazi, Zellij, Starship, Git, Delta, bat themes
- files under the Linux home directory such as `~/.config/*`, `~/.gitconfig`,
  and `~/.tmux.conf`

Do not manage host-side Windows settings from this repo:

- Windows Terminal profiles, keybindings, fonts, or color schemes
- Warp settings
- Windows proxy clients
- WSL `.wslconfig`

Those are allowed to exist on the machine, but they are not part of this
dotfiles repo.

## How To Use

When setting up this repo on a new Linux environment:

1. Read this file and `docs/terminal-stack.md`.
2. Detect OS, package manager, and current shell.
3. Prefer fish as the interactive shell unless the user explicitly asks
   otherwise.
4. Install the package set for the detected distro.
5. Copy reference configs into the real config paths. Two files are exceptions
   and must be merged or appended instead — `claude/settings.json` and
   `shell/bashrc-fish-switch.sh`.
6. Before overwriting existing config, inspect it and make timestamped backups.
7. Preserve machine-specific values such as `user.name`, `user.email`, tokens,
   proxy settings, and secrets.
8. Set this repo's own commit identity — see "GitHub identity" below. A fresh
   clone has no local identity, so commits silently go out under the machine's
   global (work) address until this is done.

Important: do not use symlinks. Copy reference files from this repo into the
machine config locations so each machine can have small local differences.

## 1. Language Toolchains

### Rust

- Install via package manager or `rustup`.
- Preferred default: nightly.
- Recommended components: `rust-analyzer`, `rust-src`, `clippy`, `rustfmt`.
- Fish path is handled by `shell/config.fish`.

### Python

- Install `uv`.
- Use `uv` and `uvx` for project environments and Python tools.

### Multi-runtime Management

- Install `mise`.
- Activate it from fish with `mise activate fish | source`.
- Use `.tool-versions` or `mise.toml` per project when needed.

## 2. Shell

Fish is the primary shell.

- Reference config: `shell/config.fish`
- Target path: `~/.config/fish/config.fish`
- Previous zsh behavior has been migrated into `shell/config.fish`.

Fish is the *interactive* shell, not the login shell. Do not run `chsh -s
$(which fish)`. Leave `/etc/passwd` on `/bin/bash` and append
`shell/bashrc-fish-switch.sh` to `~/.bashrc` instead:

```bash
grep -q 'dotfiles: interactive bash -> fish' ~/.bashrc ||
  cat ~/.dotfiles/shell/bashrc-fish-switch.sh >> ~/.bashrc
```

Append, never overwrite — the rest of `~/.bashrc` is distro-provided. Making fish
the login shell breaks VSCode Remote-SSH, whose bootstrap is a bash script sent
over `ssh host bash -c '...'`; the symptom is `Connecting with SSH timed out`.
The appended block hands over to fish only for a real interactive terminal, so
`ssh host 'cmd'`, the VSCode server, and this agent's own Bash tool all stay in
bash. Read `shell/README.md` before changing the conditions.

Two rules keep that working, because `$SHELL` is what tools actually consult and
`exec fish` does not rewrite it: never `chsh` to fish, and never assign `SHELL`
in `shell/config.fish` or in zellij's `env` block.

The fish config initializes:

- Starship prompt
- zoxide directory jumping
- zsh-era `cd -> zoxide` behavior through `alias cd z`
- fzf keybindings
- atuin history
- direnv
- mise
- Yazi `y` wrapper
- `IS_SANDBOX=1`, exported outside the `status is-interactive` guard so
  non-interactive fish and Zellij resurrect also see it. It only makes an
  explicit `--dangerously-skip-permissions` possible as root; the default
  permission mode comes from `claude/settings.json`. No alias adds that flag.

## 3. Terminal Workspace

### Zellij

- Install via package manager.
- Reference config: `zellij/config.kdl`
- Target path: `~/.config/zellij/config.kdl`
- Default interaction model is normal-mode first (`default_mode "normal"`), with
  the stock keybindings plus a `tmux` mode.
- Theme is `catppuccin-mocha` here, a deliberate exception to the Rose Pine
  default. See `theme/README.md`.
- The config declares `env { IS_SANDBOX "1" }` so every pane and every
  resurrected command inherits it without depending on the fish config being
  read. See `claude/README.md` for what it does and does not enable.
- Zellij rewrites this file when it regenerates defaults. After a rewrite,
  re-apply the repo copy or capture the machine copy back into the repo.

### Tmux

- Reference config: `tmux/.tmux.conf`
- Target path: `~/.tmux.conf`
- Kept as a lightweight fallback even when Zellij is preferred.

## 4. File, Search, And Preview Tools

From apt:

```text
ffmpeg 7zip jq poppler-utils fd-find ripgrep zoxide imagemagick eza bat
```

Not packaged in Ubuntu 24.04 — install prebuilt binaries into `~/.local/bin`:

```text
yazi resvg fzf
```

`fzf` is on that second list even though apt has one: 24.04 ships 0.44, which
predates the `--fish` flag that `shell/config.fish` needs.

Ubuntu renames two binaries. `fd-find` installs `fdfind`, `bat` installs
`batcat`, and the fish config calls both by their upstream names:

```bash
mkdir -p ~/.local/bin
ln -sf /usr/bin/fdfind ~/.local/bin/fd
ln -sf /usr/bin/batcat ~/.local/bin/bat
```

Targets:

- `yazi/` -> `~/.config/yazi/`
- `theme/rose-pine.tmTheme` -> `~/.config/bat/themes/rose-pine.tmTheme`
- Run `bat cache --build` after copying the bat theme.
- Run `ya pkg install` from `~/.config/yazi` after copying Yazi config.

## 5. Editor

### Neovim

- Install `python3-pynvim` from apt. Do **not** use apt's `neovim`: 24.04 ships
  0.9.5. Use the upstream tarball instead — this machine runs 0.12.4 unpacked
  into `/opt/nvim` with a symlink at `~/.local/bin/nvim`.
- Config source: `nvim/` submodule, tracking upstream
  `https://github.com/FatPigeorz/nvim_config` read-only over HTTPS so a new
  machine can `clone --recursive` without an SSH key.
- Preferred target: clone/copy to `~/.config/nvim`.
- Initialize plugins once with `nvim --headless '+qa'`.
- Install Mason LSPs declared by the config:
  `lua-language-server`, `pyright`, `rust-analyzer`, `clangd`.

## 6. Version Control

From apt (`github-cli` is called `gh` here):

```text
git git-delta gh
```

`lazygit` is not packaged in 24.04 — install a prebuilt binary into
`~/.local/bin`.

`git-delta` is required, not optional, once `git/.gitconfig` is in place: it sets
`core.pager = delta`, so `git diff` fails outright without it.

Targets:

- `git/.gitconfig` -> `~/.gitconfig`
- `git/ignore` -> `~/.config/git/ignore`

`git/.gitconfig` sets no `user.name` / `user.email` on purpose. This file is
copied to `~/.gitconfig` verbatim, and the work address should not be in a repo
that may be public. Set the identity per machine after copying:

```bash
git config --global user.name  "<name>"
git config --global user.email "<address>"
```

Until that is done, git refuses to commit rather than guessing — which is the
point. GitHub repos need a different address; see the next section.

Notes on the reference file:

- `core.pager = delta` and `[interactive] diffFilter` assume `git-delta` is
  installed. Without it, `git diff` fails — install `git-delta` or drop those
  two settings on that machine.
- `[url "https://github"] insteadOf = git://github` rewrites legacy `git://`
  URLs, which some vendored dependencies still use.
- `core.hooksPath` is intentionally not set, so per-repo hooks keep working.
- No `[user]` section, per the paragraph above.

### GitHub identity

The global identity above is the GitLab / work one. GitHub repos need a
different address, so this dotfiles repo sets its own identity locally:

```bash
git config --local user.name "Zhang Houbin"
git config --local user.email "64059464+zhanghb18@users.noreply.github.com"
```

Two things to know:

- `--local` lives in `.git/config`, which is not tracked. After cloning this
  repo on a new machine, run those two commands again or commits go out under
  the work email.
- The `64059464+` prefix is required. This GitHub account was created after
  2017-07-18, so the bare `zhanghb18@users.noreply.github.com` form does not
  get attributed to the account.

`--local` is deliberately the only mechanism. A `hasconfig:remote.*.url`
`includeIf` in `git/.gitconfig` could set this automatically, but it was dropped:
it would put a GitHub identity into every machine's global config to serve the
one repo that talks to GitHub, and two ways to set the same thing is worse than
one step to remember.

## 7. Package Summary

For Ubuntu 24.04:

```bash
sudo apt update
sudo apt install -y \
  fish zoxide direnv tmux git git-delta gh \
  ffmpeg 7zip jq poppler-utils imagemagick \
  fd-find ripgrep eza bat \
  nodejs npm golang-go rustup python3-pynvim \
  btop duf hyperfine sd
```

Then the two rename symlinks from section 4.

Not in apt at all. Prebuilt binaries, which is how this machine has them:

| Tool | Lands in |
|---|---|
| starship, atuin, mise, yazi, resvg, lazygit, fzf | `~/.local/bin/` |
| uv, zellij | `/usr/local/bin/` |
| neovim (0.12.4) | `/opt/nvim`, symlinked into `~/.local/bin/` |
| dust, procs, tokei | `cargo install du-dust procs tokei` |

Held back from apt on purpose: `fzf` (0.44, no `--fish`) and `neovim` (0.9.5).
Both are covered above.

The upstream repo targeted Arch. If a machine is Arch rather than Ubuntu, the
Arch names are in this repo's history at `70f3773`.

Optional font packages are machine/host specific. Do not manage Windows fonts
from this repo.

## 8. Theme

Use Rose Pine where configs exist:

- Starship palette in `starship/starship.toml`
- Yazi flavor in `yazi/flavors/`
- bat/delta syntax theme via `theme/rose-pine.tmTheme`

Read `theme/README.md` for palette details.

## 9. Claude Code

- Reference config: `claude/settings.json`
- Target path: `~/.claude/settings.json`
- Default permission mode is `auto`, set through
  `permissions.defaultMode`. Bypass is not the default: it skips every prompt.
- This file is the one exception to "copy reference configs into place". Merge it
  instead, because the live file also holds the machine's gateway `env`, its
  gateway-specific `model` id, and platform-injected `hooks`, none of which
  belong in this repo.
- Read `claude/README.md` before touching it — it carries the merge command and
  the reason each excluded key is excluded.
