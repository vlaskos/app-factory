import SwiftUI
import SwiftData

@main
struct ShoppingListApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Item.self)
    }
}
