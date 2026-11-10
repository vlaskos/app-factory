import Testing
import Foundation
import SwiftData
@testable import BillSplitter

@MainActor
struct BillStoreTests {
    // Container held as a property so it outlives each test (SwiftData lifetime gotcha).
    let container: ModelContainer
    let store: SwiftDataBillStore

    init() throws {
        container = try ModelContainer(
            for: Person.self, Expense.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        store = SwiftDataBillStore(context: container.mainContext)
    }

    @Test("adding a person persists")
    func addPerson() throws {
        try store.addPerson(name: "Kos")
        #expect(try store.people().map(\.name) == ["Kos"])
    }

    @Test("a blank person name is rejected")
    func blankName() {
        #expect(throws: BillStoreError.self) { try store.addPerson(name: "  ") }
    }

    @Test("an expense round-trips its Decimal amount and payer")
    func addExpense() throws {
        try store.addPerson(name: "Kos")
        let kos = try store.people()[0]
        try store.addExpense(title: "Lunch", amount: Decimal(4250) / 100, payerID: kos.id)
        let expenses = try store.expenses()
        #expect(expenses.count == 1)
        #expect(expenses[0].amount == Decimal(4250) / 100)   // 42.50 survives SwiftData round-trip
        #expect(expenses[0].payerID == kos.id)
    }

    @Test("a non-positive amount is rejected")
    func nonPositiveAmount() throws {
        try store.addPerson(name: "Kos")
        let kos = try store.people()[0]
        #expect(throws: BillStoreError.self) {
            try store.addExpense(title: "Freebie", amount: 0, payerID: kos.id)
        }
    }

    @Test("AC-3: deleting an expense removes it")
    func deleteExpense() throws {
        try store.addPerson(name: "Kos")
        let kos = try store.people()[0]
        try store.addExpense(title: "Lunch", amount: 10, payerID: kos.id)
        try store.delete(try store.expenses()[0])
        #expect(try store.expenses().isEmpty)
    }
}
