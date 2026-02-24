{
  self,
  lib,
  config,
  ...
}:
{
  flake.mergeTargets = self.lib.perMachine (machine: {
    module.home = {
      imports = machine.roles |> lib.map (role: config.flake.modules.homeManager.${role} or { });
    };
  });
}
