{ ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    keep-outputs = true;
    keep-derivations = true;
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;
}
