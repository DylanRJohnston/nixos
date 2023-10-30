{ common, pkgs, modules, ... }: {
  imports = with common; [
    user
    modules.jovian
  ];

  jovian = {
    steam.enable = true;
    devices.steamdeck.enable = true;
  };

  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.defaultSession = "gamescope-wayland";
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "dylanj";

  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-dock
    jupiter-docker-updater-bin
    steamdeck-firmware
  ];

  system.stateVersion = "23.11";
}
