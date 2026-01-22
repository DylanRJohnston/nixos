{ lib, config, ... }:
{
  options = {
    custom.direnv.enable = lib.mkEnableOption "Enable direnv";
  };

  config.programs.direnv = lib.mkIf config.custom.direnv.enable {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };
}
