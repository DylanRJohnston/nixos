{ lib, pkgs, config, modulesPath, common, ... }:

with lib;
let
  defaultUser = "dylanj";
  syschdemd = import common.syschdemd { inherit lib pkgs config defaultUser common; };
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    common.fonts
  ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = "experimental-features = nix-command flakes";
  nixpkgs.config.allowUnfree = true;

  # WSL is closer to a container than anything else
  boot.isContainer = true;

  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;

  networking.dhcpcd.enable = false;

  programs.zsh.enable = true;
  users.users.${defaultUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  users.users.root = {
    shell = "${syschdemd}/bin/syschdemd";
    # Otherwise WSL fails to login as root with "initgroups failed 5"
    extraGroups = [ "root" ];
  };

  security.sudo.wheelNeedsPassword = false;

  # Disable systemd units that don't make sense on WSL
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  systemd.services.firewall.enable = false;
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-udevd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;

  networking.hostName = "dylanj-desktop";

  environment.noXlibs = lib.mkForce false;
  environment.systemPackages = with pkgs; [ vim htop tmux git vscode wget nixpkgs-fmt ];

  system.stateVersion = "22.05";
}
