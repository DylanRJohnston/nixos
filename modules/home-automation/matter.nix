{ arc, ... }:
{
  arc.home-automation.includes = [ arc.home-automation._.matter ];

  arc.home-automation._.matter.nixos = {
    services.matter-server = {
      enable = true;
    };
  };
}
