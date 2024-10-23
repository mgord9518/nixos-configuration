{
  description = "System and home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    #nur.url = "github:nix-community/NUR";

    suyu.url = "git+https://git.suyu.dev/suyu/nix-flake";
    mgord9518-nur-packages = {
      url = "github:mgord9518/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, nur, suyu, mgord9518-nur-packages } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    mgord9518-nur = mgord9518-nur-packages.legacyPackages.${system};
  in {
    nixosConfigurations.framework = nixpkgs.lib.nixosSystem {
      modules = [ ./hosts/framework/configuration.nix ];
      specialArgs = {
        inherit mgord9518-nur;
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
  
    homeConfigurations.mgord9518 = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [ ./home-manager/home.nix ];
    };
  };
}
