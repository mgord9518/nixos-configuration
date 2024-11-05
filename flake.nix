{
  description = "System and home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    #nur.url = "github:nix-community/NUR";

    suyu.url          = "git+https://git.suyu.dev/suyu/nix-flake";
    mgord9518-nur.url = "github:mgord9518/nur";
    mist.url          = "github:mgord9518/mist";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, nur, suyu, mgord9518-nur, mist } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    flakes = {
      mgord9518-nur = mgord9518-nur.legacyPackages.${system};
      mist = mist.packages.${system}.default;
    };
  in {
    nixosConfigurations.framework = nixpkgs.lib.nixosSystem {
      modules = [ ./hosts/framework/configuration.nix ];
      specialArgs = {
        inherit flakes;
      };
    };

    nixosConfigurations.jamea = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/jamea/configuration.nix
      ];
      specialArgs = {
        inherit suyu;
      };
    };

    nixosConfigurations.surface = nixpkgs.lib.nixosSystem {
      modules = [ ./hosts/surface/configuration.nix ];
      specialArgs = {
        inherit flakes;
      };
    };
  
    homeConfigurations.mgord9518 = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [ ./home-manager/home.nix ];
    };
  };
}
