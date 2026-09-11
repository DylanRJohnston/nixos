{
  arc,
  darwinAspectTest,
  nixosAspectTest,
  ...
}:
{
  arc.base.includes = [ arc.base._.ssh ];

  arc.base._.ssh = {
    nixos.programs.ssh.startAgent = true;

    darwin.homeManager.programs.ssh.settings = {
      "*".extraOptions = {
        "UseKeychain" = "yes";
      };
    };

    homeManager = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
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

  flake.tests.ssh = {
    nixos = nixosAspectTest {
      aspects = [ arc.base ];
      expr = host: {
        inherit (host.programs.ssh) startAgent;
        inherit (host.home-manager.users.tux.programs.ssh) enable;
        github = host.home-manager.users.tux.programs.ssh.settings."github.com".data;
        personal = host.home-manager.users.tux.programs.ssh.settings."personal.github.com".data;
        thothPort = host.home-manager.users.tux.programs.ssh.settings.thoth.data.port;
      };
      enabled = {
        startAgent = true;
        enable = true;
        github = {
          header = "Host github.com";
          hostname = "github.com";
          identityFile = "~/.ssh/id_ed25519";
        };
        personal = {
          header = "Host personal.github.com";
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/personal";
        };
        thothPort = 8022;
      };
      disabledErr.msg = "attribute.*home-manager.*missing";
    };

    darwin = darwinAspectTest {
      aspects = [ arc.base ];
      expr = host: {
        inherit (host.home-manager.users.tux.programs.ssh) enable;
        useKeychain = host.home-manager.users.tux.programs.ssh.settings."*".data.extraOptions.UseKeychain;
        githubIdentity = host.home-manager.users.tux.programs.ssh.settings."github.com".data.identityFile;
        personalIdentity =
          host.home-manager.users.tux.programs.ssh.settings."personal.github.com".data.identityFile;
        thothPort = host.home-manager.users.tux.programs.ssh.settings.thoth.data.port;
      };
      enabled = {
        enable = true;
        useKeychain = "yes";
        githubIdentity = "~/.ssh/id_ed25519";
        personalIdentity = "~/.ssh/personal";
        thothPort = 8022;
      };
      disabledErr.msg = "attribute.*home-manager.*missing";
    };
  };
}
