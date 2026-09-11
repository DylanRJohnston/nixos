{
  arc,
  darwinAspectTest,
  den,
  inputs,
  nixosAspectTest,
  ...
}:
{
  arc.secrets = {
      nixos.imports = [ inputs.sops-nix.nixosModules.sops ];
      darwin.imports = [ inputs.sops-nix.darwinModules.sops ];

      os.sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

  flake.tests.sops = {
    nixos = nixosAspectTest {
      baseline = [ arc.base ];
      aspects = [ arc.secrets ];
      expr = host: host.sops.age.sshKeyPaths;
      enabled = [ "/etc/ssh/ssh_host_ed25519_key" ];
      disabledErr.msg = "attribute.*sops.*missing";
    };

    darwin = darwinAspectTest {
      baseline = [ arc.base ];
      aspects = [ arc.secrets ];
      expr = host: host.sops.age.sshKeyPaths;
      enabled = [ "/etc/ssh/ssh_host_ed25519_key" ];
      disabledErr.msg = "attribute.*sops.*missing";
    };
  };
}
