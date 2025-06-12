import UIKit
import Combine

public class MarketGroupTabItemView: UIView {

    // MARK: - Private Properties
    private let viewModel: MarketGroupTabItemViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let underlineView = UIView()

    // MARK: - Layout Constants
    private struct Constants {
        static let horizontalPadding: CGFloat = 16.0
        static let verticalPadding: CGFloat = 2.0
        static let underlineHeight: CGFloat = 2.0
        static let animationDuration: TimeInterval = 0.2
        static let minimumHeight: CGFloat = 42.0
    }

    // MARK: - Initialization
    public init(viewModel: MarketGroupTabItemViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(underlineView)

        self.backgroundColor = StyleProvider.Color.backgroundPrimary
        containerView.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        // Container view setup
        containerView.clipsToBounds = true

        // Title label setup
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        
        // Underline view setup
        underlineView.isHidden = true
        underlineView.layer.cornerRadius = Constants.underlineHeight / 2
    }

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        underlineView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumHeight),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.horizontalPadding),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: underlineView.topAnchor),

            // Underline view constraints
            underlineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            underlineView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            underlineView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            underlineView.heightAnchor.constraint(equalToConstant: Constants.underlineHeight)
        ])
    }

    private func setupBindings() {
        // Title binding
        viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &cancellables)

        // Visual state binding
        viewModel.visualStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] visualState in
                self?.updateVisualState(visualState)
            }
            .store(in: &cancellables)
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    // MARK: - Action Handlers
    @objc private func handleTap() {
        viewModel.handleTap()

        // Add haptic feedback for better UX
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    // MARK: - State Updates
    private func updateVisualState(_ visualState: MarketGroupTabItemVisualState) {
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: [.curveEaseInOut]) {
            self.applyVisualState(visualState)
        }
    }

    private func applyVisualState(_ visualState: MarketGroupTabItemVisualState) {
        switch visualState {
        case .idle:
            applyIdleState()
        case .selected:
            applySelectedState()
        case .disabled:
            applyDisabledState()
        }
    }

    private func applyIdleState() {
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        underlineView.isHidden = true
        underlineView.backgroundColor = .clear
        isUserInteractionEnabled = true
        alpha = 1.0
    }

    private func applySelectedState() {
        titleLabel.textColor = StyleProvider.Color.highlightPrimary
        titleLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        underlineView.isHidden = false
        underlineView.backgroundColor = StyleProvider.Color.highlightPrimary
        isUserInteractionEnabled = true
        alpha = 1.0
    }

    private func applyDisabledState() {
        titleLabel.textColor = StyleProvider.Color.textPrimary.withAlphaComponent(0.5)
        titleLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        underlineView.isHidden = true
        underlineView.backgroundColor = .clear
        isUserInteractionEnabled = false
        alpha = 0.6
    }

}

// MARK: - Intrinsic Content Size
extension MarketGroupTabItemView {
    public override var intrinsicContentSize: CGSize {
        let titleSize = titleLabel.intrinsicContentSize
        return CGSize(
            width: titleSize.width + (Constants.horizontalPadding * 2),
            height: Constants.minimumHeight
        )
    }
}

// MARK: - Preview Provider
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("1x2 Tab - Selected") {
    PreviewUIView {
        MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.oneXTwoTab)
    }
    .frame(height: 50)
    .padding()
    .background(Color(UIColor.systemBackground))
}

@available(iOS 17.0, *)
#Preview("Double Chance Tab - Idle") {
    PreviewUIView {
        MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.doubleChanceTab)
    }
    .frame(height: 50)
    .padding()
    .background(Color(UIColor.systemBackground))
}

@available(iOS 17.0, *)
#Preview("Disabled Tab") {
    PreviewUIView {
        MarketGroupTabItemView(viewModel: MockMarketGroupTabItemViewModel.disabledTab)
    }
    .frame(height: 50)
    .padding()
    .background(Color(UIColor.systemBackground))
}

@available(iOS 17.0, *)
#Preview("Multiple Tabs Layout") {
    PreviewUIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill

        let tabs = [
            ("1x2", true),
            ("Double Chance", false),
            ("Over/Under", false)
        ]

        for (title, selected) in tabs {
            let tabView = MarketGroupTabItemView(
                viewModel: MockMarketGroupTabItemViewModel.customTab(
                    id: title.lowercased().replacingOccurrences(of: "/", with: "_"),
                    title: title,
                    selected: selected
                )
            )
            stackView.addArrangedSubview(tabView)
        }

        return stackView
    }
    .frame(height: 50)
    .padding()
    .background(Color(UIColor.systemBackground))
}

#endif
