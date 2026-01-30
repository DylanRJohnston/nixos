{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (builtins.elem "base" config.custom.roles) {
    system.stateVersion = 5;

    system.primaryUser = config.custom.primaryUser;

    nix.enable = true;

    programs.zsh.enable = true;
    environment.systemPackages = [
      pkgs.vim
      pkgs.git
      pkgs.nil
    ];

    custom.fonts.enable = true;
    custom.homebrew.enable = true;
    custom.nix-config.enable = true;
    custom.system-defaults.enable = true;
    custom.touchID.enable = true;
  };
}
