{ arc, ... }: {
  arc.development.includes = [ arc.development._.platform-io ];

  arc.development._.platform-io.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [platformio-core];
    services.udev.packages = with pkgs; [platformio-core.udev];
  };
}
