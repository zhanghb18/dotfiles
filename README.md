# Linux Terminal Configuration

Personal Linux-side development environment. Fish-first shell, modern CLI tools,
and a unified Rose Pine theme.

This repo intentionally manages only the Linux user environment. On Windows/WSL,
Windows Terminal, fonts, Warp, and other host-side settings are configured
outside this repo.

## Quick Setup

```bash
git clone --recursive https://github.com/zhanghb18/dotfiles.git ~/.dotfiles
```

Then ask an agent to read `CLAUDE.md` and set up the Linux environment.

### After cloning: fix the commit identity

`.git/config` is not tracked, so a fresh clone inherits the machine's global
identity — on a work machine that is the work email, and commits go out under it
without any warning. Run these two commands right after cloning:

```bash
git config --local user.name "Zhang Houbin"
git config --local user.email "64059464+zhanghb18@users.noreply.github.com"
```

This is the only repo here that talks to GitHub, so it stays a per-repo setting
and nothing global changes. See "GitHub identity" in `CLAUDE.md` for why the
`64059464+` prefix is required.

## Terminal Stack

Read `docs/terminal-stack.md` for the current fish-based stack, install plan,
and host/Linux responsibility boundary.

## What's Included

| Category | Tools |
|----------|-------|
| Shell | fish, Starship, zoxide, fzf, atuin, direnv |
| Language Toolchains | Rust nightly, uv, mise, Node.js, Go |
| Terminal Workspace | Zellij, tmux |
| File & Search | Yazi, ripgrep, fd, eza, bat |
| Editor | Neovim submodule |
| Version Control | Git, Delta, lazygit, GitHub CLI |
| System Utilities | btop, duf, dust, procs, hyperfine, tokei, sd |
| Theme | Rose Pine across supported tools |

## Directory Structure

```text
atuin/          - Atuin history search config
docs/           - Notes for the current Linux terminal stack
shell/          - fish config and shell reference notes
starship/       - Starship prompt config
yazi/           - Yazi file manager config and Rose Pine flavor
zellij/         - Zellij multiplexer config
git/            - Git config and global ignore
nvim/           - Neovim config submodule
tmux/           - Tmux config
theme/          - Rose Pine theme assets
```

## Principles

- Linux-side config only.
- Fish is the default interactive shell.
- No symlinks: copy reference files into their real config locations.
- Keep host terminal/app settings out of this repo.
- Prefer apt on Ubuntu 24.04; a handful of tools are not packaged and come in as
  prebuilt binaries under `~/.local/bin`.
- Keep existing machine-specific secrets and identities intact.
