import SwiftUI

struct BalancesView: View {
    let model: BillSplitterModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(model.balances) { balance in
                    HStack {
                        Text(balance.person.name)
                        Spacer()
                        Text(Money.string(cents: balance.netCents))
                            .foregroundStyle(color(for: balance.netCents))
                            .monospacedDigit()
                    }
                }
            }
            .navigationTitle("Balances")
            .overlay {
                if model.people.isEmpty {
                    ContentUnavailableView(
                        "No balances yet",
                        systemImage: "equal.circle",
                        description: Text("Add people and expenses to see who owes what.")
                    )
                }
            }
        }
    }

    private func color(for cents: Int) -> Color {
        if cents > 0 { return .green }   // owed to them
        if cents < 0 { return .red }     // they owe
        return .secondary
    }
}
