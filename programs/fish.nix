{ ... }:
{
  programs.fish = {
    enable = true;

    shellInit = ''
      fish_add_path --path /nix/var/nix/profiles/default/bin
      if set -q SSH_CONNECTION
      if test "$TERM" = "xterm-kitty"
        if not infocmp xterm-kitty >/dev/null 2>&1
          set -gx TERM xterm-256color
        end
      end
    end
  '';

    interactiveShellInit = ''
      # No greeting
      set fish_greeting
    fastfetch
  '';

    shellAliases = {
      pamcan = "pacman";
      gc     = "git clone";
      l      = "eza --icons";
      ls     = "eza --icons";
      clear  = "printf '\\033[2J\\033[3J\\033[1;1H'";
      q      = "qs -c ii";
      ll     = "eza --icons --group-directories-first -T -L 1";
      l1     = "eza --icons --group-directories-first -T -L 1";
      l2     = "eza --icons --group-directories-first -T -L 2";
    };

    functions = {
      fish_prompt = {
        description = "Write out the prompt";
        body = ''
          printf '%s@%s %s%s%s > ' $USER $hostname \
              (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
        '';
      };
    };
  };
}
