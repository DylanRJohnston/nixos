{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };
}
