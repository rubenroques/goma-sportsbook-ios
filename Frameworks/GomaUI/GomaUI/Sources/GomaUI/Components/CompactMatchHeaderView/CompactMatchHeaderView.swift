import UIKit
import Combine
import SwiftUI

/// Compact header for inline match cards
/// Displays date/time or LIVE badge on left, icons + market count on right
final public class CompactMatchHeaderView: UIView {

    // MARK: - UI Components
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()

    // Left side
    private lazy var leftStackView: UIStackView = Self.createLeftStackView()
    private lazy var liveBadge: UIView = Self.createLiveBadge()
    private lazy var liveBadgeLabel: UILabel = Self.createLiveBadgeLabel()
    private lazy var statusLabel: UILabel = Self.createStatusLabel()

    // Right side
    private lazy var rightStackView: UIStackView = Self.createRightStackView()
    private lazy var iconsStackView: UIStackView = Self.createIconsStackView()
    private lazy var marketCountLabel: UILabel = Self.createMarketCountLabel()
    private lazy var arrowImageView: UIImageView = Self.createArrowImageView()

    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: CompactMatchHeaderViewModelProtocol?
    private var iconImageViews: [UIImageView] = []

    // MARK: - Public Callbacks
    public var onMarketCountTapped: (() -> Void) = {}

    // MARK: - Initialization
    public init(viewModel: CompactMatchHeaderViewModelProtocol? = nil) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()

        if let viewModel = viewModel {
            configureImmediately(with: viewModel)
            setupBindings()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    /// Configures the view with a new view model for efficient reuse
    public func configure(with newViewModel: CompactMatchHeaderViewModelProtocol?) {
        cancellables.removeAll()
        self.viewModel = newViewModel

        if let viewModel = newViewModel {
            configureImmediately(with: viewModel)
            setupBindings()
        }
    }

    /// Prepare for reuse in table/collection view cells
    public func cleanupForReuse() {
        cancellables.removeAll()
        clearIcons()
    }

    // MARK: - Private Configuration
    private func configureImmediately(with viewModel: CompactMatchHeaderViewModelProtocol) {
        render(state: viewModel.currentDisplayState)
    }

    private func clearIcons() {
        iconImageViews.forEach { $0.removeFromSuperview() }
        iconImageViews.removeAll()
    }
}

// MARK: - ViewCode
extension CompactMatchHeaderView {
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }

    private func buildViewHierarchy() {
        addSubview(containerStackView)

        // Left side: LIVE badge or date/time
        liveBadge.addSubview(liveBadgeLabel)
        leftStackView.addArrangedSubview(liveBadge)
        leftStackView.addArrangedSubview(statusLabel)

        // Right side: icons + market count + arrow
        rightStackView.addArrangedSubview(iconsStackView)
        rightStackView.addArrangedSubview(marketCountLabel)
        rightStackView.addArrangedSubview(arrowImageView)

        containerStackView.addArrangedSubview(leftStackView)
        containerStackView.addArrangedSubview(rightStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // LIVE badge internal constraints
            liveBadgeLabel.topAnchor.constraint(equalTo: liveBadge.topAnchor, constant: 2),
            liveBadgeLabel.bottomAnchor.constraint(equalTo: liveBadge.bottomAnchor, constant: -2),
            liveBadgeLabel.leadingAnchor.constraint(equalTo: liveBadge.leadingAnchor, constant: 6),
            liveBadgeLabel.trailingAnchor.constraint(equalTo: liveBadge.trailingAnchor, constant: -6),

            // Arrow size
            arrowImageView.widthAnchor.constraint(equalToConstant: 8),
            arrowImageView.heightAnchor.constraint(equalToConstant: 12)
        ])

        liveBadgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        statusLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Content priorities
        leftStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightStackView.setContentHuggingPriority(.required, for: .horizontal)
        rightStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
    }

    private func setupAdditionalConfiguration() {
        backgroundColor = .clear

        // Market count tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(marketCountAreaTapped))
        rightStackView.addGestureRecognizer(tapGesture)
        rightStackView.isUserInteractionEnabled = true
    }

    @objc private func marketCountAreaTapped() {
        onMarketCountTapped()
        viewModel?.onMarketCountTapped()
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        viewModel.displayStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)
    }

    private func render(state: CompactMatchHeaderDisplayState) {
        // Render left side based on mode
        switch state.mode {
        case .preLive(let dateText):
            liveBadge.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = dateText
            statusLabel.textColor = StyleProvider.Color.highlightPrimary
            statusLabel.font = StyleProvider.fontWith(type: .bold, size: 12)

        case .live(let statusText):
            liveBadge.isHidden = false
            statusLabel.isHidden = false
            statusLabel.text = statusText
            statusLabel.textColor = StyleProvider.Color.highlightPrimary
            statusLabel.font = StyleProvider.fontWith(type: .bold, size: 12)
        }

        // Render icons
        updateIcons(with: state.icons)

        // Render market count
        if let countText = state.marketCountText {
            marketCountLabel.text = countText
            marketCountLabel.isHidden = false
            arrowImageView.isHidden = !state.showMarketCountArrow
        } else {
            marketCountLabel.isHidden = true
            arrowImageView.isHidden = true
        }
    }

    private func updateIcons(with icons: [CompactMatchHeaderIcon]) {
        clearIcons()

        for icon in icons where icon.isVisible {
            let imageView = Self.createIconImageView(iconName: icon.iconName)
            iconsStackView.addArrangedSubview(imageView)
            iconImageViews.append(imageView)
        }

        iconsStackView.isHidden = iconImageViews.isEmpty
    }
}

// MARK: - UI Elements Factory
extension CompactMatchHeaderView {
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }

    private static func createLeftStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 6
        return stackView
    }

    private static func createRightStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }

    private static func createLiveBadge() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.layer.cornerRadius = 4
        view.isHidden = true
        return view
    }

    private static func createLiveBadgeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "LIVE"
        label.font = StyleProvider.fontWith(type: .bold, size: 10)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }

    private static func createStatusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.numberOfLines = 1
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

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18)
        ])

        return imageView
    }

    private static func createMarketCountLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }

    private static func createArrowImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary

        // Use SF Symbol for arrow
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        imageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)

        return imageView
    }
}

// MARK: - Preview Provider
#if DEBUG
@available(iOS 17.0, *)
#Preview("CompactMatchHeaderView States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "CompactMatchHeaderView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 20)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(titleLabel)

        // Pre-live state
        let preLiveLabel = UILabel()
        preLiveLabel.text = "Pre-live:"
        preLiveLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        preLiveLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(preLiveLabel)

        let preLiveHeader = CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.preLiveToday)
        stackView.addArrangedSubview(preLiveHeader)

        // Pre-live with date
        let preLiveDateLabel = UILabel()
        preLiveDateLabel.text = "Pre-live (future date):"
        preLiveDateLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        preLiveDateLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(preLiveDateLabel)

        let preLiveDateHeader = CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.preLiveFutureDate)
        stackView.addArrangedSubview(preLiveDateHeader)

        // Live state
        let liveLabel = UILabel()
        liveLabel.text = "Live (2nd Set):"
        liveLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        liveLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(liveLabel)

        let liveHeader = CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.liveTennis)
        stackView.addArrangedSubview(liveHeader)

        // Live football
        let liveFootballLabel = UILabel()
        liveFootballLabel.text = "Live (45'):"
        liveFootballLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        liveFootballLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(liveFootballLabel)

        let liveFootballHeader = CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.liveFootball)
        stackView.addArrangedSubview(liveFootballHeader)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}
#endif
