import SwiftUI

enum CalcKey: Hashable {
    case digit(Int)
    case decimalPoint
    case op(Operator)
    case equals
    case clear
}

struct CalculatorView: View {
    @State private var model = CalculatorModel()

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: DesignTokens.spacing1),
        count: 4
    )
    private let keys: [CalcKey] = [
        .clear, .op(.divide), .op(.multiply), .op(.subtract),
        .digit(7), .digit(8), .digit(9), .op(.add),
        .digit(4), .digit(5), .digit(6), .equals,
        .digit(1), .digit(2), .digit(3), .decimalPoint,
        .digit(0),
    ]

    var body: some View {
        VStack(spacing: DesignTokens.spacing3) {
            Spacer()
            Text(model.display)
                .font(.system(size: 64, weight: .light, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(model.hasError ? Color.red : Color.primary)
                .accessibilityLabel("Display")
                .accessibilityValue(model.display)

            LazyVGrid(columns: columns, spacing: DesignTokens.spacing1) {
                ForEach(keys, id: \.self) { key in
                    Button {
                        handle(key)
                    } label: {
                        Text(title(key))
                            .font(.title2)
                            .frame(maxWidth: .infinity, minHeight: 64)
                    }
                    .buttonStyle(.bordered)
                    .tint(tint(key))
                    .accessibilityLabel(title(key))
                }
            }
        }
        .padding(DesignTokens.spacing2)
    }

    private func title(_ key: CalcKey) -> String {
        switch key {
        case .digit(let digit): return String(digit)
        case .decimalPoint: return "."
        case .op(let op): return String(op.rawValue)
        case .equals: return "="
        case .clear: return "C"
        }
    }

    private func tint(_ key: CalcKey) -> Color {
        switch key {
        case .op, .equals: return .accentColor
        case .clear: return .red
        default: return .secondary
        }
    }

    private func handle(_ key: CalcKey) {
        switch key {
        case .digit(let digit): model.tapDigit(digit)
        case .decimalPoint: model.tapDecimalPoint()
        case .op(let op): model.tapOperator(op)
        case .equals: model.tapEquals()
        case .clear: model.clear()
        }
    }
}
