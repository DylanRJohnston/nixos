{
  flake.modules.darwin.entertainment.homebrew.casks = [
    "audacity"
    "gimp"
    "signal"
    "slack"
    "spotify"
    "transmission"
    "vlc"
  ];

  flake.modules.nixos.entertainment.home =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        audacity
        gimp
        spotify
        vlc
      ];
    };
}
