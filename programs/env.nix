{ lib, ... }:
let
  secretsPath = /home/wanmixc/configuration/secrets.json;
  secrets =
    if builtins.pathExists secretsPath
    then builtins.fromJSON (builtins.readFile secretsPath)
    else { };
  supermemoryCodexApiKey = secrets.supermemory_codex_api_key or "";
in
{
  home.sessionVariables =
    {
      EDITOR = "nvim";
    }
    // lib.optionalAttrs (supermemoryCodexApiKey != "") {
      SUPERMEMORY_CODEX_API_KEY = supermemoryCodexApiKey;
    };

  programs.fish.shellInit = lib.optionalString (supermemoryCodexApiKey != "") ''
    set -gx SUPERMEMORY_CODEX_API_KEY "${supermemoryCodexApiKey}"
  '';
}
