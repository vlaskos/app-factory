---
name: test-author
description: Author the GATING tests from the approved spec, in a context separate from build (anti-self-gaming). ESDLC pipeline skill — stage 4.
model: Opus
---

Author the **gating** test suite from `spec.md`. This suite is the required check at Gate 2, so it must be impossible to pass with a hollow app.

**Autonomous skill, separation of powers.** Runs after feature tasks are green, in a context that has **not** seen `build`'s implementation reasoning. The agent that writes code must not write the tests that gate it — otherwise vacuous/`.disabled()` tests game the only hard gate. Reads `spec.md` (each `AC-N` + its "Verified by") and the code's **public surface**, never the builder's chain-of-thought.

Load the vendored skills `swift-testing-pro` (conventions) + `swiftdata-testing` (in-memory container isolation).

Follow these steps exactly — do not skip or reorder them.

## Step 1 — Load inputs
Read `spec.md`, [[architecture]], and the public API of the compiled sources. Load the two test skills.

## Step 2 — One failable test per AC
For each `AC-N`, write ≥1 Swift Testing test asserting its "Verified by" outcome, tagged with the AC id (`@Test("AC-3: even split nets to zero")`):
- Target the **pure logic types** (`BalanceCalculator`, `ExpressionEvaluator`, `ItemStore`) and the `@Observable @MainActor` view model's observable state — these stay independently testable under MVVM.
- Assert **real data-dependent values** (balances net to zero, `2+2==4`, item persists across a fresh store), never "a function was called" or "a view renders."
- SwiftData: spin up an **in-memory `ModelContainer`** per `swiftdata-testing`; never touch the on-disk store.

## Step 3 — Anti-gaming self-rules (the whole point)
- Every `AC-N` has ≥1 test; a test that cannot fail is not a test.
- The diff is **tests-only**. If an AC is untestable as built, **FAIL back** to spec/build — do NOT edit production code to make a hollow test pass.
- Never add `.disabled()`, never delete or weaken an existing test.

## Step 4 — Run + report
Run the suite on the simulator. Emit pass/fail per AC. Any AC lacking a genuinely failable test = overall FAIL.

## Report format (return verbatim)
```
| AC   | Test                          | Result |
|------|-------------------------------|--------|
| AC-1 | AC-1: add persists            | pass   |
| AC-2 | AC-2: check reorders          | pass   |
| AC-3 | AC-3: even split nets to zero | pass   |
Overall: PASS
```

**Constraints — always apply:**
- Separate context from `build`; never read the builder's reasoning.
- Tests-only diff; never weaken/disable/delete tests; never edit production to satisfy a test.
- Every test references an AC id; every AC has ≥1 failable, data-dependent test.
- swift-testing only (the hard gate). XCTest only if UI automation later needs it — not a gate.
