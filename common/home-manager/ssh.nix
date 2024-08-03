{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
      };
      "personal.github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/personal";
      };
      "familyzone.github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/familyzone";
      };
      "pi" = {
        hostname = "10.55.0.1";
        user = "dylanj";
        port = 2022;
        forwardAgent = true;
      };
      "steamdeck" = {
        hostname = "192.168.1.148";
        user = "dylanj";
        port = 2022;
        forwardAgent = true;
      };
      "macbook-pro" = {
        hostname = "192.168.1.104";
        user = "dylanj";
        port = 2022;
        forwardAgent = true;
      };
      "nix-build-slave-arm64" = {
        hostname = "127.0.0.1";
        identityFile = "~/.nixpkgs/dockerfiles/buildhosts/nix-build-slave.key";
        port = 3022;
        user = "root";
      };
      "nix-build-slave-amd64" = {
        hostname = "127.0.0.1";
        identityFile = "~/.nixpkgs/dockerfiles/buildhosts/nix-build-slave.key";
        port = 4022;
        user = "root";
      };
    };
  };
}
