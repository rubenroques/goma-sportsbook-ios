//
//  VerticalMatchInfoView.swift
//  Sportsbook
//
//  Created by Claude on 2024-07-01.
//

import UIKit
import SwiftUI
import Combine

// MARK: - ViewModel
class VerticalMatchInfoViewModel {
    // MARK: Display State
    enum DisplayState {
        case preLive(date: String, time: String)
        case live(matchTimeStatus: String)
        case ended
    }
    
    // MARK: Serving Indicator
    enum ServingIndicator {
        case none
        case home
        case away
    }
    
    // MARK: Publishers
    private(set) var homeTeamNamePublisher = CurrentValueSubject<String, Never>("")
    private(set) var awayTeamNamePublisher = CurrentValueSubject<String, Never>("")
    private(set) var displayStatePublisher = CurrentValueSubject<DisplayState, Never>(.preLive(date: "", time: ""))
    private(set) var servingIndicatorPublisher = CurrentValueSubject<ServingIndicator, Never>(.none)
    private(set) var detailedScorePublisher = CurrentValueSubject<(sportCode: String, score: [String: Score]), Never>(("", [:]))
    private(set) var marketNamePublisher = CurrentValueSubject<String, Never>("")
    
    // MARK: Initialization
    init(homeTeamName: String = "",
         awayTeamName: String = "",
         displayState: DisplayState = .preLive(date: "", time: ""),
         servingIndicator: ServingIndicator = .none,
         detailedScore: (sportCode: String, score: [String: Score]) = ("", [:]),
         marketName: String = "") {
        
        self.homeTeamNamePublisher.send(homeTeamName)
        self.awayTeamNamePublisher.send(awayTeamName)
        self.displayStatePublisher.send(displayState)
        self.servingIndicatorPublisher.send(servingIndicator)
        self.detailedScorePublisher.send(detailedScore)
        self.marketNamePublisher.send(marketName)
    }
    
    // MARK: Configuration
    func configure(homeTeamName: String,
                   awayTeamName: String,
                   displayState: DisplayState,
                   servingIndicator: ServingIndicator = .none,
                   detailedScore: (sportCode: String, score: [String: Score]) = ("", [:]),
                   marketName: String = "") {
        
        self.homeTeamNamePublisher.send(homeTeamName)
        self.awayTeamNamePublisher.send(awayTeamName)
        self.displayStatePublisher.send(displayState)
        self.servingIndicatorPublisher.send(servingIndicator)
        self.detailedScorePublisher.send(detailedScore)
        self.marketNamePublisher.send(marketName)
    }
}

class VerticalMatchInfoView: UIView {
    
    // MARK: Private Properties
    private lazy var topSeparatorAlphaLineView: FadingView = Self.createTopSeparatorAlphaLineView()
    private lazy var detailedScoreView: ScoreView = Self.createDetailedScoreView()
    private lazy var homeNameLabel: UILabel = Self.createHomeNameLabel()
    private lazy var awayNameLabel: UILabel = Self.createAwayNameLabel()
    private lazy var homeServingIndicatorView: UIView = Self.createHomeServingIndicatorView()
    private lazy var awayServingIndicatorView: UIView = Self.createAwayServingIndicatorView()
    private lazy var dateNewLabel: UILabel = Self.createDateNewLabel()
    private lazy var timeNewLabel: UILabel = Self.createTimeNewLabel()
    private lazy var matchTimeStatusNewLabel: UILabel = Self.createMatchTimeStatusNewLabel()
    private lazy var marketNamePillLabelView: PillLabelView = Self.createMarketNamePillLabelView()
    private lazy var homeElementsStackView: UIStackView = Self.createHomeElementsStackView()
    private lazy var awayElementsStackView: UIStackView = Self.createAwayElementsStackView()
    
