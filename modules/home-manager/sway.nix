{ config, lib, osConfig, pkgs, ... }:
{
  options.custom.sway.enable = lib.mkOption {
    type = lib.types.bool;
    default = pkgs.stdenv.isLinux && osConfig.custom.desktop.enable;
    description = "enable the mutable sway configuration symlink";
  };

  config = lib.mkIf config.custom.sway.enable {
    home.file.".config/sway/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/mutable/sway.config";
  };
}
