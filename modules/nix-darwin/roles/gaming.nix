{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (builtins.elem "gaming" config.custom.roles) {
    homebrew.casks = [
      "discord"
      "steam"
    ];
  };
}
