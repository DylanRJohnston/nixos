{ pkgs, lib, ... }:
{
  options = {
    custom.fonts.enable = lib.mkEnableOption "Enable custom fonts";
  };

  config = {
    fonts = {
      packages = [ pkgs.nerd-fonts.fira-code ];
    };
  };
}
