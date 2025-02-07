//
//  CashbackInfoView.swift
//  Sportsbook
//
//  Created by André Lascas on 26/06/2023.
//

import UIKit
import SwiftUI

class CashbackInfoView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()

    var didTapInfoAction: (() -> Void) = { }

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.headerInput
    }

    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false

        let infoTap = UITapGestureRecognizer(target: self, action: #selector(self.tapInfo))
        self.containerView.addGestureRecognizer(infoTap)
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.highlightSecondary
        self.titleLabel.textColor = UIColor.App.buttonTextPrimary
        self.iconImageView.backgroundColor = .clear
    }

    @objc private func tapInfo() {
        self.didTapInfoAction()
    }
}

extension CashbackInfoView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("cashback")
        label.font = AppFont.with(type: .bold, size: 11)
        label.numberOfLines = 0
        return label
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "info_small_icon")
        imageView.contentMode = .center
        return imageView
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.iconImageView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 5),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 4),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -4),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 1),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.iconImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 11),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor)
        ])

    }

}

#if DEBUG
// MARK: - Preview
@available(iOS 17.0, *)
#Preview("CashbackInfoView") {
    // Create container view with auto layout
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false

    // Create CashbackInfoView
    let cashbackView = CashbackInfoView()
    cashbackView.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(cashbackView)

    // Setup constraints to show a reasonable preview size
    NSLayoutConstraint.activate([
        cashbackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
        cashbackView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
        cashbackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
        container.heightAnchor.constraint(equalToConstant: 100),
        container.widthAnchor.constraint(equalToConstant: 200)
    ])

    // Add tap action for testing
    cashbackView.didTapInfoAction = {
        print("Info tapped in preview")
    }

    return container
}
#endif

// MARK: - SwiftUI Implementation
enum ToolTipType {
    case info
    case error
    case warning
    case success

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

class SmallToolTipViewModel: ObservableObject {
    @Published var text: String
    @Published var type: ToolTipType
    var onTap: () -> Void

    init(text: String, type: ToolTipType = .info, onTap: @escaping () -> Void = {}) {
        self.text = text
        self.type = type
        self.onTap = onTap
    }
}

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
