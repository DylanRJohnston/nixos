{
  lib,
  config,
  ...
}:
{
  options.custom.homebridge.enable = lib.mkEnableOption "Enable homebridge service";
  config = lib.mkIf config.custom.homebridge.enable {
    services.homebridge = {
      enable = true;
      openFirewall = true;
    };
  };
}
