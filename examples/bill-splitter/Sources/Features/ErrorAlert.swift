import SwiftUI

extension View {
    /// Presents `model.errorMessage` as a dismissible alert.
    func errorAlert(_ model: BillSplitterModel) -> some View {
        alert(
            "Something went wrong",
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
}
