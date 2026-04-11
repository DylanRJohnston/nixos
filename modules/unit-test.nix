# Adapted from https://github.com/vic/den/blob/5a4b828a445d5f5c1803e201dcdd5a5cbb7563ce/templates/ci/modules/test-support/eval-den.nix
rec {
  imports = [ flake.flakeModule.unit-test ];

  flake.flakeModule.unit-test =
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
            config.flake.flakeModule.arc
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
    in
    {
      # imports = [ inputs.den.flakeOutputs.checks ];
      _module.args.unitTest = unitTest;

      # flake.checks = lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ] (
      #   system:
      #   let
      #     pkgs = inputs.nixpkgs.legacyPackages.${system};
      #   in
      #   {
      #     unit-tests = pkgs.runCommand "unit-tests" { } ''
      #       export HOME="$(realpath .)"
      #       ${pkgs.nix-unit}/bin/nix-unit \
      #           --eval-store "$HOME" \
      #           --extra-experimental-features "nix-command flakes pipe-operators" \
      #           --override-input darwin ${inputs.darwin} \
      #           --override-input den ${inputs.den} \
      #           --override-input hardware ${inputs.hardware} \
      #           --override-input home-manager ${inputs.home-manager} \
      #           --override-input import-tree ${inputs.import-tree} \
      #           --override-input nixpkgs ${inputs.nixpkgs} \
      #           --flake ${inputs.self}\#tests
      #       touch $out
      #     '';
      #   }
      # );
    };

}
