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
5. Copy reference configs into the real config paths.
6. Before overwriting existing config, inspect it and make timestamped backups.
7. Preserve machine-specific values such as `user.name`, `user.email`, tokens,
   proxy settings, and secrets.

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
  non-interactive fish and Zellij resurrect also see it

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
  resurrected command inherits it without depending on a fish alias.
- Zellij rewrites this file when it regenerates defaults. After a rewrite,
  re-apply the repo copy or capture the machine copy back into the repo.

### Tmux

- Reference config: `tmux/.tmux.conf`
- Target path: `~/.tmux.conf`
- Kept as a lightweight fallback even when Zellij is preferred.

## 4. File, Search, And Preview Tools

Install:

```text
yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick eza bat
```

Targets:

- `yazi/` -> `~/.config/yazi/`
- `theme/rose-pine.tmTheme` -> `~/.config/bat/themes/rose-pine.tmTheme`
- Run `bat cache --build` after copying the bat theme.
- Run `ya pkg install` from `~/.config/yazi` after copying Yazi config.

## 5. Editor

### Neovim

- Install `neovim` and `python-pynvim`.
- Config source: `nvim/` submodule, tracking upstream
  `https://github.com/FatPigeorz/nvim_config` read-only over HTTPS so a new
  machine can `clone --recursive` without an SSH key.
- Preferred target: clone/copy to `~/.config/nvim`.
- Initialize plugins once with `nvim --headless '+qa'`.
- Install Mason LSPs declared by the config:
  `lua-language-server`, `pyright`, `rust-analyzer`, `clangd`.

## 6. Version Control

Install:

```text
git git-delta lazygit github-cli
```

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

To make this automatic instead of per-clone, key it off the remote URL in
`git/.gitconfig` and drop the `--local` step:

```gitconfig
[includeIf "hasconfig:remote.*.url:https://github.com/**"]
	path = ~/.config/git/github.inc
[includeIf "hasconfig:remote.*.url:git@github.com:**"]
	path = ~/.config/git/github.inc
```

Requires git >= 2.36. All GitHub remotes are on `github.com` and all work
remotes are on `ai-git.shiyak-office.com`, so the condition is unambiguous.

## 7. Package Summary

For Arch Linux:

```bash
sudo pacman -S --needed \
  fish starship zoxide fzf atuin direnv mise uv nodejs npm go rustup \
  zellij tmux yazi ffmpeg 7zip jq poppler fd ripgrep resvg imagemagick \
  eza bat neovim python-pynvim git git-delta lazygit github-cli \
  btop duf dust procs hyperfine tokei sd
```

Optional font packages are machine/host specific. Do not manage Windows fonts
from this repo.

## 8. Theme

Use Rose Pine where configs exist:

- Starship palette in `starship/starship.toml`
- Yazi flavor in `yazi/flavors/`
- bat/delta syntax theme via `theme/rose-pine.tmTheme`

Read `theme/README.md` for palette details.
