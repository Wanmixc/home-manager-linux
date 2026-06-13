{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    direnv
    eza
    ripgrep
    shfmt
    unzip
    zoxide
  ];

  programs.direnv.enable = true;
}
