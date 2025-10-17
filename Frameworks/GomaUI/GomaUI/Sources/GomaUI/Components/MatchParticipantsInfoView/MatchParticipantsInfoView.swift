import UIKit
import Combine
import SwiftUI

final public class MatchParticipantsInfoView: UIView {
    
    // MARK: - UI Components
    private lazy var containerStackView = Self.createContainerStackView()
    private lazy var horizontalLayoutView = Self.createHorizontalLayoutView()
    private lazy var verticalLayoutView = Self.createVerticalLayoutView()
    
    // MARK: - Horizontal Layout Components
    private lazy var homeParticipantLabel = Self.createParticipantLabel()
    private lazy var awayParticipantLabel = Self.createParticipantLabel()
    private lazy var centerStackView = Self.createCenterStackView()
    private lazy var dateLabel = Self.createDateLabel()
    private lazy var timeLabel = Self.createTimeLabel()
    private lazy var scoreLabel = Self.createScoreLabel()
    private lazy var matchTimeLabel = Self.createMatchTimeLabel()
    private lazy var liveIndicatorView = Self.createLiveIndicatorView()
    
    // MARK: - Vertical Layout Components
    private lazy var verticalHomeStackView = Self.createVerticalParticipantStackView()
    private lazy var verticalAwayStackView = Self.createVerticalParticipantStackView()
    private lazy var verticalHomeNameLabel = Self.createParticipantLabel()
    private lazy var verticalAwayNameLabel = Self.createParticipantLabel()
    private lazy var verticalHomeServingIndicator = Self.createServingIndicatorView()
    private lazy var verticalAwayServingIndicator = Self.createServingIndicatorView()
    private lazy var verticalDateLabel = Self.createVerticalDateLabel()
    private lazy var verticalTimeLabel = Self.createVerticalTimeLabel()
    private lazy var verticalMatchTimeLabel = Self.createVerticalMatchTimeLabel()
    private lazy var scoreView = Self.createScoreView()
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: MatchParticipantsInfoViewModelProtocol
    
    // MARK: - Public Properties
    public var onParticipantTapped: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: MatchParticipantsInfoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewCode
extension MatchParticipantsInfoView {
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }
    
    private func buildViewHierarchy() {
        addSubview(containerStackView)
        
        // Container holds both layout views
        containerStackView.addArrangedSubview(horizontalLayoutView)
        containerStackView.addArrangedSubview(verticalLayoutView)
        
        // Setup horizontal layout
        setupHorizontalLayout()
        
        // Setup vertical layout
        setupVerticalLayout()
    }
    
    private func setupHorizontalLayout() {
        horizontalLayoutView.addSubview(homeParticipantLabel)
        horizontalLayoutView.addSubview(awayParticipantLabel)
        horizontalLayoutView.addSubview(centerStackView)
        
        // Center stack contains date/time or score info
        centerStackView.addArrangedSubview(dateLabel)
        centerStackView.addArrangedSubview(timeLabel)
        centerStackView.addArrangedSubview(scoreLabel)
        centerStackView.addArrangedSubview(matchTimeLabel)
        centerStackView.addArrangedSubview(liveIndicatorView)
    }
    
    private func setupVerticalLayout() {
        verticalLayoutView.addSubview(verticalHomeStackView)
        verticalLayoutView.addSubview(verticalAwayStackView)
        verticalLayoutView.addSubview(verticalDateLabel)
        verticalLayoutView.addSubview(verticalTimeLabel)
        verticalLayoutView.addSubview(verticalMatchTimeLabel)
        verticalLayoutView.addSubview(scoreView)
        
        // Setup participant stacks with serving indicators
        verticalHomeStackView.addArrangedSubview(verticalHomeNameLabel)
        verticalHomeStackView.addArrangedSubview(verticalHomeServingIndicator)
        
        verticalAwayStackView.addArrangedSubview(verticalAwayNameLabel)
        verticalAwayStackView.addArrangedSubview(verticalAwayServingIndicator)
    }
    
