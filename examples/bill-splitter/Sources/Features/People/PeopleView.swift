import SwiftUI

struct PeopleView: View {
    let model: BillSplitterModel
    @State private var newName = ""

    private var canAdd: Bool {
        !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: DesignTokens.spacing2) {
                        TextField("Add a person", text: $newName)
                            .onSubmit(add)
                        Button("Add", action: add)
                            .disabled(!canAdd)
                    }
                }
                ForEach(model.people) { person in
                    Text(person.name)
                }
                .onDelete(perform: model.deletePeople)
            }
            .navigationTitle("People")
            .overlay {
                if model.people.isEmpty {
                    ContentUnavailableView(
                        "No people yet",
                        systemImage: "person.2",
                        description: Text("Add everyone who’s splitting the bill.")
                    )
                }
            }
        }
        .errorAlert(model)
    }

    private func add() {
        guard canAdd else { return }
        model.addPerson(newName)
        newName = ""
    }
}
