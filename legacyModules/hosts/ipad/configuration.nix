{
  ...
}:
{

  custom.roles = [ "development" ];

  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "26.05";

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