    private func setupConstraints() {
        var allConstraints: [NSLayoutConstraint] = []
        
        // Container constraints
        allConstraints.append(contentsOf: [
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Horizontal layout constraints
        allConstraints.append(contentsOf: setupHorizontalConstraints())
        
        // Vertical layout constraints
        allConstraints.append(contentsOf: setupVerticalConstraints())
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    private func setupHorizontalConstraints() -> [NSLayoutConstraint] {
        return [
            // Home participant - left side
            homeParticipantLabel.leadingAnchor.constraint(equalTo: horizontalLayoutView.leadingAnchor),
            homeParticipantLabel.topAnchor.constraint(equalTo: horizontalLayoutView.topAnchor, constant: 4),
            homeParticipantLabel.centerYAnchor.constraint(equalTo: horizontalLayoutView.centerYAnchor),
            
            // Center stack - middle
            centerStackView.centerXAnchor.constraint(equalTo: horizontalLayoutView.centerXAnchor),
            centerStackView.centerYAnchor.constraint(equalTo: horizontalLayoutView.centerYAnchor),
            centerStackView.leadingAnchor.constraint(greaterThanOrEqualTo: homeParticipantLabel.trailingAnchor, constant: 8),
            centerStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 78),
            
            // Away participant - right side
            awayParticipantLabel.leadingAnchor.constraint(greaterThanOrEqualTo: centerStackView.trailingAnchor, constant: 8),
            awayParticipantLabel.trailingAnchor.constraint(equalTo: horizontalLayoutView.trailingAnchor),
            awayParticipantLabel.topAnchor.constraint(equalTo: horizontalLayoutView.topAnchor, constant: 4),
            awayParticipantLabel.centerYAnchor.constraint(equalTo: horizontalLayoutView.centerYAnchor),
            
            // Live indicator size
            liveIndicatorView.widthAnchor.constraint(equalToConstant: 8),
            liveIndicatorView.heightAnchor.constraint(equalToConstant: 8),
            
            // Minimum height
            horizontalLayoutView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ]
    }
    
    private func setupVerticalConstraints() -> [NSLayoutConstraint] {
        return [
            // Home participant stack
            verticalHomeStackView.leadingAnchor.constraint(equalTo: verticalLayoutView.leadingAnchor, constant: 12),
            verticalHomeStackView.topAnchor.constraint(equalTo: verticalLayoutView.topAnchor, constant: 13),
            
            // Away participant stack
            verticalAwayStackView.leadingAnchor.constraint(equalTo: verticalLayoutView.leadingAnchor, constant: 12),
            verticalAwayStackView.topAnchor.constraint(equalTo: verticalLayoutView.topAnchor, constant: 33),
            
            // Date/time labels on the right
            verticalDateLabel.trailingAnchor.constraint(equalTo: verticalLayoutView.trailingAnchor, constant: -12),
            verticalDateLabel.topAnchor.constraint(equalTo: verticalHomeNameLabel.topAnchor),
            verticalDateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: verticalHomeStackView.trailingAnchor, constant: 8),
            
            verticalTimeLabel.trailingAnchor.constraint(equalTo: verticalLayoutView.trailingAnchor, constant: -12),
            verticalTimeLabel.bottomAnchor.constraint(equalTo: verticalAwayNameLabel.bottomAnchor),
            verticalTimeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: verticalAwayStackView.trailingAnchor, constant: 8),
            
            verticalMatchTimeLabel.trailingAnchor.constraint(equalTo: verticalLayoutView.trailingAnchor, constant: -12),
            verticalMatchTimeLabel.bottomAnchor.constraint(equalTo: verticalLayoutView.bottomAnchor, constant: -6),
            
            // Score view
            scoreView.trailingAnchor.constraint(equalTo: verticalLayoutView.trailingAnchor, constant: -12),
            scoreView.topAnchor.constraint(equalTo: verticalLayoutView.topAnchor, constant: 13),
            scoreView.leadingAnchor.constraint(greaterThanOrEqualTo: verticalHomeStackView.trailingAnchor, constant: 8),
            
            // Serving indicators
            verticalHomeServingIndicator.widthAnchor.constraint(equalToConstant: 9),
            verticalHomeServingIndicator.heightAnchor.constraint(equalToConstant: 9),
            verticalAwayServingIndicator.widthAnchor.constraint(equalToConstant: 9),
            verticalAwayServingIndicator.heightAnchor.constraint(equalToConstant: 9),
            
            // Height constraint
            verticalLayoutView.heightAnchor.constraint(equalToConstant: 80)
        ]
    }
    
    private func setupAdditionalConfiguration() {
        backgroundColor = StyleProvider.Color.backgroundPrimary
        
        // Initially show horizontal layout
        horizontalLayoutView.isHidden = false
        verticalLayoutView.isHidden = true
    }
    
    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
        
