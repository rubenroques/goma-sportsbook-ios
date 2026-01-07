import UIKit
import Combine

/// Mock implementation of InlineMatchCardViewModelProtocol for testing and previews
public  final class MockInlineMatchCardViewModel: InlineMatchCardViewModelProtocol {

    // MARK: - Private Properties
    private let displayStateSubject: CurrentValueSubject<InlineMatchCardDisplayState, Never>
    private let headerViewModelSubject: CurrentValueSubject<CompactMatchHeaderViewModelProtocol, Never>
    private let outcomesViewModelSubject: CurrentValueSubject<CompactOutcomesLineViewModelProtocol, Never>
    private let scoreViewModelSubject: CurrentValueSubject<InlineScoreViewModelProtocol?, Never>

    // MARK: - Protocol Properties (Publishers)
    public var displayStatePublisher: AnyPublisher<InlineMatchCardDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    public var headerViewModelPublisher: AnyPublisher<CompactMatchHeaderViewModelProtocol, Never> {
        headerViewModelSubject.eraseToAnyPublisher()
    }

    public var outcomesViewModelPublisher: AnyPublisher<CompactOutcomesLineViewModelProtocol, Never> {
        outcomesViewModelSubject.eraseToAnyPublisher()
    }

    public var scoreViewModelPublisher: AnyPublisher<InlineScoreViewModelProtocol?, Never> {
        scoreViewModelSubject.eraseToAnyPublisher()
    }

    // MARK: - Protocol Properties (Synchronous)
    public var currentDisplayState: InlineMatchCardDisplayState {
        displayStateSubject.value
    }

    public var currentHeaderViewModel: CompactMatchHeaderViewModelProtocol {
        headerViewModelSubject.value
    }

    public var currentOutcomesViewModel: CompactOutcomesLineViewModelProtocol {
        outcomesViewModelSubject.value
    }

    public var currentScoreViewModel: InlineScoreViewModelProtocol? {
        scoreViewModelSubject.value
    }

    // MARK: - Initialization
    public init(
        displayState: InlineMatchCardDisplayState,
        headerViewModel: CompactMatchHeaderViewModelProtocol,
        outcomesViewModel: CompactOutcomesLineViewModelProtocol,
        scoreViewModel: InlineScoreViewModelProtocol?
    ) {
        self.displayStateSubject = CurrentValueSubject(displayState)
        self.headerViewModelSubject = CurrentValueSubject(headerViewModel)
        self.outcomesViewModelSubject = CurrentValueSubject(outcomesViewModel)
        self.scoreViewModelSubject = CurrentValueSubject(scoreViewModel)
    }

    // MARK: - Protocol Methods
    public func onCardTapped() {
        // Mock: Log action for testing
    }

    public func onOutcomeSelected(outcomeId: String) {
        // Mock: Forward to outcomes view model
    }

    public func onOutcomeDeselected(outcomeId: String) {
        // Mock: Forward to outcomes view model
    }

    public func onMoreMarketsTapped() {
        // Mock: Log action for testing
    }
}

// MARK: - Factory Methods
extension MockInlineMatchCardViewModel {

    // MARK: - Pre-Live Football (3-way)
    public static var preLiveFootball: MockInlineMatchCardViewModel {
        let displayState = InlineMatchCardDisplayState(
            matchId: "football_1",
            homeParticipantName: "Sunderland Football Club",
            awayParticipantName: "Everton",
            isLive: false
        )

        let headerVM = MockCompactMatchHeaderViewModel.preLiveToday
        let outcomesVM = MockCompactOutcomesLineViewModel.threeWayMarket

        return MockInlineMatchCardViewModel(
            displayState: displayState,
            headerViewModel: headerVM,
            outcomesViewModel: outcomesVM,
            scoreViewModel: nil
        )
    }

    // MARK: - Pre-Live Future Date
    public static var preLiveFutureDate: MockInlineMatchCardViewModel {
        let displayState = InlineMatchCardDisplayState(
            matchId: "football_2",
            homeParticipantName: "Westham",
            awayParticipantName: "Burnley",
            isLive: false
        )

        let headerVM = MockCompactMatchHeaderViewModel.preLiveFutureDate
        let outcomesVM = MockCompactOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: OutcomeItemData(id: "1", bettingOfferId: "o1", title: "1", value: "2.03"),
            middleOutcome: OutcomeItemData(id: "X", bettingOfferId: "o2", title: "X", value: "3.50"),
            rightOutcome: OutcomeItemData(id: "2", bettingOfferId: "o3", title: "2", value: "3.80")
        )

