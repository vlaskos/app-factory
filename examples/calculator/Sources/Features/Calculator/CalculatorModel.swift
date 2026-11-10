import Foundation
import Observation

/// MVVM view model: owns the keypad input state machine and delegates arithmetic
/// to the pure `ExpressionEvaluator`. Persists the last result in `UserDefaults`.
@MainActor
@Observable
final class CalculatorModel {
    private(set) var display: String = "0"
    private(set) var hasError = false

    private var tokens: [Token] = []     // finalized numbers + operators
    private var entry: String = ""       // the number currently being typed
    private var justEvaluated = false    // next digit starts a fresh expression

    private let defaults: UserDefaults
    static let lastResultKey = "calculator.lastResult"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let last = defaults.string(forKey: Self.lastResultKey) {
            display = last
        }
    }

    func tapDigit(_ digit: Int) {
        resetIfNeeded()
        if entry == "0" { entry = "" }     // no leading zeros
        entry += String(digit)
        display = entry
    }

    func tapDecimalPoint() {
        resetIfNeeded()
        if entry.isEmpty { entry = "0" }
        if !entry.contains(".") { entry += "." }
        display = entry
    }

    func tapOperator(_ op: Operator) {
        if hasError { return }
        commitEntryIfNeeded()
        guard !tokens.isEmpty else { return }     // ignore a leading operator
        if case .op = tokens[tokens.count - 1] {
            tokens[tokens.count - 1] = .op(op)    // replace a doubled operator
        } else {
            tokens.append(.op(op))
        }
        justEvaluated = false
    }

    func tapEquals() {
        if hasError { return }
        commitEntryIfNeeded()
        do {
            let result = try ExpressionEvaluator.evaluate(tokens)
            let text = Self.format(result)
            display = text
            defaults.set(text, forKey: Self.lastResultKey)
            tokens = [.number(result)]            // allow chaining from the result
            entry = ""
            justEvaluated = true
            hasError = false
        } catch {
            display = "Error"
            hasError = true
            tokens = []
            entry = ""
        }
    }

    func clear() {
        tokens = []
        entry = ""
        display = "0"
        hasError = false
        justEvaluated = false
    }

    private func resetIfNeeded() {
        if hasError || justEvaluated {
            tokens = []
            entry = ""
            hasError = false
            justEvaluated = false
        }
    }

    private func commitEntryIfNeeded() {
        guard !entry.isEmpty, let value = Decimal(string: entry) else { return }
        tokens.append(.number(value))
        entry = ""
    }

    static func format(_ value: Decimal) -> String {
        value.formatted(.number.precision(.fractionLength(0...8)))
    }
}
