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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixtune = {
      url = "github:yuzhoumo/nixtune";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-azurevpnclient = {
      url = "github:yuzhoumo/nix-azurevpnclient";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, nix-index-database, sops-nix, nixos-wsl, nixtune, nix-azurevpnclient, ... }: {
    nixosConfigurations = {
      thinkpad = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixos-hardware}/lenovo/thinkpad/p14s/intel"
          nix-index-database.nixosModules.nix-index
          sops-nix.nixosModules.sops
          nixtune.nixosModules.default
          nix-azurevpnclient.nixosModules.default
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
        modules = [
          nixos-wsl.nixosModules.default
          {
            wsl.enable = true;
          }
          nix-index-database.nixosModules.nix-index
          sops-nix.nixosModules.sops
          nixtune.nixosModules.default
          nix-azurevpnclient.nixosModules.default
          ./hosts/wsl-work
        ];
      };
    };
  };
}
