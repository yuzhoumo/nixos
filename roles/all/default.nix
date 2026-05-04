{ ... }:

{
  imports = [
    ./boot.nix
    ./nix.nix
    ./packages.nix
    ./shell.nix
    ./sops.nix
    ./users.nix
  ];
}
