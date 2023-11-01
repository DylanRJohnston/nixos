{ pkgs, lib, ... }:
let fonts = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
      ];
    })
  ];
in {
  fonts = { fontDir.enable = true; }
    // (
      if pkgs.stdenv.isLinux
        then { packages = fonts; }
        else { fonts = fonts; }
    );
}
