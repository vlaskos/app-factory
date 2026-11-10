import SwiftUI
import SwiftData

/// Composition root: builds the shared view model from the environment's SwiftData
/// context and hands it to the three tabs. Built lazily in `.task` because the
/// environment context isn't available in `init`.
struct RootView: View {
    @Environment(\.modelContext) private var context
    @State private var model: BillSplitterModel?

    var body: some View {
        Group {
            if let model {
                TabView {
                    PeopleView(model: model)
                        .tabItem { Label("People", systemImage: "person.2") }
                    ExpensesView(model: model)
                        .tabItem { Label("Expenses", systemImage: "list.bullet.rectangle") }
                    BalancesView(model: model)
                        .tabItem { Label("Balances", systemImage: "equal.circle") }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            guard model == nil else { return }
            let m = BillSplitterModel(store: SwiftDataBillStore(context: context))
            m.load()
            model = m
        }
    }
}
