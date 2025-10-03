import UIKit
import Combine

public final class MockSuggestedBetsExpandedViewModel: SuggestedBetsExpandedViewModelProtocol {
    private let displayStateSubject: CurrentValueSubject<SuggestedBetsSectionState, Never>
    private let matchCardsSubject: CurrentValueSubject<[TallOddsMatchCardViewModelProtocol], Never>

    public var displayStatePublisher: AnyPublisher<SuggestedBetsSectionState, Never> { displayStateSubject.eraseToAnyPublisher() }
    public var matchCardViewModelsPublisher: AnyPublisher<[TallOddsMatchCardViewModelProtocol], Never> { matchCardsSubject.eraseToAnyPublisher() }
    public var matchCardViewModels: [TallOddsMatchCardViewModelProtocol] { matchCardsSubject.value }

    public init(title: String = "Explore more bets",
                isExpanded: Bool = true,
                matchCardViewModels: [TallOddsMatchCardViewModelProtocol]) {
        self.matchCardsSubject = .init(matchCardViewModels)
        let initialState = SuggestedBetsSectionState(title: title,
                                                     isExpanded: isExpanded,
                                                     currentPageIndex: 0,
                                                     totalPages: matchCardViewModels.count,
                                                     isVisible: true)
        self.displayStateSubject = .init(initialState)
    }

    public func toggleExpanded() {
        let current = displayStateSubject.value
        let updated = SuggestedBetsSectionState(title: current.title,
                                                isExpanded: !current.isExpanded,
                                                currentPageIndex: current.currentPageIndex,
                                                totalPages: current.totalPages,
                                                isVisible: current.isVisible)
        displayStateSubject.send(updated)
    }

    public func didScrollToPage(_ index: Int) {
        let current = displayStateSubject.value
        let clamped = max(0, min(index, max(0, current.totalPages - 1)))
        let updated = SuggestedBetsSectionState(title: current.title,
                                                isExpanded: current.isExpanded,
                                                currentPageIndex: clamped,
                                                totalPages: current.totalPages,
                                                isVisible: current.isVisible)
        displayStateSubject.send(updated)
    }

    // Convenience factory
    public static var demo: MockSuggestedBetsExpandedViewModel {
        let vms: [MockTallOddsMatchCardViewModel] = [
            .premierLeagueMock(singleLineOutcomes: true),
            .liveMock(singleLineOutcomes: true),
            .compactMock(singleLineOutcomes: true),
            .bundesliegaMock(singleLineOutcomes: true)
        ]
        return MockSuggestedBetsExpandedViewModel(matchCardViewModels: vms)
    }
}


