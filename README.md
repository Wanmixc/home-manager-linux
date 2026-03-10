# Home Manager Linux

Personal [Home Manager](https://nix-community.github.io/home-manager/) configuration for Linux, managed with [Nix](https://nixos.org/).

This repository declaratively defines the user environment — installed packages, dotfiles, shell settings, and program configurations — so everything can be reproduced on any Linux machine with Nix.

> [!IMPORTANT]
> Before running `home-manager switch`, create a `secrets.json` file in the repository root:
>
> ```json
> {
>   "github_token": "your github token",
>   "gitlab_token": "your gitlab token"
> }
> ```

## What's Included

| Category | Details |
|---|---|
| **Editor** | Neovim (custom `nvim/init.lua`), Vim |
| **Shell & Terminal** | Tmux, Zoxide, Direnv, Bash Language Server, ShFmt |
| **File Manager** | Yazi (with Neovim integration and Fish shell support) |
| **Git** | Git with [delta](https://github.com/dandavison/delta) (side-by-side diffs), GitUI |
| **Search & Utilities** | Ripgrep, Bat, Eza, Unzip, Fastfetch |
| **AI Tools** | [OpenCode](https://opencode.ai/), [Codex CLI](https://github.com/openai/codex) |
| **Browser** | Microsoft Edge |
| **Runtime** | Bun |

## Repository Structure

```
.
├── home.nix              # Main Home Manager configuration
├── nvim/
│   └── init.lua          # Neovim configuration
├── fastfetch/
│   └── config.jsonc      # Fastfetch system info display config
├── opencode_config/
│   └── just-chat.txt     # Custom prompt for OpenCode chat agent
├── secrets.json          # (git-ignored) GitHub/GitLab tokens
└── README.md
```

## Getting Started

### Prerequisites

- [Nix](https://nixos.org/download/) package manager
- [Home Manager](https://nix-community.github.io/home-manager/) installed as a standalone tool or NixOS module

### Setup

1. Clone this repository:

   ```bash
   git clone https://github.com/Wanmixc/home-manager-linux.git ~/.config/home-manager
   ```

2. Create a `secrets.json` file in the repository root with your tokens:

   ```json
   {
     "github_token": "your github token",
     "gitlab_token": "your gitlab token"
   }
   ```

3. Apply the configuration:

   ```bash
   home-manager switch
   ```

## Key Configuration Highlights

- **Git** — Configured with `delta` for side-by-side diffs, automatic remote setup on push, and private repo access via tokens from `secrets.json`.
- **Yazi** — Opens text files in Neovim by default; hidden files are shown.
- **Direnv** — Enabled for per-directory environment management.
- **Codex CLI** — Packaged as a custom Nix overlay fetched from the official GitHub release.
- **OpenCode** — Includes a custom "just-chat" agent with a minimal, chat-only prompt.
