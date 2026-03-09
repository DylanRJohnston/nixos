{
  flake.modules.darwin.base.home = {
    targets.darwin.copyApps.enable = false;
    targets.darwin.copyApps.enableChecks = false;
  };
}
