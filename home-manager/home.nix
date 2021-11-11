{
  imports = [
    ./config
    ./packages.nix
    ./services
  ];

  programs.home-manager = {
    enable = true;
    path = "…";
  };
}
