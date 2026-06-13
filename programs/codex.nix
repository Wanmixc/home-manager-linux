{ pkgs, lib, ... }:
let
  codexPkg = pkgs.stdenvNoCC.mkDerivation {
    pname = "codex";
    version = "0.121.0";

    src = pkgs.fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v0.121.0/codex-x86_64-unknown-linux-musl.tar.gz";
      sha256 = "sha256-J4xysD1OH2YbqCjBzPNuui+I2AdMcOPwMhHb+2MSc8Q=";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.gnutar
    ];

    buildInputs = [
      pkgs.stdenv.cc.cc.lib
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
in
{
  home.packages = with pkgs; [
    codexPkg
    bash-language-server
    bun
    gitui
  ];

  home.activation.codexCommitMessageSkill = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    install -Dm644 ${../codex/skills/commit-message-id/SKILL.md} \
      "$HOME/.codex/skills/commit-message-id/SKILL.md"
    install -Dm644 ${../codex/skills/commit-message-id/agents/openai.yaml} \
      "$HOME/.codex/skills/commit-message-id/agents/openai.yaml"
  '';
}
