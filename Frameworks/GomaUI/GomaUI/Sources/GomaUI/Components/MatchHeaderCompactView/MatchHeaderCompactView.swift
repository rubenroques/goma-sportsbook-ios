import UIKit
import SwiftUI
import Combine

public final class MatchHeaderCompactView: UIView {

    // MARK: - UI Components
    private let containerView = UIView()
    private let gradientView = GradientView()
    private let teamsStackView = UIStackView()
    private let homeTeamLabel = UILabel()
    private let awayTeamLabel = UILabel()
    private lazy var scoreView = Self.createScoreView()
    private let breadcrumbLabel = UILabel()
    private let bottomBorderView = UIView()
    
    // MARK: - Properties
    private let viewModel: MatchHeaderCompactViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentData: MatchHeaderCompactData?
    
    // MARK: - Initialization
    public init(viewModel: MatchHeaderCompactViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = StyleProvider.Color.gameHeader
        
        // Gradient background setup - anchored to component view
        addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.colors = [
            (color: StyleProvider.Color.gameHeader, location: 0.0),
            (color: StyleProvider.Color.backgroundGradient2, location: 1.0)
        ]
        gradientView.setHorizontalGradient() // Left to right
        
        // Container setup - on top of gradient with padding
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear

        // Teams stack setup (vertical)
        containerView.addSubview(teamsStackView)
        teamsStackView.translatesAutoresizingMaskIntoConstraints = false
        teamsStackView.axis = .vertical
        teamsStackView.spacing = 2
        teamsStackView.alignment = .leading
        
        // Team labels setup
        homeTeamLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        homeTeamLabel.textColor = StyleProvider.Color.gameHeaderTextPrimary
        homeTeamLabel.numberOfLines = 1
        homeTeamLabel.lineBreakMode = .byTruncatingTail
        
        awayTeamLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        awayTeamLabel.textColor = StyleProvider.Color.gameHeaderTextPrimary
        awayTeamLabel.numberOfLines = 1
        awayTeamLabel.lineBreakMode = .byTruncatingTail
        
        teamsStackView.addArrangedSubview(homeTeamLabel)
        teamsStackView.addArrangedSubview(awayTeamLabel)

        // ScoreView setup (hidden by default, shown only for live matches)
        containerView.addSubview(scoreView)
        scoreView.isHidden = true  // Will be shown when live data is available

        // Breadcrumb setup
        containerView.addSubview(breadcrumbLabel)
        breadcrumbLabel.translatesAutoresizingMaskIntoConstraints = false
        breadcrumbLabel.font = StyleProvider.fontWith(type: .semibold, size: 12)
        breadcrumbLabel.textColor = StyleProvider.Color.gameHeaderTextSecondary
        breadcrumbLabel.numberOfLines = 0
        breadcrumbLabel.lineBreakMode = .byTruncatingTail
        breadcrumbLabel.isUserInteractionEnabled = true

        // Add tap gesture for breadcrumb interactions
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(breadcrumbTapped(_:)))
        breadcrumbLabel.addGestureRecognizer(tapGesture)

