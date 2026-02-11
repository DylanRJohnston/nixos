{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.custom.fonts;
  rebuild =
    if pkgs.stdenv.isLinux then
      "/run/current-system/sw/bin/nixos-rebuild"
    else if pkgs.stdenv.isDarwin then
      "/run/current-system/sw/bin/darwin-rebuild"
    else
      throw "Unsupported platform, isLinux and isDarwin are both false";
in
{
  options.custom.rebuild.enable = mkEnableOption "Enable passwordless rebuild";

  config = mkIf cfg.enable {
    security.sudo.extraConfig = ''
      ALL ALL=NOPASSWD: ${rebuild}
    '';
  };
}
