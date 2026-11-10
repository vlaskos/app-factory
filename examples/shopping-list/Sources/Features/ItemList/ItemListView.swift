import SwiftUI

struct ItemListView: View {
    @State private var model: ItemListModel
    @State private var newTitle = ""

    init(store: ItemStore) {
        _model = State(initialValue: ItemListModel(store: store))
    }

    private var canAdd: Bool {
        !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: DesignTokens.spacing2) {
                    TextField("Add an item", text: $newTitle)
                        .onSubmit(addItem)
                    Button("Add", action: addItem)
                        .disabled(!canAdd)
                }
            }

            ForEach(model.items) { item in
                Button {
                    model.toggle(item)
                } label: {
                    Label(item.title, systemImage: item.isDone ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.isDone ? DesignTokens.doneForeground : .primary)
                }
                .accessibilityLabel(item.title)
                .accessibilityValue(item.isDone ? "done" : "not done")
            }
            .onDelete(perform: model.delete)
        }
        .navigationTitle("Shopping List")
        .overlay {
            if model.items.isEmpty {
                ContentUnavailableView(
                    "No items yet",
                    systemImage: "cart",
                    description: Text("Add something above to get started.")
                )
            }
        }
        .onAppear(perform: model.load)
        .alert(
            "Couldn’t save",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.clearError() } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }

    private func addItem() {
        guard canAdd else { return }
        model.add(newTitle)
        newTitle = ""
    }
}
