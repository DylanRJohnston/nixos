# 3. Adopt upstream den host projection

## Status

Accepted

## Context

The repository used the `dylanrjohnston/den` strict-mode fork and custom host-aspect fan-out. Returning to upstream den v0.19.0 must preserve transitive host configuration for OS users and Home Manager, strict namespace checking, and platform-specific HM configuration. Upstream has different host selection and schema-hook semantics, so merely changing the input is insufficient.

The alternatives were to retain the fork and custom projection, recreate its writable `host.aspects` API upstream, or adopt upstream selection and native projection. Retaining the fork preserves additional maintenance responsibility; recreating the API conflicts with upstream's read-only resolved aspect tree. Registering projection through deferred `arc.schema.user.includes` was tested and did not activate the required hook. Removing the OS HM shim would lose platform-specific HM configuration.

## Decision

Use upstream den v0.19.0 and its native host-to-user projection, with a small shared integration module rather than custom fan-out.

- Hosts select aspects with `aspect.includes`. `host.aspects` is read-only introspection. Explicit includes replace default named-host selection, so hosts and synthetic fixtures must explicitly include `den.aspects.<host>` when needed.
- Host-dependent aspects use plain context functions (`{ host, ... }: { ... }`), replacing deprecated `den.lib.perHost` wrappers.
- Register `den.batteries.host-aspects` directly in `den.schema.user.includes`; default user classes to `[ "user" "homeManager" ]`. Export the integration through `flake.flakeModule` so importing consumers receive the same hook. Do not transport this hook through deferred `arc.schema.user.includes`.
- Native OS-user and HM projections remain separate module evaluations. Preserve the OS deferred `homeManager` option and HM's `imports = [ osConfig.homeManager ]` shim, supporting `nixos.homeManager`, `darwin.homeManager`, and `os.homeManager` alongside direct `homeManager` content. Preserve explicit platform HM imports so base hosts with no users still evaluate.
- Retain strict namespace integration, explicit deferred class declarations, and removal of generated provides-navigation aliases when re-importing exported aspects.
- Assign SSH public keys through `users.<name>.config.key`. Upstream `configOf` treats top-level `key` as module metadata and strips it rather than applying it as user configuration.

This decision changes framework integration and selection syntax, not the independent role/profile composition policy in ADR 0002. Existing accepted records remain historical descriptions of their decisions.

## Consequences

Native projection reduces custom framework machinery while preserving transitive OS, user, and HM behavior. Consumers and tests must import the exported integration, use explicit selection, and retain named host aspects where required. Plain aspect context functions and separate HM evaluation preserve the appropriate context at each destination.

The namespace adapter and OS HM shim remain intentional compatibility responsibilities. User key assignment is explicit because the shorthand collides with upstream metadata: focused mesh tests confirmed that changing only to `config.key` restores expected cross-host keys, rejecting the earlier unproven namespace-closure hypothesis.

Architectural acceptance is not a claim that migration validation is complete. Final focused regression reruns, repository CI, and any non-activating system build remain separate completion gates tracked in the migration handoff. No build or deployment success is asserted by this record.
