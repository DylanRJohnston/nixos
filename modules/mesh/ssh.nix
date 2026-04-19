{ lib, arc, ... }:
{
  arc.mesh.includes = [ arc.mesh._.ssh ];

  arc.mesh._.ssh = {
    nixos.programs.mosh.enable = true;

    os.services.openssh = {
      enable = true;
      extraConfig = lib.mkBefore ''
        PasswordAuthentication no
        PermitRootLogin prohibit-password
        KbdInteractiveAuthentication no
      '';
    };
  };
}
