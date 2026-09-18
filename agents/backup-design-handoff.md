# Backup Design Handoff

## Purpose

This document hands off the design discussion for durable backups of the services on `mimir`. No backup implementation has been made yet. A fresh agent should use this as context, verify any runtime assumptions on the host before deployment, agree the remaining policy choices with the user, and then implement the design with focused black-box tests.

## User goal and constraints

- The user is running an increasing number of mutable services through Podman and wants durable backups of their persistent data.
- The initial idea was a Backblaze B2 mirror such as:

  ```bash
  b2 sync --keep-days 30 --replace-newer <source> <destination>
  ```

- The user currently has no NAS and normally prefers one onsite plus one offsite backup.
- `/mnt/external` is a **2 TB USB-C HDD**. It is primary bulk storage, not an independent onsite backup for data already stored on it.
- The repository was clean at the beginning and end of the design investigation. No code or configuration changes were made before this handoff.

## Main recommendation reached in discussion

Prefer **Restic using Backblaze B2's S3-compatible API** over raw `b2 sync`.

Reasons:

- Client-side encryption independent of B2
- Content-defined deduplication and compression
- Point-in-time snapshots
- Daily/weekly/monthly/yearly retention policies
- Selective and full restore workflows
- Repository consistency and data-integrity checks
- Backend portability

The Restic documentation currently recommends its S3 backend for B2 rather than Restic's native B2 backend because of error-handling issues in the native B2 library:

- <https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html#backblaze-b2>

The user's proposed `b2 sync` is a versioned mirror rather than a backup-native snapshot system. It is better than no backup but is not the preferred foundation.

## Verified repository state

### Existing backup aspect

`modules/backup.nix` currently contains only:

```nix
{
  arc.backup.darwin.homebrew.casks = [ "backblaze" ];
}
```

`arc.backup` is selected by the Darwin host `odin`, but not by `mimir`. There is no existing NixOS Restic configuration.

### Host and storage

`hosts/mimir/mimir.nix` defines:

```nix
bulkStoragePath = "/mnt/external";
```

`hosts/mimir/hardware-configuration.nix` mounts `/mnt/external` by UUID as ext4. The hardware is a 2 TB USB-C HDD according to the user.

Because it is ext4, there are no cheap atomic filesystem snapshots available in the present layout. Reformatting or migrating to Btrfs should not be attempted without another complete copy of the disk's contents and explicit user approval.

### Secrets

The repository already uses `sops-nix`. Existing modules include `arc.secrets` and define `sops.secrets` from host-specific encrypted YAML files. B2 and Restic credentials should follow this pattern and must not be embedded in Nix source or end up in the Nix store.

Likely secret values:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `RESTIC_PASSWORD`

The application key should be restricted to the dedicated B2 bucket. The Restic password must also be retained somewhere independent of `mimir`; losing it makes the repository unrecoverable.

### NixOS Restic support

The pinned NixOS module provides `services.restic.backups` with relevant options including:

- `backupPrepareCommand`
- `backupCleanupCommand`
- `environmentFile`
- `passwordFile`
- `paths`
- `exclude`
- `initialize`
- `pruneOpts`
- `runCheck`
- `checkOpts`
- `timerConfig`

This was verified by evaluating the pinned NixOS options, not assumed from another Nixpkgs version.

## Verified persistent service data

The following paths come from the evaluated and source Nix configuration. Runtime contents and database formats should still be checked on `mimir` before finalizing exclusions or consistency hooks.

| Service | Runtime | Persistent path(s) | Notes |
|---|---|---|---|
| Home Assistant | Podman | `/etc/nixos/modules/home-automation/config` | Writable `/config` is currently inside the Nix checkout. This mixes generated state with declarative configuration and should eventually be separated. |
| Calibre Web Automated | Podman | `/var/lib/calibre-web-automated/config`, `/mnt/external/calibre-web-automated/library`, `/mnt/external/calibre-web-automated/ingest` | Config and library are authoritative; ingest is a queue and may be optional. See the Calibre clarification below. |
| KOReader Sync | Podman | `/var/lib/koreader-sync-server/data/redis` | Log directories under `/var/lib/koreader-sync-server/logs` should normally be excluded. |
| Matter.js server | Podman | `/var/lib/matter-server` | Losing Matter fabric state would be particularly disruptive. |
| Music Assistant | Podman | `/var/lib/music-assistant` | Stateful `/data` bind mount. |
| Uptime Kuma | Podman | `/var/lib/uptime-kuma` | Managed with `StateDirectory = "uptime-kuma"`. |
| ESPHome | Native NixOS service | `/var/lib/esphome` | Not Podman, but contains service state worth considering; build caches such as `.platformio` may be reproducible. |
| Public ingress/cloudflared | Podman | SOPS credential mount only | No ordinary mutable data directory was identified; encrypted source secrets are handled separately. |

