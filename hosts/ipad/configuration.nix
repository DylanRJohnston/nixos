{
  common,
  config,
  hardware,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{

  imports = with common; [
    #  code-server
    fonts
    g-ether
    mosh
    nix-config
    openssh
    raspberry-pi
    roles
    ssh-sudo
    user
    wifi
    zsh
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "25.05";

  fileSystems."/mnt/external" = {
    device = "/dev/disk/by-uuid/2ac2b713-dc25-4f75-b00f-2ec6c937bfa3";
    fsType = "ext4";
  };

  networking.firewall.interfaces.wlan0.allowedTCPPorts = [
    9080
    8096
    6767
    5055
    9696
    8080
    7878
    8989
  ];
  networking.firewall.interfaces.wlan0.allowedUDPPorts = [ 1900 ];

  virtualisation.docker.enable = true;
}
