{ arc, nixosAspectTest, ... }:
{
  arc.home-automation.includes = [
    arc.home-automation._.router
  ];

  arc.home-automation._.router.nixos = {
    services.tailscale-serve.router.target = "192.168.0.1:80";
  };

  flake.tests.home-automation-router = nixosAspectTest {
    baseline = [ arc.base ];
    aspects = [ arc.home-automation ];
    expr =
      igloo:
      if igloo.services.tailscale-serve ? router then
        igloo.services.tailscale-serve.router.target
      else
        false;
    enabled = "192.168.0.1:80";
    disabled = false;
  };
}
