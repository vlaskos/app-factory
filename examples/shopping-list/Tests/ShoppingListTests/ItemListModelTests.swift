import Testing
import SwiftData
@testable import ShoppingList

@MainActor
struct ItemListModelTests {
    // Container held as a property so it outlives each test (see ItemStoreTests).
    let container: ModelContainer
    let model: ItemListModel

    init() throws {
        container = try ModelContainer(
            for: Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        model = ItemListModel(store: SwiftDataItemStore(context: container.mainContext))
    }

    @Test("AC-1: add surfaces the item in the view model")
    func addShows() {
        model.add("Bread")
        #expect(model.items.map(\.title) == ["Bread"])
    }

    @Test("AC-1: a blank add sets an error and adds nothing")
    func blankAddErrors() {
        model.add("   ")
        #expect(model.items.isEmpty)
        #expect(model.errorMessage != nil)
    }

    @Test("AC-2: toggling updates the model’s ordering")
    func toggleReorders() {
        model.add("A")
        model.add("B")
        model.toggle(model.items[0])
        #expect(model.items.last?.isDone == true)
    }
}
