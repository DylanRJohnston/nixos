{
  config,
  den,
  lib,
  unitTest,
  ...
}:
{
  options.flake.formatter = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.package;
    default = { };
  };

  config.flake = {
    formatter = den.lib.perSystem ({ pkgs, ... }: pkgs.nixfmt);

    tests.formatter.test-all-systems = unitTest {
      expr = lib.mapAttrs (_: formatter: formatter.meta.mainProgram) config.flake.formatter;
      expected = {
        aarch64-darwin = "nixfmt";
        aarch64-linux = "nixfmt";
        x86_64-linux = "nixfmt";
      };
    };
  };
}
