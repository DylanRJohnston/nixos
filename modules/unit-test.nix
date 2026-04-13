# Adapted from https://github.com/vic/den/blob/5a4b828a445d5f5c1803e201dcdd5a5cbb7563ce/templates/ci/modules/test-support/eval-den.nix
let
  module =
    {
      config,
      inputs,
      lib,
      ...
    }:
    let
      unitTest = module: {
        inherit ((evalArc module).config) expr expected;
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

      testModule =
        { config, ... }:
        {
          options.expr = lib.mkOption { };
          options.expected = lib.mkOption { };

          config._module.args.igloo = config.flake.nixosConfigurations.igloo.config;
          config._module.args.apple = config.flake.darwinConfigurations.apple.config;
        };

      perSystem =
        fn:
        [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ]
        |> lib.map (
          system:
          fn {
            inherit system;
            pkgs = inputs.nixpkgs.legacyPackages.${system};
          }
          |> lib.attrsToList
          |> lib.map (
            { name, value }:
            {
              kind = name;
              name = system;
              value = value;
            }
          )
        )
        |> lib.flatten
        |> lib.groupBy (it: it.kind)
        |> lib.mapAttrs (_: lib.listToAttrs);

    in
    {
      _module.args.unitTest = unitTest;

      flake = perSystem (
        { pkgs, ... }:
        rec {
          packages.unit-tests = pkgs.writeShellScriptBin "unit-tests" ''
            find . -name '*.nix' | entr -c nix-unit --flake ".#tests$1"
          '';

          devShells.default = (
            pkgs.mkShell {
              buildInputs = [ packages.unit-tests ];
            }
          );
        }
      );
    };
in
{
  imports = [ module ];
  flake.flakeModules.unit-test = module;
}
