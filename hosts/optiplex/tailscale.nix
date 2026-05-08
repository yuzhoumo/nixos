{ config, pkgs, ... }:

{
  imports = [
    ../../modules/tailscale
  ];

  sops.secrets = {
    tailscale-oauth-key = {
      owner = "root";
      restartUnits = [ "tailscaled-autoconnect.service" ];
    };
  };

  services.tailscale = {
    authKeyFile = config.sops.secrets.tailscale-oauth-optiplex.path;
    authKeyParameters.ephemeral = false;
    authKeyParameters.preauthorized = true;
    extraUpFlags = [
      "--advertise-tags=tag:self-auth,tag:minecraft"
      "--advertise-exit-node"
      "--ssh"
    ];
  };
}
