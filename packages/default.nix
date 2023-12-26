self: prev: {
  pam_reattach = prev.callPackage ./pam_reattach.nix { };
  # awscli2 = prev.callPackage ./awscli2.nix { };
  # bluez = prev.bluez.overrideAttrs (old: {
  #  patches = old.patches ++ [
  #    (prev.fetchpatch {
  #      url = "https://github.com/bluez/bluez/commit/3a9c637010f8dc1ba3e8382abe01065761d4f5bb.patch";
  #      hash = "sha256-UUmYMHnxYrw663nEEC2mv3zj5e0omkLNejmmPUtgS3c=";
  #    })
  #  ];
  #});
}
