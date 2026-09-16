# Terminal Stack

This repo documents and manages the Linux side of the terminal stack.

## Boundary

Managed here:

- Linux shell and CLI tool config
- `~/.config/fish/config.fish`
- `~/.bashrc` (only the appended fish-handoff block)
- `~/.config/atuin/config.toml`
- `~/.config/starship.toml`
- `~/.config/yazi/`
- `~/.config/zellij/config.kdl`
- `~/.config/nvim`
- `~/.claude/settings.json` (portable keys only — see `claude/README.md`)
- `~/.gitconfig`
- `~/.config/git/ignore`
- `~/.tmux.conf`

Not managed here:

- Windows Terminal settings
- Windows fonts
- Warp settings
- WSL `.wslconfig`
- Windows proxy applications

Those host-side pieces can be documented elsewhere, but the dotfiles repo stays
Linux-focused.

## Current Shape

The current preferred environment is:

```text
Ubuntu 24.04 LTS, native or under WSL
bash as the login shell, fish as the interactive shell
Starship prompt
Zellij for workspace sessions
Neovim for editing
Yazi for file browsing
lazygit for Git workflows
Rose Pine theme across supported tools
```

Windows Terminal can launch the WSL distro, but its profile JSON and font setup
live outside this repo.

## Shell

Fish is the default shell. The reference file is:

```text
shell/config.fish
```

Install it to:

```text
~/.config/fish/config.fish
```

Fish is not the login shell, though. `/etc/passwd` stays on `/bin/bash` and
`~/.bashrc` execs fish only for a plain interactive terminal, using the block in
`shell/bashrc-fish-switch.sh`. The reason is VSCode Remote-SSH: it bootstraps by
running a bash script through `ssh host bash -c '...'`, fish cannot parse it, and
the connection fails with `Connecting with SSH timed out`. Anything driving a
shell programmatically — scripts, `ssh host 'cmd'`, Claude Code's Bash tool —
stays in bash for the same reason. `NO_FISH=1` skips the handoff for one session.
See `shell/README.md` for the exact conditions.

The config wires up:

- vi-style command editing with modal cursor shapes
- `starship init fish`
- `zoxide init fish`
- `fzf --fish`
- `atuin init fish`
- `direnv hook fish`
- `mise activate fish`
- a `y` wrapper for Yazi cwd handoff
- zsh-era `cd -> zoxide` behavior through `alias cd z`
- `IS_SANDBOX=1`

`IS_SANDBOX` is exported before the `status is-interactive` guard on purpose:

```fish
set -gx IS_SANDBOX 1
```

Inside the guard, non-interactive fish and Zellij resurrect would not pick it
up. Zellij sets the same variable through `env { IS_SANDBOX "1" }` in
`zellij/config.kdl`, so panes get it even when the shell config is not read.

What that variable buys is narrow: it is the gate that lets Claude Code accept
`--dangerously-skip-permissions` while running as root. It does not turn bypass
on. The default permission mode is `auto`, set in `claude/settings.json`, and no
alias passes the bypass flag — a session that wants it has to say so on the
command line.

Fish starts in vi normal mode for command-line editing:

```fish
fish_vi_key_bindings
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual block
bind -M insert jk 'set fish_bind_mode default; commandline -f repaint'
set -g fish_bind_mode default
```

Atuin history search keeps selected commands editable instead of executing them
immediately:

```toml
enter_accept = false
```

With the up-arrow Atuin picker, `Enter` and `Tab` put the selected command back
on the prompt. Press `Enter` again from the shell prompt to run it.

The old zsh settings have been migrated to fish. New setup should not install
or manage zsh config from this repo.

## Core Tools

Package names below are Ubuntu's. They differ from the upstream Arch names in
several places, and a few tools are not packaged at all — see "Not In apt".

From apt:

```text
fish zoxide direnv eza bat fd-find ripgrep git git-delta gh tmux
```

Toolchains from apt:

```text
rustup nodejs npm golang-go python3-pynvim
```

Quality-of-life from apt:

```text
btop duf hyperfine sd jq poppler-utils ffmpeg 7zip imagemagick
```

### Not In apt

Ubuntu 24.04 does not package these. This machine installs them as prebuilt
binaries:

