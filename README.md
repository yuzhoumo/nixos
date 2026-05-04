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

| host     | type    | roles        | purpose                  |
|----------|---------|--------------|--------------------------|
| thinkpad | laptop  | all,desktop  | personal laptop          |
| optiplex | server  | all,server   | lightweight homelab node |

## Secrets (sops-nix)

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) using
age keys derived from each host's ed25519 SSH key.

### Onboarding a new host to sops

1. Get the host's age public key from its SSH host key:

   ```sh
   ssh-keyscan -t ed25519 <host-ip> | nix run nixpkgs#ssh-to-age
   ```

2. Add the key to `.sops.yaml`:

   ```yaml
   keys:
     - &newhost age1...

   creation_rules:
     - path_regex: secrets/secrets.yaml$
       key_groups:
         - age:
           # ... existing hosts
           - *newhost
   ```

3. Re-encrypt secrets for the new key (run from a host that can decrypt):

   ```sh
   sops updatekeys secrets/secrets.yaml
   ```

4. Set up the sops CLI on the new host so you can edit secrets locally:

   ```sh
   mkdir -p ~/.config/sops/age
   sudo nix run nixpkgs#ssh-to-age -- -private-key \
     -i /etc/ssh/ssh_host_ed25519_key > ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   ```

5. Configure sops in the host's `default.nix`:

   ```nix
   sops = {
     defaultSopsFile = ../../secrets/secrets.yaml;
     secrets.my-secret = {};
   };
   ```

   sops-nix defaults to reading `/etc/ssh/ssh_host_ed25519_key`, so no
   `age.keyFile` or `age.sshKeyPaths` is needed.
