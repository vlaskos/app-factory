# Calculator — golden-path reference app

Hand-built reference implementing the `calculator` archetype to the ESDLC constitution
(MVVM + `@Observable`, pure logic core, swift-testing). Third backwards-build de-risk —
chosen because it is pure computation with **no persistence store**, stressing the
`test-author` gating approach on an algorithm (precedence, error states, chaining).

## Stack & shape
- iOS 17 min, Swift 6, SwiftUI, Observation, swift-testing; project via XcodeGen
- **1 screen:** keypad + display (`CalculatorView`)
- **MVVM:** `CalculatorModel` (`@Observable @MainActor`) owns the keypad input state machine
- **Pure core:** `ExpressionEvaluator` — shunting-yard → RPN → fold, in `Decimal`, with +−×÷
  precedence (left-associative). Divide-by-zero **throws** `EvaluatorError`; the model turns that
  into an "Error" display state — never a crash. This is the heavily-tested type.
- **Persistence:** last result saved to `UserDefaults` (injectable for tests), restored on launch.
  No SwiftData — this archetype doesn't need it.

## Verification (run 2026-10-28, Xcode 26.2 / Swift 6.2.3)
No external dependencies → verified fully offline, no `.xcodeproj` needed:

- ✅ **Whole-app typecheck** vs the **iOS 26 simulator SDK** under Swift 6 strict concurrency — GREEN
  (incl. `Decimal.FormatStyle` precision, `LazyVGrid`, Hashable `CalcKey` with an associated `Operator`).
- ✅ **Gating suite** — **13 tests / 2 suites** via swift-testing, parallel — all PASS, first run, no bugs.

### ACs exercised
- **AC-1 (precedence):** `2 + 3 × 4 = 14`, `8 − 3 − 2 = 3`, `1 + 9 ÷ 2 = 5.5`, `2 × 3 + 4 × 5 = 26`.
- **AC-2 (divide-by-zero):** throws at the evaluator and shows "Error" / `hasError` at the model — no crash.
- **AC-3 (chaining):** `2 + 3 =` then `× 4 =` → `20`; result feeds the next operation.
- Plus: error recovery (typing after "Error" starts fresh), clear, `UserDefaults` persistence round-trip.

## Build & test (needs a machine with XcodeGen)
```sh
brew install xcodegen            # once
cd examples/calculator
xcodegen generate
xcodebuild -scheme Calculator -destination 'generic/platform=iOS Simulator' build
```

## Acceptance criteria → tests
| AC | Covered by |
|----|-----------|
| AC-1 precedence / associativity | `ExpressionEvaluatorTests.precedence/leftAssociative/divisionPrecedence/chained`, `CalculatorModelTests.precedenceThroughModel` |
| AC-2 divide-by-zero never crashes | `ExpressionEvaluatorTests.divideByZero`, `CalculatorModelTests.divideByZero` |
| AC-3 chained operations | `ExpressionEvaluatorTests.chained`, `CalculatorModelTests.chaining` |
