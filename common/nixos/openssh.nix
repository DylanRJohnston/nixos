{
  programs.mosh.enable = true;
  services.openssh = {
    enable = true;
    ports = [ 2022 ];
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  security.pam.enableSSHAgentAuth = true;

  users.users.dylanj.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICX6q5M2rAKRjKckyxL31RCxUFDvAZ5gYWbfxnA3rUaz dylanj@macbook-pro.lan"
  ];

}
