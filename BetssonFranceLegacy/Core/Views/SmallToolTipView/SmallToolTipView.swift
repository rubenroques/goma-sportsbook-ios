import Foundation
import UIKit
import SwiftUI

@available(iOS 14.0, *)
struct SmallToolTipView: View {
    @StateObject private var viewModel: SmallToolTipViewModel

    init(viewModel: SmallToolTipViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Button(action: viewModel.onTap) {
            HStack(spacing: 1) {
                Text(viewModel.text)
                    .font(.appFont(type: .bold, size: 11))
                    .foregroundColor(viewModel.type.textColor)
                    .lineLimit(1)

                Image(systemName: viewModel.type.icon)
                    .font(.appFont(type: .bold, size: 11))
                    .foregroundColor(viewModel.type.textColor)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(viewModel.type.backgroundColor)
            .clipShape(Capsule())
        }
    }
}

// MARK: - UIKit Integration
@available(iOS 14.0, *)
extension SmallToolTipView {
    func asUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        hostingController.view.backgroundColor = .clear
        return hostingController.view
    }
}

@available(iOS 14.0, *)
extension SmallToolTipViewModel.ToolTipType {

    var icon: String {
        switch self {
        case .info: return "info.circle"
        case .error: return "exclamationmark.circle"
        case .warning: return "exclamationmark.triangle"
        case .success: return "checkmark.circle"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .info: return Color(UIColor.App.highlightSecondary)
        case .error: return Color(UIColor.systemRed)
        case .warning: return Color(UIColor.systemYellow)
        case .success: return Color(UIColor.systemGreen)
        }
    }

    var textColor: Color {
        return Color(UIColor.App.buttonTextPrimary)
    }

}

// MARK: - SwiftUI Previews
#if DEBUG
@available(iOS 17.0, *)
#Preview("SmallToolTipView - All States") {
    VStack(spacing: 20) {
        SmallToolTipView(viewModel: SmallToolTipViewModel(
            text: "Info Message",
            type: .info,
            onTap: { print("Info tapped") }
        ))

        SmallToolTipView(viewModel: SmallToolTipViewModel(
            text: "Error Message",
            type: .error,
            onTap: { print("Error tapped") }
        ))

        SmallToolTipView(viewModel: SmallToolTipViewModel(
            text: "Warning Message",
            type: .warning,
            onTap: { print("Warning tapped") }
        ))

        SmallToolTipView(viewModel: SmallToolTipViewModel(
            text: "Success Message",
            type: .success,
            onTap: { print("Success tapped") }
        ))
    }
    .padding()
    .background(Color(.systemBackground))
}

// Example of UIKit integration preview
@available(iOS 17.0, *)
#Preview("SmallToolTipView - In UIKit") {
    let toolTipView = SmallToolTipView(viewModel: SmallToolTipViewModel(
        text: "Info in UIKit",
        type: .info,
        onTap: { print("UIKit integration tapped") }
    ))

    let uiView = UIView()
    uiView.backgroundColor = .systemBackground

    let hostingView = toolTipView.asUIView()
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    uiView.addSubview(hostingView)

    NSLayoutConstraint.activate([
        hostingView.centerXAnchor.constraint(equalTo: uiView.centerXAnchor),
        hostingView.centerYAnchor.constraint(equalTo: uiView.centerYAnchor)
    ])

    return uiView
}

@available(iOS 17.0, *)
#Preview("Comparison - UIKit vs SwiftUI") {
    // Create container view
    let container = UIView()
    container.backgroundColor = .systemBackground

    // Create UIKit version
    let cashbackView = CashbackInfoView()
    cashbackView.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(cashbackView)

    // Create SwiftUI version
    let toolTipView = SmallToolTipView(viewModel: SmallToolTipViewModel(
        text: "Cashback",
        type: .info,
        onTap: { print("SwiftUI version tapped") }
    ))
    let hostingView = toolTipView.asUIView()
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(hostingView)

    // Add labels
    let uikitLabel = UILabel()
    uikitLabel.text = "UIKit Version"
    uikitLabel.font = .systemFont(ofSize: 12)
    uikitLabel.textColor = .gray
    uikitLabel.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(uikitLabel)

    let swiftUILabel = UILabel()
    swiftUILabel.text = "SwiftUI Version"
    swiftUILabel.font = .systemFont(ofSize: 12)
    swiftUILabel.textColor = .gray
    swiftUILabel.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(swiftUILabel)

    // Setup constraints
    NSLayoutConstraint.activate([
        // UIKit label
        uikitLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
        uikitLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),

        // UIKit view
        cashbackView.topAnchor.constraint(equalTo: uikitLabel.bottomAnchor, constant: 8),
        cashbackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),

        // SwiftUI label
        swiftUILabel.topAnchor.constraint(equalTo: cashbackView.bottomAnchor, constant: 20),
        swiftUILabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),

        // SwiftUI view
        hostingView.topAnchor.constraint(equalTo: swiftUILabel.bottomAnchor, constant: 8),
        hostingView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),

        // Container size
        container.heightAnchor.constraint(equalToConstant: 160)
    ])

    return container
}
#endif
