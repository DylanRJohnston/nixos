{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (builtins.elem "base" config.custom.roles) {
    programs.zsh.enable = true;
    networking.networkmanager.enable = true;

    custom.fonts.enable = true;
    custom.nix-config.enable = true;
    custom.console.enable = true;
  };
}
