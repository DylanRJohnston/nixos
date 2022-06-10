self: super: {
  pam_reattach = super.callPackage ./pam_reattach.nix { };
}
