{
  flake.modules.darwin.base = { }; # Fully migrated

  flake.modules.nixos.base = {
    custom = {
      bootloader.enable = true;
      console.enable = true;
      desktop.enable = true;
      localisation.enable = true;
      system-packages.enable = true;
      users.enable = true;
    };

    programs.ssh.startAgent = true;
    networking.networkmanager.enable = true;

    system.stateVersion = "26.05";
  };

  flake.modules.homeManager.base = {
    targets.darwin.copyApps.enable = false;
    targets.darwin.copyApps.enableChecks = false;

    custom = {
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
