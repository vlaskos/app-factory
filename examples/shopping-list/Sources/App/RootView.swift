import SwiftUI
import SwiftData

/// Composition root: owns navigation and wires the SwiftData-backed store into the feature.
struct RootView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            ItemListView(store: SwiftDataItemStore(context: context))
        }
    }
}
