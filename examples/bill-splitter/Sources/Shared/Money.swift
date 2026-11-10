import Foundation

/// Decimal ⇄ integer-cents conversion and currency formatting (swift-format-style).
enum Money {
    /// Round a decimal amount to whole cents (.plain rounding).
    static func cents(_ amount: Decimal) -> Int {
        var scaled = amount * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &scaled, 0, .plain)
        return NSDecimalNumber(decimal: rounded).intValue
    }

    static func decimal(cents: Int) -> Decimal {
        Decimal(cents) / 100
    }

    static func string(cents: Int, code: String = Locale.current.currency?.identifier ?? "USD") -> String {
        decimal(cents: cents).formatted(.currency(code: code))
    }
}
