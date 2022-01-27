{ nixosSystem, home-manager }: nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./nixos
    home-manager
    ./home-manager
  ];
}
