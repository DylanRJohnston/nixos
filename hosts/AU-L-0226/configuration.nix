{ common, ... }: {
  imports = [
    common.base
  ];

  homebrew.casks = [
    "lastpass"
  ];


  nix.distributedBuilds = true;
  # nix.buildMachines = [
  #   {
  #     hostName = "nix-build-slave-amd64";
  #     system = "x86_64-linux";
  #     sshUser = "root";
  #     maxJobs = 8;
  #   }
  #   {
  #     hostName = "nix-build-slave-arm64";
  #     system = "aarch64-linux";
  #     sshUser = "root";
  #     maxJobs = 8;
  #   }
  # ];

  users.users.dylanj.home = "/Users/dylanj";
}