| Tool | Where it lands here |
|---|---|
| starship, atuin, mise, yazi, resvg, lazygit, fzf | `~/.local/bin/` |
| uv, zellij | `/usr/local/bin/` |
| neovim | tarball in `/opt/nvim`, symlinked into `~/.local/bin/nvim` |
| dust, procs, tokei | not installed here; `cargo install du-dust procs tokei` |

`fzf` is in that list on purpose even though apt has it. See below.

### Ubuntu Gotchas

Four things bite on Ubuntu that do not exist on Arch. All four are load-bearing
for `shell/config.fish`, so skipping them leaves a broken prompt.

**Binaries are renamed.** `fd-find` installs `fdfind` and `bat` installs
`batcat`, because both names collide with older Debian packages. The fish config
calls `fd` and `bat` (`alias cat bat`, `alias find fd`, and the fzf defaults), so
bridge them once:

```bash
mkdir -p ~/.local/bin
ln -sf /usr/bin/fdfind ~/.local/bin/fd
ln -sf /usr/bin/batcat ~/.local/bin/bat
```

**apt's fzf is too old.** 24.04 ships 0.44, which has no `--fish` flag, and
`shell/config.fish` runs `fzf --fish | source`. Install a current fzf binary
into `~/.local/bin` instead of `apt install fzf` (this machine runs 0.74).

**apt's neovim is too old.** 24.04 ships 0.9.5. Use the upstream tarball; this
machine runs 0.12.4 out of `/opt/nvim`.

**ImageMagick is version 6.** `imagemagick` provides `convert` via
`convert-im6.q16`, not the `magick` entry point that ImageMagick 7 uses. Fine for
Yazi previews, worth knowing if something asks for `magick`.

## Ubuntu Install Command

```bash
sudo apt update
sudo apt install -y \
  fish zoxide direnv tmux git git-delta gh \
  ffmpeg 7zip jq poppler-utils imagemagick \
  fd-find ripgrep eza bat \
  nodejs npm golang-go rustup python3-pynvim \
  btop duf hyperfine sd
```

Deliberately not in that line: `fzf` and `neovim`, both too old in 24.04, and
everything under "Not In apt".

Then the rename bridge:

```bash
mkdir -p ~/.local/bin
ln -sf /usr/bin/fdfind ~/.local/bin/fd
ln -sf /usr/bin/batcat ~/.local/bin/bat
```

`git-delta` is not optional if `git/.gitconfig` is applied: that file sets
`core.pager = delta`, so `git diff` fails outright when delta is missing.

## Apply Configs

Copy files instead of symlinking:

```bash
mkdir -p ~/.config/fish ~/.config/atuin ~/.config/bat/themes ~/.config/git

cp ~/.dotfiles/shell/config.fish ~/.config/fish/config.fish
cp ~/.dotfiles/atuin/config.toml ~/.config/atuin/config.toml
cp ~/.dotfiles/starship/starship.toml ~/.config/starship.toml
cp -a ~/.dotfiles/yazi ~/.config/yazi
cp ~/.dotfiles/zellij/config.kdl ~/.config/zellij/config.kdl
cp ~/.dotfiles/theme/rose-pine.tmTheme ~/.config/bat/themes/rose-pine.tmTheme
cp ~/.dotfiles/git/ignore ~/.config/git/ignore
cp ~/.dotfiles/git/.gitconfig ~/.gitconfig
cp ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf

bat cache --build
```

`~/.bashrc` is appended to, not copied over, since the rest of it comes from the
distro:

```bash
grep -q 'dotfiles: interactive bash -> fish' ~/.bashrc ||
  cat ~/.dotfiles/shell/bashrc-fish-switch.sh >> ~/.bashrc
```

For Neovim, prefer a real clone/copy at `~/.config/nvim` instead of a symlink.

## WSL Proxy Note

If this Linux environment runs under WSL and Windows owns the proxy, keep proxy
mechanics outside this repo. The shell config should not hard-code a local proxy.

On a configured WSL machine, the proxy may appear through environment variables:

```bash
env | grep -i proxy
```

For commands that drop environment variables through `sudo`, pass proxy values
explicitly only when needed:

```bash
sudo env http_proxy=$http_proxy https_proxy=$https_proxy apt update
```
