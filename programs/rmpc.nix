{ ... }:
{
  programs.rmpc = {
    enable = true;
    config = builtins.readFile ./rmpc/config.ron;
  };

  xdg.configFile."rmpc/themes/theme.ron".source = ./rmpc/theme.ron;
}
