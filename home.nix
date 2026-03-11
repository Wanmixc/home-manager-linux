{ config, pkgs, lib, ... }:
let
  secrets = builtins.fromJSON (builtins.readFile ./secrets.json);
in
{
  # Modules
  imports = [
    ./tmux/tmux.nix
  ];

  # Nixpkgs
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (final: prev: {
      codex = prev.stdenvNoCC.mkDerivation {
        pname = "codex";
        version = "0.112.0";

        src = prev.fetchurl {
          url = "https://github.com/openai/codex/releases/download/rust-v0.112.0/codex-x86_64-unknown-linux-musl.tar.gz";
          sha256 = "sha256-8riPhKgOfFt90k5TCP830IL0ryMRH0igaIyvdCIuwxQ=";
        };

        nativeBuildInputs = [
          prev.autoPatchelfHook
          prev.gnutar
        ];

        buildInputs = [
          prev.stdenv.cc.cc.lib
        ];

        dontConfigure = true;
        dontBuild = true;

        unpackPhase = ''
          tar -xzf $src
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp codex-x86_64-unknown-linux-musl $out/bin/codex
          chmod +x $out/bin/codex
        '';
      };
    })
  ];

  # Home metadata
  home.username = "wanmixc";
  home.homeDirectory = "/home/wanmixc";
  home.stateVersion = "25.11";

  # Packages
  home.packages = with pkgs; [
    bash-language-server
    bat
    bun
    codex
    direnv
    eza
    fastfetch
    gitui
    microsoft-edge
    neovim
    ripgrep
    shfmt
    sxiv
    tmux
    unzip
    yazi
    zoxide
  ];

  # Session
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # XDG
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.configFile = {
    "fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
    "nvim/init.lua".source = ./nvim/init.lua;
    "rmpc/themes/theme.ron".source = ./rmpc/theme.ron;
  };

  # Programs
  programs = {
    home-manager.enable = true;
    direnv.enable = true;
    vim.enable = true;

    git = {
      enable = true;
      package = pkgs.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      userEmail = "wanmixc@gmail.com"; # FIXME: set your git email
      userName = "wanmixc"; #FIXME: set your git username
      extraConfig = {
        # FIXME: uncomment the next lines if you want to be able to clone private https repos
        url = {
          "https://oauth2:${secrets.github_token}@github.com" = {
            insteadOf = "https://github.com";
          };
          # "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
          #   insteadOf = "https://gitlab.com";
          # };
        };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };

    rmpc = {
      enable = true;
      config = builtins.readFile ./rmpc/config.ron;
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
      
      settings = {
        mgr = {
          show_hidden = true;
        };

        opener = {
          edit = [
            {
              run = ''nvim "$@"'';
              block = true;
              orphan = false;
              desc = "Edit with Neovim";
            }
          ];
        };

        open = {
          rules = [
            { mime = "text/*"; use = "edit"; }
            { mime = "application/json"; use = "edit"; }
            { mime = "application/x-yaml"; use = "edit"; }
            { mime = "application/xml"; use = "edit"; }
            { mime = "*/javascript"; use = "edit"; }
            { mime = "*/typescript"; use = "edit"; }
            { mime = "*/x-python"; use = "edit"; }
            { mime = "*/x-shellscript"; use = "edit"; }
          ];
        };
      };
    };
  };

  # Services
  services.mpd = {
    enable = true;
    musicDirectory = config.xdg.userDirs.music;
    network.startWhenNeeded = true;
    extraConfig = ''
      auto_update "yes"
      restore_paused "yes"
      follow_outside_symlinks "yes"
      follow_inside_symlinks "yes"

      audio_output {
        type "pulse"
        name "PulseAudio / PipeWire"
      }
    '';
  };
}
