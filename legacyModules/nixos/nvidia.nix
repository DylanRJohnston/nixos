{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.nvidia;
in
{
  options.custom.nvidia.enable = lib.mkEnableOption "Enable nvidia";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
    };
  };
}
