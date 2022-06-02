{ common, ... }: {
  services.screen-locker = {
    enable = true;
    lockCmd = "${common.scripts.i3lock}";
  };
}
