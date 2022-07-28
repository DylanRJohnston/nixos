self: super: {
  pam_reattach = self.callPackage ./pam_reattach.nix { };
}
