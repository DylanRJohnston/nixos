{ darwinSystem, home-manager }: darwinSystem {
  system = "aarch64-darwin";
  modules = [
    ./nix-darwin
    home-manager
    ./home-manager.nix
  ];
}
