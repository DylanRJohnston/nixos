{ lib, arc, ... }:
{
  arc.remote-builders.nixos = {
    nix = {
      distributedBuilds = true;
      extraOptions = ''
        builders-use-substitutes = true
      '';
      # TODO: Make this automatically dirived from den.hosts
      buildMachines =
        {
          "loki" = 10;
          "eu.nixbuild.net" = 10;
        }
        |> lib.mapAttrsToList (
          hostName: speedFactor: {
            inherit hostName speedFactor;
            maxJobs = 12;
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
        );
    };
  };
}