### Docker media stack

`mimir` also runs a Docker Compose media stack from `/mnt/external`, although the user's initial concern focused on Podman. Its Compose file stores mutable configuration under relative paths such as:

- `/mnt/external/config/sabnzbd`
- `/mnt/external/configs/jellyfin/...`
- `/mnt/external/configs/mediarr/bazarr`
- `/mnt/external/configs/mediarr/jellyseerr`
- `/mnt/external/configs/mediarr/prowlarr`
- `/mnt/external/configs/mediarr/qbittorrent`
- `/mnt/external/configs/mediarr/radarr`
- `/mnt/external/configs/mediarr/sonarr`

The bulk media and downloads are also exposed from `/mnt/external`. Configuration and watch/history databases may be worth backing up even if replaceable movies, television, caches, logs, and downloads are excluded.

## Important Calibre clarification

The user clarified that Calibre Web Automated (CWA) is now effectively the authoritative library manager. CWA can interact with a conventional Calibre library and bundles Calibre tooling, but there is no separate live Calibre service or external database involved in this deployment. The old Calibre installation on `odin` has effectively been decommissioned after the user verified that CWA's ingest plugins work.

The authoritative Calibre backup set is therefore:

```text
/var/lib/calibre-web-automated/config
/mnt/external/calibre-web-automated/library
```

The library directory contains the standard filesystem-based Calibre library, including books, covers, and `metadata.db`. These paths should be captured as one logical recovery point. The ingest directory is optional but may be included if unprocessed files can remain there for meaningful periods.

There is no need to back up a Calibre server or database on `odin` as part of this recovery chain.

A possible secondary safeguard discussed was periodically running Calibre's metadata export/backup tooling so OPF metadata is stored alongside books, but the exact `calibredb backup_metadata` invocation inside the CWA image was **not verified**. Test its command, paths, locking behavior, and value before automating it. Existing CWA-specific technical notes live in `agents/calibre-web-automated.md`.

## Consistency problem

Several services likely use SQLite, Redis, or files that must agree with one another. Restic creates a coherent repository snapshot, but reading a live directory does not itself guarantee application-level consistency. Copying a database, its WAL, and related files at different moments can produce an unusable restore.

The safe initial policy discussed was:

1. Stop or quiesce the relevant stateful services.
2. Capture a consistent local copy or filesystem snapshot.
3. Restart services immediately.
4. Upload the captured data asynchronously.

With current ext4 storage, the practical choices are:

- Stop services for the entire Restic read of their live paths; simple, but the first cloud backup may cause substantial downtime.
- Stop services briefly, copy small mutable state into a staging directory, restart services, and then back up the staging directory. This requires enough temporary space and is not practical for an entire large library.
- Use application-native database exports where available, after verifying restore behavior.

For CWA specifically, stop `podman-calibre-web-automated.service` while capturing both its config and library. The first library upload may need a maintenance window. Incremental Restic runs should generally be much quicker when most books remain unchanged.

A future Btrfs layout would allow stop -> atomic read-only snapshot -> immediate restart -> asynchronous Restic upload, but migration is not a prerequisite for deploying the first reliable offsite backup.

## Recommended data classes

### Critical or irreplaceable

Back up frequently and retain for a long time:

- Home Assistant state and automation data
- Matter fabric and credentials
- CWA config and Calibre library
- KOReader synchronization data
- Service configuration and meaningful user state
- Nix configuration if it is not already pushed safely elsewhere
- Secrets required for disaster recovery, with careful handling

### Useful but reproducible

Back up selectively or less aggressively:

- Music Assistant state
- Uptime Kuma state
- ESPHome configuration
- Sonarr/Radarr/Prowlarr/Jellyfin/Jellyseerr configuration and history

### Replaceable or transient

Normally exclude unless the user explicitly values it:

- Logs
- Caches and build artifacts
- Container images and Podman/Docker internal storage
- Incomplete downloads
- Jellyfin transcode/cache data
- Replaceable media whose B2 storage and restore cost is not justified

The user has not yet made a final decision about backing up the full media library.

## Recommended repository topology with current hardware

### Offsite B2 repository

Use Restic against B2's S3-compatible endpoint, conceptually:

