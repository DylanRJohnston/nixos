{
  lib,
  config,
  ...
}:
let
  cfg = config.custom.determinate;
in
{
  options.custom.determinate.enable = lib.mkEnableOption "Enable determinate nix";

  config = lib.mkIf cfg.enable {
    nix.enable = lib.mkForce false;

    determinateNix = {
      enable = true;
      customSettings = {
        substituters = [ "https://aseipp-nix-cache.freetls.fastly.net" ];
      };
    };
  };
}
