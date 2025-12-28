{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Used for user packages and dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
      nixpkgs-unstable,
      home-manager,
      disko,
      sops-nix,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        ThinkPadT490s = nixpkgs.lib.nixosSystem {
          modules = [
            {
              nixpkgs.overlays = [
                (_: _: {
                  mullvad = nixpkgs-unstable.legacyPackages.x86_64-linux.mullvad;
                })
              ];
            }
            disko.nixosModules.disko
            ./disko/ThinkPadT490s.nix
            ./nixos/hardware-configuration.nix
            ./nixos/common.nix
            ./nixos/ThinkPadT490s.nix
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
        Main-pc = nixpkgs.lib.nixosSystem {
          modules = [
            {
              nixpkgs.overlays = [
                (_: _: {
                  mullvad = nixpkgs-unstable.legacyPackages.x86_64-linux.mullvad;
                })
              ];
            }
            disko.nixosModules.disko
            ./disko/Main-pc.nix
            ./nixos/hardware-configuration_other.nix
            ./nixos/common.nix
            ./nixos/Main-pc.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              networking.hostName = "Main-pc"; # Define your hostname.
              home-manager = {
                extraSpecialArgs = { inherit inputs; };
                useGlobalPkgs = true;
                users.eugene = {
                  imports = [
                    ./home/common.nix
                    ./home/Main-pc.nix
                  ];
                };
              };
            }
          ];
        };
      };
    };
}
