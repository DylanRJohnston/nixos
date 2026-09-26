# Architecture Decision Records

This directory contains lightweight Architecture Decision Records (ADRs) for significant design choices in this repository. The format follows [Peter Evans' Lightweight Architecture Decision Records](https://github.com/peter-evans/lightweight-architecture-decision-records): short, numbered Markdown documents that preserve the context, decision, status, and consequences.

ADRs complement current guidance such as `AGENTS.md`. Current guidance may change as the repository evolves; ADRs preserve why an approach was selected, which alternatives were rejected or deferred, and how a later decision superseded it.

## Decisions

| ADR | Title | Status |
| --- | --- | --- |
| [0001](0001-adopt-lightweight-architecture-decision-records.md) | Adopt lightweight architecture decision records | Accepted |
| [0002](0002-separate-hardware-profiles-from-host-roles.md) | Separate hardware profiles from host roles | Accepted |

## Process

Create an ADR when a decision:

- establishes or changes a cross-cutting architectural rule;
- involves meaningful alternatives or tradeoffs;
- constrains future implementation choices; or
- would be difficult to understand from the final code and Git diff alone.

Do not create ADRs for routine implementation details or easily reversible local changes.

1. Copy [`template.md`](template.md).
2. Assign the next four-digit sequence number and a short kebab-case filename.
3. Keep the record concise and use one of these statuses: `Proposed`, `Accepted`, `Deprecated`, or `Superseded by [ADR NNNN](...)`.
4. Review the ADR with the code or configuration that implements it.
5. Treat accepted ADRs as historical records. Make only minor factual or link corrections in place. If the decision changes, add a new ADR, mark the old one as superseded, and update this index.
