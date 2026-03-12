# NixOS Configurations

Flake-based NixOS configs with shared modules and per-host customization.

## Usage

```sh
# Build and switch
sudo nixos-rebuild switch --flake .#thinkpad

# Test without switching
sudo nixos-rebuild test --flake .#thinkpad

# Build only
nix build .#nixosConfigurations.thinkpad.config.system.build.toplevel
```
