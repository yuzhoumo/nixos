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

  # force tailscaled to use nftables (critical for clean nftables-only systems)
  # avoids "iptables-compat" translation layer issues
  networking.nftables.enable = true;
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  # optimization: prevent systemd from waiting for network online
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;
}