    // Constraints that need to be stored for later adjustment
    private var homeContentRedesignTopConstraint: NSLayoutConstraint!
    private var awayContentRedesignTopConstraint: NSLayoutConstraint!
    private var homeToRightConstraint: NSLayoutConstraint!
    private var awayToRightConstraint: NSLayoutConstraint!
    
    // MARK: ViewModel
    private var viewModel: VerticalMatchInfoViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        self.setupWithTheme()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupSubviews()
        self.setupWithTheme()
    }
    
    // MARK: Theme Setup
    private func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundCards
        self.topSeparatorAlphaLineView.backgroundColor = UIColor.App.highlightPrimary
        
        self.homeNameLabel.textColor = UIColor.App.textPrimary
        self.awayNameLabel.textColor = UIColor.App.textPrimary
        
        self.homeServingIndicatorView.backgroundColor = UIColor.App.highlightPrimary
        self.awayServingIndicatorView.backgroundColor = UIColor.App.highlightPrimary
        
        self.dateNewLabel.textColor = UIColor.App.textSecondary
        self.timeNewLabel.textColor = UIColor.App.textPrimary
        self.matchTimeStatusNewLabel.textColor = UIColor.App.textSecondary
        
        self.detailedScoreView.setupWithTheme()
    }
    
    // MARK: Configuration
    func configure(with viewModel: VerticalMatchInfoViewModel) {
        self.viewModel = viewModel
        self.setupBindings()
    }
    
    private func setupBindings() {
        guard let viewModel = viewModel else { return }
        
        // Clear previous cancellables
        cancellables.removeAll()
        
        // Bind home team name
        viewModel.homeTeamNamePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] name in
                self?.homeNameLabel.text = name
            }
            .store(in: &cancellables)
        
        // Bind away team name
        viewModel.awayTeamNamePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] name in
                self?.awayNameLabel.text = name
            }
            .store(in: &cancellables)
        
        // Bind display state
        viewModel.displayStatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .preLive(let date, let time):
                    self?.dateNewLabel.text = date
                    self?.timeNewLabel.text = time
                    self?.dateNewLabel.isHidden = false
                    self?.timeNewLabel.isHidden = false
                    self?.matchTimeStatusNewLabel.isHidden = true
                    
                case .live(let matchTimeStatus):
                    self?.dateNewLabel.isHidden = true
                    self?.timeNewLabel.isHidden = true
                    self?.matchTimeStatusNewLabel.isHidden = false
                    self?.matchTimeStatusNewLabel.text = matchTimeStatus
                    
                case .ended:
                    self?.dateNewLabel.isHidden = true
                    self?.timeNewLabel.isHidden = true
                    self?.matchTimeStatusNewLabel.isHidden = false
                    self?.matchTimeStatusNewLabel.text = localized("live_status_ended")
                }
            }
            .store(in: &cancellables)
        
        // Bind serving indicator
        viewModel.servingIndicatorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] indicator in
                switch indicator {
                case .none:
                    self?.homeServingIndicatorView.isHidden = true
                    self?.awayServingIndicatorView.isHidden = true
                case .home:
                    self?.homeServingIndicatorView.isHidden = false
                    self?.awayServingIndicatorView.isHidden = true
                case .away:
                    self?.homeServingIndicatorView.isHidden = true
                    self?.awayServingIndicatorView.isHidden = false
                }
            }
            .store(in: &cancellables)
        
        // Bind detailed score
        viewModel.detailedScorePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] scoreData in
                self?.detailedScoreView.sportCode = scoreData.sportCode
                self?.detailedScoreView.updateScores(scoreData.score)
            }
            .store(in: &cancellables)
        
        // Bind market name
        viewModel.marketNamePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] marketName in
                self?.marketNamePillLabelView.title = marketName
                self?.marketNamePillLabelView.isHidden = marketName.isEmpty
            }
            .store(in: &cancellables)
    }
    
}

