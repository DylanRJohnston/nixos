{ common, ... }: {
  imports = [
    common.base
  ];

  homebrew.casks = [
    "lastpass"
  ];
}
