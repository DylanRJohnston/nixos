{
  inputs,
  den,
  lib,
  unitTest,
  ...
}:
let
  conditionalAspect =
    class: aspect: { host, ... }: if host.class == class then aspect else { };
  platformHelpers = {
    inherit (den.lib) nixos darwin;
  };
  platformTest =
    { system, hostName, helper, expected }:
    unitTest (
      { igloo, apple, ... }:
      {
        den.hosts.${system}.${hostName}.aspect.includes = [
          (platformHelpers.${helper} {
            os.environment.etc."conditional-aspect".text = "included";
          })
        ];

        expr = builtins.hasAttr "conditional-aspect" (
          if hostName == "igloo" then igloo.environment.etc else apple.environment.etc
        );
        inherit expected;
      }
    );
in
{
  den.lib.nixos = conditionalAspect "nixos";
  den.lib.darwin = conditionalAspect "darwin";
  den.lib.perSystem = den.lib.withSystems [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  den.lib.withSystems =
    systems: fn:
    lib.genAttrs systems (
      system:
      fn {
        inherit system;
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      }
    );
  flake.tests.lib = {
    test-nixos-on-nixos = platformTest {
      system = "x86_64-linux";
      hostName = "igloo";
      helper = "nixos";
      expected = true;
    };
    test-nixos-on-darwin = platformTest {
      system = "aarch64-darwin";
      hostName = "apple";
      helper = "nixos";
      expected = false;
    };
    test-darwin-on-darwin = platformTest {
      system = "aarch64-darwin";
      hostName = "apple";
      helper = "darwin";
      expected = true;
    };
    test-darwin-on-nixos = platformTest {
      system = "x86_64-linux";
      hostName = "igloo";
      helper = "darwin";
      expected = false;
    };
  };
}