```text
s3:https://s3.<region>.backblazeb2.com/<bucket>/mimir
```

Use one repository or prefix per host to limit blast radius and simplify restoration.

### Optional local repository on the USB HDD

A Restic repository under `/mnt/external` is a legitimate second local copy only for data whose primary copy is on a different root device, such as `/var/lib/...` state. It is **not** a backup of the Calibre library, media, or other data already stored on the same physical HDD.

For example:

```text
/mnt/external/local-backup/mimir-state
```

could provide fast recovery of root-hosted state from root-device failure. The same state should still be sent to B2.

Do not describe snapshots or a Restic repository on `/mnt/external` as an independent onsite backup of `/mnt/external` itself.

## Suggested scheduling and retention

The discussion proposed, but did not finalize:

- Critical state backup every six hours
- Local root-state backup as often as every two hours if desired
- Large library backup nightly or after significant ingestion
- Randomized systemd timer delay

Suggested Restic retention:

- Keep all snapshots within the most recent 48 hours, or at least several recent snapshots
- 14 daily
- 8 weekly
- 12 monthly
- 3 yearly

This is preferable to retaining only 30 days because configuration corruption can remain unnoticed for months. Confirm frequency, acceptable downtime, storage budget, and retention with the user before implementation.

Run regular structural `restic check`. Periodically use `--read-data-subset` rather than downloading the entire B2 repository for every check. Full data checks can incur bandwidth or transaction costs.

## B2 lifecycle, deletion, and immutability

Restic's S3 backend hides or replaces objects as repository maintenance proceeds. Backblaze may retain old/hidden versions unless lifecycle rules remove them. Restic's documentation recommends a B2 lifecycle equivalent to keeping only the latest object version so hidden versions do not accumulate indefinitely.

Do **not** enable default B2 Object Lock blindly on a normal Restic repository. Restic pruning deletes and rewrites repository objects, and bucket-wide retention can cause maintenance operations to fail. Backblaze documents Object Lock here:

- <https://www.backblaze.com/docs/cloud-storage-object-lock>

A normal bucket-restricted application key protects against broad account exposure but a fully compromised backup client may still be able to delete its Restic repository. Strong ransomware resistance would require a deliberately tested append-only design, separate maintenance credentials/host, a compatible hosted backup service, or another independent copy. This was identified as a later hardening step, not a blocker for the initial backup.

## Mount and disk safety

Backups involving `/mnt/external` must fail if the expected disk is not mounted. Otherwise the system could successfully record an empty mountpoint and eventually expire snapshots containing real data.

The eventual service should include:

- `RequiresMountsFor = [ "/mnt/external" ]` or equivalent dependency
- A volume marker such as `/mnt/external/.mimir-storage`
- Verification of the expected filesystem/mount before backup
- Failure on a missing or read-only mount
- Free-space monitoring

Because the USB HDD contains primary data, also consider:

- `smartd` if the USB bridge exposes SMART
- Periodic extended SMART tests
- Monitoring kernel logs for USB resets and I/O errors
- Periodic filesystem checks appropriate for ext4
- Disabling USB autosuspend for this device only if actual disconnect evidence warrants it

## Proposed Nix architecture

A ground-up design should avoid a permanently hard-coded central path list. Each stateful service module could register externally observable backup requirements in a behavior-free option schema, conceptually:

```nix
services.arc-backup.datasets.home-assistant = {
  paths = [ "/srv/state/home-assistant" ];
  units = [ "podman-homeassistant.service" ];
  class = "critical";
};
```

Possible registration fields:

- Persistent paths
- Units to quiesce
- Optional prepare/export command
- Optional cleanup command
- Exclusions
- Backup class or schedule
- Required mounts

Because optional aspects would register data consumed by another optional aspect, behavior-free option declarations belong in universal host context (`arc.ctx.host`) according to `agents/aspect-system.md`. Runtime behavior, packages, timers, credentials, and Restic jobs belong under `arc.backup`.

This registration design was recommended but not approved or implemented. Avoid overengineering the first version if a small explicit path list is enough to establish a working, tested backup quickly.

## Longer-term storage layout discussed

If storage is rebuilt later, normalize bind-mounted persistence under clear roots such as:

```text
/srv/state/       small important mutable application state
/srv/library/     important user content such as books
/srv/media/       large replaceable media
/srv/downloads/   temporary data
/srv/backups/     staging, exports, or local repositories
```

Home Assistant's writable state should eventually move out of the Nix checkout. A snapshot-capable filesystem such as Btrfs could provide fast, consistent read-only snapshots and checksumming. These are longer-term improvements, not prerequisites for the first backup deployment.

