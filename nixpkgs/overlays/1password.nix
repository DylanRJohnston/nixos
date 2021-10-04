(self: super: {
  _1password-gui = super._1password-gui.overrideAttrs
    (_: rec {
      version = "8.2.0";
      src = super.fetchurl {
        url = "https://downloads.1password.com/linux/tar/stable/x86_64/1password-${version}.x64.tar.gz";
        sha256 = "1hnpvvval8a9ny5x5zffn5lf5qrwc4hcs3jvhqmd7m4adh2i6y2i";
      };
    });
})
