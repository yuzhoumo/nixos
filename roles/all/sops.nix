{ pkgs, ... }:

{
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  environment.variables.SOPS_AGE_KEY_FILE = "/etc/sops/age/keys.txt";

  # sops-nix will default to the host ssh keys for decrypting secrets, but we
  # still need to derive the age keyfile for the CLI separately
  system.activationScripts.generate-sops-age-key = {
    deps = [ "etc" ];
    text = ''
      KEY_FILE="/etc/sops/age/keys.txt"
      SSH_KEY="/etc/ssh/ssh_host_ed25519_key"

      [ -f "$SSH_KEY" ] || exit 0
      [ -f "$KEY_FILE" ] && exit 0

      mkdir -p "$(dirname "$KEY_FILE")"
      ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i "$SSH_KEY" > "$KEY_FILE"
      chown root:wheel "$KEY_FILE"
      chmod 640 "$KEY_FILE"
    '';
  };
}
