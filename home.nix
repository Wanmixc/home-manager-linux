{ config, pkgs, ... }:
let
  secrets = builtins.fromJSON (builtins.readFile ./secrets.json);
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "wanmixc";
  home.homeDirectory = "/home/wanmixc";

  home.stateVersion = "25.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    neovim
    bash-language-server
    shfmt
    yazi
    eza
    tmux
    sxiv
    git
    unzip
    bat
    ripgrep
    gitui
    direnv
    zoxide
    fastfetch
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/wanmixc/etc/profile.d/hm-session-vars.sh
  #

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
  xdg.configFile."nvim/init.lua".source = ./nvim/init.lua;
  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    
    direnv.enable = true;

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

    vim = {
      enable = true;
    };
  };
}
