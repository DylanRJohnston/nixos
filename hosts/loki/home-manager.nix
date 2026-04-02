{
  den.aspects.loki.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        firefox
        spotify
      ];
    };
}
