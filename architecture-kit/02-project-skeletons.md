# 02 · Project skeletons

The canonical top-level directory layout for each pattern from `01`. Create only the directories that
will hold files this run; document the rest in `templates/ARCHITECTURE.md` and let them appear as real
code lands. Adapt casing to the language (PascalCase for Swift).

> ⚠️ **Read "Skeleton rules" at the bottom before adding any `.gitkeep` — it matters on iOS.**

### MVVM (feature-based) — the SwiftUI default
```
<source-root>/
├── App/                    App entry, delegates, app-level configuration
├── Features/               Vertical feature slices (Auth, Home, Profile, …)
│   └── <Feature>/
│       ├── Views/          SwiftUI views
│       ├── ViewModels/     @Observable @MainActor view models
│       └── Models/         Feature-private types only
├── Core/                   Cross-feature infrastructure
│   ├── Networking/         HTTP client, endpoints, error types
│   ├── Storage/            Persistence, keychain, defaults
│   ├── Models/             Types shared by 2+ features
│   └── Extensions/         Framework extensions (View+, String+, Date+)
├── UI/                     Design-system atoms
│   ├── Components/         Reusable UI (PrimaryButton, LoadingView, ErrorView)
│   └── Theme/              Colors, Fonts, Spacing
└── Resources/              Assets, localization catalogs, static config
```

### MV (plain SwiftUI)
```
<source-root>/
├── App/
├── Features/<Feature>/     Views + the @Observable store/model they bind to (no VM layer)
├── Core/                   Networking, Storage, shared Models, Extensions
├── UI/                     Components, Theme
└── Resources/
```

### MVC
```
<source-root>/
├── controllers/   Handle requests/actions, orchestrate views + models
├── models/        Data + validation
├── views/         Presentation
└── services/      Business logic that doesn't fit in a model
```

### MVP
```
<source-root>/
├── views/         Passive views implementing a ViewProtocol
├── presenters/    Framework-free orchestration
└── models/        Data types
```

### Clean / VIPER
```
<source-root>/
├── domain/
│   ├── entities/        Domain entities with invariants
│   ├── usecases/        Application-independent business rules
│   └── repositories/    Repository interfaces
├── application/         Application services / interactors
├── infrastructure/      Concrete implementations (DB, HTTP, filesystem)
└── presentation/        UI layer (view models / presenters / views)
```

### Redux / Flux / TCA
```
<source-root>/
├── state/         Slices, initial state, reducers
├── actions/       Typed actions
├── selectors/     Derived state
├── views/         Components wired to the store
└── effects/       Side-effect handlers
```

### DDD / Hexagonal (ports & adapters)
```
<source-root>/
├── domain/        Aggregates, entities, value objects, domain services, events
├── application/   Application services + inbound/outbound port interfaces
└── infrastructure/ Adapters: persistence, http, messaging
```

### Feature-first / vertical slice
```
<source-root>/
├── features/<feature>/   Each feature owns its full stack (inner shape = your chosen pattern)
└── shared/               Cross-feature utilities (use sparingly)
```

### MVC + services / repositories
```
<source-root>/
├── controllers/   Thin HTTP/action layer
├── services/      Business logic (service objects / interactors)
├── repositories/  Data-access abstractions (+ an in-memory impl for tests)
├── models/        Plain data
└── views/         (or templates/, if server-rendered)
```

### Simple / no formal pattern
```
<source-root>/
├── src/           Application code
└── tests/         Tests parallel to src/
```

---

## Skeleton rules

- **`.gitkeep`, not README stubs — except in build-swept trees.** One 0-byte `.gitkeep` per empty dir is
  the standard git convention; delete it when real content lands.
- **iOS / Xcode exception (important):** if the `.pbxproj` contains `PBXFileSystemSynchronizedRootGroup`
  (any modern Xcode template), **every file under the source root is auto-included in the target**. A
  `.gitkeep` then becomes a bundle resource, and multiple identically-named ones collide into
  *"Multiple commands produce…"* build errors. There: **create no placeholder files inside the source
  root** — materialize only the directories that receive real files this run, and document the full
  intended layout in `templates/ARCHITECTURE.md`. The rest appear as real code lands.
- **IDE auto-generated files:** with Xcode synchronized groups, moving files on disk is safe (no
  project-file edit) — you may move `<Name>App.swift` / `ContentView.swift` → `App/` and
  `Assets.xcassets` → `Resources/`. **Never move `Preview Content/`** — its path is pinned in build
  settings (`DEVELOPMENT_ASSET_PATHS`). For projects with explicit file references, don't move anything;
  note in `ARCHITECTURE.md` that the dev can move them via the IDE when ready.
- **Don't materialize empty layer folders you won't use yet.** A skeleton is a map, not a mandate.

→ Next: `03-starter-module-shapes.md` for a well-shaped first module.
