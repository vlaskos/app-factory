import Testing
import Foundation
@testable import Calculator

@MainActor
struct CalculatorModelTests {
    private func makeModel() -> CalculatorModel {
        let defaults = UserDefaults(suiteName: "calc.test.\(UUID().uuidString)") ?? .standard
        return CalculatorModel(defaults: defaults)
    }

    @Test("AC-1: 2 + 3 × 4 = shows 14 (precedence through the keypad)")
    func precedenceThroughModel() {
        let model = makeModel()
        model.tapDigit(2); model.tapOperator(.add)
        model.tapDigit(3); model.tapOperator(.multiply)
        model.tapDigit(4); model.tapEquals()
        #expect(model.display == "14")
        #expect(model.hasError == false)
    }

    @Test("AC-2: dividing by zero shows Error, not a crash")
    func divideByZero() {
        let model = makeModel()
        model.tapDigit(5); model.tapOperator(.divide)
        model.tapDigit(0); model.tapEquals()
        #expect(model.display == "Error")
        #expect(model.hasError == true)
    }

    @Test("AC-3: a result chains into the next operation (2+3=5, ×4=20)")
    func chaining() {
        let model = makeModel()
        model.tapDigit(2); model.tapOperator(.add); model.tapDigit(3); model.tapEquals()
        model.tapOperator(.multiply); model.tapDigit(4); model.tapEquals()
        #expect(model.display == "20")
    }

    @Test("clear resets the display to zero")
    func clearResets() {
        let model = makeModel()
        model.tapDigit(9); model.tapDigit(9)
        model.clear()
        #expect(model.display == "0")
    }

    @Test("typing after an error starts fresh")
    func recoverFromError() {
        let model = makeModel()
        model.tapDigit(5); model.tapOperator(.divide); model.tapDigit(0); model.tapEquals()
        model.tapDigit(7)
        #expect(model.display == "7")
        #expect(model.hasError == false)
    }

    @Test("the last result is persisted and restored on relaunch")
    func persistsLastResult() {
        let defaults = UserDefaults(suiteName: "calc.test.\(UUID().uuidString)") ?? .standard
        let first = CalculatorModel(defaults: defaults)
        first.tapDigit(7); first.tapOperator(.add); first.tapDigit(8); first.tapEquals()
        #expect(first.display == "15")

        let second = CalculatorModel(defaults: defaults)
        #expect(second.display == "15")
    }
}
