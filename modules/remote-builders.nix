{ arc, nixosAspectTest, ... }:
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

  flake.tests.remote-builders = nixosAspectTest {
    baseline = [ arc.base ];
    aspects = [ arc.remote-builders ];
    expr =
      igloo:
      if igloo.nix.settings.fallback or false then
        {
          inherit (igloo.nix) distributedBuilds;
          inherit (igloo.nix.settings) builders-use-substitutes connect-timeout fallback;
        }
      else
        false;
    enabled = {
      distributedBuilds = true;
      builders-use-substitutes = true;
      connect-timeout = 5;
      fallback = true;
    };
    disabled = false;
  };
}
