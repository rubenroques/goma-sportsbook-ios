import UIKit
import SwiftUI
import Combine


public final class TicketSelectionView: UIView {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        view.layer.cornerRadius = 8
        return view
    }()
    
    // Left content (competition info)
    private let leftContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let sportIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        return imageView
    }()
    private let countryFlagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    private let competitionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 10)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    // Right content (date/live indicator)
    private let rightContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 10)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    private lazy var resultTagCapsuleViewModel: MockCapsuleViewModel = {
        return MockCapsuleViewModel.tagStyle
    }()
    private lazy var resultTagCapsuleView: CapsuleView = {
        let view = CapsuleView(viewModel: resultTagCapsuleViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    private let liveIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.layer.cornerRadius = 9
        view.isHidden = true
        return view
    }()
    private let liveLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 10)
        label.textColor = StyleProvider.Color.allWhite
        label.text = LocalizationProvider.string("live_uppercase")
        label.textAlignment = .center
        return label
    }()
    private let liveIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = StyleProvider.Color.allWhite
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Match content
    private let matchContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let homeTeamLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    private let awayTeamLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    private let homeScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    private let awayScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    // Separator
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        return view
    }()
    
    // Bottom section (betting market information)
    private let bottomSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let marketLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.text = LocalizationProvider.string("market")
        label.numberOfLines = 1
        return label
    }()
    private let selectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.text = LocalizationProvider.string("selection")
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    private let oddsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.text = LocalizationProvider.string("odds")
        label.numberOfLines = 1
        return label
    }()
    private let oddsValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.text = "0.00"
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    // MARK: - Properties
    private let viewModel: TicketSelectionViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Dynamic constraints for state-based layout
    private var leftContentViewTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    public init(viewModel: TicketSelectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupView()
        setupConstraints()
        
        // Immediate UI update with current data for proper table view sizing
        updateUI(with: viewModel.currentTicketData)
        
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        
        // Container setup
        addSubview(containerView)
        
        // Left content setup (competition info)
        containerView.addSubview(leftContentView)
        
        leftContentView.addSubview(sportIconImageView)
        
        leftContentView.addSubview(countryFlagImageView)
        
        leftContentView.addSubview(competitionLabel)
        
        // Right content setup (date/live indicator)
        containerView.addSubview(rightContentView)
        
        rightContentView.addSubview(liveIndicatorView)
        
        rightContentView.addSubview(dateLabel)
        
        rightContentView.addSubview(resultTagCapsuleView)
        
        liveIndicatorView.addSubview(liveLabel)
        
        liveIndicatorView.addSubview(liveIconImageView)
        
        // Match content setup
        containerView.addSubview(matchContentView)
        
        matchContentView.addSubview(homeTeamLabel)
        
        matchContentView.addSubview(awayTeamLabel)
        
        matchContentView.addSubview(homeScoreLabel)
        
        matchContentView.addSubview(awayScoreLabel)
        
        // Separator setup
        containerView.addSubview(separatorView)
        
        // Bottom section setup
        containerView.addSubview(bottomSectionView)
        
        bottomSectionView.addSubview(marketLabel)
        
        bottomSectionView.addSubview(selectionLabel)
        
        bottomSectionView.addSubview(oddsLabel)
        
        bottomSectionView.addSubview(oddsValueLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Left content constraints (top section)
            leftContentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            leftContentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            leftContentView.heightAnchor.constraint(equalToConstant: 20),
            
            sportIconImageView.leadingAnchor.constraint(equalTo: leftContentView.leadingAnchor),
            sportIconImageView.centerYAnchor.constraint(equalTo: leftContentView.centerYAnchor),
            sportIconImageView.widthAnchor.constraint(equalToConstant: 16),
            sportIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            countryFlagImageView.leadingAnchor.constraint(equalTo: sportIconImageView.trailingAnchor, constant: 8),
            countryFlagImageView.centerYAnchor.constraint(equalTo: leftContentView.centerYAnchor),
            countryFlagImageView.widthAnchor.constraint(equalToConstant: 16),
            countryFlagImageView.heightAnchor.constraint(equalToConstant: 16),
            
            competitionLabel.leadingAnchor.constraint(equalTo: countryFlagImageView.trailingAnchor, constant: 8),
            competitionLabel.centerYAnchor.constraint(equalTo: leftContentView.centerYAnchor),
            competitionLabel.trailingAnchor.constraint(lessThanOrEqualTo: leftContentView.trailingAnchor),
            
            // Right content constraints (top section)
            rightContentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            rightContentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            rightContentView.heightAnchor.constraint(equalToConstant: 20),
            
            dateLabel.leadingAnchor.constraint(equalTo: rightContentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: rightContentView.trailingAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: rightContentView.centerYAnchor),
            
            resultTagCapsuleView.trailingAnchor.constraint(equalTo: rightContentView.trailingAnchor),
            resultTagCapsuleView.centerYAnchor.constraint(equalTo: rightContentView.centerYAnchor),
            resultTagCapsuleView.heightAnchor.constraint(equalToConstant: 18),
            
            liveIndicatorView.trailingAnchor.constraint(equalTo: rightContentView.trailingAnchor),
            liveIndicatorView.centerYAnchor.constraint(equalTo: rightContentView.centerYAnchor),
            
            liveLabel.leadingAnchor.constraint(equalTo: liveIndicatorView.leadingAnchor, constant: 5),
            liveLabel.topAnchor.constraint(equalTo: liveIndicatorView.topAnchor, constant: 5),
            liveLabel.bottomAnchor.constraint(equalTo: liveIndicatorView.bottomAnchor, constant: -5),
            
            liveIconImageView.leadingAnchor.constraint(equalTo: liveLabel.trailingAnchor, constant: 3),
            liveIconImageView.trailingAnchor.constraint(equalTo: liveIndicatorView.trailingAnchor, constant: -5),
            liveIconImageView.centerYAnchor.constraint(equalTo: liveIndicatorView.centerYAnchor),
            liveIconImageView.widthAnchor.constraint(equalToConstant: 7),
            liveIconImageView.heightAnchor.constraint(equalToConstant: 7),
            
            // Match content constraints (middle section)
            matchContentView.topAnchor.constraint(equalTo: leftContentView.bottomAnchor, constant: 4),
            matchContentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            matchContentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            matchContentView.heightAnchor.constraint(equalToConstant: 40),
            
            // Home team and score constraints
            homeTeamLabel.leadingAnchor.constraint(equalTo: matchContentView.leadingAnchor),
            homeTeamLabel.topAnchor.constraint(equalTo: matchContentView.topAnchor),
            homeTeamLabel.trailingAnchor.constraint(lessThanOrEqualTo: homeScoreLabel.leadingAnchor, constant: -8),
            
            homeScoreLabel.trailingAnchor.constraint(equalTo: matchContentView.trailingAnchor),
            homeScoreLabel.centerYAnchor.constraint(equalTo: homeTeamLabel.centerYAnchor),
            homeScoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            // Away team and score constraints
            awayTeamLabel.leadingAnchor.constraint(equalTo: matchContentView.leadingAnchor),
            awayTeamLabel.topAnchor.constraint(equalTo: homeTeamLabel.bottomAnchor, constant: 4),
            awayTeamLabel.trailingAnchor.constraint(lessThanOrEqualTo: awayScoreLabel.leadingAnchor, constant: -8),
            
            awayScoreLabel.trailingAnchor.constraint(equalTo: matchContentView.trailingAnchor),
            awayScoreLabel.centerYAnchor.constraint(equalTo: awayTeamLabel.centerYAnchor),
            awayScoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            // Separator constraints
            separatorView.topAnchor.constraint(equalTo: matchContentView.bottomAnchor, constant: 8),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            // Bottom section constraints
            bottomSectionView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 8),
            bottomSectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            bottomSectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            bottomSectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            marketLabel.leadingAnchor.constraint(equalTo: bottomSectionView.leadingAnchor),
            marketLabel.topAnchor.constraint(equalTo: bottomSectionView.topAnchor),
            marketLabel.trailingAnchor.constraint(lessThanOrEqualTo: selectionLabel.leadingAnchor, constant: -8),
            
            selectionLabel.trailingAnchor.constraint(equalTo: bottomSectionView.trailingAnchor),
            selectionLabel.topAnchor.constraint(equalTo: bottomSectionView.topAnchor),
            
            oddsLabel.leadingAnchor.constraint(equalTo: bottomSectionView.leadingAnchor),
            oddsLabel.topAnchor.constraint(equalTo: marketLabel.bottomAnchor, constant: 4),
            oddsLabel.bottomAnchor.constraint(equalTo: bottomSectionView.bottomAnchor),
            oddsLabel.trailingAnchor.constraint(lessThanOrEqualTo: oddsValueLabel.leadingAnchor, constant: -8),
            
            oddsValueLabel.trailingAnchor.constraint(equalTo: bottomSectionView.trailingAnchor),
            oddsValueLabel.topAnchor.constraint(equalTo: selectionLabel.bottomAnchor, constant: 4),
            oddsValueLabel.bottomAnchor.constraint(equalTo: bottomSectionView.bottomAnchor)
        ])
        
        // Setup initial dynamic constraint
        setupDynamicConstraints()
    }
    
    private func setupDynamicConstraints() {
        // Initial constraint - anchor to resultTagLabel (preLive state)
        leftContentViewTrailingConstraint = leftContentView.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -8)
        leftContentViewTrailingConstraint?.isActive = true
    }
    
    private func bindViewModel() {
        viewModel.ticketDataPublisher
            .dropFirst() // Skip initial value since we already used currentTicketData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ticketData in
                self?.updateUI(with: ticketData)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with ticketData: TicketSelectionData) {
        // Update competition info
        competitionLabel.text = ticketData.competitionName
        
        // Update team names
        homeTeamLabel.text = ticketData.homeTeamName
        awayTeamLabel.text = ticketData.awayTeamName
        
        // Update scores (only visible in live state)
        if ticketData.isLive {
            homeScoreLabel.text = "\(ticketData.homeScore)"
            awayScoreLabel.text = "\(ticketData.awayScore)"
            homeScoreLabel.isHidden = false
            awayScoreLabel.isHidden = false
        } else {
            homeScoreLabel.isHidden = true
            awayScoreLabel.isHidden = true
        }
        
        // Update right content based on state
        if ticketData.isLive {
            dateLabel.isHidden = true
            liveIndicatorView.isHidden = false
            
            // Update constraint to anchor to liveIndicatorView
            updateLeftContentViewConstraint(to: liveIndicatorView.leadingAnchor)
        } else {
            // By default, we show the `dateLabel` item for a later checking if there is a bet result.
            // If there's a result, the capsule will be set and the `dateLabel` will be hidden
            // at `updateResultTag(with status:)` function.
            dateLabel.isHidden = false
            liveIndicatorView.isHidden = true
            dateLabel.text = ticketData.matchDate
            
            // Update constraint to anchor to dateLabel
            updateLeftContentViewConstraint(to: dateLabel.leadingAnchor)
        }
        
        // Update sport icon and country flag if provided
        if let sportIcon = ticketData.sportIcon {
            if let customImage = UIImage(named: sportIcon) {
                sportIconImageView.image = customImage
            }
            else if let systemImage = UIImage(systemName: sportIcon) {
                sportIconImageView.image = systemImage
            }
        }
        
        if let countryFlag = ticketData.countryFlag {
            if let customImage = UIImage(named: countryFlag) {
                countryFlagImageView.image = customImage
            }
            else if let systemImage = UIImage(systemName: countryFlag) {
                countryFlagImageView.image = systemImage
            }
        }
        
        // Update betting market information
        marketLabel.text = ticketData.marketName
        selectionLabel.text = ticketData.selectionName
        oddsLabel.text = LocalizationProvider.string("odds")
        oddsValueLabel.text = ticketData.oddsValue
    }
    
    private func updateLeftContentViewConstraint(to anchor: NSLayoutXAxisAnchor) {
        // Deactivate current constraint
        leftContentViewTrailingConstraint?.isActive = false
        
        // Create and activate new constraint
        leftContentViewTrailingConstraint = leftContentView.trailingAnchor.constraint(equalTo: anchor, constant: -8)
        leftContentViewTrailingConstraint?.isActive = true
        
        // Animate the constraint change
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
}

