{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Used for user packages and dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list where available
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      disko,
      sops-nix,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.ThinkPadT490s = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          ./disko/ThinkPadT490s.nix
          ./nixos/common.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            networking.hostName = "ThinkPadT490s"; # Define your hostname.
            home-manager = {
              extraSpecialArgs = { inherit inputs; };
              useGlobalPkgs = true;
              users.eugene = {
                imports = [
                  ./home/common.nix
                ];
              };
            };
          }
        ];
      };
    };
}