// MARK: - Factory Methods
extension VerticalMatchInfoView {
    private static func createTopSeparatorAlphaLineView() -> FadingView {
        let fadingView = FadingView()
        fadingView.translatesAutoresizingMaskIntoConstraints = false
        fadingView.colors = [.clear, .black, .black, .clear]
        fadingView.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadingView.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadingView.fadeLocations = [0.0, 0.42, 0.58, 1.0]
        return fadingView
    }
    
    private static func createDetailedScoreView() -> ScoreView {
        let scoreView = ScoreView(sportCode: "", score: [:])
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        return scoreView
    }
    
    private static func createHomeNameLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createAwayNameLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createHomeServingIndicatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createAwayServingIndicatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createDateNewLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 11)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createTimeNewLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createMatchTimeStatusNewLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 11)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createMarketNamePillLabelView() -> PillLabelView {
        let marketNamePillLabelView = PillLabelView()
        marketNamePillLabelView.translatesAutoresizingMaskIntoConstraints = false
        return marketNamePillLabelView
    }
    
    private static func createHomeElementsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }
    
    private static func createAwayElementsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }
    
    
    // MARK: Layout Setup
    private func setupSubviews() {
        self.addSubview(self.topSeparatorAlphaLineView)
        self.addSubview(self.detailedScoreView)
        
        self.homeElementsStackView.addArrangedSubview(self.homeNameLabel)
        self.homeElementsStackView.addArrangedSubview(self.homeServingIndicatorView)
        
        self.addSubview(self.homeElementsStackView)
        
        self.awayElementsStackView.addArrangedSubview(self.awayNameLabel)
        self.awayElementsStackView.addArrangedSubview(self.awayServingIndicatorView)
        
        self.addSubview(self.awayElementsStackView)
        
        self.addSubview(self.dateNewLabel)
        self.addSubview(self.timeNewLabel)
        self.addSubview(self.matchTimeStatusNewLabel)
        self.addSubview(self.marketNamePillLabelView)
        
        self.homeContentRedesignTopConstraint = self.homeElementsStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 13)
        self.awayContentRedesignTopConstraint = self.awayElementsStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 33)
        
        self.homeToRightConstraint = self.dateNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.homeElementsStackView.trailingAnchor, constant: 5)
        self.awayToRightConstraint = self.timeNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.awayElementsStackView.trailingAnchor, constant: 5)
        
        self.initConstraints()
        
        // Set initial state
        self.homeServingIndicatorView.isHidden = true
        self.awayServingIndicatorView.isHidden = true
        self.matchTimeStatusNewLabel.isHidden = true
        self.marketNamePillLabelView.isHidden = true
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.topSeparatorAlphaLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.topSeparatorAlphaLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.topSeparatorAlphaLineView.heightAnchor.constraint(equalToConstant: 1),
            self.topSeparatorAlphaLineView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            
            self.detailedScoreView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            self.detailedScoreView.topAnchor.constraint(equalTo: self.topAnchor, constant: 13),
            
            self.detailedScoreView.leadingAnchor.constraint(greaterThanOrEqualTo: self.homeElementsStackView.trailingAnchor, constant: 5),
            self.homeContentRedesignTopConstraint,
            self.homeNameLabel.heightAnchor.constraint(equalTo: self.detailedScoreView.heightAnchor, multiplier: 0.5, constant: 1),
            
            self.detailedScoreView.leadingAnchor.constraint(greaterThanOrEqualTo: self.awayElementsStackView.trailingAnchor, constant: 5),
            self.awayContentRedesignTopConstraint,
            self.awayNameLabel.heightAnchor.constraint(equalTo: self.detailedScoreView.heightAnchor, multiplier: 0.5, constant: 1),
            
            self.homeElementsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            self.awayElementsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            
            self.homeServingIndicatorView.widthAnchor.constraint(equalTo: self.homeServingIndicatorView.heightAnchor),
            self.homeServingIndicatorView.widthAnchor.constraint(equalToConstant: 9),
            
            self.awayServingIndicatorView.widthAnchor.constraint(equalTo: self.awayServingIndicatorView.heightAnchor),
            self.awayServingIndicatorView.widthAnchor.constraint(equalToConstant: 9),
            
            self.dateNewLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            self.dateNewLabel.topAnchor.constraint(equalTo: self.homeNameLabel.topAnchor),
            self.homeToRightConstraint,
            
            self.timeNewLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            self.timeNewLabel.bottomAnchor.constraint(equalTo: self.awayNameLabel.bottomAnchor),
            self.awayToRightConstraint,
            
            self.matchTimeStatusNewLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            self.matchTimeStatusNewLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6),
            
            self.marketNamePillLabelView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 11),
            self.marketNamePillLabelView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            
            self.matchTimeStatusNewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.marketNamePillLabelView.trailingAnchor, constant: 5),
            
            // Minimum height constraint
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
        
        self.marketNamePillLabelView.setContentCompressionResistancePriority(UILayoutPriority(990), for: .horizontal)
        self.matchTimeStatusNewLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.homeNameLabel.setContentHuggingPriority(UILayoutPriority(990), for: .horizontal)
        self.awayNameLabel.setContentHuggingPriority(UILayoutPriority(990), for: .horizontal)
    }
}

