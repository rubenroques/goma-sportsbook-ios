import UIKit
import Combine
import SwiftUI

final public class TallOddsMatchCardView: UIView {

    // MARK: - UI Components
    private lazy var containerView = Self.createContainerView()
    private lazy var contentStackView = Self.createContentStackView()
    private lazy var separatorContainer = Self.createSeparatorContainer()
    private lazy var separatorLine: FadingView = Self.createSeparatorLine()

    // Child components
    private lazy var matchHeaderView = createMatchHeaderView()
    private lazy var participantsContainerView = Self.createParticipantsContainer()
    private lazy var participantsStackView = Self.createParticipantsStackView()

    private lazy var homeParticipantLabel = Self.createParticipantLabel()
    private lazy var awayParticipantLabel = Self.createParticipantLabel()
    private lazy var scoreView = Self.createScoreView()

    private lazy var marketInfoContainer = Self.createMarketInfoContainer()
    private lazy var marketInfoLineView = Self.createMarketInfoLineView()
    private lazy var marketOutcomesView = Self.createMarketOutcomesView()

    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: TallOddsMatchCardViewModelProtocol?

    // MARK: - Public Properties
    public var onMatchHeaderTapped: (() -> Void) = {}
    public var onFavoriteToggled: (() -> Void) = {}
    public var onOutcomeSelected: ((String) -> Void) = { _ in }
    public var onMarketInfoTapped: (() -> Void) = {}
    public var onCardTapped: (() -> Void) = {}

    // MARK: - Private Properties
    private let imageResolver: MatchHeaderImageResolver
    private let customBackgroundColor: UIColor?

    // MARK: - Initialization
    public init(viewModel: TallOddsMatchCardViewModelProtocol? = nil, imageResolver: MatchHeaderImageResolver = DefaultMatchHeaderImageResolver(),
                customBackgroundColor: UIColor? = nil) {
        self.viewModel = viewModel
        self.imageResolver = imageResolver
        self.customBackgroundColor = customBackgroundColor
        super.init(frame: .zero)
        setupSubviews()

        if let viewModel {
            // ✅ CRITICAL: Configure immediately with current data (synchronous for UITableView sizing)
            configureImmediately(with: viewModel)

            // Subscribe to updates for real-time changes (asynchronous)
            setupBindings()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reconfiguration
    /// Configures the view with a new view model for efficient reuse
    /// Pass nil to reset the view to empty state
    public func configure(with newViewModel: TallOddsMatchCardViewModelProtocol?) {
        // Clear previous bindings
        cancellables.removeAll()

        // Update view model reference
        self.viewModel = newViewModel

        // Reset to empty state
        resetChildViewsState()

        // If we have a view model, configure immediately with current data
        if let viewModel = newViewModel {
            // ✅ CRITICAL: Configure immediately with current data (synchronous for UITableView sizing)
            configureImmediately(with: viewModel)

            // Subscribe to updates for real-time changes (asynchronous)
            setupBindings()
        }
    }

    /// Immediately configure the view with current data from view model
    /// This is synchronous and required for proper UITableView automatic dimension calculation
    private func configureImmediately(with viewModel: TallOddsMatchCardViewModelProtocol) {
        // Update display state immediately
        self.render(state: viewModel.currentDisplayState)

        // Update child views immediately with current data
        self.updateMatchHeaderView(with: viewModel.currentMatchHeaderViewModel)
        self.updateMarketInfoLineView(with: viewModel.currentMarketInfoLineViewModel)
        self.updateMarketOutcomesView(with: viewModel.currentMarketOutcomesViewModel)
        self.updateScoreView(with: viewModel.currentScoreViewModel)
    }

    /// Prepares the view for reuse by clearing reactive bindings and resetting state
    public func prepareForReuse() {
        // Cancel all active publishers
        cancellables.removeAll()

        // Reset child views to prevent stale state
        // Note: We don't remove the views from hierarchy, just reset their state
        resetChildViewsState()
    }

    // MARK: - Private Reset Methods
    private func resetChildViewsState() {
        // Reset participant labels
        homeParticipantLabel.text = ""
        awayParticipantLabel.text = ""

        // Reset container view appearance
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary

        // Cleanup MatchHeaderView for reuse (it supports this)
        matchHeaderView.cleanupForReuse()

        // Cleanup ScoreView for reuse
        scoreView.cleanupForReuse()

        // Note: MarketInfoLineView and MarketOutcomesMultiLineView will be reconfigured
        // when new bindings are established using their configure methods
    }
}

// MARK: - ViewCode
extension TallOddsMatchCardView {

    private func setupBindings() {
        guard let viewModel else { return }

        // Bind to display state
        // Use dropFirst() since we already configured with current value
        viewModel.displayStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)

        // Bind child view models
        setupChildViewModelBindings()
    }

    private func setupChildViewModelBindings() {
        guard let viewModel else { return }

        // Match Header View Model
        // Use dropFirst() since we already configured with current value
        viewModel.matchHeaderViewModelPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] headerViewModel in
                self?.updateMatchHeaderView(with: headerViewModel)
            }
            .store(in: &cancellables)

