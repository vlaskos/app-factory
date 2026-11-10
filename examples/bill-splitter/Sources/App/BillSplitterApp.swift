import SwiftUI
import SwiftData

@main
struct BillSplitterApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Person.self, Expense.self])
    }
}
