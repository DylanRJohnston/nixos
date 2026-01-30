{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.custom.fonts;
in
{
  options.custom.rebuild.enable = mkEnableOption "Enable passwordless rebuild";

  config = mkIf cfg.enable {
    security.sudo.extraConfig = ''
      ALL ALL=NOPASSWD: /run/current-system/sw/bin/nixos-rebuild
    '';
  };
}
