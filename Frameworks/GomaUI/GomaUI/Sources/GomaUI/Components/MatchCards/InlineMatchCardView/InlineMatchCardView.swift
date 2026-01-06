import UIKit
import Combine
import SwiftUI

/// Inline match card component for compact event display
/// Replaces TallOddsMatchCardView with a more compact layout
final public class InlineMatchCardView: UIView {

    // MARK: - UI Components
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()

    // Header
    private lazy var headerView: CompactMatchHeaderView = Self.createHeaderView()

    // Content row (participants + outcomes)
    private lazy var contentStackView: UIStackView = Self.createContentStackView()

    // Left side: Participants + Score
    private lazy var participantsContainer: UIView = Self.createParticipantsContainer()
    private lazy var participantsStackView: UIStackView = Self.createParticipantsStackView()
    private lazy var homeParticipantLabel: UILabel = Self.createParticipantLabel()
    private lazy var awayParticipantLabel: UILabel = Self.createParticipantLabel()
    private lazy var scoreView: InlineScoreView = Self.createScoreView()

    // Right side: Outcomes
    private lazy var outcomesView: CompactOutcomesLineView = Self.createOutcomesView()

    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: InlineMatchCardViewModelProtocol?

    // MARK: - Public Callbacks
    public var onCardTapped: (() -> Void) = {}
    public var onOutcomeSelected: ((String) -> Void) = { _ in }
    public var onOutcomeDeselected: ((String) -> Void) = { _ in }
    public var onMoreMarketsTapped: (() -> Void) = {}

    // MARK: - Constants
    private enum Constants {
        static let containerSpacing: CGFloat = 4.0
        static let contentSpacing: CGFloat = 4.0
        static let participantsSpacing: CGFloat = 1.0
        static let horizontalPadding: CGFloat = 10.0
        static let verticalPadding: CGFloat = 6.0
        static let outcomesLineWidth: CGFloat = 200.0
    }

    // MARK: - Initialization
    public init(viewModel: InlineMatchCardViewModelProtocol? = nil) {
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
    public func configure(with newViewModel: InlineMatchCardViewModelProtocol?) {
        cancellables.removeAll()
        self.viewModel = newViewModel
        resetChildViewsState()

        if let viewModel = newViewModel {
            configureImmediately(with: viewModel)
            setupBindings()
        }
    }

    /// Prepare for reuse in table/collection view cells
    public func prepareForReuse() {
        cancellables.removeAll()
        resetChildViewsState()
    }

    // MARK: - Private Configuration
    private func configureImmediately(with viewModel: InlineMatchCardViewModelProtocol) {
        render(state: viewModel.currentDisplayState)
        updateHeaderView(with: viewModel.currentHeaderViewModel)
        updateOutcomesView(with: viewModel.currentOutcomesViewModel)
        updateScoreView(with: viewModel.currentScoreViewModel)
    }

    private func resetChildViewsState() {
        homeParticipantLabel.text = ""
        awayParticipantLabel.text = ""
        headerView.cleanupForReuse()
        outcomesView.cleanupForReuse()
        scoreView.cleanupForReuse()
    }
}

// MARK: - ViewCode
extension InlineMatchCardView {
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }

