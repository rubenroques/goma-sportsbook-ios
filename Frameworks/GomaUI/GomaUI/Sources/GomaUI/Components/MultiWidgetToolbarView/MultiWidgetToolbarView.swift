//
//  MultiWidgetToolbarView.swift
//  GomaUI
//

import UIKit
import Combine
import SwiftUI

final public class MultiWidgetToolbarView: UIView {

    // MARK: - Private Properties
    private let linesContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 14
        return stackView
    }()

    private let viewModel: MultiWidgetToolbarViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Properties
    public var onWidgetSelected: ((String) -> Void) = { _ in }
    public var onBalanceTapped: ((String) -> Void) = { _ in }

    // MARK: - Initialization
    public init(viewModel: MultiWidgetToolbarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false

        setupSubviews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupSubviews() {
        self.backgroundColor = StyleProvider.Color.topBarGradient1

        self.linesContainerStackView.backgroundColor = StyleProvider.Color.topBarGradient1

        self.addSubview(self.linesContainerStackView)
        NSLayoutConstraint.activate([
            self.linesContainerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            self.linesContainerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            self.linesContainerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            self.linesContainerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }

    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &self.cancellables)
    }

    // MARK: - Rendering
    private func render(state: MultiWidgetToolbarDisplayState) {
        // Clear existing content
        self.linesContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add lines of widgets
        for lineData in state.lines {
            let lineStackView = self.createLineStackView(for: lineData.mode)

            // Add widgets to line
            for widgetData in lineData.widgets {
                let widgetView = self.createWidgetView(for: widgetData.widget)

                // Configure different types of widgets
                switch widgetData.widget.type {
                case .space:
                    widgetView.setContentHuggingPriority(.defaultLow, for: .horizontal)
                    widgetView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                default:
                    if lineData.mode == .flex {
                        widgetView.setContentHuggingPriority(.required, for: .horizontal)
                        widgetView.setContentCompressionResistancePriority(.required, for: .horizontal)
                    }
                }

                lineStackView.addArrangedSubview(widgetView)
            }

            self.linesContainerStackView.addArrangedSubview(lineStackView)
        }
    }

    // MARK: - Factory Methods
    private func createLineStackView(for mode: LayoutMode) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6

        switch mode {
        case .flex:
            stackView.distribution = .fill
        case .split:
            stackView.distribution = .fillEqually
            stackView.spacing = 12  // Add more spacing for buttons in split mode
        }
        stackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return stackView
    }

    private func createWidgetView(for widget: Widget) -> UIView {
        switch widget.type {
        case .image:
            return createImageWidget(widget)
        case .wallet:
            return createWalletWidget(widget)
        case .avatar:
            return createAvatarWidget(widget)
        case .support:
            return createSupportWidget(widget)
        case .languageSwitcher:
            return createLanguageSwitcherWidget(widget)
        case .button:
            return createButtonWidget(widget)
        case .signUpButton:
            return createSignUpButtonWidget(widget)
        case .loginButton:
            return createLoginButtonWidget(widget)
        case .space:
            return createSpaceWidget()
        }
    }

    private func createImageWidget(_ widget: Widget) -> UIView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default_brand_horizontal", in: Bundle.module, with: nil) ?? UIImage()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.contrastTextColor

        // Set fixed height, let width grow to maintain aspect ratio
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 32)
        ])

        return imageView
    }

    private func createWalletWidget(_ widget: Widget) -> UIView {
        let walletData = WalletWidgetData(
            id: widget.id,
            balance: "2,000.01",
            depositButtonTitle: "DEPOSIT"
        )
        let viewModel = MockWalletWidgetViewModel(walletData: walletData)
        let walletView = WalletWidgetView(viewModel: viewModel)
        walletView.onDepositTapped = { [weak self] widgetID in
            self?.viewModel.selectWidget(id: widgetID)
            self?.onWidgetSelected(widgetID)
        }
        walletView.onBalanceTapped = { [weak self] widgetID in
            self?.onBalanceTapped(widgetID)
        }
        return walletView
    }

    private func createAvatarWidget(_ widget: Widget) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.09)
        view.layer.cornerRadius = 16

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "generic_user_profile_icon", in: Bundle.module, with: nil)
        imageView.tintColor = StyleProvider.Color.contrastTextColor
        imageView.contentMode = .scaleAspectFit

        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 22),
            imageView.widthAnchor.constraint(equalToConstant: 22),

            view.heightAnchor.constraint(equalToConstant: 32),
            view.widthAnchor.constraint(equalToConstant: 32)
        ])
        
        // Add tap gesture
        view.accessibilityIdentifier = widget.id
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)

        return view
    }

    private func createSupportWidget(_ widget: Widget) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.09)
        view.layer.cornerRadius = 16

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "support_question", in: Bundle.module, with: nil)?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = StyleProvider.Color.allWhite
        imageView.contentMode = .scaleAspectFit

        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            imageView.heightAnchor.constraint(equalToConstant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 20),

            view.heightAnchor.constraint(equalToConstant: 32),
            view.widthAnchor.constraint(equalToConstant: 32)
        ])

        return view

    }
    private func createLanguageSwitcherWidget(_ widget: Widget) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.09)
        view.layer.cornerRadius = 16

        let label = UILabel()
        label.text = "EN"
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.allWhite
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            view.heightAnchor.constraint(equalToConstant: 32),
            view.widthAnchor.constraint(equalToConstant: 32)
        ])

        return view
    }

    private func createButtonWidget(_ widget: Widget) -> UIView {
        return createStyledButton(
            title: widget.label?.uppercased(),
            backgroundColor: .clear,
            titleColor: StyleProvider.Color.buttonTextSecondary,
            borderColor: nil
        )
    }

    private func createSignUpButtonWidget(_ widget: Widget) -> UIView {
        let registerButton = createStyledButton(
            title: widget.label?.uppercased(),
            backgroundColor: StyleProvider.Color.buttonBackgroundPrimary,
            titleColor: StyleProvider.Color.buttonTextPrimary,
            borderColor: nil
        )
        
        registerButton.accessibilityIdentifier = widget.id
        registerButton.addTarget(self, action: #selector(widgetTapped), for: .primaryActionTriggered)
        
        return registerButton
    }

    private func createLoginButtonWidget(_ widget: Widget) -> UIView {
        let loginButton = createStyledButton(
            title: widget.label?.uppercased(),
            backgroundColor: .clear,
            titleColor: StyleProvider.Color.buttonTextSecondary,
            borderColor: StyleProvider.Color.buttonTextSecondary
        )
        
        loginButton.accessibilityIdentifier = widget.id
        loginButton.addTarget(self, action: #selector(widgetTapped), for: .primaryActionTriggered)
        
        return loginButton
    }

    private func createStyledButton(
        title: String?,
        backgroundColor: UIColor,
        titleColor: UIColor,
        borderColor: UIColor?
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 20)
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true

        // Apply border if specified
        if let borderColor = borderColor {
            button.layer.borderWidth = 1
            button.layer.borderColor = borderColor.cgColor
        }

        return button
    }

    private func createSpaceWidget() -> UIView {
        let spacer = UIView()
//        #if DEBUG
//        spacer.backgroundColor = .systemCyan
//        spacer.heightAnchor.constraint(equalToConstant: 5).isActive = true
//        #endif
        return spacer
    }

    // MARK: - Action Handlers
    @objc private func widgetTapped(_ sender: UIButton) {
        guard let widgetID = sender.accessibilityIdentifier else { return }
        viewModel.selectWidget(id: widgetID)
        onWidgetSelected(widgetID)
    }

    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let widgetID = view.accessibilityIdentifier else { return }
        viewModel.selectWidget(id: widgetID)
        onWidgetSelected(widgetID)
    }

    // MARK: - Public Methods
    public func setLoggedInState(_ isLoggedIn: Bool) {
        viewModel.setLayoutState(isLoggedIn ? .loggedIn : .loggedOut)
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Logged In") {

    let numberOfLines: CGFloat = 1
    let heightPerLine: CGFloat = 76
    let previewHeight = (numberOfLines * heightPerLine)

    PreviewUIView {
        let viewModel = MockMultiWidgetToolbarViewModel.defaultMock
        let toolbar = MultiWidgetToolbarView(viewModel: viewModel)

        // Set initial state
        viewModel.setLayoutState(.loggedIn)

        return toolbar
    }
    .frame(height: previewHeight)
}

@available(iOS 17.0, *)
#Preview("Logged Out") {
    let numberOfLines: CGFloat = 2
    let heightPerLine: CGFloat = 56
    let previewHeight = (numberOfLines * heightPerLine)

    PreviewUIView {

        let viewModel = MockMultiWidgetToolbarViewModel.defaultMock
        let toolbar = MultiWidgetToolbarView(viewModel: viewModel)

        // Set initial state
        viewModel.setLayoutState(.loggedOut)

        return toolbar
    }
    .frame(height: 140)
}

#endif
