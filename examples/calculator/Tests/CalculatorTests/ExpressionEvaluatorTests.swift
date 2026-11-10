import Testing
import Foundation
@testable import Calculator

struct ExpressionEvaluatorTests {
    private func eval(_ tokens: [Token]) throws -> Decimal {
        try ExpressionEvaluator.evaluate(tokens)
    }

    @Test("AC-1: multiplication takes precedence over addition (2 + 3 × 4 = 14)")
    func precedence() throws {
        let result = try eval([.number(2), .op(.add), .number(3), .op(.multiply), .number(4)])
        #expect(result == 14)
    }

    @Test("AC-1: subtraction is left-associative (8 − 3 − 2 = 3)")
    func leftAssociative() throws {
        let result = try eval([.number(8), .op(.subtract), .number(3), .op(.subtract), .number(2)])
        #expect(result == 3)
    }

    @Test("AC-1: division before addition yields a decimal (1 + 9 ÷ 2 = 5.5)")
    func divisionPrecedence() throws {
        let result = try eval([.number(1), .op(.add), .number(9), .op(.divide), .number(2)])
        #expect(result == Decimal(11) / 2)
    }

    @Test("AC-2: dividing by zero throws instead of crashing")
    func divideByZero() {
        #expect(throws: EvaluatorError.divisionByZero) {
            _ = try ExpressionEvaluator.evaluate([.number(5), .op(.divide), .number(0)])
        }
    }

    @Test("AC-3: a longer chain respects precedence (2 × 3 + 4 × 5 = 26)")
    func chained() throws {
        let result = try eval([
            .number(2), .op(.multiply), .number(3), .op(.add),
            .number(4), .op(.multiply), .number(5),
        ])
        #expect(result == 26)
    }

    @Test("a single number evaluates to itself")
    func singleNumber() throws {
        #expect(try eval([.number(42)]) == 42)
    }

    @Test("a trailing operator is malformed")
    func malformed() {
        #expect(throws: EvaluatorError.malformed) {
            _ = try ExpressionEvaluator.evaluate([.number(5), .op(.add)])
        }
    }
}
