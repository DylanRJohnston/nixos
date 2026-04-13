{ arc, ... }:
{
  arc.mesh.includes = [ arc.mesh._.ssh ];

  arc.mesh._.ssh = {
    nixos.programs.mosh.enable = true;

    os.services.openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication no
        PermitRootLogin no
      '';
    };
  };
}
