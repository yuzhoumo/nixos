{ pkgs, ... }:

{
  users.users.ppanda = {
    isNormalUser = true;
    description = "PerpetualPanda";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    home = "/home/ppanda";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPt6a7BXOx2ceDfve7vZai7y4Avo7ylUm/x1JRYrjErY ppanda@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlL9baqTTX+nqQroKpRpmIjRuW0beX0fCB4uIYxVLcx ppanda@esper"
    ];
  };
}
