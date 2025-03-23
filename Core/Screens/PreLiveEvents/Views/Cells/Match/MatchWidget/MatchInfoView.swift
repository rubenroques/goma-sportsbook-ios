//
//  MatchInfoView.swift
//  Sportsbook
//
//  Created by Claude on 2024-07-03.
//

import UIKit
import SwiftUI
import Combine

// MARK: - ViewModel
class MatchInfoViewModel {
    // MARK: Display Mode
    enum DisplayMode {
        case horizontal
        case vertical
    }

    // MARK: Display State
    enum DisplayState {
        case preLive(date: String, time: String)
        case live(score: String, matchTime: String?)
        case ended(score: String)
    }

    // MARK: Serving Indicator
    enum ServingIndicator {
        case none
        case home
        case away
    }

    // MARK: Publishers
    private(set) var displayModePublisher = CurrentValueSubject<DisplayMode, Never>(.horizontal)
    private(set) var homeTeamNamePublisher = CurrentValueSubject<String, Never>("")
    private(set) var awayTeamNamePublisher = CurrentValueSubject<String, Never>("")
    private(set) var displayStatePublisher = CurrentValueSubject<DisplayState, Never>(.preLive(date: "", time: ""))
    private(set) var servingIndicatorPublisher = CurrentValueSubject<ServingIndicator, Never>(.none)
    private(set) var detailedScorePublisher = CurrentValueSubject<(sportCode: String, score: [String: Score]), Never>(("", [:]))
    private(set) var marketNamePublisher = CurrentValueSubject<String, Never>("")

    // MARK: Initialization
    init(displayMode: DisplayMode = .horizontal,
         homeTeamName: String = "",
         awayTeamName: String = "",
         displayState: DisplayState = .preLive(date: "", time: ""),
         servingIndicator: ServingIndicator = .none,
         detailedScore: (sportCode: String, score: [String: Score]) = ("", [:]),
         marketName: String = "") {

        self.displayModePublisher.send(displayMode)
        self.homeTeamNamePublisher.send(homeTeamName)
        self.awayTeamNamePublisher.send(awayTeamName)
        self.displayStatePublisher.send(displayState)
        self.servingIndicatorPublisher.send(servingIndicator)
        self.detailedScorePublisher.send(detailedScore)
        self.marketNamePublisher.send(marketName)
    }

    // MARK: Configuration Methods
    func setDisplayMode(_ mode: DisplayMode) {
        self.displayModePublisher.send(mode)
    }

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

class MatchInfoView: UIView {

    // MARK: Private Properties
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    private lazy var horizontalMatchInfoView: HorizontalMatchInfoView = Self.createHorizontalMatchInfoView()
    private lazy var verticalMatchInfoView: VerticalMatchInfoView = Self.createVerticalMatchInfoView()

    // MARK: ViewModel
    private var viewModel: MatchInfoViewModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime Cycle
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

    private func setupWithTheme() {
        self.backgroundColor = .clear
        self.containerStackView.backgroundColor = .clear
    }

    // MARK: Configuration
    func configure(with viewModel: MatchInfoViewModel) {
        self.viewModel = viewModel
        self.setupBindings()
    }

    func cleanupForReuse() {
        self.viewModel = nil
        self.cancellables.removeAll()
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        // Clear previous cancellables
        self.cancellables.removeAll()

        // Bind display mode
        viewModel.displayModePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayMode in
                switch displayMode {
                case .horizontal:
                    self?.horizontalMatchInfoView.isHidden = false
                    self?.verticalMatchInfoView.isHidden = true
                case .vertical:
                    self?.horizontalMatchInfoView.isHidden = true
                    self?.verticalMatchInfoView.isHidden = false
                }
            }
            .store(in: &self.cancellables)

        // Create a binding for the horizontal view
        Publishers.CombineLatest3(
            viewModel.homeTeamNamePublisher,
            viewModel.awayTeamNamePublisher,
            viewModel.displayStatePublisher
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] homeTeamName, awayTeamName, displayState in
            // Create appropriate HorizontalMatchInfoViewModel from parent data
            let horizontalState: HorizontalMatchInfoViewModel.DisplayState

            switch displayState {
            case .preLive(let date, let time):
                horizontalState = .preLive(date: date, time: time)

            case .live(let score, let matchTime):
                horizontalState = .live(score: score, matchTime: matchTime)

            case .ended(let score):
                horizontalState = .ended(score: score)
            }

            let horizontalViewModel = HorizontalMatchInfoViewModel(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                displayState: horizontalState
            )

            self?.horizontalMatchInfoView.configure(with: horizontalViewModel)
        }
        .store(in: &self.cancellables)

