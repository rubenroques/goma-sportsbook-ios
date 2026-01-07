import UIKit
import Combine
import SwiftUI
import Kingfisher

/// Banner view for displaying match information with betting outcomes
public final class MatchBannerView: UIView, TopBannerViewProtocol {

    // MARK: - Private Properties
    private lazy var backgroundImageView: UIImageView = Self.createBackgroundImageView()
    private lazy var contentContainer: UIView = Self.createContentContainer()
    private lazy var headerLabel: UILabel = Self.createHeaderLabel()
    private lazy var homeTeamLabel: UILabel = Self.createTeamLabel()
    private lazy var awayTeamLabel: UILabel = Self.createTeamLabel()
    private lazy var homeScoreLabel: UILabel = Self.createScoreLabel()
    private lazy var awayScoreLabel: UILabel = Self.createScoreLabel()
    private lazy var outcomesContainerView: UIView = Self.createOutcomesContainerView()
    private var marketOutcomesView: MarketOutcomesLineView?

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: MatchBannerViewModelProtocol?

    // MARK: - TopBannerViewProtocol Properties
    public var type: String {
        return "MatchBannerView"
    }

    public var isVisible: Bool = true

    // MARK: - Public Callbacks
    public var onOutcomeSelected: ((String) -> Void) = { _ in }
    public var onOutcomeDeselected: ((String) -> Void) = { _ in }

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        setupWithTheme()

        // Initialize with empty state
        configure(with: MockMatchBannerViewModel.emptyState)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        setupConstraints()
        setupWithTheme()

        // Initialize with empty state
        configure(with: MockMatchBannerViewModel.emptyState)
    }

    // MARK: - Public Configuration
    /// Configure the view with a view model (synchronous for collection view compatibility)
    public func configure(with viewModel: MatchBannerViewModelProtocol) {
        self.viewModel = viewModel

        // Clear previous subscriptions
        cancellables.removeAll()

        // Immediate synchronous update with current data
        updateUI(with: viewModel.currentMatchData)
    }

    // MARK: - TopBannerViewProtocol
    public func bannerDidBecomeVisible() {

    }

    public func bannerDidBecomeHidden() {
        // Optional: Pause any real-time updates
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        backgroundColor = .clear
        clipsToBounds = true

        addSubview(backgroundImageView)
        addSubview(contentContainer)
        
        contentContainer.addSubview(headerLabel)
        contentContainer.addSubview(homeTeamLabel)
        contentContainer.addSubview(awayTeamLabel)
        contentContainer.addSubview(homeScoreLabel)
        contentContainer.addSubview(awayScoreLabel)
        contentContainer.addSubview(outcomesContainerView)

        setupActions()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background image view - full coverage
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Content container - with exact 16px padding
            contentContainer.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            // Header - 16px height, 11px font
            headerLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            headerLabel.widthAnchor.constraint(equalTo: contentContainer.widthAnchor, multiplier: 0.8),
            headerLabel.heightAnchor.constraint(equalToConstant: 16),

            // Home team - 16px height, 2px gap from header
            homeTeamLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4),
            homeTeamLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            homeTeamLabel.trailingAnchor.constraint(lessThanOrEqualTo: homeScoreLabel.leadingAnchor, constant: -8),
            homeTeamLabel.heightAnchor.constraint(equalToConstant: 16),

            // Away team - 16px height, 2px gap from home team
            awayTeamLabel.topAnchor.constraint(equalTo: homeTeamLabel.bottomAnchor, constant: 4),
            awayTeamLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            awayTeamLabel.trailingAnchor.constraint(lessThanOrEqualTo: awayScoreLabel.leadingAnchor, constant: -8),
            awayTeamLabel.heightAnchor.constraint(equalToConstant: 16),

            // Home score - aligned with home team
            homeScoreLabel.centerYAnchor.constraint(equalTo: homeTeamLabel.centerYAnchor),
            homeScoreLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            homeScoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),

            // Away score - aligned with away team
            awayScoreLabel.centerYAnchor.constraint(equalTo: awayTeamLabel.centerYAnchor),
            awayScoreLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            awayScoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),

            // Outcomes container - 48px height, 4px gap from away team
            outcomesContainerView.topAnchor.constraint(equalTo: awayTeamLabel.bottomAnchor, constant: 6),
            outcomesContainerView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            outcomesContainerView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            outcomesContainerView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupWithTheme() {
        // Background overlay for text readability
        contentContainer.backgroundColor = .clear
        backgroundImageView.backgroundColor = .clear
        
        // Text colors for visibility over background images
        headerLabel.textColor = StyleProvider.Color.allWhite
        homeTeamLabel.textColor = StyleProvider.Color.allWhite
        awayTeamLabel.textColor = StyleProvider.Color.allWhite
        homeScoreLabel.textColor = StyleProvider.Color.allWhite
        awayScoreLabel.textColor = StyleProvider.Color.allWhite
    }

    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBannerTap))
        contentContainer.addGestureRecognizer(tapGesture)
    }


    private func updateUI(with matchData: MatchBannerModel) {
        // Update header text
        headerLabel.text = matchData.headerText

        // Update team names
        homeTeamLabel.text = matchData.homeTeam
        awayTeamLabel.text = matchData.awayTeam

        // Update background image
        if let imageURLString = matchData.backgroundImageURL, !imageURLString.isEmpty, let imageURL = URL(string: imageURLString) {
            backgroundImageView.kf.setImage(with: imageURL)
            backgroundImageView.backgroundColor = StyleProvider.Color.backgroundGradientDark
        } else {
            backgroundImageView.image = nil
            backgroundImageView.backgroundColor = StyleProvider.Color.backgroundGradientDark
        }

        // Update score visibility and data
        updateScoreVisibility(isLive: matchData.isLive)
        if matchData.isLive, let homeScore = matchData.homeScore, let awayScore = matchData.awayScore {
            homeScoreLabel.text = "\(homeScore)"
            awayScoreLabel.text = "\(awayScore)"
        } else {
            homeScoreLabel.text = ""
            awayScoreLabel.text = ""
        }

        // Update market outcomes
        updateMarketOutcomesView()

        // Update visibility
        updateVisibility(for: matchData)
    }

    private func updateScoreVisibility(isLive: Bool) {
        homeScoreLabel.isHidden = !isLive
        awayScoreLabel.isHidden = !isLive
    }

    private func updateMarketOutcomesView() {
        guard let viewModel = viewModel else {
            return
        }

        let marketViewModel = viewModel.marketOutcomesViewModel

        // Remove existing market outcomes view if any
        marketOutcomesView?.removeFromSuperview()

        // Create new market outcomes view with protocol (works with Mock OR Production ViewModel)
        marketOutcomesView = MarketOutcomesLineView(viewModel: marketViewModel)
        guard let outcomeView = marketOutcomesView else { return }

        outcomeView.translatesAutoresizingMaskIntoConstraints = false
        outcomesContainerView.addSubview(outcomeView)

        // Setup constraints - outcomes view fills the container with 0 padding
        NSLayoutConstraint.activate([
            outcomeView.topAnchor.constraint(equalTo: outcomesContainerView.topAnchor),
            outcomeView.leadingAnchor.constraint(equalTo: outcomesContainerView.leadingAnchor),
            outcomeView.trailingAnchor.constraint(equalTo: outcomesContainerView.trailingAnchor),
            outcomeView.bottomAnchor.constraint(equalTo: outcomesContainerView.bottomAnchor)
        ])

        // Setup outcome selection callbacks
        outcomeView.onOutcomeSelected = { [weak self] outcomeId, _ in
            self?.onOutcomeSelected(outcomeId)
            self?.viewModel?.onOutcomeSelected(outcomeId: outcomeId)
        }

        outcomeView.onOutcomeDeselected = { [weak self] outcomeId, _ in
            self?.onOutcomeDeselected(outcomeId)
            self?.viewModel?.onOutcomeDeselected(outcomeId: outcomeId)
        }
    }

    private func updateVisibility(for matchData: MatchBannerModel) {
        // Hide components if data is empty
        let isEmpty = matchData.id.isEmpty

        headerLabel.isHidden = isEmpty
        homeTeamLabel.isHidden = isEmpty
        awayTeamLabel.isHidden = isEmpty
        marketOutcomesView?.isHidden = isEmpty
    }

    @objc private func handleBannerTap() {
        viewModel?.userDidTapBanner()
    }
}

