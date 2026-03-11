{
  den.hosts.aarch64-darwin.macbook-pro = {
    users.dylanj = { };

    roles = [
      "base"
      "development"
      "entertainment"
      "gaming"
    ];
  };

  den.aspects.macbook-pro.darwin = {
    homebrew.casks = [
      "backblaze"
    ];
  };
}
