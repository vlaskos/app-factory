---
name: scaffold
description: Generate the known-good project skeleton for an archetype — the golden-template replacement. Owns all shared files; must build green before any feature task. ESDLC pipeline skill — stage 2.5.
model: Sonnet
---

Generate a project that **compiles and launches empty**, so feature tasks only add screens onto a known-good base. This skill *is* the template — generated fresh and verified every run (there is no checked-in golden template).

**Autonomous skill.** Runs once per run, right after Gate 1, **before** any `build` feature task. Does not chat, does not touch git.

> **Note on "SPM-only":** a pure SwiftPM package cannot produce an iOS `.app` — an Xcode project is required to build an app bundle. So the rule is: **dependencies via SPM only** (no CocoaPods), but the project itself is generated. We use **XcodeGen** (`project.yml` → `.xcodeproj`) because it is text-based, deterministic, and regenerates the `pbxproj` instead of merging it — which is exactly how we avoid the pbxproj-conflict problem.

Follow these steps exactly — do not skip or reorder them.

## Step 1 — Load context + skills
Read `brief.json` (archetype, `display_name`), the `T0` scaffold task from `tasks.json`, and [[architecture]]. Load the vendored skills `swiftdata-pro` + `swiftui-ui-patterns` (+ `swiftui-design-principles` for the tokens file).

## Step 2 — Generate the project (XcodeGen)
Write `project.yml` and run `xcodegen generate`:
- one app target; deployment = the current iOS baseline ([[architecture]] § Stack);
- `display_name` as the display name; bundle id = a placeholder (`com.esdlc.slotXX` — the slot allocator / release step sets the real one);
- source globs for `App/`, `Shared/`, `Features/` (folders are the source of truth — adding a feature file needs no project edit, `xcodegen generate` picks it up);
- a `Tests/` unit-test target that `import Testing`.

_Zero-dependency alternative:_ an Xcode-16 **filesystem-synchronized** `.xcodeproj` shell — new files in synced folders are picked up with no regeneration. Use only if XcodeGen is unavailable.

## Step 3 — Generate the shared files (scaffold owns ALL of these)
Per [[architecture]] § Project layout + § Shared-file ownership:
- `App/<Name>App.swift` — `@main`, `WindowGroup`, injects the SwiftData `ModelContainer` + the composition root.
- `App/AppRouter.swift` — root `TabView`/`NavigationStack` wired to the archetype's screen set (empty destinations the feature tasks fill).
- `Shared/Models.swift` — the archetype's `@Model` types (§ Supported archetypes).
- `Shared/ItemStore.swift` — the Repository **protocol** + a SwiftData-backed impl + an in-memory impl (for previews/tests).
- `Shared/DesignTokens.swift` — base-8 spacing + semantic colors (per `swiftui-design-principles`).
- `Info.plist` — `ITSAppUsesNonExemptEncryption=false`.
- `Assets.xcassets` — AppIcon placeholder + AccentColor.
- `ARCHITECTURE.md` — from `architecture-kit/templates/ARCHITECTURE.md`: the fixed pattern (MVVM, feature-based), layer diagram, testability conventions, the **intended-vs-built** layout (document dirs not yet materialized), and "things deliberately not done". This is the source of truth the `audit` stage checks the code against for drift.

Placeholder rule (architecture-kit `02`): **materialize only directories that receive real files this run** — never scatter `.gitkeep` in the source root (auto-included → "Multiple commands produce…"); document the rest in `ARCHITECTURE.md`.

## Step 4 — Build-green gate (before any feature task)
Run `xcodebuildmcp simulator build-and-run --scheme <App> --simulator "iPhone 16"`. The app must launch to a valid, empty root screen. Loop build→fix→green under the **Circuit Breaker** (max 3 correctness attempts + no-progress detector). A red scaffold **blocks the run** → escalate to the dashboard; never hand a non-compiling skeleton to feature tasks.

## Step 5 — Emit the merge surface
Return to the spine: the green tree + the **registry** of slots feature tasks may declare into (route names, shared-model fields, Info.plist keys). The merge step validates every feature `needs` against this registry and hard-fails on an undeclared or conflicting need.

## Report format (return verbatim)
```
Scaffold: QuickCart (shopping-list)
Project: XcodeGen OK — synchronized folders [App/, Shared/, Features/, Tests/]
Shared files: App/QuickCartApp.swift, App/AppRouter.swift, Shared/{Models,ItemStore,DesignTokens}.swift, Info.plist, Assets.xcassets
Registry: routes=[list,add], model_fields=[items:[Item]], plist_keys=[]
Build: GREEN (simulator, iPhone 16) — attempts used: 1/3
```

**Constraints — always apply:**
- Scaffold is the ONLY task that writes shared files; it creates the slots, never the feature content.
- Dependencies via SPM only; the project is generated, never hand-merged.
- Simulator only; no signing. Built to [[architecture]]; MVVM; no force-unwraps.
- Must end GREEN or escalate — a non-compiling skeleton is a hard stop.
