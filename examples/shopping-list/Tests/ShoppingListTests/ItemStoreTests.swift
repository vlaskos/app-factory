import Testing
import SwiftData
@testable import ShoppingList

@MainActor
struct ItemStoreTests {
    // Held as properties so the in-memory container outlives each test.
    // (A factory returning only `container.mainContext` lets the container
    // deallocate on return → the next save() hits a torn-down store / SIGTRAP.)
    let container: ModelContainer
    let store: SwiftDataItemStore

    init() throws {
        container = try ModelContainer(
            for: Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        store = SwiftDataItemStore(context: container.mainContext)
    }

    @Test("AC-1: adding a non-empty item persists it")
    func addPersists() throws {
        try store.add(title: "Milk")
        #expect(try store.all().map(\.title) == ["Milk"])
    }

    @Test("AC-1: blank titles are rejected")
    func blankRejected() throws {
        #expect(throws: ItemStoreError.self) {
            try store.add(title: "   ")
        }
    }

    @Test("AC-2: checking an item sorts it below unchecked")
    func toggleReorders() throws {
        try store.add(title: "A")
        try store.add(title: "B")
        let first = try store.all()[0]
        try store.toggle(first)                   // A → done, should fall to the bottom
        #expect(try store.all().last?.isDone == true)
        #expect(try store.all().first?.isDone == false)
    }

    @Test("AC-3: deleting removes the item")
    func deleteRemoves() throws {
        try store.add(title: "Eggs")
        let item = try store.all()[0]
        try store.delete(item)
        #expect(try store.all().isEmpty)
    }
}
