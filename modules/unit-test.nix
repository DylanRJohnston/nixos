# Adapted from https://github.com/vic/den/blob/5a4b828a445d5f5c1803e201dcdd5a5cbb7563ce/templates/ci/modules/test-support/eval-den.nix
let
  module =
    {
      config,
      perSystem,
      inputs,
      lib,
      ...
    }:
    let
      testModule =
        { config, ... }:
        {
          options.expr = lib.mkOption { };
          options.expected = lib.mkOption { };

          config._module.args.igloo = config.flake.nixosConfigurations.igloo.config;
          config._module.args.apple = config.flake.darwinConfigurations.apple.config;
        };

      evalArc =
        module:
        lib.evalModules {
          specialArgs = {
            inputs = inputs // {
              arc = config.flake;
            };
          };
          modules = [
            config.flake.flakeModule
            module
            testModule
          ];
        };

      unitTest = module: {
        inherit ((evalArc module).config) expr expected;
      };
    in
    {
      _module.args.unitTest = unitTest;

      flake.packages = den.lib.perSystem (
        { pkgs, ... }:
        {
          unit-tests = pkgs.writeShellScriptBin "unit-tests" ''
            find . -name '*.nix' | entr -c nix-unit --flake ".#tests$1"
          '';
        }
      );
    };
in
{
  imports = [ module ];
  flake.flakeModules.unit-test = module;
}
