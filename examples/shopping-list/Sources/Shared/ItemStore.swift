import Foundation
import SwiftData

/// Repository seam — the view model depends on this protocol, tests inject an in-memory
/// SwiftData container behind it. No SwiftData types leak into the views.
@MainActor
protocol ItemStore {
    func all() throws -> [Item]
    func add(title: String) throws
    func toggle(_ item: Item) throws
    func delete(_ item: Item) throws
}

enum ItemStoreError: LocalizedError {
    case emptyTitle
    var errorDescription: String? {
        switch self {
        case .emptyTitle: "Item name can’t be empty."
        }
    }
}

@MainActor
final class SwiftDataItemStore: ItemStore {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func all() throws -> [Item] {
        // Bool isn't Comparable, so we can't sort by \.isDone in the FetchDescriptor
        // (and SortDescriptor's Bool overload needs NSObject, which @Model isn't).
        // Fetch by creation order, then partition unchecked-first in Swift.
        let descriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\.createdAt)])
        let items = try context.fetch(descriptor)
        return items.sorted { lhs, rhs in
            if lhs.isDone != rhs.isDone { return !lhs.isDone }
            return lhs.createdAt < rhs.createdAt
        }
    }

    func add(title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ItemStoreError.emptyTitle }
        context.insert(Item(title: trimmed))
        try context.save()
    }

    func toggle(_ item: Item) throws {
        item.isDone.toggle()
        try context.save()
    }

    func delete(_ item: Item) throws {
        context.delete(item)
        try context.save()
    }
}
