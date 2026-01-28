{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (builtins.elem "base" config.custom.roles) {
    custom = {
      bootloader.enable = true;
      console.enable = true;
      desktop.enable = true;
      fonts.enable = true;
      localisation.enable = true;
      nix-config.enable = true;
      system-packages.enable = true;
      users.enable = true;
    };

    programs.ssh.startAgent = true;
    networking.networkmanager.enable = true;

    networking.hostName = "desktop";
    system.stateVersion = "25.11";
  };
}
