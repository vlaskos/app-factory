import Foundation

enum Operator: Character {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"

    var precedence: Int {
        switch self {
        case .add, .subtract: 1
        case .multiply, .divide: 2
        }
    }

    func apply(_ lhs: Decimal, _ rhs: Decimal) throws -> Decimal {
        switch self {
        case .add: return lhs + rhs
        case .subtract: return lhs - rhs
        case .multiply: return lhs * rhs
        case .divide:
            guard rhs != 0 else { throw EvaluatorError.divisionByZero }
            return lhs / rhs
        }
    }
}

enum Token: Equatable {
    case number(Decimal)
    case op(Operator)
}

enum EvaluatorError: LocalizedError, Equatable {
    case divisionByZero
    case malformed

    var errorDescription: String? {
        switch self {
        case .divisionByZero: "Cannot divide by zero."
        case .malformed: "That expression isn’t complete."
        }
    }
}

/// Pure infix evaluator for +−×÷ with precedence (left-associative), in `Decimal`.
/// Shunting-yard → RPN → fold. No UI, no persistence — the unit-tested core.
enum ExpressionEvaluator {
    static func evaluate(_ tokens: [Token]) throws -> Decimal {
        var output: [Token] = []
        var operators: [Operator] = []

        for token in tokens {
            switch token {
            case .number:
                output.append(token)
            case .op(let incoming):
                while let top = operators.last, top.precedence >= incoming.precedence {
                    output.append(.op(top))
                    operators.removeLast()
                }
                operators.append(incoming)
            }
        }
        while let top = operators.last {
            output.append(.op(top))
            operators.removeLast()
        }

        var stack: [Decimal] = []
        for token in output {
            switch token {
            case .number(let value):
                stack.append(value)
            case .op(let op):
                guard stack.count >= 2 else { throw EvaluatorError.malformed }
                let rhs = stack.removeLast()
                let lhs = stack.removeLast()
                stack.append(try op.apply(lhs, rhs))
            }
        }
        guard stack.count == 1 else { throw EvaluatorError.malformed }
        return stack[0]
    }
}
