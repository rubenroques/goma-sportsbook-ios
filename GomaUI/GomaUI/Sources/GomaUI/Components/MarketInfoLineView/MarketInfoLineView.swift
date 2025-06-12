import UIKit
import Combine
import SwiftUI

final public class MarketInfoLineView: UIView {
    // MARK: - UI Components
    private lazy var marketNamePillView = Self.createMarketNamePillView()
    private lazy var marketCountLabel = Self.createMarketCountLabel()
    private lazy var iconsStackView = Self.createIconsStackView()

    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: MarketInfoLineViewModelProtocol
    private var iconImageViews: [UIImageView] = []

    // MARK: - Initialization
    public init(viewModel: MarketInfoLineViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    /// Configures the view with a new view model for efficient reuse
    public func configure(with newViewModel: MarketInfoLineViewModelProtocol) {
        // Clear previous bindings
        cancellables.removeAll()
        
        // Update view model reference
        self.viewModel = newViewModel
        
        // Re-establish bindings with new view model
        setupBindings()
    }
}

// MARK: - ViewCode
extension MarketInfoLineView {
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }

    private func buildViewHierarchy() {
        addSubview(marketNamePillView)
        addSubview(iconsStackView)
        addSubview(marketCountLabel)
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 17),

            // Market Name Pill - Left side, vertically centered
            marketNamePillView.heightAnchor.constraint(equalToConstant: 17),
            marketNamePillView.leadingAnchor.constraint(equalTo: leadingAnchor),
            marketNamePillView.centerYAnchor.constraint(equalTo: centerYAnchor),
            marketNamePillView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            marketNamePillView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),

            // Market Count Label - Far right, vertically centered
            marketCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            marketCountLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            marketCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            // Icons Stack View - Between pill and count, vertically centered
            iconsStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            iconsStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),            
            iconsStackView.trailingAnchor.constraint(equalTo: marketCountLabel.leadingAnchor, constant: -4),

            // Minimum 10px spacing between pill and icons
            iconsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: marketNamePillView.trailingAnchor, constant: 16)
        ])

        // Set constraint priorities for proper text truncation
        marketNamePillView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        marketNamePillView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        iconsStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconsStackView.setContentHuggingPriority(.required, for: .horizontal)

        marketCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        marketCountLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func setupAdditionalConfiguration() {
        backgroundColor = .clear
    }

    private func setupBindings() {
        // Bind to display state
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)

        // Bind market name pill view model
        viewModel.marketNamePillViewModelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pillViewModel in
                self?.updateMarketNamePill(with: pillViewModel)
            }
            .store(in: &cancellables)
    }

    private func render(state: MarketInfoLineDisplayState) {
        // Update market count label
        marketCountLabel.text = state.marketCountText
        marketCountLabel.isHidden = !state.shouldShowMarketCount

        // Update icons
        updateIcons(with: state.visibleIcons)
    }

    private func updateMarketNamePill(with viewModel: MarketNamePillLabelViewModelProtocol) {
        // Remove existing pill view
        marketNamePillView.removeFromSuperview()

        // Create new pill view with updated view model
        marketNamePillView = MarketNamePillLabelView(viewModel: viewModel)
        marketNamePillView.translatesAutoresizingMaskIntoConstraints = false

        // Re-add to view and re-setup constraints
        addSubview(marketNamePillView)
        setupConstraints()

        // Set proper priorities for text truncation
        marketNamePillView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        marketNamePillView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    private func updateIcons(with icons: [MarketInfoIcon]) {
        // Remove existing icon views
        iconImageViews.forEach { $0.removeFromSuperview() }
        iconImageViews.removeAll()

        // Add new icon views
        for icon in icons where icon.isVisible {
            let iconImageView = Self.createIconImageView(iconName: icon.iconName)
            iconsStackView.addArrangedSubview(iconImageView)
            iconImageViews.append(iconImageView)
        }
    }
}

// MARK: - UI Elements Factory
extension MarketInfoLineView {
    private static func createMarketNamePillView() -> UIView {
        // This will be replaced with actual MarketNamePillLabelView in updateMarketNamePill
        let placeholder = UIView()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        return placeholder
    }

    private static func createMarketCountLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }

    private static func createIconsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }

    private static func createIconImageView(iconName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: iconName, in: Bundle.module, compatibleWith: nil)

        // Set fixed size for icons
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 15)
        ])

        return imageView
    }
}

// MARK: - Preview Provider
#if DEBUG
@available(iOS 17.0, *)
#Preview("Default") {
    PreviewUIView {
        MarketInfoLineView(viewModel: MockMarketInfoLineViewModel.defaultMock)
    }
    .frame(height: 40)
    .padding(.horizontal, 16)
}

@available(iOS 17.0, *)
#Preview("Many Icons") {
    PreviewUIView {
        MarketInfoLineView(viewModel: MockMarketInfoLineViewModel.manyIconsMock)
    }
    .frame(height: 40)
    .padding(.horizontal, 16)
}

@available(iOS 17.0, *)
#Preview("Long Market Name") {
    PreviewUIView {
        MarketInfoLineView(viewModel: MockMarketInfoLineViewModel.longMarketNameMock)
    }
    .frame(height: 40)
    .padding(.horizontal, 16)
}
#endif
