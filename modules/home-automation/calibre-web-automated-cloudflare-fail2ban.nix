{
  arc,
  den,
  inputs,
  lib,
  unitTest,
  ...
}:
{
  arc.home-automation._.calibre-web-automated._.cloudflare-fail2ban = den.lib.perHost (
    { host }:
    let
      secretFile = "${inputs.self}/secrets/${host.name}/cloudflare-tunnel.yaml";
    in
    {
      includes = [ arc.secrets ];

      nixos =
        { config, pkgs, ... }:
        let
          cloudflareIpAccess = pkgs.writeTextFile {
            name = "cloudflare-ip-access";
            executable = true;
            text = ''
              #!${pkgs.python3}/bin/python3
              import ipaddress
              import json
              import os
              import re
              import sys
              import tempfile
              import urllib.error
              import urllib.request

              STATE_DIRECTORY = "/var/lib/fail2ban/cloudflare-ip-access"
              RULE_ID_PATTERN = re.compile(r"^[0-9a-f]{32}$")
              ZONE_ID_PATTERN = re.compile(r"^[0-9a-f]{32}$")


              def read_secret(path):
                  with open(path, "r", encoding="utf-8") as secret_file:
                      value = secret_file.read().strip()
                  if not value:
                      raise ValueError(f"credential file is empty: {path}")
                  return value


              def request(method, url, token, body=None):
                  data = None if body is None else json.dumps(body).encode("utf-8")
                  api_request = urllib.request.Request(
                      url,
                      data=data,
                      method=method,
                      headers={
                          "Authorization": f"Bearer {token}",
                          "Content-Type": "application/json",
                          "User-Agent": "fail2ban-calibre-opds/1.0",
                      },
                  )
                  try:
                      with urllib.request.urlopen(api_request, timeout=30) as response:
                          payload = json.load(response)
                  except urllib.error.HTTPError as error:
                      try:
                          payload = json.load(error)
                      except (json.JSONDecodeError, UnicodeDecodeError):
                          payload = {"errors": [{"message": f"HTTP {error.code}"}]}
                      raise RuntimeError(api_error(payload)) from error
                  except urllib.error.URLError as error:
                      raise RuntimeError(f"Cloudflare API request failed: {error.reason}") from error

                  if not payload.get("success"):
                      raise RuntimeError(api_error(payload))
                  return payload["result"]


              def api_error(payload):
                  messages = [error.get("message", "unknown error") for error in payload.get("errors", [])]
                  return "Cloudflare API rejected the request: " + "; ".join(messages or ["unknown error"])


              def state_path(address):
                  return os.path.join(STATE_DIRECTORY, f"{address.compressed}.rule")


              def save_rule_id(path, rule_id):
                  if not RULE_ID_PATTERN.fullmatch(rule_id):
                      raise RuntimeError("Cloudflare returned an invalid rule ID")
                  os.makedirs(STATE_DIRECTORY, mode=0o700, exist_ok=True)
                  descriptor, temporary_path = tempfile.mkstemp(dir=STATE_DIRECTORY)
                  try:
                      os.fchmod(descriptor, 0o600)
                      with os.fdopen(descriptor, "w", encoding="utf-8") as state_file:
                          state_file.write(rule_id + "\n")
                      os.replace(temporary_path, path)
                  finally:
                      if os.path.exists(temporary_path):
                          os.unlink(temporary_path)


              def ban(address, api_url, token):
                  path = state_path(address)
                  if os.path.exists(path):
                      return
                  result = request(
                      "POST",
                      api_url,
                      token,
                      {
                          "mode": "block",
                          "configuration": {
                              "target": "ip6" if address.version == 6 else "ip",
                              "value": address.compressed,
                          },
                          "notes": "Fail2ban: repeated Calibre OPDS authentication failures",
                      },
                  )
                  save_rule_id(path, result["id"])


              def unban(address, api_url, token):
                  path = state_path(address)
                  try:
                      with open(path, "r", encoding="utf-8") as state_file:
                          rule_id = state_file.read().strip()
                  except FileNotFoundError:
                      return
                  if not RULE_ID_PATTERN.fullmatch(rule_id):
                      raise RuntimeError(f"invalid stored Cloudflare rule ID for {address.compressed}")
                  request("DELETE", f"{api_url}/{rule_id}", token)
                  os.unlink(path)


              def main():
                  if len(sys.argv) != 5 or sys.argv[1] not in ("ban", "unban"):
                      raise ValueError("usage: cloudflare-ip-access ban|unban IP TOKEN_FILE ZONE_ID_FILE")
                  operation, raw_address, token_file, zone_id_file = sys.argv[1:]
                  address = ipaddress.ip_address(raw_address)
                  token = read_secret(token_file)
                  zone_id = read_secret(zone_id_file)
                  if not ZONE_ID_PATTERN.fullmatch(zone_id):
                      raise ValueError("Cloudflare zone ID must be 32 lowercase hexadecimal characters")
                  api_url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/firewall/access_rules/rules"
                  if operation == "ban":
                      ban(address, api_url, token)
                  else:
                      unban(address, api_url, token)


              if __name__ == "__main__":
                  try:
                      main()
                  except Exception as error:
                      print(f"cloudflare-ip-access: {error}", file=sys.stderr)
                      sys.exit(1)
            '';
          };
        in
        {
          assertions = [
            {
              assertion = builtins.pathExists secretFile;
              message = "arc.home-automation._.calibre-web-automated._.cloudflare-fail2ban requires secrets/${host.name}/cloudflare-tunnel.yaml to exist";
            }
          ];

          sops.secrets = {
            cloudflare-firewall-api-token = {
              sopsFile = secretFile;
              key = "firewall-api-token";
              mode = "0400";
              restartUnits = [ "fail2ban.service" ];
            };
            cloudflare-zone-id = {
              sopsFile = secretFile;
              key = "zone-id";
              mode = "0400";
              restartUnits = [ "fail2ban.service" ];
            };
          };

          environment.etc."fail2ban/action.d/cloudflare-ip-access.conf".text = ''
            [Definition]
            actionban = ${cloudflareIpAccess} ban <ip> ${config.sops.secrets.cloudflare-firewall-api-token.path} ${config.sops.secrets.cloudflare-zone-id.path}
            actionunban = ${cloudflareIpAccess} unban <ip> ${config.sops.secrets.cloudflare-firewall-api-token.path} ${config.sops.secrets.cloudflare-zone-id.path}
          '';

          services.fail2ban = {
            enable = true;
            jails.calibre-opds-cloudflare = {
              filter.Definition.failregex = ''^<HOST> \S+ \S+ [^"]*"(?:GET|HEAD) /opds(?:[/?][^ ]*)? HTTP/\d(?:\.\d)?" 401\b'';
              settings = {
                backend = "auto";
                logpath = "/var/lib/calibre-web-automated/config/access.log";
                action = "cloudflare-ip-access";
                findtime = "10m";
                maxretry = 10;
                bantime = "-1";
                usedns = "no";
              };
            };
          };
        };
    }
  );

  flake.tests.calibre-web-automated-cloudflare-fail2ban = {
    test-enabled = unitTest (
      {
        arc,
        config,
        lib,
        ...
      }:
      let
        mimir = config.flake.nixosConfigurations.mimir.config;
        jail = mimir.services.fail2ban.jails.calibre-opds-cloudflare;
      in
      {
        den.hosts.aarch64-linux.mimir-fail2ban-test = {
          name = "mimir";
          bulkStoragePath = "/srv/bulk";
          users.tux = { };
          aspects = [
            arc.base
            arc.home-automation
            arc.home-automation._.calibre-web-automated._.cloudflare-fail2ban
          ];
        };

        expr = {
          fail2banEnabled = mimir.services.fail2ban.enable;
          filter = jail.filter;
          inherit (jail.settings)
            action
            backend
            bantime
            findtime
            logpath
            maxretry
            usedns
            ;
          actionInstalled = mimir.environment.etc ? "fail2ban/action.d/cloudflare-ip-access.conf";
          containerInstalled = mimir.virtualisation.oci-containers.containers ? calibre-web-automated;
          secrets =
            lib.mapAttrs
              (_: secret: {
                inherit (secret) key mode;
                restartUnits = lib.unique secret.restartUnits;
                expectedSource = lib.hasSuffix "/secrets/mimir/cloudflare-tunnel.yaml" secret.sopsFile;
              })
              {
                inherit (mimir.sops.secrets)
                  cloudflare-firewall-api-token
                  cloudflare-zone-id
                  ;
              };
        };
        expected = {
          fail2banEnabled = true;
          filter.Definition.failregex = ''^<HOST> \S+ \S+ [^"]*"(?:GET|HEAD) /opds(?:[/?][^ ]*)? HTTP/\d(?:\.\d)?" 401\b'';
          action = "cloudflare-ip-access";
          backend = "auto";
          bantime = "-1";
          findtime = "10m";
          logpath = "/var/lib/calibre-web-automated/config/access.log";
          maxretry = 10;
          usedns = "no";
          actionInstalled = true;
          containerInstalled = true;
          secrets = {
            cloudflare-firewall-api-token = {
              key = "firewall-api-token";
              mode = "0400";
              restartUnits = [ "fail2ban.service" ];
              expectedSource = true;
            };
            cloudflare-zone-id = {
              key = "zone-id";
              mode = "0400";
              restartUnits = [ "fail2ban.service" ];
              expectedSource = true;
            };
          };
        };
      }
    );

    test-disabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo = {
          users.tux = { };
          aspects = [ arc.base ];
        };

        expr = {
          fail2banEnabled = igloo.services.fail2ban.enable;
          jailInstalled = igloo.services.fail2ban.jails ? calibre-opds-cloudflare;
          actionInstalled = igloo.environment.etc ? "fail2ban/action.d/cloudflare-ip-access.conf";
        };
        expected = {
          fail2banEnabled = false;
          jailInstalled = false;
          actionInstalled = false;
        };
      }
    );
  };
}
