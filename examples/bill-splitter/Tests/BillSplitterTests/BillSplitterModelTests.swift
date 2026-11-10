import Testing
import Foundation
import SwiftData
@testable import BillSplitter

@MainActor
struct BillSplitterModelTests {
    let container: ModelContainer
    let model: BillSplitterModel

    init() throws {
        container = try ModelContainer(
            for: Person.self, Expense.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        model = BillSplitterModel(store: SwiftDataBillStore(context: container.mainContext))
    }

    @Test("adding people surfaces them in order")
    func addPeople() {
        model.addPerson("A")
        model.addPerson("B")
        #expect(model.people.map(\.name) == ["A", "B"])
    }

    @Test("AC-1 + AC-2: balances reflect an even split and net to zero")
    func balancesComputed() {
        model.addPerson("A")
        model.addPerson("B")
        let a = model.people[0]
        model.addExpense(title: "Dinner", amount: Decimal(30), payerID: a.id)

        let byName = Dictionary(uniqueKeysWithValues: model.balances.map { ($0.person.name, $0.netCents) })
        #expect(byName["A"] == 1500)    // paid 3000, owes 1500
        #expect(byName["B"] == -1500)
        #expect(model.balances.map(\.netCents).reduce(0, +) == 0)
    }

    @Test("AC-3: deleting the only expense zeroes every balance")
    func deleteRecomputes() {
        model.addPerson("A")
        model.addPerson("B")
        let a = model.people[0]
        model.addExpense(title: "Dinner", amount: Decimal(30), payerID: a.id)
        model.deleteExpenses(at: IndexSet(integer: 0))

        #expect(model.expenses.isEmpty)
        #expect(model.balances.allSatisfy { $0.netCents == 0 })
    }

    @Test("a blank person name sets an error and adds nothing")
    func blankNameErrors() {
        model.addPerson("   ")
        #expect(model.people.isEmpty)
        #expect(model.errorMessage != nil)
    }
}
