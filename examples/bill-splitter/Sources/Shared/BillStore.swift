import Foundation
import SwiftData

/// Repository seam. The view model depends on this protocol; tests inject an
/// in-memory SwiftData container behind it.
@MainActor
protocol BillStore {
    func people() throws -> [Person]
    func addPerson(name: String) throws
    func delete(_ person: Person) throws
    func expenses() throws -> [Expense]
    func addExpense(title: String, amount: Decimal, payerID: UUID) throws
    func delete(_ expense: Expense) throws
}

enum BillStoreError: LocalizedError {
    case emptyName
    case emptyTitle
    case nonPositiveAmount

    var errorDescription: String? {
        switch self {
        case .emptyName: "Person name can’t be empty."
        case .emptyTitle: "Expense needs a description."
        case .nonPositiveAmount: "Amount must be greater than zero."
        }
    }
}

@MainActor
final class SwiftDataBillStore: BillStore {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func people() throws -> [Person] {
        try context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.createdAt)]))
    }

    func addPerson(name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw BillStoreError.emptyName }
        context.insert(Person(name: trimmed))
        try context.save()
    }

    func delete(_ person: Person) throws {
        context.delete(person)
        try context.save()
    }

    func expenses() throws -> [Expense] {
        try context.fetch(FetchDescriptor<Expense>(sortBy: [SortDescriptor(\.createdAt)]))
    }

    func addExpense(title: String, amount: Decimal, payerID: UUID) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw BillStoreError.emptyTitle }
        guard amount > 0 else { throw BillStoreError.nonPositiveAmount }
        context.insert(Expense(title: trimmed, amount: amount, payerID: payerID))
        try context.save()
    }

    func delete(_ expense: Expense) throws {
        context.delete(expense)
        try context.save()
    }
}
