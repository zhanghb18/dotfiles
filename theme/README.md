# Theme: Rosé Pine

[Rosé Pine](https://rosepinetheme.com/) (variant: `main`) is the default across
tools. Zellij is the one deliberate exception — see below.

## Palette

```
base      #191724
surface   #1f1d2e
overlay   #26233a
muted     #6e6a86
subtle    #908caa
text      #e0def4
love      #eb6f92
gold      #f6c177
rose      #ebbcba
pine      #31748f
foam      #9ccfd8
iris      #c4a7e7
```

## Per-tool Configuration

### Neovim
- Plugin: `rose-pine/neovim`
- Set `vim.cmd.colorscheme('rose-pine')` with variant `main`
- Reference: `nvim/lua/plugins/colorscheme.lua`

### Starship
- Use `palette = "rose_pine"` and define `[palettes.rose_pine]` with the colors above
- Reference: `starship/starship.toml`

### Zellij
- Exception: this repo runs `theme "catppuccin-mocha"`, not rose-pine.
- Zellij does ship a built-in `rose-pine` theme, so switching back is a
  one-line change in `zellij/config.kdl`.
- Reference: `zellij/config.kdl`

### Yazi
- Install flavor: `ya pkg add Mintass/rose-pine`
- Set in theme.toml:
  ```toml
  [flavor]
  dark = "rose-pine"
  light = "rose-pine"
  ```
- Reference: `yazi/theme.toml`, `yazi/flavors/rose-pine.yazi/`

### bat / delta (git diff)
- Copy `theme/rose-pine.tmTheme` to `~/.config/bat/themes/` then run `bat cache --build`
- Set `syntax-theme = rose-pine` in `.gitconfig` under `[delta]`
- Reference: `git/.gitconfig`

### Terminal emulator
- Out of scope for this repo. The host terminal (Windows Terminal, Warp, iTerm2)
  is configured on the host — see the boundary in `CLAUDE.md`.
- If you do theme one by hand, find the port at https://rosepinetheme.com/, or
  set background `#191724`, foreground `#e0def4`, cursor `#524f67`.

## Adding theme to a new tool

1. Check https://rosepinetheme.com/ for an official port
2. If available, install and configure per that tool's docs
3. If not, use the palette above to create a custom config
4. Document the setup steps in this file
