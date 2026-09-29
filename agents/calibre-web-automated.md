# Calibre Web Automated

## Calibre user plugins

The NextGen container requires `CWA_CALIBRE_USER_PLUGINS=true` to load installed Calibre user plugins; ZIPs and existing activation/settings files alone are not sufficient. Keep this opt-in in the container environment and its black-box test. It enables all installed user plugins, so only trusted plugin ZIPs should be present.

The host directory `/var/lib/calibre-web-automated/config/.config/calibre/plugins` maps to `/config/.config/calibre/plugins` in the container. Preserve plugin settings and the `DeACSM/` activation directory when troubleshooting ACSM ingestion. After deploying an environment change, check container startup logs for `Registered Calibre plugin` before retrying an ACSM from `processed_books/failed`.

## Returning DeACSM library loans

BorrowBox and other Adobe Content Server distributors disable returns in their own UI after an ACSM is fulfilled by an external Adobe-compatible client. A DeACSM return is a separately signed `loanReturn` request to the fulfillment response's `operatorURL + "/LoanReturn"`; fulfillment notifications whose response text mentions “Return accepted” are not loan returns.

CWA does not expose the Calibre plugin configuration UI. The `arc.home-automation._.calibre-web-automated` aspect therefore installs `cwa-loans`, which executes the mounted `calibre-web-automated-loans.py` helper through CWA's own `calibre-debug`. The helper deliberately delegates signing and notification behavior to the installed DeACSM plugin instead of reimplementing Adobe's protocol.

Keep both plugin preferences APIs supported: DeACSM 0.0.16 exposes `DeACSM_Prefs` and persists with `writeprefs()`, while newer ACSM Input builds expose `ACSMInput_Prefs` with `refresh()` and `commit()`.

After deploying the configuration, list persisted loan records on the CWA host:

```bash
sudo cwa-loans list
```

Return exactly one loan using the displayed ID:

```bash
sudo cwa-loans return <loan-id>
```

The command uses DeACSM's existing account/device activation and removes the local loan record only after DeACSM reports a successful return. It takes the same Calibre single-instance lock used during ACSM ingestion so a return cannot race an import.

The wrapper must run as root because the NixOS OCI container is managed by rootful Podman. It enters the container as UID/GID 1000, matching the configured CWA `PUID` and `PGID`, and explicitly sets `CALIBRE_CONFIG_DIRECTORY=/config/.config/calibre`.
