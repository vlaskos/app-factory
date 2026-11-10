---
chunk: architecture
domain: ios-swift-swiftui
pattern_scope: agnostic            # works for MVVM, MVC, MVP, Clean/VIPER, TCA, DDD, feature-first, …
role_in_sdlc: [bootstrap, build, review]
tool_opinion: none                 # decides structure; never picks linter/formatter/test/CI/MCP
self_contained: true               # references only files inside this folder
---

# LLM Architecture Layer

The **Architecture chunk** of a project-setup process: the piece that *forms* a project's architecture
at bootstrap and keeps it honest across the lifecycle. Pattern-agnostic (pick MVVM, Clean, TCA, DDD,
feature-first, …), iOS/Swift/SwiftUI-focused, and **tool-neutral** — it decides directory structure and
module shape, never which linter, formatter, test framework, or CI you run.

Everything this kit refers to is in this folder. Nothing external is required.

## What's inside

| File | Phase | Purpose |
|---|---|---|
| `01-architecture-selection.md` | bootstrap | Pattern menu + a decision guide — choose the architecture from project scope. |
| `02-project-skeletons.md` | bootstrap | The canonical directory skeleton for each pattern + the iOS/Xcode placeholder rules. |
| `03-starter-module-shapes.md` | bootstrap | A minimal, well-shaped starter module per pattern + the SwiftUI `@Observable` ownership pattern + the quality bar. |
| `04-coding-standards.md` | build | Architecture-level Swift/SwiftUI standards: isolation, DI, boundaries, model purity. |
| `05-architecture-review-checklist.md` | review | A tool-free checklist for the architecture review gate. |
| `templates/ARCHITECTURE.md` | all | The `ARCHITECTURE.md` doc template to fill in per project (records the *why*). |
| `skills/swift-architecture-skill/SKILL.md` | review | An on-demand architecture-audit skill for an LLM agent (configurable header). |

## How to use it

**At bootstrap (form the architecture):**
1. `01` — pick the pattern from project scope.
2. `02` — create that pattern's directory skeleton (mind the Xcode placeholder rules).
3. `03` — drop in the starter module as a "taste" of the pattern; replace with real work later.
4. Fill `templates/ARCHITECTURE.md` with the actual decisions and their rationale.
5. Adopt `04` as the project's architecture coding standards.

**During build:** keep `04` in the agent's context (or paste it into the project brief) so new code
stays inside the chosen pattern's boundaries.

**At review (reuse across the SDLC):** run `05` as a manual gate, and/or install
`skills/swift-architecture-skill/` so an LLM agent audits the codebase against the chosen pattern on
each change.

## Configuration

- **Pattern:** choose any in `01`; `02`–`03` have a skeleton + starter shape for each. "Decide later"
  is valid — skip the starter and formalize as the project grows.
- **Naming casing:** adapt skeleton/module names to the language (PascalCase for Swift types, etc.).
- **The audit skill** carries a small config header (stack, app location, backend) — fill it per project.
- **Tools stay out:** this kit never installs a linter/formatter/test framework/CI. Those are separate
  decisions; this chunk only governs *shape*.
