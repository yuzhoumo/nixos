{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both"; # both client and server subnet router
    extraDaemonFlags = ["--no-logs-no-support"]; # disable telemetry
  };

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ]; # always allow traffic from Tailscale network
    allowedUDPPorts = [ config.services.tailscale.port ]; # allow Tailscale UDP port through the firewall
    checkReversePath = "loose"; # fix firewall issues when enabling exit node (https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111)
  };
}
