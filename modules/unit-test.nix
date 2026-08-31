# Adapted from https://github.com/vic/den/blob/5a4b828a445d5f5c1803e201dcdd5a5cbb7563ce/templates/ci/modules/test-support/eval-den.nix
let
  module =
    {
      config,
      den,
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
          options.expectedError = lib.mkOption { };

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

      unitTest =
        module:
        let
          evaluated = evalArc module;
        in
        { inherit (evaluated.config) expr; }
        // lib.optionalAttrs evaluated.options.expected.isDefined {
          inherit (evaluated.config) expected;
        }
        // lib.optionalAttrs evaluated.options.expectedError.isDefined {
          inherit (evaluated.config) expectedError;
        };
    in
    {
      _module.args.unitTest = unitTest;

      flake.tests.unit-test.test-expected-error = unitTest {
        expr = throw "unit-test harness expected failure";
        expectedError = {
          type = "ThrownError";
          msg = "harness expected failure";
        };
      };

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
