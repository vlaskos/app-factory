---
name: audit
description: Asymmetric review pass (Opus auditor over Sonnet coder) on the green branch; advisory + bounded auto-fix under the Circuit Breaker. ESDLC pipeline skill — stage 5.
model: Opus
---

Review the green feature branch before Gate 2. The coder was **Sonnet**; the auditor is **Opus** — asymmetric on purpose (a stronger, independent reviewer catches what the author can't see).

**Autonomous skill.** Runs after `test-author` is green, before the human Ship gate. Advisory + bounded auto-fix; **never self-merges**.

Load the vendored skills `ios-code-audit` (orchestration) + `swiftui-pro` (SwiftUI/HIG/a11y review); reuse `swift-concurrency-pro` (concurrency review); and `swift-architecture-skill` (`architecture-kit/`) for the **structural** lens.

Follow these steps exactly — do not skip or reorder them.

## Step 1 — Load inputs
Read the full diff (scaffold + feature tasks), `spec.md`, and [[architecture]]. Load the three audit skills.

## Step 2 — Audit across dimensions
Run the pass (ios-code-audit orchestration) over:
- **Correctness / bugs** — logic errors, edge cases, force-unwraps, unhandled errors.
- **Concurrency** (`swift-concurrency-pro`) — data races, `@MainActor` isolation, `@unchecked Sendable`.
- **SwiftUI / HIG / a11y** (`swiftui-pro`; authoritative HIG values from the vendored `apple-hig` corpus) — modern APIs, view hygiene, Dynamic Type, VoiceOver, light/dark contrast ≥ 4.5:1, accent used sparingly for the primary action.
- **Structural / architecture** (`swift-architecture-skill`, 8 checks) — name the pattern actually in use, then judge against it + the app's `ARCHITECTURE.md`: boundary violations (views with logic / VMs making layout calls), service-layer coupling (VM → backend without a repository), DI (injectable protocols vs hardcoded singletons), model purity (no UI state / I/O in models), over-broad `…Manager` types, shared mutable state unsafe under strict concurrency, missing abstractions repeated across 3+ VMs, feature-vs-type folder organization. Structural findings are **advisory** (never auto-rewritten — see Step 4).
- **Constitution conformance** — MVVM? DI via init+Environment? Repository? no singletons? capability allow-list? shared-file ownership respected? (drift from fixed MVVM = a finding).
- **Design-system adherence** — every feature screen styles through `DesignSystem.swift` (`DS.Palette.*`, `DS.Typeface.*`, `DS.Space.*`, `DS.Radius.*`, the `DS*` components). Flag any screen that bypasses it with a hardcoded `Color(...)` / `.foregroundColor(.blue)` / `.font(.system(...))` / raw padding number (mechanical → auto-fixable to the nearest token). An unstyled, default-SwiftUI screen is a finding.
- **Demo-ware smell** — values hardcoded where `spec.md` marked them `real`.

## Step 3 — Verify before flagging
Each Critical/High finding must cite **file:line** + a concrete failure (input → wrong output). Discard anything unverifiable — no plausible-but-wrong noise reaches the dashboard.

## Step 4 — Bounded auto-fix
Auto-fix **only** Low-risk, mechanical findings (missing a11y label, force-unwrap → safe unwrap, dead code). Bounded by the **Circuit Breaker** (max 3 fix attempts + no-progress detector on normalized error/diff). Anything structural → an **advisory note** to the dashboard, never an auto-rewrite.

## Step 5 — Constitution guard
Explicitly confirm no fix "refactored the ViewModel away" ([[architecture]] § Precedence). The auditor must not drift the app toward Model-View; MVVM is fixed.

## Step 6 — Re-verify
Re-run build + the gating suite after any fix. A fix that reds the build or breaks a gating test is **reverted**, and the finding downgraded to advisory.

## Report format (return verbatim)
```
| Severity | Location                  | Issue                         | Action      |
|----------|---------------------------|-------------------------------|-------------|
| High     | Balances.swift:42         | divide-by-zero on empty group | auto-fixed  |
| Medium   | ItemRow.swift:18          | no VoiceOver label            | auto-fixed  |
| Low      | AddItem.swift:30          | copy: "OK" → "Add item"       | advisory    |
Build after fixes: GREEN · Gating suite: PASS · Constitution: conformant (MVVM) ✓
```

**Constraints — always apply:**
- Advisory + bounded auto-fix ONLY; never self-merge (Gate 2 is the human).
- Never weaken/delete tests; never edit to pass a test.
- Honor the Circuit Breaker; escalate structural issues rather than loop.
- Verify findings (file:line + failure) before flagging; no speculative noise.