        // Market Info Line View Model
        // Use dropFirst() since we already configured with current value
        viewModel.marketInfoLineViewModelPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketInfoViewModel in
                self?.updateMarketInfoLineView(with: marketInfoViewModel)
            }
            .store(in: &cancellables)

        // Market Outcomes View Model
        // Use dropFirst() since we already configured with current value
        viewModel.marketOutcomesViewModelPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outcomesViewModel in
                self?.updateMarketOutcomesView(with: outcomesViewModel)
            }
            .store(in: &cancellables)

        // Score View Model
        // Use dropFirst() since we already configured with current value
        viewModel.scoreViewModelPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scoreViewModel in
                self?.updateScoreView(with: scoreViewModel)
            }
            .store(in: &cancellables)
    }

    private func render(state: TallOddsMatchCardDisplayState) {
        // Update container appearance
        if let customBackgroundColor {
            containerView.backgroundColor = customBackgroundColor
        }
        else {
            containerView.backgroundColor = .clear
        }

        // Update participant labels
        homeParticipantLabel.text = state.homeParticipantName
        awayParticipantLabel.text = state.awayParticipantName

        // Update score visibility based on live state
        scoreView.isHidden = !state.isLive
    }

    // MARK: - Child View Updates
    private func updateMatchHeaderView(with viewModel: MatchHeaderViewModelProtocol) {
        // Efficiently reconfigure existing view - MatchHeaderView supports this
        matchHeaderView.configure(with: viewModel)
    }

    private func updateMarketInfoLineView(with viewModel: MarketInfoLineViewModelProtocol) {
        // Efficiently reconfigure existing view
        marketInfoLineView.configure(with: viewModel)
    }

    private func updateMarketOutcomesView(with viewModel: MarketOutcomesMultiLineViewModelProtocol) {
        // Efficiently reconfigure existing view
        marketOutcomesView.configure(with: viewModel)

        // Invalidate intrinsic content size after outcomes update (most important for dynamic height)
        invalidateIntrinsicContentSize()
        
    }

    private func updateScoreView(with viewModel: ScoreViewModelProtocol?) {
        if let scoreViewModel = viewModel {
            scoreView.configure(with: scoreViewModel)
        }
    }

    // MARK: - Actions
    @objc private func matchHeaderTapped() {
        onMatchHeaderTapped()
        viewModel?.onMatchHeaderAction()
    }
    
    @objc private func cardTapped() {
        onCardTapped()
        viewModel?.onCardTapped()
    }

}

