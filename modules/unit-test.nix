# Adapted from https://github.com/vic/den/blob/5a4b828a445d5f5c1803e201dcdd5a5cbb7563ce/templates/ci/modules/test-support/eval-den.nix
let
  module =
    {
      arc,
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
        {
          inherit (evaluated.config) expr;
        }
        // lib.optionalAttrs evaluated.options.expected.isDefined {
          inherit (evaluated.config) expected;
        }
        // lib.optionalAttrs evaluated.options.expectedError.isDefined {
          inherit (evaluated.config) expectedError;
        };

      mkAspectTest =
        { system, hostName }:
        spec@{
          aspects,
          expr,
          baseline ? [ ],
          host ? { },
          ...
        }:
        let
          mkTest =
            state:
            unitTest {
              __functionArgs = {
                ${hostName} = false;
              };

              __functor =
                _self: args:
                let
                  errorKey = "${state}Err";
                  outcome =
                    if builtins.hasAttr state spec then
                      { expected = spec.${state}; }
                    else
                      { expectedError = spec.${errorKey}; };
                in
                {
                  den.hosts.${system}.${hostName} = host // {
                    users.tux = { };
                    aspects = baseline ++ lib.optionals (state == "enabled") aspects;
                  };
                }
                // {
                  expr = expr args.${hostName};
                }
                // outcome;
            };
        in
        {
          test-enabled = mkTest "enabled";
          test-disabled = mkTest "disabled";
        };

      darwinAspectTest = mkAspectTest {
        system = "aarch64-darwin";
        hostName = "apple";
      };

      nixosAspectTest = mkAspectTest {
        system = "x86_64-linux";
        hostName = "igloo";
      };
    in
    {
      _module.args = {
        inherit darwinAspectTest nixosAspectTest unitTest;
      };

      flake.tests.unit-test = {
        test-expected-error = unitTest {
          expr = throw "unit-test harness expected failure";
          expectedError = {
            type = "ThrownError";
            msg = "harness expected failure";
          };
        };

        shared-expression = nixosAspectTest {
          baseline = [ arc.base ];
          aspects = [ arc.interactive ];
          expr = igloo: igloo.qt.enable;
          enabled = true;
          disabled = false;
        };

        shared-expression-error = nixosAspectTest {
          baseline = [ arc.base ];
          aspects = [
            {
              nixos.environment.etc."aspect-test".text = "enabled";
            }
          ];
          expr = igloo: igloo.environment.etc."aspect-test".text;
          enabled = "enabled";
          disabledErr.msg = "attribute.*aspect-test.*missing";
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
