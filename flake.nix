{
  description = "Wanmixc multi-machine Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      mkHome = module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          modules = [ module ];
        };
    in
    {
      homeConfigurations = {
        "wanmixc-cachyos-nix" = mkHome ./hosts/cachyos-nix.nix;
        "wanmixc-wsl" = mkHome ./hosts/wsl.nix;
        "wanmixc-vps" = mkHome ./hosts/vps.nix;
      };
    };
}
