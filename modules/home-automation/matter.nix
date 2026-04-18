{ arc, ... }:
{
  arc.home-automation.includes = [ arc.home-automation._.matter ];

  arc.home-automation._.matter.nixos = { pkgs, ... }: {
    services.matter-server = {
      enable = true;
    };

    services.tailscale-serve."matter".target = "127.0.0.1:5580";
  };
}
