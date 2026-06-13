# Multi-Machine Home Manager Plan

## Scope

Use one Home Manager repo across exactly these machines:

1. `cachyos-nix`
2. `wsl`
3. `vps`

## Hard Rules

1. Work on `main`, not branch `vps`.
2. AI apps:
   - `cachyos-nix` -> `codex` only
   - `wsl` -> `codex` only
   - `vps` -> `deepseek` only
3. Neovim:
   - use one shared config only
   - source of truth is the `programs/nvim/` folder now used by Home Manager
4. Keep config simple:
   - `hosts/` only selects what each machine imports
   - `programs/` contains flat `.nix` files
   - one app/program/concern per `.nix` file

## Current Structure

```text
~/.config/home-manager
├── flake.nix
├── home.nix
├── hosts/
│   ├── cachyos-nix.nix
│   ├── wsl.nix
│   └── vps.nix
├── programs/
│   ├── base.nix
│   ├── env.nix
│   ├── git.nix
│   ├── fish.nix
│   ├── xdg.nix
│   ├── devtools.nix
│   ├── desktop.nix
│   ├── codex.nix
│   ├── deepseek.nix
│   ├── nvim.nix
│   ├── tmux.nix
│   ├── yazi.nix
│   ├── fastfetch.nix
│   ├── rmpc.nix
│   ├── mpd.nix
│   └── nvim/
├── tmux/
├── fastfetch/
├── rmpc/
├── codex/
├── deepseek/
└── secrets.json
```

## Status

### Completed

- Added `flake.nix`.
- Added host targets:
  - [cachyos-nix.nix](/home/wanmixc/.config/home-manager/hosts/cachyos-nix.nix)
  - [wsl.nix](/home/wanmixc/.config/home-manager/hosts/wsl.nix)
  - [vps.nix](/home/wanmixc/.config/home-manager/hosts/vps.nix)
- Made `secrets.json` optional in [git.nix](/home/wanmixc/.config/home-manager/programs/git.nix).
- Split configuration into flat files under [programs/](/home/wanmixc/.config/home-manager/programs).
- Removed nested `modules/core`, `modules/apps`, `modules/features` structure.
- `codex` is only imported on `cachyos-nix` and `wsl`.
- `deepseek` is only imported on `vps`.
- `tmux/tmux.nix` is preserved and reused through [tmux.nix](/home/wanmixc/.config/home-manager/programs/tmux.nix).
- Neovim now uses the repo [programs/nvim/](/home/wanmixc/.config/home-manager/programs/nvim) folder as the visible config source.

### Remaining

- `fastfetch/config.jsonc` is still desktop-specific and not fully portable.
- No cleanup commit has been created yet.

## Host Mapping

### `cachyos-nix`

Imports:

- `base.nix`
- `env.nix`
- `git.nix`
- `fish.nix`
- `xdg.nix`
- `devtools.nix`
- `codex.nix`
- `desktop.nix`
- `nvim.nix`
- `tmux.nix`
- `yazi.nix`
- `fastfetch.nix`
- `rmpc.nix`
- `mpd.nix`

### `wsl`

Imports:

- `base.nix`
- `env.nix`
- `git.nix`
- `fish.nix`
- `xdg.nix`
- `devtools.nix`
- `codex.nix`
- `nvim.nix`
- `tmux.nix`
- `yazi.nix`
- `fastfetch.nix`

### `vps`

Imports:

- `base.nix`
- `env.nix`
- `git.nix`
- `fish.nix`
- `xdg.nix`
- `devtools.nix`
- `deepseek.nix`
- `nvim.nix`
- `tmux.nix`
- `yazi.nix`
- `fastfetch.nix`

## Notes

- `home.nix` is only a compatibility wrapper now.
- For normal use, prefer `home-manager switch --flake ...`.
- If a new machine is added later, add a new file under `hosts/` and import the needed files from `programs/`.
