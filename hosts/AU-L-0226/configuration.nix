{ common, ... }: {
  imports = [
    common.base
  ];

  homebrew.casks = [
    "lastpass"
  ];

  nix.useSandbox = true;
}
