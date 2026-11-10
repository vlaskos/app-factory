import Testing
import Foundation
@testable import BillSplitter

struct BalanceCalculatorTests {
    let a = UUID(), b = UUID(), c = UUID()

    @Test("AC-1: even split charges the payer their own share back")
    func evenSplit() {
        let net = BalanceCalculator.net(
            people: [a, b, c],
            charges: [.init(payer: a, amountCents: 3000)]   // 30.00 paid by a
        )
        #expect(net[a] == 2000)   // paid 3000, owes 1000 share
        #expect(net[b] == -1000)
        #expect(net[c] == -1000)
    }

    @Test("AC-2: every balance set nets to exactly zero")
    func netsToZero() {
        let net = BalanceCalculator.net(
            people: [a, b, c],
            charges: [
                .init(payer: a, amountCents: 1000),
                .init(payer: b, amountCents: 555),
                .init(payer: c, amountCents: 12_347),
            ]
        )
        #expect(net.values.reduce(0, +) == 0)
    }

    @Test("remainder cents are distributed so shares sum to the charge (10.00 / 3)")
    func remainderDistribution() {
        let net = BalanceCalculator.net(
            people: [a, b, c],
            charges: [.init(payer: a, amountCents: 1000)]   // 334 / 333 / 333
        )
        #expect(net[a] == 666)    // +1000 - 334
        #expect(net[b] == -333)
        #expect(net[c] == -333)
        #expect(net.values.reduce(0, +) == 0)
    }

    @Test("a lone person owes nothing to themselves")
    func singlePerson() {
        let net = BalanceCalculator.net(people: [a], charges: [.init(payer: a, amountCents: 999)])
        #expect(net[a] == 0)
    }

    @Test("no people yields an empty result")
    func noPeople() {
        let net = BalanceCalculator.net(people: [], charges: [.init(payer: a, amountCents: 100)])
        #expect(net.isEmpty)
    }
}
