import Foundation
import Observation

/// MVVM view model (fixed constitution). Owns no SwiftData types — only the `ItemStore` seam.
@MainActor
@Observable
final class ItemListModel {
    private(set) var items: [Item] = []
    private(set) var errorMessage: String?

    private let store: ItemStore

    init(store: ItemStore) {
        self.store = store
    }

    func load() {
        do { items = try store.all() }
        catch { errorMessage = error.localizedDescription }
    }

    func add(_ title: String) {
        do {
            try store.add(title: title)
            load()
        } catch { errorMessage = error.localizedDescription }
    }

    func toggle(_ item: Item) {
        do {
            try store.toggle(item)
            load()
        } catch { errorMessage = error.localizedDescription }
    }

    func delete(at offsets: IndexSet) {
        do {
            for index in offsets { try store.delete(items[index]) }
            load()
        } catch { errorMessage = error.localizedDescription }
    }

    func clearError() {
        errorMessage = nil
    }
}
