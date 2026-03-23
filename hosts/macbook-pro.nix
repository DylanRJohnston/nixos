{ kit, ... }:
{
  den.hosts.aarch64-darwin.macbook-pro = {
    users.dylanj = { };

    includes = [
      kit.base
      kit.development
      kit.entertainment
      kit.gaming
    ];
  };

  den.aspects.macbook-pro.darwin.homebrew.casks = [
    "backblaze"
  ];
}
