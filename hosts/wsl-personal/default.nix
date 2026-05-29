{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/developer
    ../../modules/users/ppanda.nix
  ];

  wsl.defaultUser = "ppanda";
  wsl.interop.register = true;

  # Pin a UID distinct from other concurrently-running WSL distros. WSL2
  # shares one kernel and cgroup tree across distros, so a duplicate UID
  # collides on user-<uid>.slice and user@<uid>.service fails with
  # "Failed to spawn executor: Device or resource busy".
  users.users.ppanda.uid = 1000;

  networking.hostName = "wsl-personal";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