// MARK: - Subviews Factory Methods
extension MatchBannerView {

    private static func createBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    private static func createContentContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    private static func createHeaderLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 11)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }

    private static func createTeamLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }

    private static func createScoreLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isHidden = true // Hidden by default, shown for live matches
        return label
    }

    private static func createOutcomesContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

}

// MARK: - SwiftUI Previews
#if DEBUG

#Preview("Prelive Match") {
    PreviewUIViewController {
        let vc = UIViewController()
        let matchBanner = MatchBannerView()
        matchBanner.configure(with: MockMatchBannerViewModel.preliveMatch)
        matchBanner.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = UIColor.backgroundTestColor
        vc.view.addSubview(matchBanner)

        NSLayoutConstraint.activate([
            matchBanner.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            matchBanner.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            matchBanner.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            matchBanner.heightAnchor.constraint(equalToConstant: 136)
        ])

        return vc
    }
}

#Preview("Live Match") {
    PreviewUIViewController {
        let vc = UIViewController()
        let matchBanner = MatchBannerView()
        matchBanner.configure(with: MockMatchBannerViewModel.liveMatch)
        matchBanner.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = UIColor.backgroundTestColor
        vc.view.addSubview(matchBanner)

        NSLayoutConstraint.activate([
            matchBanner.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            matchBanner.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            matchBanner.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            matchBanner.heightAnchor.constraint(equalToConstant: 136)
        ])

        return vc
    }
}

#Preview("Interactive Match") {
    PreviewUIViewController {
        let vc = UIViewController()
        let matchBanner = MatchBannerView()
        matchBanner.configure(with: MockMatchBannerViewModel.interactiveMatch)
        matchBanner.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = UIColor.backgroundTestColor
        vc.view.addSubview(matchBanner)

        NSLayoutConstraint.activate([
            matchBanner.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            matchBanner.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            matchBanner.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            matchBanner.heightAnchor.constraint(equalToConstant: 136)
        ])

        return vc
    }
}

#Preview("Empty State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let matchBanner = MatchBannerView()
        matchBanner.configure(with: MockMatchBannerViewModel.emptyState)
        matchBanner.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = UIColor.backgroundTestColor
        vc.view.addSubview(matchBanner)

        NSLayoutConstraint.activate([
            matchBanner.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            matchBanner.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            matchBanner.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            matchBanner.heightAnchor.constraint(equalToConstant: 136)
        ])

        return vc
    }
}

#endif
