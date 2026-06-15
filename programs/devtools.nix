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
    atac
  ];

  programs.direnv.enable = true;
}
