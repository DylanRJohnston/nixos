{ pkgs, ... }: {

  nixpkgs.overlays = [(self: super: { nerdfonts = super.nerdfonts.override { fonts = [ "FiraCode" ]; }; })];

  fonts = {
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      source-code-pro
      ubuntu_font_family
      nerdfonts 
    ];
  };
}
