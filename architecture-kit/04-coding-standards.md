# 04 · Architecture coding standards

Pattern-agnostic Swift/SwiftUI rules that keep code inside whatever architecture you chose in `01`.
Paste these into the project brief (the file your LLM agent loads every session) so new code is written
to them, not corrected into them after the fact.

## Isolation & concurrency (Swift 6 strict concurrency)

- **Default to `@MainActor` for UI-touching types; opt data/services out with `nonisolated`.** If the
  project sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, every declaration is `@MainActor` unless
  marked otherwise — annotate deliberately, don't drift.
- **Models and the networking layer are `nonisolated` and `Sendable`** so they cross actor boundaries
  freely.
- **View models are `@MainActor @Observable final class`.** UI state stays on main.
- **Fix strict-concurrency diagnostics with `nonisolated` / `Sendable`, not `@unchecked`**, unless a
  closure-carrying type genuinely forces it (document why at the declaration).
- **Async only.** `async/await`, no completion-handler callbacks.

## State ownership (SwiftUI)

- Own an `@Observable` view model/store with `@State private var vm = …`. **Never `@StateObject`** —
  that is the legacy `ObservableObject` pattern.
- Get bindings via `@Bindable` (in `body` or as a child-view property), not by reaching for a VM you
  don't own.
- Local view state is `@State`; cross-feature shared state is an injected `@Observable` store.

## Dependency injection & boundaries

- **Depend on protocols, not concretions.** Services sit behind a `protocol … : Sendable`; view
  models/use-cases take the protocol in `init` with a `.shared` (or fake) default. Tests substitute a
  fake; production callsites stay short.
- **Respect the layer boundary of your pattern:**
  - Views hold *no* business logic; view models/presenters make *no* layout decisions.
  - View models never call networking/the backend directly — only through a service/repository.
  - Models are pure data: no UI state, no I/O.
- **No god objects.** A type named `…Manager` that fetches, caches, formats, and navigates is a smell —
  split it along its responsibilities.

## Data loading discipline (for VM/store `load()`)

- `guard !isLoading` re-entrancy guard; set/reset `isLoading` with `defer`.
- Structured concurrency — no detached `Task { }` wrappers inside `load()`, so cancellation propagates.
- Catch cancellation (`CancellationError`, your network layer's `.cancelled`) **silently** — it's the
  normal result of navigating away mid-request.
- Gate auto-load so re-appearance doesn't refire: `.task { if vm.items.isEmpty { await vm.load() } }`.

## Organization

- **By feature, not by type** past a few screens (see `01` §cross-cutting). A feature is found and
  changed in one place.
- Shared-by-2+-features code goes to `Core/`; single-feature types stay in the feature.
- Extract a view when it exceeds ~100 lines; extract repeated modifier chains into a `ViewModifier`.

## Testability (so the review gate in `05` can pass)

- Inject `UserDefaults`/clients/sessions; never hardcode `.standard` or a live singleton into logic.
- Pull non-trivial logic out of views into small, pure helpers that test without standing up SwiftUI.
- Keep protocols as the seam: a fake conformer is the unit-test substitute.

## Commit convention (structure only — not a tool choice)

Use Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`). This is a message
format, not a tool the kit installs.

→ Enforce at review time with `05-architecture-review-checklist.md`.
