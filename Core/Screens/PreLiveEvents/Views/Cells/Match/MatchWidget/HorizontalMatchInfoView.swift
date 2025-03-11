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
    // MARK: Publishers
    private(set) var homeTeamNamePublisher = CurrentValueSubject<String, Never>("")
    private(set) var awayTeamNamePublisher = CurrentValueSubject<String, Never>("")
    private(set) var startDateStringPublisher = CurrentValueSubject<String, Never>("")
    private(set) var startTimeStringPublisher = CurrentValueSubject<String, Never>("")
    private(set) var matchScorePublisher = CurrentValueSubject<String?, Never>(nil)

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

        // Update date and time
        self.updateDateAndTime(date: match.date)

        // Update score if available
        self.updateScore(match: match)
    }

    // MARK: Update Methods
    func updateDateAndTime(date: Date?) {

        guard
            let date = date
        else {
            self.startDateStringPublisher.send("")
            self.startTimeStringPublisher.send("")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        let dateString = dateFormatter.string(from: date)

        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: date)

        self.startDateStringPublisher.send(dateString)
        self.startTimeStringPublisher.send(timeString)
    }

    func updateScore(match: Match) {
        if let homeParticipantScore = match.homeParticipantScore, let awayParticipantScore = match.awayParticipantScore {
            let scoreString = "\(homeParticipantScore) - \(awayParticipantScore)"
            self.matchScorePublisher.send(scoreString)
        }
        else {
            self.matchScorePublisher.send(nil)
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

        // Bind date
        viewModel.startDateStringPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] date in
                self?.dateLabel.text = date
            }
            .store(in: &cancellables)

        // Bind time
        viewModel.startTimeStringPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] time in
                self?.timeLabel.text = time
            }
            .store(in: &cancellables)

        // Bind score
        viewModel.matchScorePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] score in
                if let score = score {
                    self?.resultLabel.text = score
                    self?.resultStackView.isHidden = false
                }
                else {
                    self?.resultStackView.isHidden = true
                }
            }
            .store(in: &cancellables)
    }

    // For backward compatibility
    func configure(homeParticipant: String, awayParticipant: String, date: String, time: String, result: String?) {
        self.homeParticipantNameLabel.text = homeParticipant
        self.awayParticipantNameLabel.text = awayParticipant
        self.dateLabel.text = date
        self.timeLabel.text = time

        if let result = result {
            self.resultLabel.text = result
            self.resultStackView.isHidden = false
        }
        else {
            self.resultStackView.isHidden = true
        }
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
        return stackView
    }

    private static func createResultLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 17)
        label.numberOfLines = 1
        label.textAlignment = .center
        let heightConstraint = label.heightAnchor.constraint(equalToConstant: 15)
        heightConstraint.isActive = true
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.homeParticipantNameLabel)
        self.addSubview(self.awayParticipantNameLabel)
        self.addSubview(self.dateStackView)
        self.addSubview(self.resultStackView)

        // Add subviews to date stack view
        self.dateStackView.addArrangedSubview(self.dateLabel)
        self.dateStackView.addArrangedSubview(self.timeLabel)

        // Add subviews to result stack view
        self.resultStackView.addArrangedSubview(self.resultLabel)

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
            self.dateStackView.leadingAnchor.constraint(equalTo: self.homeParticipantNameLabel.trailingAnchor, constant: 10),

            // Away participant label - right side
            self.awayParticipantNameLabel.leadingAnchor.constraint(equalTo: self.dateStackView.trailingAnchor, constant: 10),
            self.awayParticipantNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.awayParticipantNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            self.awayParticipantNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            // Result stack view - center (overlays date stack view when visible)
            self.resultStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.resultLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -4),

            // Minimum height constraint
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 67)
        ])
    }
}

// MARK: - SwiftUI Previews
@available(iOS 17.0, *)
#Preview("HorizontalMatchInfoView - Standard") {
    PreviewUIView {
        let view = HorizontalMatchInfoView()
        // let match = PreviewModelsHelper.createFootballMatch()
        // let viewModel = HorizontalMatchInfoViewModel(match: match)
        // view.configure(with: viewModel)
        
        view.configure(homeParticipant: "Real Madrid",
                       awayParticipant: "Barcelona",
                       date: "11 March",
                       time: "20:30",
                       result: "0 - 0")
        view.backgroundColor = .lightGray
        return view
    }
    .frame(width: 300, height: 67)
}

@available(iOS 17.0, *)
#Preview("HorizontalMatchInfoView - With Result") {
    PreviewUIView {
        let view = HorizontalMatchInfoView()
        let match = PreviewModelsHelper.createLiveFootballMatch()
        let viewModel = HorizontalMatchInfoViewModel(match: match)
        view.configure(with: viewModel)
        return view
    }
    .frame(width: 300, height: 67)
}

@available(iOS 17.0, *)
#Preview("HorizontalMatchInfoView - Multiple States") {
    VStack(spacing: 20) {
        PreviewUIView {
            let view = HorizontalMatchInfoView()
            let match = PreviewModelsHelper.createFootballMatch()
            let viewModel = HorizontalMatchInfoViewModel(match: match)
            view.configure(with: viewModel)
            return view
        }
        .frame(width: 300, height: 67)

        PreviewUIView {
            let view = HorizontalMatchInfoView()
            let match = PreviewModelsHelper.createLiveFootballMatch()
            let viewModel = HorizontalMatchInfoViewModel(match: match)
            view.configure(with: viewModel)
            return view
        }
        .frame(width: 300, height: 67)

        PreviewUIView {
            let view = HorizontalMatchInfoView()
            let match = PreviewModelsHelper.createCompletedFootballMatch()
            let viewModel = HorizontalMatchInfoViewModel(match: match)
            view.configure(with: viewModel)
            return view
        }
        .frame(width: 300, height: 67)
    }
    .padding()
}
