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
}