// MARK: - ViewCode
extension TallOddsMatchCardView {
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }

    private func buildViewHierarchy() {
        // Main container hierarchy
        addSubview(containerView)
        containerView.addSubview(contentStackView)

        // Setup separator container hierarchy
        separatorContainer.addSubview(separatorLine)

        // Setup participants container hierarchy
        participantsContainerView.addSubview(participantsStackView)
        participantsContainerView.addSubview(scoreView)
        participantsStackView.addArrangedSubview(homeParticipantLabel)
        participantsStackView.addArrangedSubview(awayParticipantLabel)

        // Setup market info container hierarchy
        marketInfoContainer.addSubview(marketInfoLineView)

        // Add all views to content stack in order
        contentStackView.addArrangedSubview(matchHeaderView)
        contentStackView.addArrangedSubview(separatorContainer)
        contentStackView.addArrangedSubview(participantsContainerView)
        contentStackView.addArrangedSubview(marketInfoContainer)
        contentStackView.addArrangedSubview(marketOutcomesView)
    }

    private func setupConstraints() {
        // Container view constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // Content stack view constraints
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Separator container constraints
        NSLayoutConstraint.activate([
            separatorContainer.heightAnchor.constraint(equalToConstant: 10),
            separatorLine.centerYAnchor.constraint(equalTo: separatorContainer.centerYAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: separatorContainer.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: separatorContainer.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])

        // Participants container constraints
        NSLayoutConstraint.activate([
            // Participants stack view (left side)
            participantsStackView.topAnchor.constraint(equalTo: participantsContainerView.topAnchor),
            participantsStackView.leadingAnchor.constraint(equalTo: participantsContainerView.leadingAnchor),
            participantsStackView.bottomAnchor.constraint(equalTo: participantsContainerView.bottomAnchor),

            // Individual label heights
            homeParticipantLabel.heightAnchor.constraint(equalToConstant: 20),
            awayParticipantLabel.heightAnchor.constraint(equalToConstant: 20),

            // Score view (right side, aligned with participant names)
            scoreView.topAnchor.constraint(equalTo: homeParticipantLabel.topAnchor),
            scoreView.bottomAnchor.constraint(equalTo: awayParticipantLabel.bottomAnchor),
            scoreView.trailingAnchor.constraint(equalTo: participantsContainerView.trailingAnchor),
            scoreView.leadingAnchor.constraint(greaterThanOrEqualTo: participantsStackView.trailingAnchor, constant: 8)
        ])

        // Market info container constraints
        NSLayoutConstraint.activate([
            marketInfoLineView.topAnchor.constraint(equalTo: marketInfoContainer.topAnchor, constant: 5),
            marketInfoLineView.leadingAnchor.constraint(equalTo: marketInfoContainer.leadingAnchor),
            marketInfoLineView.trailingAnchor.constraint(equalTo: marketInfoContainer.trailingAnchor),
            marketInfoLineView.centerYAnchor.constraint(equalTo: marketInfoContainer.centerYAnchor),
            marketInfoLineView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    private func setupAdditionalConfiguration() {
        if let customBackgroundColor {
            self.backgroundColor = customBackgroundColor
            self.containerView.backgroundColor = customBackgroundColor
            self.contentStackView.backgroundColor = customBackgroundColor
        }
        else {
            self.backgroundColor = StyleProvider.Color.backgroundCards
            self.containerView.backgroundColor = StyleProvider.Color.backgroundCards
            self.contentStackView.backgroundColor = StyleProvider.Color.backgroundCards
        }

        self.separatorLine.backgroundColor = StyleProvider.Color.highlightPrimary

        // Setup general card tap gesture recognizer
        let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        containerView.addGestureRecognizer(cardTapGesture)
        containerView.isUserInteractionEnabled = true

        // Setup match header gesture recognizer
        let headerTapGesture = UITapGestureRecognizer(target: self, action: #selector(matchHeaderTapped))
        matchHeaderView.addGestureRecognizer(headerTapGesture)
        matchHeaderView.isUserInteractionEnabled = true

        // Setup market outcomes callback
        marketOutcomesView.onOutcomeSelected = { [weak self] outcomeId, outcomeType in
            self?.onOutcomeSelected(outcomeId)
            self?.viewModel?.onOutcomeSelected(outcomeId: outcomeId)
        }
        
        marketOutcomesView.onOutcomeDeselected = { [weak self] outcomeId, outcomeType in
            self?.viewModel?.onOutcomeDeselected(outcomeId: outcomeId)
        }
    }

}

// MARK: - UI Elements Factory
extension TallOddsMatchCardView {
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return view
    }

    private static func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }

    private static func createSeparatorContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }

    private static func createSeparatorLine() -> FadingView {
        let fadingView = FadingView()
        fadingView.translatesAutoresizingMaskIntoConstraints = false
        fadingView.colors = [.clear, .black, .black, .clear]
        fadingView.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadingView.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadingView.fadeLocations = [0.0, 0.42, 0.58, 1.0]
        return fadingView
    }

    private static func createParticipantsContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }

    private static func createParticipantsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 2
        return stackView
    }

    private static func createMarketInfoContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }

    private func createMatchHeaderView() -> MatchHeaderView {
        // Create with a mock view model that will be replaced immediately
        let mockViewModel = MockMatchHeaderViewModel.defaultMock
        let headerView = MatchHeaderView(viewModel: mockViewModel, imageResolver: imageResolver)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }

    private static func createMarketInfoLineView() -> MarketInfoLineView {
        // Create with a mock view model that will be replaced immediately
        let mockViewModel = MockMarketInfoLineViewModel.defaultMock
        let infoView = MarketInfoLineView(viewModel: mockViewModel)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        return infoView
    }

    private static func createMarketOutcomesView() -> MarketOutcomesMultiLineView {
        // Create with a mock view model that will be replaced immediately
        let mockViewModel = MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup
        let outcomesView = MarketOutcomesMultiLineView(viewModel: mockViewModel)
        outcomesView.translatesAutoresizingMaskIntoConstraints = false
        return outcomesView
    }

    private static func createParticipantLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14.5)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }
    
    private static func createScoreView() -> ScoreView {
        let scoreView = ScoreView()
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        return scoreView
    }
}



// MARK: - Preview Provider
#if DEBUG
@available(iOS 17.0, *)
#Preview("Premier League Match") {
    PreviewUIView {
        let viewModel = MockTallOddsMatchCardViewModel.premierLeagueMock
        return TallOddsMatchCardView(viewModel: viewModel)
    }
    .frame(height: 300)
    .padding(.horizontal, 16)
}

@available(iOS 17.0, *)
#Preview("Compact Match") {
    PreviewUIView {
        let viewModel = MockTallOddsMatchCardViewModel.compactMock
        return TallOddsMatchCardView(viewModel: viewModel)
    }
    .frame(height: 250)
    .padding(.horizontal, 16)
}

@available(iOS 17.0, *)
#Preview("Live Match with Score") {
    PreviewUIView {
        let viewModel = MockTallOddsMatchCardViewModel.liveMock
        return TallOddsMatchCardView(viewModel: viewModel)
    }
    .frame(height: 300)
    .padding(.horizontal, 16)
}
#endif


