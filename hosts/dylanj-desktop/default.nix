{ nixosSystem, ... }: nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    home-manager
    ./home-manager.nix
  ];
}
