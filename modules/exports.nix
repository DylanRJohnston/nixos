{
  inputs,
  ...
}:
{
  flake.flakeModule = inputs.import-tree ../modules;
}
