import SwiftUI

struct ExpensesView: View {
    let model: BillSplitterModel
    @State private var title = ""
    @State private var amount: Decimal = 0
    @State private var payerID: UUID?

    private var canAdd: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && amount > 0 && payerID != nil
    }

    var body: some View {
        NavigationStack {
            List {
                if model.people.isEmpty {
                    Section {
                        Text("Add people first.").foregroundStyle(.secondary)
                    }
                } else {
                    Section("New expense") {
                        TextField("What for?", text: $title)
                        TextField("Amount", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                        Picker("Paid by", selection: $payerID) {
                            Text("Select…").tag(UUID?.none)
                            ForEach(model.people) { person in
                                Text(person.name).tag(UUID?.some(person.id))
                            }
                        }
                        Button("Add expense", action: add)
                            .disabled(!canAdd)
                    }
                }

                Section("Expenses") {
                    ForEach(model.expenses) { expense in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(expense.title)
                                Text(payerName(expense.payerID))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(Money.string(cents: Money.cents(expense.amount)))
                                .monospacedDigit()
                        }
                    }
                    .onDelete(perform: model.deleteExpenses)
                }
            }
            .navigationTitle("Expenses")
        }
        .errorAlert(model)
    }

    private func add() {
        guard let payerID, canAdd else { return }
        model.addExpense(title: title, amount: amount, payerID: payerID)
        title = ""
        amount = 0
    }

    private func payerName(_ id: UUID) -> String {
        model.people.first { $0.id == id }?.name ?? "—"
    }
}
