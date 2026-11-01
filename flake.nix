{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Used for user packages and dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
    snapborg-repo = {
      url = "github:totikom/snapborg/nix_flake";
      flake = false;
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
      snapborg-repo,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      snapborgSrc = snapborg-repo;
      snapborg = pkgs.callPackage (snapborgSrc + "/nix/default.nix") {
        lib = pkgs.lib;
        inherit pkgs;
        pythonPackages = pkgs.python313Packages;
        src = snapborgSrc;
      };
      commonModules = [
        {
          nixpkgs.overlays = [
            (_: _: {
              mullvad = nixpkgs-unstable.legacyPackages.x86_64-linux.mullvad;
              joplin-desktop = nixpkgs-unstable.legacyPackages.x86_64-linux.joplin-desktop;
              deltachat-desktop = nixpkgs-unstable.legacyPackages.x86_64-linux.deltachat-desktop;
            })
          ];
        }
        {
          environment.systemPackages = [
            snapborg
          ];
        }
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager

      ];
      mkHost =
        {
          hostName,
          homeImports,
        }:
        nixpkgs.lib.nixosSystem {
          modules = commonModules ++ [
            ./disko/${hostName}.nix
            ./hardware/${hostName}.nix
            ./nixos/${hostName}.nix
            ./nixos/common.nix
            {
              networking.hostName = hostName;
              home-manager = {
                useGlobalPkgs = true;
                users.eugene = {
                  imports = homeImports;
                };
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        ThinkPadT490s = mkHost {
          hostName = "ThinkPadT490s";
          homeImports = [
            ./home/common.nix
          ];
        };
        Main-pc = mkHost {
          hostName = "Main-pc";
          homeImports = [
            ./home/common.nix
            ./home/Main-pc.nix
          ];
        };
      };
    };
}
