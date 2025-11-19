import UIKit
import SwiftUI
import Combine

public final class MatchHeaderCompactView: UIView {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let gradientView = GradientView()
    private let leftContentView = UIView()
    private let teamsStackView = UIStackView()
    private let homeTeamLabel = UILabel()
    private let awayTeamLabel = UILabel()
    private let breadcrumbLabel = UILabel()
    private let matchTimeLabel = UILabel()
    private let liveIndicatorView = UIView()
    private let statisticsButton = UIButton()
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
        
        // Left content setup
        containerView.addSubview(leftContentView)
        leftContentView.translatesAutoresizingMaskIntoConstraints = false
        leftContentView.backgroundColor = .clear
        
        // Teams stack setup (vertical)
        leftContentView.addSubview(teamsStackView)
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
        
        // Breadcrumb setup
        leftContentView.addSubview(breadcrumbLabel)
        breadcrumbLabel.translatesAutoresizingMaskIntoConstraints = false
        breadcrumbLabel.font = StyleProvider.fontWith(type: .semibold, size: 12)
        breadcrumbLabel.textColor = StyleProvider.Color.gameHeaderTextSecondary
        breadcrumbLabel.numberOfLines = 0
        breadcrumbLabel.lineBreakMode = .byTruncatingTail
        breadcrumbLabel.isUserInteractionEnabled = true