        // Create a binding for the vertical view
        Publishers.CombineLatest(
            Publishers.CombineLatest3(
                viewModel.homeTeamNamePublisher,
                viewModel.awayTeamNamePublisher,
                viewModel.displayStatePublisher
            ),
            Publishers.CombineLatest3(
                viewModel.detailedScorePublisher,
                viewModel.marketNamePublisher,
                viewModel.servingIndicatorPublisher
            )
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] firstGroup, secondGroup in
            let (homeTeamName, awayTeamName, displayState) = firstGroup
            let (detailedScore, marketName, servingIndicator) = secondGroup

            // Create appropriate VerticalMatchInfoViewModel from parent data
            let verticalState: VerticalMatchInfoViewModel.DisplayState

            switch displayState {
            case .preLive(let date, let time):
                verticalState = .preLive(date: date, time: time)

            case .live(_, let matchTime):
                verticalState = .live(matchTimeStatus: matchTime ?? "")

            case .ended:
                verticalState = .ended
            }

            let verticalServingIndicator: VerticalMatchInfoViewModel.ServingIndicator
            switch servingIndicator {
            case .none:
                verticalServingIndicator = .none
            case .home:
                verticalServingIndicator = .home
            case .away:
                verticalServingIndicator = .away
            }

            let verticalViewModel = VerticalMatchInfoViewModel(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                displayState: verticalState,
                servingIndicator: verticalServingIndicator,
                detailedScore: detailedScore,
                marketName: marketName
            )

            self?.verticalMatchInfoView.configure(with: verticalViewModel)
        }
        .store(in: &self.cancellables)
    }
}

// MARK: - Factory Methods
extension MatchInfoView {
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }

    private static func createHorizontalMatchInfoView() -> HorizontalMatchInfoView {
        let view = HorizontalMatchInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createVerticalMatchInfoView() -> VerticalMatchInfoView {
        let view = VerticalMatchInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    // MARK: Layout Setup
    private func setupSubviews() {
        self.addSubview(self.containerStackView)

        self.containerStackView.addArrangedSubview(self.horizontalMatchInfoView)
        self.containerStackView.addArrangedSubview(self.verticalMatchInfoView)

        // Only one view should be visible at a time
        // Default to horizontal
        self.horizontalMatchInfoView.isHidden = false
        self.verticalMatchInfoView.isHidden = true

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.containerStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

// MARK: - SwiftUI Previews
@available(iOS 17.0, *)
#Preview("MatchInfoView - Horizontal Mode") {
    PreviewUIView {
        let view = MatchInfoView()
        let viewModel = MatchInfoViewModel(
            displayMode: .horizontal,
            homeTeamName: "Real Madrid",
            awayTeamName: "Barcelona",
            displayState: .preLive(date: "Jul 24", time: "20:30")
        )

        view.configure(with: viewModel)
        view.backgroundColor = .systemGray6
        return view
    }
    .frame(width: 300, height: 67)
}

@available(iOS 17.0, *)
#Preview("MatchInfoView - Vertical Mode") {
    PreviewUIView {
        let view = MatchInfoView()
        let viewModel = MatchInfoViewModel(
            displayMode: .vertical,
            homeTeamName: "Manchester United",
            awayTeamName: "Liverpool",
            displayState: .live(score: "2 - 1", matchTime: "45' - 1st Half"),
            servingIndicator: .home,
            detailedScore: ("FTB", [:]),
            marketName: "Match Winner"
        )

        view.configure(with: viewModel)
        view.backgroundColor = .systemGray6
        return view
    }
    .frame(width: 300, height: 70)
}

@available(iOS 17.0, *)
#Preview("MatchInfoView - Both Modes") {
    VStack(spacing: 20) {
        // Horizontal Mode
        PreviewUIView {
            let view = MatchInfoView()
            let viewModel = MatchInfoViewModel(
                displayMode: .horizontal,
                homeTeamName: "Real Madrid",
                awayTeamName: "Barcelona",
                displayState: .preLive(date: "Jul 24", time: "20:30")
            )

            view.configure(with: viewModel)
            view.backgroundColor = .systemGray6
            return view
        }
        .frame(width: 300, height: 67)

        // Vertical Mode
        PreviewUIView {
            let view = MatchInfoView()
            let viewModel = MatchInfoViewModel(
                displayMode: .vertical,
                homeTeamName: "Djokovic",
                awayTeamName: "Nadal",
                displayState: .live(score: "2 - 3", matchTime: "3rd Set"),
                servingIndicator: .away,
                detailedScore: ("TNS", [:]),
                marketName: "Match Winner"
            )

            view.configure(with: viewModel)
            view.backgroundColor = .systemGray6
            return view
        }
        .frame(width: 300, height: 70)
    }
}
