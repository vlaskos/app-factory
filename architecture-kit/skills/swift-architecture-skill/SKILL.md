---
name: swift-architecture-skill
description: Audit app architecture for structural/design quality — names the pattern in use (MVVM/MV/TCA) then judges against it; boundary violations, service-layer coupling, dependency injection, model purity, over-broad "manager" types, shared mutable state under strict concurrency, missing abstractions, feature-vs-type folder organization. Use when the user asks for an architecture or structural review.
---

# Architecture audit

Audit the app's architecture for structural and design-quality issues.

<!-- CONFIG — filled for ESDLC. Override per run if a slot's layout differs. -->
App location: the generated app's source root for this run (its `App/`, `Features/`, `Shared/`|`Core/`, `UI/` under the slot checkout)
Stack: SwiftUI · iOS 26 · Swift 6 strict concurrency · Observation (`@Observable`) · SwiftData · swift-testing
Backend: none (local-only archetypes — no network by capability allow-list)
Intended pattern: MVVM (feature-based), fixed by the ESDLC constitution (`skills/architecture.md`) — flag any drift toward MV / fat views / VM-less data access

Read every service, view model, model, and utility file, plus the Views that use them. **First name the
architecture actually in use** (MVVM, MV, TCA, Clean, …), then judge the code against that pattern — and
against the intended pattern in `ARCHITECTURE.md`; drift between the two is itself a finding.

Audit for:
1. **Boundary violations** — Views containing business logic; view models making layout decisions.
2. **Service-layer coupling** — view models calling the backend/networking APIs directly instead of
   through a service or repository.
3. **Dependency injection** — hardcoded singletons vs. injectable protocols.
4. **Model-layer purity** — models that hold UI state or perform I/O.
5. **Responsibility violations** — "manager"/service types that do too much.
6. **Shared mutable state** — globals and singletons, and whether they're safe under strict concurrency.
7. **Missing abstractions** — repeated patterns across view models that should be extracted.
8. **Folder organization** — grouped by feature or by type; can a feature be found and changed in one
   place?

For each finding: **file + line, the violation, and a recommended fix with code.**
End with an **architectural-debt summary (top 5 issues)**, ranked by cost of leaving them.
