//
//  HorizontalMatchInfoView.swift
//  Sportsbook
//
//  Created by Claude on 2024-07-01.
//

import UIKit
import SwiftUI
import Combine

// MARK: - ViewModel
class HorizontalMatchInfoViewModel {
    // MARK: Display State
    enum DisplayState {
        case preLive(date: String, time: String)
        case live(score: String, matchTime: String?)
        case ended(score: String)
    }

    // MARK: Publishers
    private(set) var homeTeamNamePublisher = CurrentValueSubject<String, Never>("")
    private(set) var awayTeamNamePublisher = CurrentValueSubject<String, Never>("")
    private(set) var displayStatePublisher = CurrentValueSubject<DisplayState, Never>(.preLive(date: "", time: ""))

    // MARK: Properties
    private var match: Match?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Initialization
    init(match: Match? = nil) {
        if let match = match {
            self.configure(with: match)
        }
    }

    // MARK: Configuration
    func configure(with match: Match) {
        self.match = match

        // Update team names
        self.homeTeamNamePublisher.send(match.homeParticipant.name)
        self.awayTeamNamePublisher.send(match.awayParticipant.name)

        // Update display state based on match status
        self.updateDisplayState(match: match)
    }

    // MARK: Update Methods
    private func formatDate(_ date: Date?) -> (dateString: String, timeString: String) {
        guard let date = date else {
            return ("", "")
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let dateString = dateFormatter.string(from: date)

        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: date)

        return (dateString, timeString)
    }

    private func formatScore(homeScore: Int?, awayScore: Int?) -> String {
        guard let homeScore = homeScore, let awayScore = awayScore else {
            return ""
        }
        return "\(homeScore) - \(awayScore)"
    }

    func updateDisplayState(match: Match) {
        switch match.status {
        case .notStarted:
            let (dateString, timeString) = formatDate(match.date)
            self.displayStatePublisher.send(.preLive(date: dateString, time: timeString))

        case .inProgress:
            let score = formatScore(homeScore: match.homeParticipantScore, awayScore: match.awayParticipantScore)
            self.displayStatePublisher.send(.live(score: score, matchTime: match.matchTime))

        case .ended:
            let score = formatScore(homeScore: match.homeParticipantScore, awayScore: match.awayParticipantScore)
            self.displayStatePublisher.send(.ended(score: score))

        case .unknown:
            // Default to pre-live if status is unknown
            let (dateString, timeString) = formatDate(match.date)
            self.displayStatePublisher.send(.preLive(date: dateString, time: timeString))
        }
    }
}

class HorizontalMatchInfoView: UIView {

    // MARK: Private Properties
    private lazy var homeParticipantNameLabel: UILabel = Self.createHomeParticipantNameLabel()
    private lazy var awayParticipantNameLabel: UILabel = Self.createAwayParticipantNameLabel()
    private lazy var dateStackView: UIStackView = Self.createDateStackView()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var timeLabel: UILabel = Self.createTimeLabel()
    private lazy var resultStackView: UIStackView = Self.createResultStackView()
    private lazy var resultLabel: UILabel = Self.createResultLabel()
    private lazy var matchTimeStackView: UIStackView = Self.createMatchTimeStackView()
    private lazy var matchTimeLabel: UILabel = Self.createMatchTimeLabel()
    private lazy var liveMatchDotBaseView: UIView = Self.createLiveMatchDotBaseView()
    private lazy var liveMatchDotImageView: UIImageView = Self.createLiveMatchDotImageView()

    // MARK: ViewModel
    private var viewModel: HorizontalMatchInfoViewModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.backgroundColor = .clear

        self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
        self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary

        self.dateLabel.textColor = UIColor.App.textSecondary
        self.timeLabel.textColor = UIColor.App.textPrimary

        self.resultLabel.textColor = UIColor.App.textPrimary
        self.matchTimeLabel.textColor = UIColor.App.textSecondary

        self.liveMatchDotBaseView.backgroundColor = .clear
    }

    // MARK: Configuration
    func configure(with viewModel: HorizontalMatchInfoViewModel) {
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
                self?.homeParticipantNameLabel.text = name
            }
            .store(in: &cancellables)

        // Bind away team name
        viewModel.awayTeamNamePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] name in
                self?.awayParticipantNameLabel.text = name
            }
            .store(in: &cancellables)

        // Bind display state
        viewModel.displayStatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .preLive(let date, let time):
                    self?.dateLabel.text = date
                    self?.timeLabel.text = time
                    self?.dateStackView.isHidden = false
                    self?.resultStackView.isHidden = true
                    self?.liveMatchDotBaseView.isHidden = true

                case .live(let score, let matchTime):
                    self?.resultLabel.text = score
                    self?.matchTimeLabel.text = matchTime
                    self?.matchTimeLabel.isHidden = matchTime == nil
                    self?.dateStackView.isHidden = true
                    self?.resultStackView.isHidden = false
                    self?.liveMatchDotBaseView.isHidden = false

                case .ended(let score):
                    self?.resultLabel.text = score
                    self?.matchTimeLabel.isHidden = true
                    self?.dateStackView.isHidden = true
                    self?.resultStackView.isHidden = false
                    self?.liveMatchDotBaseView.isHidden = true
                }
            }
            .store(in: &cancellables)
    }
}

//
// MARK: Subviews initialization and setup
//
extension HorizontalMatchInfoView {

