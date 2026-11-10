import Foundation

/// Pure, SwiftData-free money math — the independently unit-tested core.
///
/// Works in integer minor units (cents) so an even split sums EXACTLY to the total
/// and every person's balance nets to exactly zero — no Decimal/float rounding drift.
enum BalanceCalculator {
    struct Charge: Equatable {
        let payer: UUID
        let amountCents: Int
    }

    /// Net position per person, in cents: positive = owed to them, negative = they owe.
    /// Each charge is split evenly across all `people`; leftover cents are handed out
    /// one each to the first people (in the given order) so shares sum to the charge.
    static func net(people: [UUID], charges: [Charge]) -> [UUID: Int] {
        var net: [UUID: Int] = Dictionary(uniqueKeysWithValues: people.map { ($0, 0) })
        guard !people.isEmpty else { return net }
        let count = people.count
        for charge in charges {
            net[charge.payer, default: 0] += charge.amountCents
            let base = charge.amountCents / count
            let remainder = charge.amountCents % count
            for (index, person) in people.enumerated() {
                let share = base + (index < remainder ? 1 : 0)
                net[person, default: 0] -= share
            }
        }
        return net
    }
}
