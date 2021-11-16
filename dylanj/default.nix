{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.dylanj = {
    imports = [
      ./config
      ./packages.nix
      ./services
    ];

    programs.home-manager = {
      enable = true;
      path = "…";
    };
  };
}
