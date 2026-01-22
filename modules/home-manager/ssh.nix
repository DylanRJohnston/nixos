{ config, lib, ... }:
{
  options.custom.ssh.enable = lib.mkEnableOption "Enable SSH configuration";

  config.programs.ssh = lib.mkIf config.custom.ssh.enable {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        extraOptions = {
          "UseKeychain" = "yes";
        };
      };
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
      };
      "personal.github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/personal";
      };
      "hypersec.gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/hypersec";
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
