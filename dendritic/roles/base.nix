{
  flake.modules.darwin.base =
    { config, pkgs, ... }:
    {
      system.stateVersion = 5;

      system.primaryUser = config.custom.primaryUser;

      nix.enable = true;

      programs.zsh.enable = true;
      environment.systemPackages = [
        pkgs.vim
        pkgs.git
        pkgs.nil
      ];

      custom.fonts.enable = true;
      custom.homebrew.enable = true;
      custom.nix-config.enable = true;
      custom.system-defaults.enable = true;
      custom.touchID.enable = true;
    };

  flake.modules.nixos.base = {
    custom = {
      bootloader.enable = true;
      console.enable = true;
      desktop.enable = true;
      fonts.enable = true;
      localisation.enable = true;
      nix-config.enable = true;
      system-packages.enable = true;
      users.enable = true;
    };

    programs.ssh.startAgent = true;
    networking.networkmanager.enable = true;

    networking.hostName = "desktop";
    system.stateVersion = "26.05";
  };

  flake.modules.homeManager.base = {
    targets.darwin.copyApps.enable = false;
    targets.darwin.copyApps.enableChecks = false;

    custom = {
      direnv.enable = true;
      git.enable = true;
      packages.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      vim.enable = true;
      vscode.enable = true;
      wezterm.enable = true;
      zed.enable = true;
      zsh.enable = true;
    };
  };
}
