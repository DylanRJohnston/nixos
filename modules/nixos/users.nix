{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.users;
in
{
  options.custom.users.enable = lib.mkEnableOption "Enable users";

  config = lib.mkIf cfg.enable {
    users.users.dylanj = {
      isNormalUser = true;
      description = "Dylan Johnston";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.zsh;
    };
  };
}
