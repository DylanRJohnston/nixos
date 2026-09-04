{
  arc,
  lib,
  unitTest,
  ...
}:
{
  arc.remote-builders.nixos = {
    nix = {
      distributedBuilds = true;
      settings = {
        builders-use-substitutes = true;
        connect-timeout = 5;
        fallback = true;
      };
      # TODO: Make this automatically derived from den.hosts
      buildMachines = [
        {
          hostName = "loki";
          speedFactor = 2;
          maxJobs = 2;
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          supportedFeatures = [
            "kvm"
            "big-parallel"
          ];
          sshKey = "/etc/ssh/ssh_host_ed25519_key";
        }
        {
          hostName = "eu.nixbuild.net";
          speedFactor = 2;
          maxJobs = 2;
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          supportedFeatures = [
            "kvm"
            "big-parallel"
          ];
          sshKey = "/etc/ssh/ssh_host_ed25519_key";
        }
        {
          hostName = "odin";
          speedFactor = 2;
          maxJobs = 2;
          systems = [
            "x86_64-linux"
            "aarch64-linux"
            "aarch64-darwin"
          ];
          supportedFeatures = [
            "kvm"
            "big-parallel"
          ];
          sshKey = "/etc/ssh/ssh_host_ed25519_key";
        }
      ];
    };
  };

  flake.tests.remote-builders = {
    test-enabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [
          arc.base
          arc.remote-builders
        ];

        expr = {
          inherit (igloo.nix) distributedBuilds;
          inherit (igloo.nix.settings) builders-use-substitutes connect-timeout fallback;
        };
        expected = {
          distributedBuilds = true;
          builders-use-substitutes = true;
          connect-timeout = 5;
          fallback = true;
        };
      }
    );

    test-disabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [ arc.base ];

        expr = igloo.nix.settings.fallback or false;
        expected = false;
      }
    );
  };
}
