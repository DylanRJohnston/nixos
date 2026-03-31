{ kit, ... }:
{
  den.hosts.aarch64-darwin.macbook-pro = {
    users.dylanj = { };

    roles = with kit; [
      base
      development
      entertainment
      gaming
    ];
  };

  den.aspects.macbook-pro.darwin.homebrew.casks = [
    "backblaze"
  ];
}
