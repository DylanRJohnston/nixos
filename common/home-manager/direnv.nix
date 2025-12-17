{ lib, config, ... }:
{
  options = {
    custom.modules.direnv.enable = lib.mkEnableOption "Enable direnv";
  };

  config.programs.direnv = lib.mkIf config.custom.modules.direnv.enable {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };
}