    private func buildViewHierarchy() {
        addSubview(containerStackView)

        // Header row
        containerStackView.addArrangedSubview(headerView)

        // Content row
        containerStackView.addArrangedSubview(contentStackView)

        // Participants container (left side)
        participantsContainer.addSubview(participantsStackView)
        participantsContainer.addSubview(scoreView)
        participantsStackView.addArrangedSubview(homeParticipantLabel)
        participantsStackView.addArrangedSubview(awayParticipantLabel)

        // Content row children
        contentStackView.addArrangedSubview(participantsContainer)
        contentStackView.addArrangedSubview(outcomesView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container stack view
            containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding),

            // Participants stack view (left side of container)
            participantsStackView.topAnchor.constraint(equalTo: participantsContainer.topAnchor),
            participantsStackView.leadingAnchor.constraint(equalTo: participantsContainer.leadingAnchor, constant: 0),
            participantsStackView.bottomAnchor.constraint(equalTo: participantsContainer.bottomAnchor),

            // Score view (right side of participants container)
            scoreView.leadingAnchor.constraint(equalTo: participantsStackView.trailingAnchor, constant: 4),
            scoreView.trailingAnchor.constraint(equalTo: participantsContainer.trailingAnchor),
            scoreView.centerYAnchor.constraint(equalTo: participantsContainer.centerYAnchor),

            // Participant label heights
            homeParticipantLabel.heightAnchor.constraint(equalToConstant: 20),
            awayParticipantLabel.heightAnchor.constraint(equalToConstant: 20),

            // Fixed width for outcomes line (consistent for 2 or 3 outcomes)
            outcomesView.widthAnchor.constraint(equalToConstant: Constants.outcomesLineWidth)
        ])

        // Content hugging and compression resistance
        participantsContainer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        participantsContainer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func setupAdditionalConfiguration() {
        backgroundColor = StyleProvider.Color.backgroundCards

        // Card tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true

        // Setup child callbacks
        setupChildCallbacks()
    }

    private func setupChildCallbacks() {
        headerView.onMarketCountTapped = { [weak self] in
            self?.onMoreMarketsTapped()
            self?.viewModel?.onMoreMarketsTapped()
        }

        outcomesView.onOutcomeSelected = { [weak self] outcomeId, _ in
            self?.onOutcomeSelected(outcomeId)
            self?.viewModel?.onOutcomeSelected(outcomeId: outcomeId)
        }

        outcomesView.onOutcomeDeselected = { [weak self] outcomeId, _ in
            self?.onOutcomeDeselected(outcomeId)
            self?.viewModel?.onOutcomeDeselected(outcomeId: outcomeId)
        }
    }

    @objc private func cardTapped() {
        onCardTapped()
        viewModel?.onCardTapped()
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        // Bind to display state
        viewModel.displayStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)

        // Bind child view models
        setupChildViewModelBindings()
    }

    private func setupChildViewModelBindings() {
        guard let viewModel = viewModel else { return }

        // Header view model
        viewModel.headerViewModelPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] headerVM in
                self?.updateHeaderView(with: headerVM)
            }
            .store(in: &cancellables)

        // Outcomes view model
        viewModel.outcomesViewModelPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outcomesVM in
                self?.updateOutcomesView(with: outcomesVM)
            }
            .store(in: &cancellables)

        // Score view model
        viewModel.scoreViewModelPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scoreVM in
                self?.updateScoreView(with: scoreVM)
            }
            .store(in: &cancellables)
    }

    private func render(state: InlineMatchCardDisplayState) {
        homeParticipantLabel.text = state.homeParticipantName
        awayParticipantLabel.text = state.awayParticipantName
        scoreView.isHidden = !state.isLive
    }

    // MARK: - Child View Updates
    private func updateHeaderView(with viewModel: CompactMatchHeaderViewModelProtocol) {
        headerView.configure(with: viewModel)
    }

    private func updateOutcomesView(with viewModel: CompactOutcomesLineViewModelProtocol) {
        outcomesView.configure(with: viewModel)
        // Re-establish callbacks after configure
        setupChildCallbacks()
    }

    private func updateScoreView(with viewModel: InlineScoreViewModelProtocol?) {
        scoreView.configure(with: viewModel)
    }
}

// MARK: - UI Elements Factory
extension InlineMatchCardView {
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Constants.containerSpacing
        return stackView
    }

    private static func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = Constants.contentSpacing
        return stackView
    }

    private static func createHeaderView() -> CompactMatchHeaderView {
        CompactMatchHeaderView()
    }

    private static func createParticipantsContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    private static func createParticipantsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = Constants.participantsSpacing
        return stackView
    }

    private static func createParticipantLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }

    private static func createScoreView() -> InlineScoreView {
        InlineScoreView()
    }

    private static func createOutcomesView() -> CompactOutcomesLineView {
        CompactOutcomesLineView()
    }
}

// MARK: - Preview Provider
#if DEBUG
#Preview("InlineMatchCardView States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "InlineMatchCardView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 20)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(titleLabel)

        // Pre-live football
        let preLiveLabel = UILabel()
        preLiveLabel.text = "Pre-live (Football 1X2):"
        preLiveLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        preLiveLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(preLiveLabel)

        let preLiveCard = InlineMatchCardView(viewModel: MockInlineMatchCardViewModel.preLiveFootball)
        stackView.addArrangedSubview(preLiveCard)

        // Live tennis
        let liveLabel = UILabel()
        liveLabel.text = "Live (Tennis):"
        liveLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        liveLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(liveLabel)

        let liveCard = InlineMatchCardView(viewModel: MockInlineMatchCardViewModel.liveTennis)
        stackView.addArrangedSubview(liveCard)

        // With selection
        let selectedLabel = UILabel()
        selectedLabel.text = "With selected outcome:"
        selectedLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        selectedLabel.textColor = StyleProvider.Color.textSecondary
        stackView.addArrangedSubview(selectedLabel)

        let selectedCard = InlineMatchCardView(viewModel: MockInlineMatchCardViewModel.withSelectedOutcome)
        stackView.addArrangedSubview(selectedCard)

        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        return vc
    }
}
#endif
