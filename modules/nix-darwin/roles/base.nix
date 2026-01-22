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
    security.pam.enableSudoTouchId = true;
    programs.zsh.enable = true;
    environment.systemPackages = [
      pkgs.vim
      pkgs.git
      pkgs.nil
    ];

    custom.fonts.enable = true;
    custom.nix-config.enable = true;
    custom.homebrew.enable = true;
    custom.system-defaults.enable = true;
  };
}