        viewModel.scoreViewModelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scoreViewModel in
                if let scoreViewModel = scoreViewModel {
                    self?.scoreView.configure(with: scoreViewModel)
                }
            }
            .store(in: &cancellables)
    }
    
    private func render(state: MatchParticipantsDisplayState) {
        // Update layout visibility
        updateLayoutVisibility(for: state.displayMode)
        
        // Update participant names
        updateParticipantNames(state.matchData)
        
        // Update match state
        updateMatchState(state.matchData.matchState)
        
        // Update serving indicators
        updateServingIndicators(state.matchData.servingIndicator)
    }
    
    private func updateLayoutVisibility(for mode: MatchDisplayMode) {
        switch mode {
        case .horizontal:
            horizontalLayoutView.isHidden = false
            verticalLayoutView.isHidden = true
        case .vertical:
            horizontalLayoutView.isHidden = true
            verticalLayoutView.isHidden = false
        }
    }
    
    private func updateParticipantNames(_ data: MatchParticipantsData) {
        // Horizontal layout
        homeParticipantLabel.text = data.homeParticipantName
        awayParticipantLabel.text = data.awayParticipantName
        
        // Vertical layout
        verticalHomeNameLabel.text = data.homeParticipantName
        verticalAwayNameLabel.text = data.awayParticipantName
    }
    
    private func updateMatchState(_ state: MatchState) {
        switch state {
        case .preLive(let date, let time):
            // Horizontal layout
            dateLabel.text = date
            timeLabel.text = time
            dateLabel.isHidden = false
            timeLabel.isHidden = false
            scoreLabel.isHidden = true
            matchTimeLabel.isHidden = true
            liveIndicatorView.isHidden = true
            
            // Vertical layout
            verticalDateLabel.text = date
            verticalTimeLabel.text = time
            verticalDateLabel.isHidden = false
            verticalTimeLabel.isHidden = false
            verticalMatchTimeLabel.isHidden = true
            
        case .live(let score, let matchTime):
            // Horizontal layout
            scoreLabel.text = score
            matchTimeLabel.text = matchTime
            dateLabel.isHidden = true
            timeLabel.isHidden = true
            scoreLabel.isHidden = false
            matchTimeLabel.isHidden = matchTime == nil
            liveIndicatorView.isHidden = false
            
            // Vertical layout
            verticalDateLabel.isHidden = true
            verticalTimeLabel.isHidden = true
            verticalMatchTimeLabel.isHidden = false
            verticalMatchTimeLabel.text = matchTime ?? "Live"
            
        case .ended(let score):
            // Horizontal layout
            scoreLabel.text = score
            dateLabel.isHidden = true
            timeLabel.isHidden = true
            scoreLabel.isHidden = false
            matchTimeLabel.isHidden = true
            liveIndicatorView.isHidden = true
            
            // Vertical layout
            verticalDateLabel.isHidden = true
            verticalTimeLabel.isHidden = true
            verticalMatchTimeLabel.isHidden = false
            verticalMatchTimeLabel.text = "Ended"
        }
    }
    
    private func updateServingIndicators(_ indicator: ServingIndicator) {
        switch indicator {
        case .none:
            verticalHomeServingIndicator.isHidden = true
            verticalAwayServingIndicator.isHidden = true
        case .home:
            verticalHomeServingIndicator.isHidden = false
            verticalAwayServingIndicator.isHidden = true
        case .away:
            verticalHomeServingIndicator.isHidden = true
            verticalAwayServingIndicator.isHidden = false
        }
    }
    
}

// MARK: - UI Elements Factory
extension MatchParticipantsInfoView {
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }
    
    private static func createHorizontalLayoutView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }
    
    private static func createVerticalLayoutView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }
    
    private static func createParticipantLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }
    
    private static func createCenterStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.backgroundColor = .clear
        return stackView
    }
    
    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }
    
    private static func createTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }
    
    private static func createScoreLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 17)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }
    
    private static func createMatchTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 10)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }
    
    private static func createLiveIndicatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.liveTag
        view.layer.cornerRadius = 4
        return view
    }
    
    private static func createVerticalParticipantStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }
    
    private static func createVerticalDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 11)
        label.textColor = StyleProvider.Color.textSecondary
        label.textAlignment = .right
        return label
    }
    
    private static func createVerticalTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .right
        return label
    }
    
    private static func createVerticalMatchTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 11)
        label.textColor = StyleProvider.Color.textSecondary
        label.textAlignment = .right
        return label
    }
    
    private static func createServingIndicatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.layer.cornerRadius = 4.5
        return view
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
#Preview("MatchParticipantsInfoView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "MatchParticipantsInfoView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Horizontal Pre-Live
        let horizontalPreLiveView = MatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.horizontalPreLive)
        horizontalPreLiveView.translatesAutoresizingMaskIntoConstraints = false

        // Horizontal Live
        let horizontalLiveView = MatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.horizontalLive)
        horizontalLiveView.translatesAutoresizingMaskIntoConstraints = false

        // Vertical Tennis Live
        let verticalTennisView = MatchParticipantsInfoView(viewModel: MockMatchParticipantsInfoViewModel.verticalTennisLive)
        verticalTennisView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(horizontalPreLiveView)
        stackView.addArrangedSubview(horizontalLiveView)
        stackView.addArrangedSubview(verticalTennisView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),

            // Fixed heights for match views
            horizontalPreLiveView.heightAnchor.constraint(equalToConstant: 70),
            horizontalLiveView.heightAnchor.constraint(equalToConstant: 70),
            verticalTennisView.heightAnchor.constraint(equalToConstant: 80)
        ])

        return vc
    }
}
#endif
