import Foundation
import Observation

/// MVVM view model shared by the three tabs. Owns no SwiftData/SwiftUI types —
/// only the `BillStore` seam and the pure `BalanceCalculator`.
@MainActor
@Observable
final class BillSplitterModel {
    private(set) var people: [Person] = []
    private(set) var expenses: [Expense] = []
    private(set) var errorMessage: String?

    private let store: BillStore
    init(store: BillStore) { self.store = store }

    func load() {
        do {
            people = try store.people()
            expenses = try store.expenses()
        } catch { errorMessage = error.localizedDescription }
    }

    func addPerson(_ name: String) { perform { try store.addPerson(name: name) } }

    func deletePeople(at offsets: IndexSet) {
        perform { for index in offsets { try store.delete(people[index]) } }
    }

    func addExpense(title: String, amount: Decimal, payerID: UUID) {
        perform { try store.addExpense(title: title, amount: amount, payerID: payerID) }
    }

    func deleteExpenses(at offsets: IndexSet) {
        perform { for index in offsets { try store.delete(expenses[index]) } }
    }

    struct Balance: Identifiable {
        let person: Person
        let netCents: Int
        var id: UUID { person.id }
    }

    /// Live balances, recomputed from current people + expenses via the pure calculator.
    var balances: [Balance] {
        let ids = Set(people.map(\.id))
        let charges = expenses
            .filter { ids.contains($0.payerID) }   // ignore expenses whose payer was removed
            .map { BalanceCalculator.Charge(payer: $0.payerID, amountCents: Money.cents($0.amount)) }
        let net = BalanceCalculator.net(people: people.map(\.id), charges: charges)
        return people.map { Balance(person: $0, netCents: net[$0.id] ?? 0) }
    }

    func clearError() { errorMessage = nil }

    private func perform(_ action: () throws -> Void) {
        do { try action(); load() }
        catch { errorMessage = error.localizedDescription }
    }
}
