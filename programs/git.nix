{ pkgs, lib, ... }:
let
  secretsPath = ../../secrets.json;
  secrets =
    if builtins.pathExists secretsPath
    then builtins.fromJSON (builtins.readFile secretsPath)
    else { };
  githubToken = secrets.github_token or "";
in
{
  programs.git = {
    enable = true;
    package = pkgs.git;
    settings =
      (lib.optionalAttrs (githubToken != "") {
        url = {
          "https://oauth2:${githubToken}@github.com" = {
            insteadOf = "https://github.com";
          };
        };
      })
      // {
        user = {
          email = "wanmixc@gmail.com";
          name = "wanmixc";
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

  programs.delta = {
    enable = true;
    options = {
      line-numbers = true;
      side-by-side = true;
      navigate = true;
    };
  };
}