        // Bottom border setup
        addSubview(bottomBorderView)
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderView.backgroundColor = StyleProvider.Color.separatorLine
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Gradient background constraints - fills entire component
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Container constraints - with 12px padding from edges
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            // Teams stack constraints - anchored to left side
            teamsStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            teamsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),

            // ScoreView constraints (aligned vertically with team labels, snapped to right edge)
            scoreView.topAnchor.constraint(equalTo: homeTeamLabel.topAnchor),
            scoreView.bottomAnchor.constraint(equalTo: awayTeamLabel.bottomAnchor),
            scoreView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scoreView.leadingAnchor.constraint(equalTo: teamsStackView.trailingAnchor, constant: 8),

            // Breadcrumb constraints
            breadcrumbLabel.topAnchor.constraint(equalTo: teamsStackView.bottomAnchor, constant: 4),
            breadcrumbLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            breadcrumbLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            breadcrumbLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Bottom border constraints
            bottomBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBorderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBorderView.heightAnchor.constraint(equalToConstant: 1)
        ])

        // Set content hugging and compression resistance for proper layout priority
        // Scores have highest priority - never compress (always visible)
        scoreView.setContentHuggingPriority(.required, for: .horizontal)
        scoreView.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Team labels compress when space is tight (scores take priority)
        homeTeamLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        awayTeamLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private func bindViewModel() {
        viewModel.headerDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateUI(with: data)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with data: MatchHeaderCompactData) {
        self.currentData = data

        homeTeamLabel.text = data.homeTeamName
        awayTeamLabel.text = data.awayTeamName

        // Configure scoreView - only show for live matches with scores
        scoreView.isHidden = !data.isLive
        if let scoreViewModel = data.scoreViewModel {
            scoreView.configure(with: scoreViewModel)
        }

        // Create attributed string for breadcrumb with underlines
        let breadcrumbText = "\(data.sport) / \(data.country) / \(data.league)"
        let attributedString = NSMutableAttributedString(string: breadcrumbText)

        // Set base attributes
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: StyleProvider.fontWith(type: .semibold, size: 12),
            .foregroundColor: StyleProvider.Color.textSecondary
        ]
        attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: breadcrumbText.count))

        // Add underline to country
        if let countryRange = breadcrumbText.range(of: data.country) {
            let nsRange = NSRange(countryRange, in: breadcrumbText)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        }

        // Add underline to league
        if let leagueRange = breadcrumbText.range(of: data.league) {
            let nsRange = NSRange(leagueRange, in: breadcrumbText)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        }

        breadcrumbLabel.attributedText = attributedString
    }

    // MARK: - Actions

    @objc private func breadcrumbTapped(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = breadcrumbLabel.attributedText,
              let data = currentData else { return }

        let location = gesture.location(in: breadcrumbLabel)
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: breadcrumbLabel.bounds.size)

        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = breadcrumbLabel.numberOfLines
        textContainer.lineBreakMode = breadcrumbLabel.lineBreakMode

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        let characterIndex = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        guard characterIndex < textStorage.length else { return }

        let fullText = attributedText.string

        // Check if tapped on country
        if let countryRange = fullText.range(of: data.country) {
            let nsCountryRange = NSRange(countryRange, in: fullText)
            if NSLocationInRange(characterIndex, nsCountryRange) {
                viewModel.handleCountryTap()
                return
            }
        }

        // Check if tapped on league
        if let leagueRange = fullText.range(of: data.league) {
            let nsLeagueRange = NSRange(leagueRange, in: fullText)
            if NSLocationInRange(characterIndex, nsLeagueRange) {
                viewModel.handleLeagueTap()
                return
            }
        }
    }

    // MARK: - Factory Methods

    private static func createScoreView() -> ScoreView {
        let scoreView = ScoreView()
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        return scoreView
    }
}

// MARK: - SwiftUI Previews
#if DEBUG
@available(iOS 17.0, *)
#Preview("Match Header - Default") {
    PreviewUIViewController {
        let vc = UIViewController()
        let headerView = MatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel.default)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Match Header - Long Content") {
    PreviewUIViewController {
        let vc = UIViewController()
        let headerView = MatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel.longContent)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Match Header - Standard") {
    PreviewUIViewController {
        let vc = UIViewController()

        let mockData = MatchHeaderCompactData(
            homeTeamName: "Manchester United",
            awayTeamName: "Glasgow Rangers",
            sport: "Football",
            country: "England",
            league: "UEFA Europa League",
            countryId: "country-england",
            leagueId: "league-uefa-europa"
        )

        let viewModel = MockMatchHeaderCompactViewModel(headerData: mockData)
        let headerView = MatchHeaderCompactView(viewModel: viewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return vc
    }
}

// MARK: - Live Tennis Previews

