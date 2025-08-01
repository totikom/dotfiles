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
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.ThinkPadT490s = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit inputs; };
              useGlobalPkgs = true;
              users.eugene = {
                imports = [
                  ./home.nix
                ];
              };
            };
          }
        ];
      };
    };
}
