{ config, pkgs, lib, ... }:
let
  secrets = builtins.fromJSON (builtins.readFile ./secrets.json);
  deepseek-tui-src = pkgs.fetchFromGitHub {
    owner = "Hmbown";
    repo = "CodeWhale";
    rev = "v0.8.44";
    hash = "sha256-gdwDAs1xmSII4Ps2DFYNR4XB64lhUjMYldFEoMENl8w=";
  };

  deepseek-cli = pkgs.rustPlatform.buildRustPackage {
    pname = "deepseek-tui-cli";
    version = "0.8.44";

    src = deepseek-tui-src;
    cargoLock.lockFile = "${deepseek-tui-src}/Cargo.lock";

    cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.dbus ];

    buildAndTestSubdir = "crates/cli";
    doCheck = false;
  };

  deepseek-tui = pkgs.rustPlatform.buildRustPackage {
    pname = "deepseek-tui";
    version = "0.8.44";

    src = deepseek-tui-src;
    cargoLock.lockFile = "${deepseek-tui-src}/Cargo.lock";

    cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.dbus ];

    buildAndTestSubdir = "crates/tui";
    doCheck = false;
  };
  deepseek-tui-combined = pkgs.symlinkJoin {
    name = "deepseek-tui-combined-0.8.44";
    paths = [
     deepseek-cli
     deepseek-tui
   ];
  };

  hermes-wheel = pkgs.fetchurl {
    url = "https://github.com/NousResearch/hermes-agent/releases/download/v2026.5.29.2/hermes_agent-0.15.2-py3-none-any.whl";
    hash = "sha256-FISwv2bSacjZAzZQm0GpwQQfx+YSTxON9xwkipVc3Ds=";
  };

  hermes-agent = pkgs.writeShellScriptBin "hermes" ''
    HERMES_VENV="$HOME/.local/share/hermes-agent"
    WHEEL="${hermes-wheel}"

    if [ ! -x "$HERMES_VENV/bin/hermes" ]; then
      echo "⚡ Bootstrapping Hermes Agent..."
      rm -rf "$HERMES_VENV"
      TMP_WHEEL="/tmp/hermes_agent-0.15.2-py3-none-any.whl"
      cp "$WHEEL" "$TMP_WHEEL"
      ${pkgs.uv}/bin/uv venv "$HERMES_VENV" --python 3.11
      ${pkgs.uv}/bin/uv pip install --python "$HERMES_VENV/bin/python" "$TMP_WHEEL"
      rm -f "$TMP_WHEEL"
      echo "✓ Hermes Agent ready."
    fi

    exec "$HERMES_VENV/bin/hermes" "$@"
  '';

in
{
  # Modules
  imports = [
    ./tmux/tmux.nix
    (import ./nvim/default.nix)
    (import ./programs/fish.nix)
    (import ./programs/git.nix)
    (import ./programs/yazi.nix)
    (import ./programs/misc.nix)
    (import ./services/mpd.nix)
  ];

  # Nixpkgs
  nixpkgs.config.allowUnfree = true;

  # Home metadata
  home.username = "wanmixc";
  home.homeDirectory = "/home/wanmixc";
  home.stateVersion = "25.11";

  # Packages
  home.packages = with pkgs; [
    bash-language-server
    bat
    bun
    eza
    fastfetch
    gitui
    ripgrep
    shfmt
    sxiv
    tmux
    unzip
    fzf
    deepseek-tui-combined
    hermes-agent
    uv
    btop
    fish
    speedtest-cli
    nodejs
    nmap
    tailscale
  ];

  # Session
  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEEPSEEK_TUI_BIN = "${deepseek-tui}/bin/deepseek-tui";
  };

  # XDG
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.configFile = {
    "fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
    "fastfetch/logo.txt".source = ./fastfetch/logo.txt;
    "rmpc/themes/theme.ron".source = ./rmpc/theme.ron;
    "starship.toml".source = ./starship/starship.toml;
  };

  # DeepSeek skills managed declaratively via Home Manager
  home.file = {
    ".deepseek/skills/commit-message-id/SKILL.md".source = ./deepseek/skills/commit-message-id/SKILL.md;
    ".deepseek/skills/skill-creator/SKILL.md".source = ./deepseek/skills/skill-creator/SKILL.md;
  };

  programs.home-manager.enable = true;
}
