{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    himmelblau = {
      url = "github:himmelblau-idm/himmelblau/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, nix-index-database, sops-nix, nixos-wsl, himmelblau, ... }: {
    nixosConfigurations = {
      thinkpad = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixos-hardware}/lenovo/thinkpad/p14s/intel"
          nix-index-database.nixosModules.nix-index
          sops-nix.nixosModules.sops
          ./hosts/thinkpad
        ];
      };
      optiplex = nixpkgs.lib.nixosSystem {
        modules = [
          nix-index-database.nixosModules.nix-index
          sops-nix.nixosModules.sops
          ./hosts/optiplex
        ];
      };
      wsl-personal = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          {
            wsl.enable = true;
          }
          nix-index-database.nixosModules.nix-index
          sops-nix.nixosModules.sops
          ./hosts/wsl-personal
        ];
      };
      wsl-work = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit himmelblau; };
        modules = [
          nixos-wsl.nixosModules.default
          {
            wsl.enable = true;
          }
          nix-index-database.nixosModules.nix-index
          sops-nix.nixosModules.sops
          ./hosts/wsl-work
        ];
      };
    };
  };
}
