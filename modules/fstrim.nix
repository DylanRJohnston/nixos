{ arc, ... }:
{
  arc.base.includes = [ arc.base._.fstrim ];

  arc.base._.fstrim = {
    nixos.services.fstrim.enable = true;
  };
}
