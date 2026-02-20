{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.custom.sunshine;
in
{
  options.custom.sunshine.enable = lib.mkEnableOption "Enable sunshine service";
  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      package = pkgs.sunshine.override { cudaSupport = true; };
    };
  };
}
