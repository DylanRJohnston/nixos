{
  den.aspects.entertainment = {
    darwin.homebrew.casks = [
      "audacity"
      "gimp"
      "signal"
      "slack"
      "spotify"
      "transmission"
      "vlc"
    ];

    nixos.homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          audacity
          gimp
          spotify
          vlc
        ];
      };
  };
}
