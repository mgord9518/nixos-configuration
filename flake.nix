{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    suyu.url          = "git+https://git.suyu.dev/suyu/nix-flake";
    mgord9518-nur.url = "github:mgord9518/nur";
    mist.url          = "github:mgord9518/mist";
    nvf.url           = "github:notashelf/nvf";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, suyu, ... } @ inputs:
  let
    system = "x86_64-linux";

    flakes = {
      mgord9518-nur = inputs.mgord9518-nur.legacyPackages.${system};
      mist          = inputs.mist.packages.${system}.default;
      suyu          = suyu.packages.${system}.default;
    };
  in {
    nixosConfigurations = {
      framework = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/framework/configuration.nix
          inputs.nvf.nixosModules.default
          inputs.home-manager.nixosModules.default
        ];
  
        specialArgs = {
          inherit flakes;
        };
      };


      tv = nixpkgs.lib.nixosSystem {
        modules = [
	  ./hosts/tv/configuration.nix
          inputs.nvf.nixosModules.default
          inputs.home-manager.nixosModules.default
	];
        
        specialArgs = {
          inherit flakes;
        };
      };
  
      jamea = nixpkgs.lib.nixosSystem {
        modules = [ ./hosts/jamea/configuration.nix ];
  
        specialArgs = {
          inherit suyu;
        };
      };
  
      surface = nixpkgs.lib.nixosSystem {
        modules = [ ./hosts/surface/configuration.nix ];
  
        specialArgs = {
          inherit flakes;
        };
      };
  
      frameworkIso = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/framework/iso.nix
          inputs.nvf.nixosModules.default
        ];
  
        specialArgs = {
          inherit flakes;
        };
      };
    };
  };
}
