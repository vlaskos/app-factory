import Foundation
import SwiftData

@Model final class Expense {
    var id: UUID
    var title: String
    var amount: Decimal          // display amount as entered; converted to cents for math
    var payerID: UUID            // references Person.id
    var createdAt: Date

    init(id: UUID = UUID(), title: String, amount: Decimal, payerID: UUID, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.amount = amount
        self.payerID = payerID
        self.createdAt = createdAt
    }
}
