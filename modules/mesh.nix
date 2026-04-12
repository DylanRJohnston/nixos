{ arc, ... }:
{
  arc.mesh.includes = [
    arc.mesh._.tailscale
    arc.mesh._.ssh
  ];

  arc.mesh._.tailscale.os.services.tailscale.enable = true;

  arc.mesh._.ssh = {
    user.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEiryutR7xApg8zJgUkquBV20JaLm93GSHh2kNg95fAn dylanj@nixos" # raspberry pi
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGm9bXqjKjMATEaJ0mcRIxVJ0bzJ3plmd3RZvvgwtPl dylanj@Dylans-MacBook-Pro.local" # macboookpro
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFK2pIjOVUaMqazexDV1Cu6NVSq4cNxUkjLvTQVPzv6v dylan.r.johnston@gmail.com" # desktop
    ];

    nixos.services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };
}
