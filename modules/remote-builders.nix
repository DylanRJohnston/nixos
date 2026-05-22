{ lib, arc, ... }:
{
  arc.remote-builders.nixos = {
    nix = {
      distributedBuilds = true;
      extraOptions = ''
        builders-use-substitutes = true
      '';
      # TODO: Make this automatically dirived from den.hosts
      buildMachines = [
        {
          hostName = "loki";
          speedFactor = 1;
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
        {
          hostName = "eu.nixbuild.net";
          speedFactor = 1;
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
        {
          hostName = "odin";
          speedFactor = 1;
          maxJobs = 12;
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
}