        return MockInlineMatchCardViewModel(
            displayState: displayState,
            headerViewModel: headerVM,
            outcomesViewModel: outcomesVM,
            scoreViewModel: nil
        )
    }

    // MARK: - Live Tennis (2-way with score)
    public static var liveTennis: MockInlineMatchCardViewModel {
        let displayState = InlineMatchCardDisplayState(
            matchId: "tennis_1",
            homeParticipantName: "Jannik, Sinner",
            awayParticipantName: "Cilis, Marin",
            isLive: true
        )

        let headerVM = MockCompactMatchHeaderViewModel.liveTennis
        let outcomesVM = MockCompactOutcomesLineViewModel.twoWayMarket
        let scoreVM = MockInlineScoreViewModel.tennisMatch

        return MockInlineMatchCardViewModel(
            displayState: displayState,
            headerViewModel: headerVM,
            outcomesViewModel: outcomesVM,
            scoreViewModel: scoreVM
        )
    }

    // MARK: - Live Football (3-way with score)
    public static var liveFootball: MockInlineMatchCardViewModel {
        let displayState = InlineMatchCardDisplayState(
            matchId: "football_live_1",
            homeParticipantName: "Liverpool F.C.",
            awayParticipantName: "Arsenal F.C.",
            isLive: true
        )

        let headerVM = MockCompactMatchHeaderViewModel.liveFootball
        let outcomesVM = MockCompactOutcomesLineViewModel.threeWayMarket
        let scoreVM = MockInlineScoreViewModel.footballMatch

        return MockInlineMatchCardViewModel(
            displayState: displayState,
            headerViewModel: headerVM,
            outcomesViewModel: outcomesVM,
            scoreViewModel: scoreVM
        )
    }

    // MARK: - Live Basketball
    public static var liveBasketball: MockInlineMatchCardViewModel {
        let displayState = InlineMatchCardDisplayState(
            matchId: "basketball_1",
            homeParticipantName: "LA Lakers",
            awayParticipantName: "Boston Celtics",
            isLive: true
        )

        let headerVM = MockCompactMatchHeaderViewModel.liveBasketball
        let outcomesVM = MockCompactOutcomesLineViewModel.twoWayMarket
        let scoreVM = MockInlineScoreViewModel.basketballMatch

        return MockInlineMatchCardViewModel(
            displayState: displayState,
            headerViewModel: headerVM,
            outcomesViewModel: outcomesVM,
            scoreViewModel: scoreVM
        )
    }

    // MARK: - With Selected Outcome
    public static var withSelectedOutcome: MockInlineMatchCardViewModel {
        let displayState = InlineMatchCardDisplayState(
            matchId: "football_selected",
            homeParticipantName: "Tottenham",
            awayParticipantName: "Man United",
            isLive: false
        )

        let headerVM = MockCompactMatchHeaderViewModel.preLiveToday
        let outcomesVM = MockCompactOutcomesLineViewModel.withSelectedOutcome

        return MockInlineMatchCardViewModel(
            displayState: displayState,
            headerViewModel: headerVM,
            outcomesViewModel: outcomesVM,
            scoreViewModel: nil
        )
    }

    // MARK: - Locked Market
    public static var lockedMarket: MockInlineMatchCardViewModel {
        let displayState = InlineMatchCardDisplayState(
            matchId: "locked_1",
            homeParticipantName: "Team A",
            awayParticipantName: "Team B",
            isLive: false
        )

        let headerVM = MockCompactMatchHeaderViewModel.preLiveToday
        let outcomesVM = MockCompactOutcomesLineViewModel.lockedMarket

        return MockInlineMatchCardViewModel(
            displayState: displayState,
            headerViewModel: headerVM,
            outcomesViewModel: outcomesVM,
            scoreViewModel: nil
        )
    }

    // MARK: - No Icons (Production Mode)
    public static var productionMode: MockInlineMatchCardViewModel {
        let displayState = InlineMatchCardDisplayState(
            matchId: "prod_1",
            homeParticipantName: "Real Madrid",
            awayParticipantName: "Barcelona",
            isLive: false
        )

        let headerVM = MockCompactMatchHeaderViewModel.preLiveNoIcons
        let outcomesVM = MockCompactOutcomesLineViewModel.threeWayMarket

        return MockInlineMatchCardViewModel(
            displayState: displayState,
            headerViewModel: headerVM,
            outcomesViewModel: outcomesVM,
            scoreViewModel: nil
        )
    }

    // MARK: - Custom Factory
    public static func custom(
        matchId: String,
        homeParticipant: String,
        awayParticipant: String,
        isLive: Bool,
        headerViewModel: CompactMatchHeaderViewModelProtocol,
        outcomesViewModel: CompactOutcomesLineViewModelProtocol,
        scoreViewModel: InlineScoreViewModelProtocol?
    ) -> MockInlineMatchCardViewModel {
        let displayState = InlineMatchCardDisplayState(
            matchId: matchId,
            homeParticipantName: homeParticipant,
            awayParticipantName: awayParticipant,
            isLive: isLive
        )

        return MockInlineMatchCardViewModel(
            displayState: displayState,
            headerViewModel: headerViewModel,
            outcomesViewModel: outcomesViewModel,
            scoreViewModel: scoreViewModel
        )
    }
}
