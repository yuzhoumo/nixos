{ pkgs, ... }:

{
  imports = [
    ../tailscale
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # use systemd-networkd for server networking
  networking.useNetworkd = true;

  # optimize UDP throughput (requires pkgs.ethtool)
  services.networkd-dispatcher = {
    enable = true;
    rules."50-udp-optimizations" = {
      onState = [ "routable" ];
      script = ''
        ${pkgs.ethtool}/bin/ethtool -K "$IFACE" rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
    bantime-increment.enable = true;
  };
}
