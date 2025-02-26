{
  lib,
  pkgs,
  config,
  defaultUser,
  common,
  ...
}:

pkgs.substituteAll {
  name = "syschdemd";
  src = common.scripts.syschdemd;
  dir = "bin";
  isExecutable = true;

  buildInputs = with pkgs; [ daemonize ];

  inherit (pkgs) daemonize;
  inherit defaultUser;
  inherit (config.security) wrapperDir;
  fsPackagesPath = lib.makeBinPath config.system.fsPackages;
}