        // Add tap gesture for breadcrumb interactions
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(breadcrumbTapped(_:)))
        breadcrumbLabel.addGestureRecognizer(tapGesture)

        // Match time label setup
        leftContentView.addSubview(matchTimeLabel)
        matchTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        matchTimeLabel.font = StyleProvider.fontWith(type: .semibold, size: 12)
        matchTimeLabel.textColor = StyleProvider.Color.gameHeaderTextSecondary
        matchTimeLabel.numberOfLines = 1
        matchTimeLabel.textAlignment = .left
        matchTimeLabel.isHidden = true

        // Live indicator view setup
        leftContentView.addSubview(liveIndicatorView)
        liveIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        liveIndicatorView.backgroundColor = StyleProvider.Color.highlightPrimary
        liveIndicatorView.layer.cornerRadius = 8.5
        liveIndicatorView.isHidden = true

        // Add "LIVE" label and play icon to live indicator
        let liveLabel = UILabel()
        liveLabel.translatesAutoresizingMaskIntoConstraints = false
        liveLabel.text = "LIVE"
        liveLabel.font = StyleProvider.fontWith(type: .bold, size: 9)
        liveLabel.textColor = .white

        let playIconView = UIImageView()
        playIconView.translatesAutoresizingMaskIntoConstraints = false
        playIconView.image = UIImage(systemName: "play.fill")
        playIconView.tintColor = .white
        playIconView.contentMode = .scaleAspectFit

        liveIndicatorView.addSubview(liveLabel)
        liveIndicatorView.addSubview(playIconView)

        NSLayoutConstraint.activate([
            liveLabel.leadingAnchor.constraint(equalTo: liveIndicatorView.leadingAnchor, constant: 6),
            liveLabel.centerYAnchor.constraint(equalTo: liveIndicatorView.centerYAnchor),

            playIconView.leadingAnchor.constraint(equalTo: liveLabel.trailingAnchor, constant: 3),
            playIconView.trailingAnchor.constraint(equalTo: liveIndicatorView.trailingAnchor, constant: -6),
            playIconView.centerYAnchor.constraint(equalTo: liveIndicatorView.centerYAnchor),
            playIconView.widthAnchor.constraint(equalToConstant: 8),
            playIconView.heightAnchor.constraint(equalToConstant: 8)
        ])

        // Statistics button setup
        containerView.addSubview(statisticsButton)
        statisticsButton.translatesAutoresizingMaskIntoConstraints = false
        statisticsButton.backgroundColor = .clear
        statisticsButton.addTarget(self, action: #selector(statisticsButtonTapped), for: .touchUpInside)
        
        // Configure button appearance
        statisticsButton.titleLabel?.font = StyleProvider.fontWith(type: .regular, size: 12)
        statisticsButton.backgroundColor = .clear
        statisticsButton.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        statisticsButton.tintColor = StyleProvider.Color.highlightPrimary
        statisticsButton.semanticContentAttribute = .forceRightToLeft // Image on right, text on left
        statisticsButton.contentHorizontalAlignment = .center
        
        // Add spacing between text and icon
        let spacing: CGFloat = 2
        statisticsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        statisticsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
        statisticsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
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
            
            // Left content constraints - anchored to left side, trailing to center
            leftContentView.topAnchor.constraint(equalTo: containerView.topAnchor),
            leftContentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leftContentView.trailingAnchor.constraint(equalTo: statisticsButton.leadingAnchor, constant: -8),
            leftContentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Statistics button constraints - anchored to right side of container
            statisticsButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statisticsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Teams stack constraints
            teamsStackView.topAnchor.constraint(equalTo: leftContentView.topAnchor),
            teamsStackView.leadingAnchor.constraint(equalTo: leftContentView.leadingAnchor),
            teamsStackView.trailingAnchor.constraint(equalTo: leftContentView.trailingAnchor),
            
            // Breadcrumb constraints
            breadcrumbLabel.topAnchor.constraint(equalTo: teamsStackView.bottomAnchor, constant: 4),
            breadcrumbLabel.leadingAnchor.constraint(equalTo: leftContentView.leadingAnchor),
            breadcrumbLabel.trailingAnchor.constraint(equalTo: leftContentView.trailingAnchor),

            // Match time label constraints - below breadcrumb
            matchTimeLabel.topAnchor.constraint(equalTo: breadcrumbLabel.bottomAnchor, constant: 4),
            matchTimeLabel.leadingAnchor.constraint(equalTo: leftContentView.leadingAnchor),
            matchTimeLabel.bottomAnchor.constraint(equalTo: leftContentView.bottomAnchor),

            // Live indicator constraints - next to match time label
            liveIndicatorView.leadingAnchor.constraint(equalTo: matchTimeLabel.trailingAnchor, constant: 6),
            liveIndicatorView.centerYAnchor.constraint(equalTo: matchTimeLabel.centerYAnchor),
            liveIndicatorView.heightAnchor.constraint(equalToConstant: 17),
            
            // Statistics button size constraints
            statisticsButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Bottom border constraints
            bottomBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBorderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBorderView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Set content hugging and compression resistance for proper layout priority
        leftContentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        leftContentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        statisticsButton.setContentHuggingPriority(.required, for: .horizontal)
        statisticsButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func bindViewModel() {
        viewModel.headerDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateUI(with: data)
            }
            .store(in: &cancellables)

        // Bind match time updates
        viewModel.matchTimePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matchTime in
                self?.matchTimeLabel.text = matchTime
                self?.matchTimeLabel.isHidden = matchTime == nil
            }
            .store(in: &cancellables)

        // Bind live indicator updates
        viewModel.isLivePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLive in
                self?.liveIndicatorView.isHidden = !isLive
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with data: MatchHeaderCompactData) {
        self.currentData = data

        homeTeamLabel.text = data.homeTeamName
        awayTeamLabel.text = data.awayTeamName

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
        
        // Show/hide statistics button
        statisticsButton.isHidden = !data.hasStatistics
        
        // Update statistics button based on collapsed state
        updateStatisticsButton(
            isCollapsed: data.isStatisticsCollapsed,
            collapsedTitle: data.statisticsCollapsedTitle,
            expandedTitle: data.statisticsExpandedTitle
        )
    }
    
    private func updateStatisticsButton(isCollapsed: Bool, collapsedTitle: String, expandedTitle: String) {
        // Update button title
        let title = isCollapsed ? collapsedTitle : expandedTitle
        statisticsButton.setTitle(title, for: .normal)
        
        // Update icon based on collapsed state
        let iconSize: CGFloat = 14
        let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
        var buttonImage: UIImage?
        
        if isCollapsed {
            // Try custom icon first, fallback to system icon
            if let customImage = UIImage(named: "chevron_down_icon") {
                buttonImage = customImage.withRenderingMode(.alwaysTemplate)
            } else {
                buttonImage = UIImage(systemName: "chevron.down", withConfiguration: config)
            }
        } else {
            // Try custom icon first, fallback to system icon
            if let customImage = UIImage(named: "chevron_up_icon") {
                buttonImage = customImage.withRenderingMode(.alwaysTemplate)
            } else {
                buttonImage = UIImage(systemName: "chevron.up", withConfiguration: config)
            }
        }
        
        statisticsButton.setImage(buttonImage, for: .normal)
    }
    
    // MARK: - Actions
    @objc private func statisticsButtonTapped() {
        viewModel.handleStatisticsTap()
    }

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
#Preview("Match Header - Expanded Statistics") {
    PreviewUIViewController {
        let vc = UIViewController()

        let mockData = MatchHeaderCompactData(
            homeTeamName: "Manchester United",
            awayTeamName: "Glasgow Rangers",
            sport: "Football",
            country: "England",
            league: "UEFA Europa League",
            countryId: "country-england",
            leagueId: "league-uefa-europa",
            hasStatistics: true,
            isStatisticsCollapsed: false
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