@available(iOS 17.0, *)
#Preview("Tennis - Live Match with Serving") {
    PreviewUIViewController {
        let vc = UIViewController()
        let headerView = MatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel.liveTennisMatch)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Tennis - Long Names Truncation") {
    PreviewUIViewController {
        let vc = UIViewController()

        // Create complex tennis score with long names
        let scoreData = [
            ScoreDisplayData(
                id: "game-current",
                homeScore: "AD",
                awayScore: "40",
                style: .background,
                highlightingMode: .winnerLoser,
                showsTrailingSeparator: true,
                servingPlayer: .home
            ),
            ScoreDisplayData(
                id: "set-1",
                homeScore: "7",
                awayScore: "6",
                index: 1,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-2",
                homeScore: "3",
                awayScore: "6",
                index: 2,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-3",
                homeScore: "6",
                awayScore: "5",
                index: 3,
                style: .simple,
                highlightingMode: .bothHighlight
            )
        ]
        let scoreViewModel = MockScoreViewModel(scoreCells: scoreData, visualState: .display)

        let mockData = MatchHeaderCompactData(
            homeTeamName: "Daniil Medvedev",
            awayTeamName: "Alexander Zverev",
            sport: "Tennis",
            country: "Australia",
            league: "Australian Open",
            countryId: "country-australia",
            leagueId: "league-aus-open",
            scoreViewModel: scoreViewModel,
            isLive: true
        )

        let viewModel = MockMatchHeaderCompactViewModel(headerData: mockData)
        let headerView = MatchHeaderCompactView(viewModel: viewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Tennis - Final Set Tiebreak") {
    PreviewUIViewController {
        let vc = UIViewController()

        // Create tiebreak scenario in final set
        let scoreData = [
            ScoreDisplayData(
                id: "tiebreak",
                homeScore: "8",
                awayScore: "7",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .away
            ),
            ScoreDisplayData(
                id: "set-1",
                homeScore: "6",
                awayScore: "7",
                index: 1,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-2",
                homeScore: "7",
                awayScore: "6",
                index: 2,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-3",
                homeScore: "6",
                awayScore: "6",
                index: 3,
                style: .simple,
                highlightingMode: .bothHighlight
            )
        ]
        let scoreViewModel = MockScoreViewModel(scoreCells: scoreData, visualState: .display)

        let mockData = MatchHeaderCompactData(
            homeTeamName: "Djokovic",
            awayTeamName: "Alcaraz",
            sport: "Tennis",
            country: "England",
            league: "Wimbledon",
            countryId: "country-uk",
            leagueId: "league-wimbledon",
            scoreViewModel: scoreViewModel,
            isLive: true
        )

        let viewModel = MockMatchHeaderCompactViewModel(headerData: mockData)
        let headerView = MatchHeaderCompactView(viewModel: viewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Tennis - Five Sets with Stats") {
    PreviewUIViewController {
        let vc = UIViewController()

        // Create five-set match (Grand Slam format)
        let scoreData = [
            ScoreDisplayData(
                id: "game-current",
                homeScore: "15",
                awayScore: "30",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .home
            ),
            ScoreDisplayData(
                id: "set-1",
                homeScore: "6",
                awayScore: "4",
                index: 1,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-2",
                homeScore: "4",
                awayScore: "6",
                index: 2,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-3",
                homeScore: "7",
                awayScore: "6",
                index: 3,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-4",
                homeScore: "3",
                awayScore: "6",
                index: 4,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-5",
                homeScore: "2",
                awayScore: "1",
                index: 5,
                style: .simple,
                highlightingMode: .bothHighlight
            )
        ]
        let scoreViewModel = MockScoreViewModel(scoreCells: scoreData, visualState: .display)

        let mockData = MatchHeaderCompactData(
            homeTeamName: "Sinner Sinner Sinner Sinner",
            awayTeamName: "Tsitsipas Tsitsipas Tsitsipas",
            sport: "Tennis",
            country: "France",
            league: "Roland Garros",
            countryId: "country-france",
            leagueId: "league-roland-garros",
            scoreViewModel: scoreViewModel,
            isLive: true
        )

        let viewModel = MockMatchHeaderCompactViewModel(headerData: mockData)
        let headerView = MatchHeaderCompactView(viewModel: viewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Tennis - Extremely Long Names") {
    PreviewUIViewController {
        let vc = UIViewController()

        // Test extreme truncation scenario
        let scoreData = [
            ScoreDisplayData(
                id: "game-current",
                homeScore: "40",
                awayScore: "40",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .away
            ),
            ScoreDisplayData(
                id: "set-1",
                homeScore: "6",
                awayScore: "3",
                index: 1,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-2",
                homeScore: "4",
                awayScore: "5",
                index: 2,
                style: .simple,
                highlightingMode: .bothHighlight
            )
        ]
        let scoreViewModel = MockScoreViewModel(scoreCells: scoreData, visualState: .display)

        let mockData = MatchHeaderCompactData(
            homeTeamName: "Stanislas Wawrinka",
            awayTeamName: "Juan Martin del Potro",
            sport: "Tennis",
            country: "United States",
            league: "US Open Championship",
            countryId: "country-usa",
            leagueId: "league-us-open",
            scoreViewModel: scoreViewModel,
            isLive: true
        )

        let viewModel = MockMatchHeaderCompactViewModel(headerData: mockData)
        let headerView = MatchHeaderCompactView(viewModel: viewModel)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return vc
    }
}
#endif
