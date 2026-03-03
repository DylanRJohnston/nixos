{
  flake.modules.homeManager.base.programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };
}
