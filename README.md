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

## Hosts

| host         | type    | purpose                  |
|--------------|---------|--------------------------|
| thinkpad     | laptop  | personal laptop          |
| optiplex     | server  | lightweight homelab node |
| wsl-personal | virtual | dev wsl for personal use |
| wsl-work     | virtual | corp-joined wsl for work |

## Secrets (sops-nix)

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) using
age keys derived from each host's ed25519 SSH key.

### Generating age keys

WSL hosts don't run `sshd`, so their host key must be created once at install
time (see below) before the host can be onboarded:

```sh
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" -C "$(hostname)"
sudo cat /etc/ssh/ssh_host_ed25519_key.pub | nix run nixpkgs#ssh-to-age
```

Bare-metal hosts keys are generated automatically by `sshd` (via `modules/ssh`),
so it already exists after installation. Get the host's age public key from its
SSH host key:

```sh
ssh-keyscan -t ed25519 <host-ip> | nix run nixpkgs#ssh-to-age
```

### Onboarding a new host to sops

1. Add the host's key to `.sops.yaml`:

   ```yaml
   host_keys:
     - &newhost age1...

   creation_rules:
     - path_regex: secrets/secrets.yaml$
       key_groups:
         - age:
           # ... existing hosts
           - *newhost
   ```

2. Re-encrypt secrets for the new key (run from a host that can decrypt):

   ```sh
   sops updatekeys secrets/<relevant-secrets-file>
   ```
