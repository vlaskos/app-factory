# 03 · Starter module shapes

A minimal, **well-shaped** first module — a *taste* of the chosen pattern, not a stub. Keep it small
(one feature slice + one test) so it reads as a template to replace. Name it `FirstModule` (or the
language's casing: `first_module` for Python/Ruby).

## Universal quality bar (applies to every shape)

- One clear responsibility per file; idiomatic naming, imports, and placement.
- **Explicit concurrency / isolation — never rely on project-level defaults.**
- Protocol/interface-based dependency, so the module is injectable and testable.
- One realistic happy-path test. **Do not run it during setup** — the team runs tests after choosing a
  framework.
- A one-line docstring on each generated file saying what it demonstrates.

### Swift concurrency trap (read before writing the Swift shapes)
A SwiftUI view that owns a `@MainActor @Observable` view model must itself be `@MainActor`, or an
`init(viewModel: FirstModuleViewModel = FirstModuleViewModel())` default fails to compile with *"call to
main actor-isolated initializer in a synchronous nonisolated context"* in any project that does **not**
set `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Annotate explicitly.

### Correct SwiftUI ownership of an `@Observable` view model
```swift
struct FirstModuleView: View {
    // Own the VM with @State — the Observation framework (iOS 17+) tracks changes
    // automatically. Do NOT use @StateObject (that's for the legacy
    // ObservableObject protocol, not @Observable).
    @State private var viewModel = FirstModuleViewModel()

    var body: some View {
        Text(viewModel.title)
            .task { await viewModel.load() }
    }
}

// A child view that needs two-way bindings takes the VM as @Bindable:
struct ChildView: View {
    @Bindable var viewModel: FirstModuleViewModel   // gives the $ prefix in body
    var body: some View { TextField("name", text: $viewModel.name) }
}
```

## Shapes by pattern

### MVVM (Swift + SwiftUI)
```
Features/FirstModule/
├── Views/FirstModuleView.swift            — View, #Preview, .accessibilityLabel; owns the VM via @State
├── ViewModels/FirstModuleViewModel.swift  — @Observable @MainActor final class; injected deps with defaults;
│                                             async load() with `guard !isLoading`; catches CancellationError silently
├── Models/FirstModuleItem.swift           — nonisolated Sendable value type
Core/Services/FirstModuleService.swift     — `nonisolated protocol FirstModuleService: Sendable` + a fake conformer
Tests/FirstModuleViewModelTests.swift      — modern test suite, uses the fake service, one happy-path test
```

### MV (plain SwiftUI)
```
Features/FirstModule/
├── FirstModuleView.swift                  — binds directly to the store with @State
├── FirstModuleStore.swift                 — @Observable @MainActor; owns state + async load()
└── FirstModuleItem.swift                  — nonisolated Sendable value type
Tests/FirstModuleStoreTests.swift          — exercises the store with a fake service
```

### MVC
```
controllers/first_module_controller.<ext>  — thin, delegates to service; proper status; happy + not-found
models/first_module.<ext>                   — data with basic validation
views/first_module/index.<ext>              — presentation with proper escaping
services/first_module_service.<ext>         — business logic (kept out of the controller)
tests/first_module_controller_test.<ext>    — one happy-path test
```

### MVP
```
views/FirstModuleViewProtocol.<ext>        — pure protocol
views/FirstModuleView.<ext>                — passive; implements the protocol
presenters/FirstModulePresenter.<ext>      — no framework imports; unit-testable
models/FirstModuleItem.<ext>               — data
tests/FirstModulePresenterTests.<ext>      — mocks the View via the protocol
```

### Clean / VIPER
```
domain/entities/FirstModuleItem.<ext>            — domain-pure, no framework
domain/usecases/GetFirstModuleItemUseCase.<ext>  — one use case
domain/repositories/FirstModuleRepository.<ext>  — interface
infrastructure/InMemoryFirstModuleRepository.<ext>— impl for tests + first run
presentation/FirstModuleViewModel.<ext>          — thin wrapper on the use case
tests/GetFirstModuleItemUseCaseTests.<ext>       — uses a fake repository
```

### Redux / Flux / TCA
```
state/firstModuleSlice.<ext>       — state + reducer
actions/firstModuleActions.<ext>   — typed actions
selectors/firstModuleSelectors.<ext>— derived state
views/FirstModuleView.<ext>        — wired to the store
tests/firstModuleSlice.test.<ext>  — one reducer test (action in → new state out)
```

### DDD / Hexagonal
```
domain/FirstModuleItem.<ext>                    — entity with invariants (constructor validates)
application/FirstModuleService.<ext>            — orchestrates domain + ports
application/ports/FirstModuleInboundPort.<ext>  — what drives the app
application/ports/FirstModuleOutboundPort.<ext> — what the app depends on
infrastructure/InMemoryFirstModuleAdapter.<ext> — one outbound impl
tests/FirstModuleServiceTests.<ext>             — uses a fake outbound adapter
```

### Feature-first / vertical slice
```
features/first_module/
├── README.md                — what this feature is
├── <shape files>            — inner shape = your chosen secondary pattern (default MVVM)
└── first_module_test.<ext>  — one test inside the same folder
```

### MVC + services / repositories
```
controllers/first_module_controller.<ext>           — thin HTTP layer
services/first_module_service.<ext>                  — business logic
repositories/first_module_repository.<ext>           — data-access interface
repositories/in_memory_first_module_repository.<ext> — impl
models/first_module.<ext>                            — plain data
tests/first_module_service_test.<ext>                — uses the in-memory repo
```

### Simple / no formal pattern
```
src/first_module.<ext>        — one function that does one clear thing, well-named
tests/first_module_test.<ext> — one assertion on that function
```

> After placing the starter, record in `ARCHITECTURE.md` that it is a template meant to be replaced, and
> delete the `.gitkeep` from the directory the starter now anchors (non-Xcode-synchronized trees only).

→ Next: `04-coding-standards.md`.
