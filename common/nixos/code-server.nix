{
  services.code-server = {
    enable = true;
    host = "10.55.0.1";
    user = "dylanj";
    auth = "none";
    extraArguments = [ "--disable-telemetry" "--user-data-dir" "/home/dylanj/.vscode" ];

  };

  networking.firewall.allowedTCPPorts = [ 4444 ];
}
