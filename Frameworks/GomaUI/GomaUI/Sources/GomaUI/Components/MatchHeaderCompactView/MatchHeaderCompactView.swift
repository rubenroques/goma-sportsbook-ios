import UIKit
import SwiftUI
import Combine

public final class MatchHeaderCompactView: UIView {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let contentStackView = UIStackView()
    private let leftContentView = UIView()
    private let teamsStackView = UIStackView()
    private let homeTeamLabel = UILabel()
    private let awayTeamLabel = UILabel()
    private let breadcrumbLabel = UILabel()
    
    private let statisticsButton = UIButton(type: .system)
    private let statisticsStackView = UIStackView()
    private let statisticsLabel = UILabel()
    private let statisticsIconImageView = UIImageView()
    
    private let bottomBorderView = UIView()
    
    // MARK: - Properties
    private let viewModel: MatchHeaderCompactViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
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
        backgroundColor = StyleProvider.Color.backgroundCards
        
        // Container setup
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Content stack setup (horizontal)
        containerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.distribution = .fill
        contentStackView.spacing = 8
        
        // Left content setup
        contentStackView.addArrangedSubview(leftContentView)
        
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
        breadcrumbLabel.textColor = StyleProvider.Color.textSecondary
        breadcrumbLabel.numberOfLines = 1
        breadcrumbLabel.lineBreakMode = .byTruncatingTail
        
        // Statistics button setup
        contentStackView.addArrangedSubview(statisticsButton)
        statisticsButton.addTarget(self, action: #selector(statisticsButtonTapped), for: .touchUpInside)
        
        // Statistics stack setup (horizontal)
        statisticsButton.addSubview(statisticsStackView)
        statisticsStackView.translatesAutoresizingMaskIntoConstraints = false
        statisticsStackView.axis = .horizontal
        statisticsStackView.spacing = 4
        statisticsStackView.alignment = .center
        statisticsStackView.isUserInteractionEnabled = false
        
        // Statistics label setup
        statisticsLabel.text = "Statistics"
        statisticsLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        statisticsLabel.textColor = StyleProvider.Color.highlightTertiary
        
        // Statistics icon setup
        statisticsIconImageView.contentMode = .scaleAspectFit
        statisticsIconImageView.tintColor = StyleProvider.Color.highlightTertiary
        
        // Create bar chart icon
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let barChartImage = UIImage(systemName: "chart.bar.fill", withConfiguration: config)
        statisticsIconImageView.image = barChartImage
        
        statisticsStackView.addArrangedSubview(statisticsLabel)
        statisticsStackView.addArrangedSubview(statisticsIconImageView)
        
        // Bottom border setup
        addSubview(bottomBorderView)
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderView.backgroundColor = StyleProvider.Color.separatorLine
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            // Content stack constraints
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Teams stack constraints
            teamsStackView.topAnchor.constraint(equalTo: leftContentView.topAnchor),
            teamsStackView.leadingAnchor.constraint(equalTo: leftContentView.leadingAnchor),
            teamsStackView.trailingAnchor.constraint(equalTo: leftContentView.trailingAnchor),
            
            // Breadcrumb constraints
            breadcrumbLabel.topAnchor.constraint(equalTo: teamsStackView.bottomAnchor, constant: 4),
            breadcrumbLabel.leadingAnchor.constraint(equalTo: leftContentView.leadingAnchor),
            breadcrumbLabel.trailingAnchor.constraint(equalTo: leftContentView.trailingAnchor),
            breadcrumbLabel.bottomAnchor.constraint(equalTo: leftContentView.bottomAnchor),
            
            // Statistics stack constraints
            statisticsStackView.topAnchor.constraint(equalTo: statisticsButton.topAnchor),
            statisticsStackView.leadingAnchor.constraint(equalTo: statisticsButton.leadingAnchor),
            statisticsStackView.trailingAnchor.constraint(equalTo: statisticsButton.trailingAnchor),
            statisticsStackView.bottomAnchor.constraint(equalTo: statisticsButton.bottomAnchor),
            
            // Statistics icon size
            statisticsIconImageView.widthAnchor.constraint(equalToConstant: 16),
            statisticsIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            // Statistics button minimum width to ensure visibility
            statisticsButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
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
        
        // Ensure statistics stack also has high priority
        statisticsStackView.setContentHuggingPriority(.required, for: .horizontal)
        statisticsStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        homeTeamLabel.text = data.homeTeamName
        awayTeamLabel.text = data.awayTeamName
        
        // Create attributed string for breadcrumb with underlines
        let breadcrumbText = "\(data.sport) / \(data.competition) / \(data.league)"
        let attributedString = NSMutableAttributedString(string: breadcrumbText)
        
        // Set base attributes
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: StyleProvider.fontWith(type: .semibold, size: 12),
            .foregroundColor: StyleProvider.Color.textSecondary
        ]
        attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: breadcrumbText.count))
        
        // Add underline to competition
        if let competitionRange = breadcrumbText.range(of: data.competition) {
            let nsRange = NSRange(competitionRange, in: breadcrumbText)
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
    }
    
    // MARK: - Actions
    @objc private func statisticsButtonTapped() {
        viewModel.handleStatisticsTap()
    }
}

// MARK: - SwiftUI Previews
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
#Preview("Match Header - Without Statistics") {
    PreviewUIViewController {
        let vc = UIViewController()
        let headerView = MatchHeaderCompactView(viewModel: MockMatchHeaderCompactViewModel.withoutStatistics)
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
