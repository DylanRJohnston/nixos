{
  flake.modules.darwin.base.security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    watchIdAuth = false;
    reattach = true;
  };
}
