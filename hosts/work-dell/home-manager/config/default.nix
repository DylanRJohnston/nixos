{ common, ... }: {
  imports = [
    common.base
    ./autorandr.nix
    ./firefox.nix
    ./rofi.nix
  ];
}
