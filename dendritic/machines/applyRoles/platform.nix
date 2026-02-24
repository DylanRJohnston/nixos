{
  self,
  lib,
  config,
  ...
}:
{
  flake.mergeTargets = self.lib.perMachine (machine: {
    module.imports =
      machine.roles |> lib.map (role: config.flake.modules.${machine.platform}.${role} or { });
  });
}