// MARK: - SwiftUI Previews
@available(iOS 17.0, *)
#Preview("VerticalMatchInfoView - Pre-Live") {
    PreviewUIView {
        let view = VerticalMatchInfoView()
        let viewModel = VerticalMatchInfoViewModel(
            homeTeamName: "Real Madrid",
            awayTeamName: "Barcelona",
            displayState: .preLive(date: "Jul 24", time: "20:30"),
            servingIndicator: .none,
            detailedScore: ("FTB", [:]),
            marketName: "Match Winner"
        )
        view.configure(with: viewModel)
        view.backgroundColor = UIColor.App.backgroundCards
        return view
    }
    .frame(width: 300, height: 100)
}
/*
@available(iOS 17.0, *)
#Preview("VerticalMatchInfoView - Live") {
    PreviewUIView {
        let view = VerticalMatchInfoView()
        let viewModel = VerticalMatchInfoViewModel(
            homeTeamName: "Manchester United",
            awayTeamName: "Liverpool",
            displayState: .live(matchTimeStatus: "45' - 1st Half"),
            servingIndicator: .home,
            detailedScore: ("FTB", [:]),
            marketName: "Match Winner"
        )
        view.configure(with: viewModel)
        view.backgroundColor = UIColor.App.backgroundCards
        return view
    }
    .frame(width: 300, height: 100)
}

@available(iOS 17.0, *)
#Preview("VerticalMatchInfoView - Ended") {
    PreviewUIView {
        let view = VerticalMatchInfoView()
        let viewModel = VerticalMatchInfoViewModel(
            homeTeamName: "Bayern Munich",
            awayTeamName: "Dortmund",
            displayState: .ended,
            servingIndicator: .none,
            detailedScore: ("FTB", [:]),
            marketName: "Match Winner"
        )
        view.configure(with: viewModel)
        view.backgroundColor = UIColor.App.backgroundCards
        return view
    }
    .frame(width: 300, height: 100)
}

@available(iOS 17.0, *)
#Preview("VerticalMatchInfoView - Tennis with Serving") {
    PreviewUIView {
        let view = VerticalMatchInfoView()
        let viewModel = VerticalMatchInfoViewModel(
            homeTeamName: "Djokovic",
            awayTeamName: "Nadal",
            displayState: .live(matchTimeStatus: "3rd Set"),
            servingIndicator: .away,
            detailedScore: ("TNS", [:]),
            marketName: "Match Winner"
        )
        view.configure(with: viewModel)
        view.backgroundColor = UIColor.App.backgroundCards
        return view
    }
    .frame(width: 300, height: 100)
}
*/
