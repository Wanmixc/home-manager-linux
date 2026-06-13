# Home Manager

Personal multi-machine [Home Manager](https://nix-community.github.io/home-manager/) configuration for:

- `cachyos-nix`
- `wsl`
- `vps`

This repository now uses a flat `programs/` layout so each app or concern is defined in one `.nix` file.

## Host Targets

Available Home Manager flake targets:

- `wanmixc-cachyos-nix`
- `wanmixc-wsl`
- `wanmixc-vps`

## Rules

AI tool policy:

- `cachyos-nix` -> `codex`
- `wsl` -> `codex`
- `vps` -> `deepseek`

Neovim policy:

- one shared Neovim config
- source of truth is the `programs/nvim/` folder in this repo

## Repository Structure

```text
.
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
│   ├── starship.nix
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
│   ├── nvim/
│   ├── starship/
│   ├── tmux/
│   ├── fastfetch/
│   ├── rmpc/
│   ├── codex/
│   └── deepseek/
└── secrets.json
```

## Secrets

`secrets.json` is optional.

If present, it may contain:

```json
{
  "github_token": "your github token"
}
```

If the file is absent, the configuration still evaluates successfully.

## Usage

Clone the repository wherever you want, for example:

```bash
git clone https://github.com/Wanmixc/home-manager-linux.git ~/.config/home-manager
cd ~/.config/home-manager
```

Apply a target with Home Manager:

```bash
home-manager switch --flake .#wanmixc-cachyos-nix
home-manager switch --flake .#wanmixc-wsl
home-manager switch --flake .#wanmixc-vps
```

If local files already exist and need backup:

```bash
home-manager switch -b backup --flake .#wanmixc-cachyos-nix
```

## Compatibility Wrapper

`home.nix` remains as a thin compatibility wrapper.

Current behavior:

- auto-selects `wsl` when WSL is detected
- auto-selects `cachyos-nix` on host `Wan-PC`
- requires explicit `--flake` selection for unsupported non-flake hosts such as VPS

For VPS, prefer:

```bash
home-manager switch --flake .#wanmixc-vps
```

## Notes

- `programs/tmux/tmux.nix` is preserved and imported through [programs/tmux.nix](/home/wanmixc/.config/home-manager/programs/tmux.nix).
- Desktop-only integrations such as Edge and Codex Chrome DevTools MCP are only enabled on the desktop host.
- DeepSeek is currently packaged through a binary release flow in [programs/deepseek.nix](/home/wanmixc/.config/home-manager/programs/deepseek.nix).
