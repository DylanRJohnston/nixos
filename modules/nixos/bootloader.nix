{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.bootloader;
in
{
  options.custom.bootloader.enable = lib.mkEnableOption "Enable bootloader";

  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
