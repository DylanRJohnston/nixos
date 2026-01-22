{ common, ... }:
{
  imports = [
    common.base
    common.nix-daemon
  ];

  custom.roles = [
    "development"
    "entertainment"
    "gaming"
  ];

  homebrew.casks = [
    "backblaze"
  ];
}
