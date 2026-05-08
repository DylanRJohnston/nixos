{ arc, ... }:
{
  arc.base.includes = [ arc.base._.ssh ];

  arc.base._.ssh = {
    nixos.programs.ssh.startAgent = true;

    darwin.homeManager.programs.ssh.matchBlocks = {
      "*".extraOptions = {
        "UseKeychain" = "yes";
      };
    };

    homeManager = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
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
          # Termux on Android (SuperNote Manta) listens on 8022
          # Note: sshd has been configured to only listen on tailscale
          thoth.port = 8022;
        };
      };
    };
  };
}
