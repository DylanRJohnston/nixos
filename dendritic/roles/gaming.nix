{
  flake.modules.darwin.gaming = {
    homebrew.casks = [
      "discord"
      "steam"
    ];
  };

  flake.modules.nixos.gaming = {
    custom = {
      nvidia.enable = true;
      steam.enable = true;
      sunshine.enable = true;
    };
  };
}