    private static func createHomeParticipantNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }

    private static func createAwayParticipantNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }

    private static func createDateStackView() -> UIStackView {
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
        label.font = AppFont.with(type: .medium, size: 12)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createResultStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.spacing = 2
        return stackView
    }

    private static func createResultLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 17)
        label.numberOfLines = 1
        label.textAlignment = .center
        let heightConstraint = label.heightAnchor.constraint(equalToConstant: 17)
        heightConstraint.isActive = true
        return label
    }

    private static func createMatchTimeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        stackView.spacing = 2
        return stackView
    }

    private static func createMatchTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 10)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createLiveMatchDotBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    private static func createLiveMatchDotImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icon_live")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func setupSubviews() {
        self.addSubview(self.homeParticipantNameLabel)
        self.addSubview(self.awayParticipantNameLabel)
        self.addSubview(self.dateStackView)
        self.addSubview(self.resultStackView)

        // Add subviews to date stack view
        self.dateStackView.addArrangedSubview(self.dateLabel)
        self.dateStackView.addArrangedSubview(self.timeLabel)

        // Add live match dot
        self.liveMatchDotBaseView.addSubview(self.liveMatchDotImageView)
        self.liveMatchDotBaseView.isHidden = true

        self.matchTimeStackView.addArrangedSubview(self.matchTimeLabel)
        self.matchTimeStackView.addArrangedSubview(self.liveMatchDotBaseView)

        // Add subviews to result stack view
        self.resultStackView.addArrangedSubview(self.matchTimeStackView)
        self.resultStackView.addArrangedSubview(self.resultLabel)

        // Set initial state
        self.matchTimeLabel.isHidden = true
        self.resultStackView.isHidden = true

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Home participant label - left side
            self.homeParticipantNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.homeParticipantNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            self.homeParticipantNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            // Date stack view - center
            self.dateStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.dateStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.dateStackView.leadingAnchor.constraint(equalTo: self.homeParticipantNameLabel.trailingAnchor, constant: -1),
            self.dateStackView.widthAnchor.constraint(equalToConstant: 78),

            // Away participant label - right side
            self.awayParticipantNameLabel.leadingAnchor.constraint(equalTo: self.dateStackView.trailingAnchor, constant: -1),
            self.awayParticipantNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.awayParticipantNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            self.awayParticipantNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            // Result stack view - center (overlays date stack view when visible)
            self.resultStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.resultLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            // Minimum height constraint
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 67),

            // Live match dot base view constraints
            self.liveMatchDotBaseView.widthAnchor.constraint(equalToConstant: 8),
            self.liveMatchDotBaseView.heightAnchor.constraint(equalTo: self.liveMatchDotBaseView.widthAnchor, multiplier: 1),

            // Live match dot image view constraints
            self.liveMatchDotImageView.centerXAnchor.constraint(equalTo: self.liveMatchDotBaseView.centerXAnchor),
            self.liveMatchDotImageView.centerYAnchor.constraint(equalTo: self.liveMatchDotBaseView.centerYAnchor),
            self.liveMatchDotImageView.widthAnchor.constraint(equalTo: self.liveMatchDotBaseView.widthAnchor),
            self.liveMatchDotImageView.heightAnchor.constraint(equalTo: self.liveMatchDotBaseView.heightAnchor)
        ])
    }
}

@available(iOS 17.0, *)
#Preview("HorizontalMatchInfoView - All States") {
    VStack(spacing: 20) {
        PreviewUIView {
            let view = HorizontalMatchInfoView()
            let match = PreviewModelsHelper.createFootballMatch()
            let viewModel = HorizontalMatchInfoViewModel(match: match)
            view.configure(with: viewModel)
            view.backgroundColor = .systemGray6
            return view
        }
        .frame(width: 300, height: 67)

        PreviewUIView {
            let view = HorizontalMatchInfoView()
            let match = PreviewModelsHelper.createLiveFootballMatch()
            let viewModel = HorizontalMatchInfoViewModel(match: match)
            view.configure(with: viewModel)
            view.backgroundColor = .systemGray6
            return view
        }
        .frame(width: 300, height: 67)

        PreviewUIView {
            let view = HorizontalMatchInfoView()
            let match = PreviewModelsHelper.createCompletedFootballMatch()
            let viewModel = HorizontalMatchInfoViewModel(match: match)
            view.configure(with: viewModel)
            view.backgroundColor = .systemGray6
            return view
        }
        .frame(width: 300, height: 67)
    }
    .padding()
}

// MARK: - SwiftUI Previews
@available(iOS 17.0, *)
#Preview("HorizontalMatchInfoView - Pre-Live") {
    PreviewUIView {
        let match = PreviewModelsHelper.createFootballMatch()
        let viewModel = HorizontalMatchInfoViewModel(match: match)

        let view = HorizontalMatchInfoView()
        view.configure(with: viewModel)

        view.backgroundColor = .systemGray6
        return view
    }
    .frame(width: 300, height: 67)
}

@available(iOS 17.0, *)
#Preview("HorizontalMatchInfoView - Live") {
    PreviewUIView {
        let match = PreviewModelsHelper.createLiveFootballMatch()
        let viewModel = HorizontalMatchInfoViewModel(match: match)

        let view = HorizontalMatchInfoView()
        view.configure(with: viewModel)

        view.backgroundColor = .systemGray6
        return view
    }
    .frame(width: 300, height: 67)
}

@available(iOS 17.0, *)
#Preview("HorizontalMatchInfoView - Ended") {
    PreviewUIView {
        let match = PreviewModelsHelper.createCompletedFootballMatch()
        let viewModel = HorizontalMatchInfoViewModel(match: match)

        let view = HorizontalMatchInfoView()
        view.configure(with: viewModel)

        view.backgroundColor = .systemGray6
        return view
    }
    .frame(width: 300, height: 67)
}

