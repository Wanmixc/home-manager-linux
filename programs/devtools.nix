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
    bubblewrap
    fzf
  ];

  programs.direnv.enable = true;
}
