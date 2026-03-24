{
  den.aspects.desktop.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        firefox
        spotify
      ];
    };
}
