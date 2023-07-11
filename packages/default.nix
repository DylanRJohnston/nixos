self: prev: {
  pam_reattach = prev.callPackage ./pam_reattach.nix { };
  # awscli2 = prev.callPackage ./awscli2.nix { };
}
