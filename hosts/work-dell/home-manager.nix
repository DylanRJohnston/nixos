{
  imports = [
    ./home-manager/config
    ./home-manager/packages.nix
    ./home-manager/services
  ];

  programs.home-manager = {
    enable = true;
    path = "…";
  };
}
