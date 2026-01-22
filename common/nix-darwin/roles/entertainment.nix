{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (builtins.elem "entertainment" config.custom.roles) {
    homebrew.casks = [
      "audacity"
      "gimp"
      "signal"
      "slack"
      "spotify"
      "transmission"
      "vlc"
    ];
  };
}
