{ arc, ... }:
{
  arc.base.includes = [ arc.base._.ssh ];

  arc.base._.ssh = {
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
        };
      };
    };
  };

  arc.mesh.os = {
    # programs.ssh.startAgent = true;
    # services.tailscale.enable = true;
  };
}
