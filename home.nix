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
    btop
    fish
    speedtest-cli
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
