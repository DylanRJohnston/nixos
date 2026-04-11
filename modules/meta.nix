{
  arc.schema.host =
    { host, lib, ... }:
    {
      options.flake = lib.mkOption {
        type = lib.types.str;
        default = "${host.primaryUser.home}/.nixpkgs";
      };
    };
}
