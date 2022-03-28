{ pkgs, ... }:
let
  pamFile = "/etc/pam.d/sudo";
  sed = "${pkgs.gnused}/bin/sed";
in
{
  config.system.activationScripts.extraActivation.text =
    ''
      echo "setting up sudo touch id authentication"
      if ! grep 'pam_tid.so' ${pamFile} > /dev/null; then
        $DRY_RUN_CMD ${sed} -i '2i\
      auth       sufficient     pam_tid.so # enabled by nix-darwin
        ' ${pamFile}
      fi
    '';
}
