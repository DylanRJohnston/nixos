{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.system-packages;
in
{
  options.custom.system-packages.enable = lib.mkEnableOption "Enable system-packages";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vim
      git
    ];

    programs.zsh.enable = true;
  };
}
