{
  flake.modules.darwin.base = { }; # Fully migrated

  flake.modules.nixos.base = {
    custom = {
      bootloader.enable = true;
      console.enable = true;
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
  };
}
