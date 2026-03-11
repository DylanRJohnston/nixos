{
  config.den.aspects.base.os =
    let
      lockfile = builtins.fromJSON (builtins.readFile ../flake.lock);
    in
    {
      nixpkgs.config.allowUnfree = true;
      nix = {
        enable = true;
        extraOptions = "experimental-features = nix-command flakes pipe-operators";

        settings = {
          substituters = [ "https://aseipp-nix-cache.freetls.fastly.net" ];
        };

        registry = {
          nixpkgs = {
            exact = false;
            from = {
              id = "nixpkgs";
              type = "indirect";
            };
            to = {
              owner = "NixOS";
              repo = "nixpkgs";
              type = "github";
              rev = lockfile.nodes.nixpkgs.locked.rev;
              narHash = lockfile.nodes.nixpkgs.locked.narHash;
            };
          };
        };
      };
    };
}
