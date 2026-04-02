{ arc, ... }:
{
  den.hosts.aarch64-darwin.odin = {
    users.dylanj = { };

    aspects = with arc; [
      base
      development
      entertainment
      gaming
      mesh

      {
        darwin.homebrew.casks = [ "backblaze" ];
      }
    ];
  };
}
