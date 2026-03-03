{
  self,
  lib,
  config,
  ...
}:
{
  mergeTargets = self.lib.perMachine (machine: {
    module.imports = machine.roles |> lib.map (role: config.flake.modules.generic.${role} or { });
  });
}
