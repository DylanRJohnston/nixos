{ arc, unitTest, ... }:
{
  arc.home-automation.includes = [
    arc.home-automation._.router
  ];

  arc.home-automation._.router.nixos = {
    services.tailscale-serve.router.target = "http://192.168.0.1";
  };

  flake.tests.home-automation-router = {
    test-enabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [
          arc.base
          arc.home-automation
        ];

        expr = igloo.services.tailscale-serve.router.target;
        expected = "http://192.168.0.1";
      }
    );

    test-disabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [ arc.base ];

        expr = igloo.services.tailscale-serve ? router;
        expected = false;
      }
    );
  };
}
