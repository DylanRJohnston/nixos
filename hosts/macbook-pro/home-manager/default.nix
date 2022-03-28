{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.dylanj = {
    imports = [
      ./packages.nix
    ];

    programs.home-manager = {
      enable = true;
    };
  };
}


