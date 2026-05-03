{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true; # clean up unused images, containers, and networks
    liveRestore = true; # keep containers running during daemon restart
    daemon.settings = {
      runtimes.runsc.path = "${pkgs.gvisor}/bin/runsc";
    };
  };

  systemd.tmpfiles.rules = [
    "d /opt/docker 0755 root root -" # docker compose files
    "d /data 0755 root root -"       # bind mount for persistent data
  ];
}
