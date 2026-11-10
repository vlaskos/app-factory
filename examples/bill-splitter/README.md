# Bill Splitter — golden-path reference app

Hand-built reference implementing the `bill-splitter` archetype (Splitwise-style) to the ESDLC
constitution (MVVM + `@Observable` + SwiftData + Repository + swift-testing). Second backwards-build
de-risk — chosen because it exercises what `shopping-list` didn't: **money math** and a **pure,
independently-tested calculator**.

## Stack & shape
- iOS 17 min, Swift 6, SwiftUI, Observation, SwiftData, swift-testing; project via XcodeGen
- **3 tabs:** People (add/remove) · Expenses (title + amount + payer picker) · Balances (who owes what)
- **MVVM:** one shared `BillSplitterModel` (`@Observable @MainActor`) over a `BillStore` repository
- **Pure core:** `BalanceCalculator` does the math in **integer cents** — no SwiftData, no SwiftUI —
  so an even split sums *exactly* to the total and every balance nets to *exactly* zero (remainder
  cents handed to the first people deterministically). This is the heavily-tested type.
- **Money:** `Money` converts `Decimal` ⇄ cents and formats currency (`.currency(code:)`, swift-format-style).

## Verification (run 2026-10-28, Xcode 26.2 / Swift 6.2.3)
Zero external dependencies → both checks ran fully offline, no `.xcodeproj` needed:

- ✅ **Whole-app typecheck** vs the **iOS 26 simulator SDK** under Swift 6 strict concurrency
  (`swiftc -typecheck Sources/**`) — GREEN on the first try (incl. `TextField(value:format:.number)`
  for `Decimal`, optional-tagged `Picker`, `.keyboardType`).
- ✅ **Gating suite** — **14 tests / 3 suites** via swift-testing, in-memory SwiftData, parallel — all PASS.

### What the run confirmed (would have been guesses otherwise)
- **`Decimal` round-trips through SwiftData** intact — `42.50` stored and re-fetched compares equal.
- **Even split is exact in integer cents** — `10.00 / 3 → 3.34 / 3.33 / 3.33`, shares sum to `10.00`,
  all balances net to `0`. (Doing this in raw `Decimal` division would have drifted off zero.)

### One real issue caught + fixed
- **Test files using `Decimal`/`IndexSet` must `import Foundation` explicitly.** The iOS test target
  gets Foundation transitively (via SwiftData/XCTest), but a bare SPM/macOS build doesn't — relying on
  the re-export is fragile. Added the explicit import. (Pre-emptively applied the shopping-list
  container-lifetime fix — containers held as `@Test` struct properties — so **no SIGTRAP** here.)

## Build & test (needs a machine with XcodeGen)
```sh
brew install xcodegen            # once
cd examples/bill-splitter
xcodegen generate
xcodebuild -scheme BillSplitter -destination 'generic/platform=iOS Simulator' build
```

## Acceptance criteria → tests
| AC | Statement | Covered by |
|----|-----------|-----------|
| AC-1 | even split charges each person their share | `BalanceCalculatorTests.evenSplit`, `BillSplitterModelTests.balancesComputed` |
| AC-2 | all balances net to exactly zero | `BalanceCalculatorTests.netsToZero/remainderDistribution`, `BillSplitterModelTests.balancesComputed` |
| AC-3 | deleting an expense recomputes | `BillStoreTests.deleteExpense`, `BillSplitterModelTests.deleteRecomputes` |
