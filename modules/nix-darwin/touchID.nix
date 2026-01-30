{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.touchID;
in
{
  options.custom.touchID.enable = mkEnableOption "Enable touchID authentication";

  config = mkIf cfg.enable {
    security.pam.services.sudo_local = {
      enable = true;
      touchIdAuth = true;
      watchIdAuth = true;
      reattach = true;
    };
  };
}
