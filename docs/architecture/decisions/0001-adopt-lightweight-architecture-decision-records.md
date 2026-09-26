# 1. Adopt lightweight architecture decision records

## Status

Accepted

## Context

Current operating guidance is recorded in files such as `AGENTS.md`, while Git preserves the line-by-line history of changes. Neither is an effective account of why a significant architecture decision was made: current guidance intentionally drops obsolete rules, and reconstructing context, rejected alternatives, and superseding decisions from commits is difficult.

The following alternatives were considered:

- Rely only on Git history: rejected because the relevant context and alternatives are not easy to discover or review as a coherent decision.
- Keep appending history to `AGENTS.md`: rejected because agent guidance should remain focused on the current rules needed to work safely in the repository.
- Adopt a tool-backed or more extensive architecture documentation system: rejected because its maintenance cost is not justified for this repository.

## Decision

Use lightweight Architecture Decision Records based on [Peter Evans' format](https://github.com/peter-evans/lightweight-architecture-decision-records).

ADRs live in `docs/architecture/decisions/` as sequentially numbered Markdown files with five sections: Title, Status, Context, Decision, and Consequences. The directory README maintains the index and process, and `template.md` provides the starting format.

Accepted ADRs are historical records. If a decision changes, create a new ADR, mark the earlier record as superseded, link the records in both directions where useful, and update the index. `AGENTS.md` and focused agent documentation continue to describe the current operating rules and link to ADRs when historical context matters.

## Consequences

Important decisions retain their context, alternatives, and time evolution close to the code. Current agent guidance can stay concise without erasing the rationale for earlier choices.

The process is manual: authors must decide when an ADR is warranted, assign the next number, maintain the index, and explicitly record supersession. This adds a small documentation cost, so routine implementation details and easily reversible local choices should not receive ADRs.
