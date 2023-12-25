let keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICX6q5M2rAKRjKckyxL31RCxUFDvAZ5gYWbfxnA3rUaz dylanj@macbook-pro.lan"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDmYQdCCtCy0xwlPdYIxF/0N7bP2XzH7WgTFAxL5Jwo/ nixos@DYLAN-DESKTOP"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGm9bXqjKjMATEaJ0mcRIxVJ0bzJ3plmd3RZvvgwtPl dylanj@Dylans-MacBook-Pro.local"
];
in {
  programs.mosh.enable = true;
  services.openssh = {
    enable = true;
    ports = [ 2022 ];
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  security.pam.enableSSHAgentAuth = true;

  users.users.dylanj.openssh.authorizedKeys.keys = keys;
  users.users.root.openssh.authorizedKeys.keys = keys;
}
