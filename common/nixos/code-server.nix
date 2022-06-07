{
  services.code-server = {
    enable = true;
    host = "10.55.0.1";
    auth = "none";
    extraArguments = [ "--disable-telemetry" "--user-data-dir" "~/.vscode" ];
  };

  networking.firewall.allowedTCPPorts = [ 4444 ];
}
