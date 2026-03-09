{
  flake.modules.nixos.base = {
    programs.ssh.startAgent = true;
    networking.networkmanager.enable = true;
  };
}
