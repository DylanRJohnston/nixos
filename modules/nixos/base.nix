{
  kit.base.nixos = {
    programs.ssh.startAgent = true;
    networking.networkmanager.enable = true;
  };
}
