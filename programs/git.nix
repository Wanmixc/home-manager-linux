{ lib, ... }:
let
  secrets = builtins.fromJSON (builtins.readFile ../secrets.json);
in
{
  programs.git = {
    enable = true;
    extraConfig = {
      url = {
        "https://oauth2:${secrets.github_token}@github.com" = {
          insteadOf = "https://github.com";
        };
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
      user = {
        email = "wanmixc@gmail.com";
        name = "wanmixc";
      };
    };
  };
}
