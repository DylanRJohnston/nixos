{ impermanence, ... }: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.dylanj = {
    imports = [
      ./config
      ./packages.nix
      ./persistence.nix
      ./services
      impermanence.nixosModules.home-manager.impermanence
    ];

    programs.home-manager = {
      enable = true;
      path = "…";
    };
  };
}
