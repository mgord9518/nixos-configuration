{
  description = "System and home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.framework = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  
    homeConfigurations.mgord9518 = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [ ./home-manager/home.nix ];
    };
  };
}