## Monitoring and restore requirements

A complete design must detect stale or failing backups. Suggested checks:

- Time since latest successful snapshot
- Restic service exit status
- Repository check status
- Missing `/mnt/external`
- USB or disk errors
- Low free space
- Unexpected backup size changes

Potential alert thresholds discussed:

- Warning after 12 hours without a successful critical-state backup
- Critical after 24 hours

The exact notification mechanism is not yet selected. Healthchecks.io or an existing project notification service could provide dead-man monitoring, but network/privacy implications should be considered.

Backups must be restore-tested. At minimum:

- Restore representative files to a temporary directory periodically
- Validate SQLite databases with `PRAGMA integrity_check` where applicable
- Parse expected JSON/YAML where appropriate
- Perform a complete manual disaster-recovery exercise periodically
- Keep recovery instructions and the Restic password somewhere accessible without `mimir`

## Future onsite copy

A NAS is not required. The most valuable later hardware addition would simply be a second USB disk large enough for the irreplaceable portion of the existing 2 TB HDD. It could be connected only for backups or rotated offline. That would provide an independent onsite copy and much faster bulk restores than B2.

## Unresolved questions

Before implementation, establish:

1. B2 bucket name and S3 region/endpoint.
2. Whether the bucket already exists and which lifecycle settings are configured.
3. Whether the full media library should be backed up or only service configuration and irreplaceable content.
4. Current used/free space on `/mnt/external` and approximate Calibre library size.
5. Acceptable service downtime and preferred backup window.
6. Whether the root device is an SD card, SSD, or something else; this affects whether moving write-heavy state is desirable.
7. Whether a local Restic repository for root-hosted state is wanted.
8. Desired monitoring/notification endpoint.
9. Whether Home Assistant state relocation should be part of the first change or a separate migration.
10. Whether the user wants a minimal first deployment or the dataset-registration framework immediately.

Do not request secret values in chat or commit plaintext credentials. The user can create/edit encrypted SOPS material through the established workflow.

## Suggested implementation sequence

1. Inspect actual data sizes, mount status, service state, and database files on `mimir`.
2. Agree backup scope, downtime, retention, and media exclusions with the user.
3. Decide whether Home Assistant state relocation is in scope now.
4. Add NixOS Restic behavior under `arc.backup` without changing `flake.nix`; modules are auto-discovered.
5. Add host-specific SOPS secret declarations and clear assertions for required secret files.
6. Add `arc.backup` to `mimir`.
7. Implement safe prepare/cleanup behavior. Cleanup must restart services even when backup fails and ideally should not start a service that was stopped before the backup.
8. Add required-mount and marker checks for `/mnt/external`.
9. Add a focused black-box test for enabled behavior and omission/default behavior. Test externally observable final NixOS configuration, not aspect internals.
10. Stage newly created module/test files before evaluating Git-backed flake outputs, preserving existing staged work.
11. Initialize the Restic repository deliberately and perform the first backup during an agreed maintenance window.
12. Perform and document an actual restore before declaring the system complete.
13. Run the focused suite, expected to be something like:

    ```bash
    nix-unit --flake '.#tests.backup'
    ```

14. Run the required repository-wide CI check:

    ```bash
    ./.github/workflows/CI.sh
    ```

## Project rules to remember

- Read `agents/aspect-system.md` before adding or restructuring modules.
- Never edit `flake.nix` to add imports; `import-tree` auto-discovers `.nix` files under `modules` and `hosts`.
- Every new feature and refactor requires black-box unit tests.
- Test both inclusion and meaningful omission/default behavior.
- Leaf test attributes must start with `test-`.
- Stage newly created files before evaluating Git-backed flake outputs.
- Preserve unrelated staged and unstaged user work.
- For every OCI bind mount, ensure the source path is created before the generated container service starts and test that behavior.
- Do not perform unrelated aspect-boundary refactors.

## Validation already performed

During the design investigation, the agent:

- Confirmed the Git worktree was clean.
- Read `agents/aspect-system.md`.
- Inventoried Podman container definitions and bind mounts.
- Inspected the Docker media Compose stack.
- Verified `/mnt/external` is configured as ext4 and learned from the user that it is a 2 TB USB-C HDD.
- Verified the pinned NixOS Restic module exposes the hooks and options listed above.
- Reviewed current Backblaze `b2 sync`, B2 Object Lock, and Restic B2/S3, retention, and integrity-check documentation.

No build or test suite was run because no repository code had been changed before creating this handoff.
