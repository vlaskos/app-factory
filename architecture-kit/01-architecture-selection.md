# 01 · Architecture selection

Pick the pattern **before** scaffolding — it decides the directory skeleton (`02`) and the starter
module (`03`). This is a menu plus a decision guide, not a mandate: the kit supports all of them.

## The menu

| # | Pattern | What it is | Natural fit |
|---|---|---|---|
| 1 | **MVVM** | View / ViewModel / Model. View-models own UI state; views stay declarative. | SwiftUI-first apps. The common default. |
| 2 | **MV (plain SwiftUI)** | Views bind directly to `@Observable` models/stores; no separate view-model layer. | Small/medium apps where a VM per view is ceremony. |
| 3 | **MVC** | View / Controller / Model. | Legacy UIKit, server-rendered backends. Risks fat controllers. |
| 4 | **MVP** | View / Presenter / Model; passive views behind a protocol. | UIKit / Android-style shops; highly unit-testable presenters. |
| 5 | **Clean / VIPER** | Entities → UseCases → Interface Adapters → Frameworks. | Large apps with rich, layered business logic. Overkill for CRUD. |
| 6 | **Redux / Flux / TCA** | Unidirectional state: store, actions, reducers, effects. | Complex, shared UI state. Adds ceremony. |
| 7 | **DDD / Hexagonal** | Explicit domain / application / infrastructure split (ports & adapters). | Rich business rules; backends and domain-heavy clients. |
| 8 | **Feature-first / vertical slice** | Organize by feature, not by layer; each feature owns its stack. | Any size; combine with one of the above *inside* each slice. |
| 9 | **MVC + services / repositories** | Thin controllers; business logic in service objects, data behind repositories. | Rails/Django-style backends and their clients. |
| 10 | **Simple / no formal pattern** | Files organized pragmatically; formalize as it grows. | Prototypes, spikes. |
| — | **Decide later** | Install structure only; skip the starter module; formalize when the shape is clearer. | Genuinely uncertain scope. |

## How to choose (by scope, not fashion)

```
            small / prototype ───────────────▶ MVVM or MV (2), or Simple (10)
   complex, long-lived domain ───────────────▶ Clean/VIPER (5) or DDD/Hexagonal (7)
          complex shared UI state ────────────▶ Redux/TCA (6)
      many features, flat team ───────────────▶ Feature-first (8) + MVVM inside
            legacy UIKit / hybrid ────────────▶ MVP (4) or MVC (3)
                    truly unsure ──────────────▶ Decide later, formalize on the 2nd feature
```

**Rules of thumb**
- Don't adopt layers you can't justify today. Clean/VIPER on a CRUD app is debt, not safety.
- Feature-first (8) is orthogonal — layer it over any of 1–7 as the *outer* organization.
- SwiftUI pushes you toward MVVM (1) or MV (2); the `@Observable` macro makes MV viable where you'd
  previously have reached for a view-model purely to get observation.
- Whatever you pick, write it (and *why*) into `templates/ARCHITECTURE.md` on day one.

## Two cross-cutting decisions that aren't "the pattern"

1. **Organize by feature or by type?** Prefer **by feature** past a handful of screens: a feature should
   be findable and changeable in one place. Grouping by type (`AllViewModels/`, `AllViews/`) spreads one
   change across the tree. (This is pattern 8 applied as the outer layout.)
2. **Where does shared infrastructure live?** A `Core/` (or `Shared/`) area for things used by 2+
   features — networking, persistence, design-system atoms, extensions. Keep truly single-feature types
   inside their feature.

→ Next: `02-project-skeletons.md` for the chosen pattern's directory layout.
