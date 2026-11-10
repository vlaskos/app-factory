# 05 · Architecture review checklist

A tool-free gate for the **review** phase — run it by hand on a change, or hand it to an LLM agent (the
skill in `skills/swift-architecture-skill/` automates exactly this). It reuses the architecture decided
at bootstrap, so the same checklist travels with the project across its whole lifecycle.

**First, name the pattern actually in use** (MVVM / MV / Clean / TCA / …) — then judge the code against
*that* pattern, not an ideal. Drift between the intended pattern (in `ARCHITECTURE.md`) and the real one
is itself a finding.

## The eight checks

- [ ] **1 · Boundary violations.** Views contain no business logic; view models/presenters make no
      layout decisions; the UI layer only renders and forwards intent.
- [ ] **2 · Service-layer coupling.** View models/use-cases reach the backend/network **only** through a
      service or repository — never a direct client call.
- [ ] **3 · Dependency injection.** Dependencies are injectable protocols, not hardcoded singletons.
      Every unit under test has a seam (a fake conformer).
- [ ] **4 · Model purity.** Models are data + invariants only — no UI state, no I/O, no framework
      imports in domain types.
- [ ] **5 · Responsibility.** No over-broad `…Manager`/service doing fetch + cache + format + navigate.
      One reason to change per type.
- [ ] **6 · Shared mutable state.** Globals/singletons are justified and **safe under strict
      concurrency** (`Sendable`, proper isolation) — not `@unchecked` escapes.
- [ ] **7 · Missing abstractions.** Patterns repeated across 3+ view models/features are extracted, not
      copy-pasted.
- [ ] **8 · Folder organization.** Code is grouped so a feature is found and changed in one place
      (by-feature past a few screens); shared infra lives in `Core/`.

## Output shape (what a good review produces)

For each finding: **file + line → the violation → a recommended fix (with code)**. Close with an
**architectural-debt summary: the top 5 issues**, ranked by cost of leaving them.

## When to run it

- On every non-trivial PR (the review gate).
- Before adopting a new cross-cutting dependency (does it respect the boundaries?).
- Periodically as a whole-codebase sweep, to catch slow drift from `ARCHITECTURE.md`.
