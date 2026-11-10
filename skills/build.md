---
name: build
description: Implement ONE task from the graph on the golden template and loop build→fix→green on the simulator. ESDLC pipeline skill — stage 3 (dev).
model: Sonnet
---

Implement exactly **one** task from `tasks.json` on the working copy, to [[architecture]] and `spec.md`, and leave the tree **green on the simulator**. One invocation = one task; the spine calls this once per task in dependency order.

**Autonomous skill.** Runs headless on Claude Code (subscription) + XcodeBuildMCP. Does not chat, does not touch git (the spine owns VCS and the two gates). Produces a diff + a build-green signal + any declared needs.

Follow these steps exactly — do not skip or reorder them.

## Step 1 — Load context + domain skills
Read the assigned task (`$TASK` — one object from `tasks.json`), `spec.md`, and [[architecture]]. Note your `owns` paths, your `satisfies` AC list, and your `needs`.
Then load the **vendored skills** for this task's domain per [[architecture]] § Vendored skills — e.g. a SwiftData list screen → `swiftdata-pro` + `swiftui-ui-patterns` + `swift-accessibility-skill` + `swiftui-design-principles`; a currency screen also → `swift-format-style`; user-visible strings → `writing-for-interfaces`. These are *how-to-write* guidance only; the constitution overrides them on any conflict (§ Precedence — we are MVVM, not MV).

## Step 2 — Respect ownership
- **Scaffold task (`kind:"scaffold"`)**: create the App entry, composition root, `Shared/` models + `ItemStore`, `Package.swift`, `Info.plist` (with `ITSAppUsesNonExemptEncryption=false`), `Assets.xcassets`. You are the ONLY task allowed to write shared files.
- **Feature task (`kind:"feature"`)**: write files **only** inside your `owns` folder. For anything shared (a route, a model field, an Info.plist key, an SPM dep), **emit it as a declared need** — do not edit the shared file. The spine's merge step applies declarations deterministically and hard-fails on conflict.

## Step 3 — Implement to the constitution
Code to [[architecture]]: `@Observable` view model owned via `@State`; DI via init + `@Environment`; Repository protocol for data; `@MainActor` on UI state; custom `LocalizedError` enums; **no force-unwraps**; async/await only; `List`/`LazyVStack` for collections. Build the real behavior for each `AC-N` you `satisfy` — honor the spec's stub-vs-real marks; never hardcode a value the spec marked `real`.

**Style through the design system.** The `design` stage already wrote `Sources/DesignSystem.swift` (same module — no import needed). Style this screen THROUGH it; **never hardcode a `Color`, `.font(.system(...))`, or a raw spacing number** (`audit` flags that):
- Colors `DS.Palette.*` (`.background/.surface/.surfaceAlt/.primary/.accent/.onAccent/.textPrimary/.textSecondary/.textMuted/.separator/.success/.warning/.danger`)
- Type `.font(DS.Typeface.largeTitle/.title/.headline/.body/.callout/.caption)` · spacing `DS.Space.xs…xl` · radius `DS.Radius.sm/md/lg`
- Pieces `DSCard { … }`, `.buttonStyle(DSPrimaryButtonStyle())`/`DSSecondaryButtonStyle()`, `DSSectionHeader("…")`, `.dsScreenBackground()` on the screen's root. Accent is for the ONE primary action; a plain, unstyled screen is **not** done.

## Step 4 — Build→fix→green loop (simulator only)
Use the XcodeBuildMCP CLI (`xcodebuildmcp-cli` skill):
```
xcodebuildmcp simulator build-and-run --scheme <App> --simulator "iPhone 16"
```
On failure: read the diagnostics, fix, rebuild. **No signing** — the dev loop stays on the simulator; the signed device-Release archive is a later gate, not this one.

**Circuit Breaker (code-enforced by the spine, surfaced here):** you get at most **3** correctness attempts per task. Normalize each error signature (strip paths/line numbers/symbols); if the normalized signature repeats or the diff is unchanged between attempts, that's **no-progress** → stop and escalate to the dashboard with the last diagnostics. Infra flakes (simulator boot timeout, etc.) are retried separately and don't burn correctness attempts.

## Step 5 — Do a quick sanity run
After green build, launch and take one screenshot via XcodeBuildMCP; confirm the screen(s) you own render and the core interaction responds. This is a smoke signal for the dashboard, **not** the gate.

## Step 6 — Hand off (no git)
Leave the working tree green. Return to the spine:
- the diff (files created/modified, all within `owns`),
- the `needs` declarations (for the merge step),
- the screenshot path,
- the per-task report below.

Do **not** author the gating tests here — those are written independently by `test-author` from `spec.md` (same agent writing code and its own gating tests games the only hard gate). You may add dev-confidence unit tests inside your `owns` folder, but they do not count as the gate.

## Report format (return verbatim to the spine)
```
Task: T1 — ItemList
Owns: Features/ItemList/  (no shared files touched ✓)
AC coverage:
| AC   | Implemented | Smoke |
|------|-------------|-------|
| AC-1 | yes         | pass  |
| AC-2 | yes         | pass  |
Declared needs: routes=[list], model_fields=[items:[Item]]
Build: GREEN (simulator, iPhone 16) — attempts used: 1/3
Screenshot: <path>
```

**Constraints — always apply:**
- Simulator only; never sign, never archive, never touch the keychain.
- Never write outside your `owns` paths; shared changes are declarations, not edits.
- Never add a capability outside the allow-list ([[architecture]]).
- No force-unwraps; all errors handled; code matches the constitution or it isn't done.
- Never disable, delete, or weaken a test in the diff. Never commit or push.
- Honor the Circuit Breaker — escalate rather than loop.
