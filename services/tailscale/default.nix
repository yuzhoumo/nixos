{ ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = both; # both client and server subnet router
    extraDaemonFlags = ["--no-logs-no-support"]; # disable logs/telemetry
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
