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
#Preview("MarketInfoLineView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "MarketInfoLineView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Default
        let defaultView = MarketInfoLineView(viewModel: MockMarketInfoLineViewModel.defaultMock)
        defaultView.translatesAutoresizingMaskIntoConstraints = false

        // Many Icons
        let manyIconsView = MarketInfoLineView(viewModel: MockMarketInfoLineViewModel.manyIconsMock)
        manyIconsView.translatesAutoresizingMaskIntoConstraints = false

        // Long Market Name
        let longNameView = MarketInfoLineView(viewModel: MockMarketInfoLineViewModel.longMarketNameMock)
        longNameView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(manyIconsView)
        stackView.addArrangedSubview(longNameView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),

            // Fixed heights
            defaultView.heightAnchor.constraint(equalToConstant: 40),
            manyIconsView.heightAnchor.constraint(equalToConstant: 40),
            longNameView.heightAnchor.constraint(equalToConstant: 40)
        ])

        return vc
    }
}
#endif