extension TicketSelectionView {
    public func updateResultTag(with status: BetTicketStatusData?) {
        guard let status else {
            resultTagCapsuleView.isHidden = true
            return
        }

        resultTagCapsuleView.isHidden = false
        dateLabel.isHidden = true

        // For cashedOut tickets, individual selections weren't resolved - show "PENDING"
        // The cashout status is shown at the ticket level (BetTicketStatusView), not per selection
        let text = switch status.status {
        case .won:
            LocalizationProvider.string("won")
        case .lost:
            LocalizationProvider.string("lost")
        case .draw:
            LocalizationProvider.string("draw")
        case .cashedOut:
            LocalizationProvider.string("pending")
        }

        let backgroundColor = switch status.status {
        case .won:
            StyleProvider.Color.alertSuccess
        case .lost, .draw:
            StyleProvider.Color.backgroundGradient2
        case .cashedOut:
            StyleProvider.Color.alertWarning
        }

        let textColor = switch status.status {
        case .won, .cashedOut:
            StyleProvider.Color.allWhite
        case .lost:
            StyleProvider.Color.alertError
        case .draw:
            StyleProvider.Color.textPrimary
        }
        
        resultTagCapsuleViewModel.configure(with: CapsuleData(
            text: text.uppercased(),
            backgroundColor: backgroundColor,
            textColor: textColor,
            font: StyleProvider.fontWith(type: .bold, size: 10),
            horizontalPadding: 5.0,
            verticalPadding: 4.0
        ))
        
        updateLeftContentViewConstraint(to: resultTagCapsuleView.leadingAnchor)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("PreLive State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketSelectionViewModel.preLiveMock
        let ticketView = TicketSelectionView(viewModel: mockViewModel)
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = UIColor.systemGray2
        vc.view.addSubview(ticketView)
        
        NSLayoutConstraint.activate([
            ticketView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#Preview("Live State") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketSelectionViewModel.liveMock
        let ticketView = TicketSelectionView(viewModel: mockViewModel)
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = UIColor.systemGray2
        vc.view.addSubview(ticketView)
        
        NSLayoutConstraint.activate([
            ticketView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#Preview("Live Draw") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketSelectionViewModel.liveDrawMock
        let ticketView = TicketSelectionView(viewModel: mockViewModel)
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = UIColor.systemGray2
        vc.view.addSubview(ticketView)
        
        NSLayoutConstraint.activate([
            ticketView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#Preview("Long Team Names") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketSelectionViewModel.longTeamNamesMock
        let ticketView = TicketSelectionView(viewModel: mockViewModel)
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = UIColor.systemGray2
        vc.view.addSubview(ticketView)
        
        NSLayoutConstraint.activate([
            ticketView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#Preview("No Icons") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockTicketSelectionViewModel.noIconsMock
        let ticketView = TicketSelectionView(viewModel: mockViewModel)
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = UIColor.systemGray2
        vc.view.addSubview(ticketView)
        
        NSLayoutConstraint.activate([
            ticketView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            ticketView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            ticketView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#endif 
