# Calibre Web Automated

## Returning DeACSM library loans

BorrowBox and other Adobe Content Server distributors disable returns in their own UI after an ACSM is fulfilled by an external Adobe-compatible client. A DeACSM return is a separately signed `loanReturn` request to the fulfillment response's `operatorURL + "/LoanReturn"`; fulfillment notifications whose response text mentions “Return accepted” are not loan returns.

CWA does not expose the Calibre plugin configuration UI. The `arc.home-automation._.calibre-web-automated` aspect therefore installs `cwa-loans`, which executes the mounted `calibre-web-automated-loans.py` helper through CWA's own `calibre-debug`. The helper deliberately delegates signing and notification behavior to the installed DeACSM plugin instead of reimplementing Adobe's protocol.

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
