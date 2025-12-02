import UIKit
import Combine

/// Mock implementation of CompactOutcomesLineViewModelProtocol for testing and previews
public final class MockCompactOutcomesLineViewModel: CompactOutcomesLineViewModelProtocol {

    // MARK: - Private Properties
    private let displayStateSubject: CurrentValueSubject<CompactOutcomesLineDisplayState, Never>
    private let leftOutcomeSubject: CurrentValueSubject<OutcomeItemViewModelProtocol?, Never>
    private let middleOutcomeSubject: CurrentValueSubject<OutcomeItemViewModelProtocol?, Never>
    private let rightOutcomeSubject: CurrentValueSubject<OutcomeItemViewModelProtocol?, Never>

    // MARK: - Protocol Properties
    public var displayStatePublisher: AnyPublisher<CompactOutcomesLineDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    public var currentDisplayState: CompactOutcomesLineDisplayState {
        displayStateSubject.value
    }

    public var leftOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> {
        leftOutcomeSubject.eraseToAnyPublisher()
    }

    public var middleOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> {
        middleOutcomeSubject.eraseToAnyPublisher()
    }

    public var rightOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> {
        rightOutcomeSubject.eraseToAnyPublisher()
    }

    public var currentLeftOutcomeViewModel: OutcomeItemViewModelProtocol? {
        leftOutcomeSubject.value
    }

    public var currentMiddleOutcomeViewModel: OutcomeItemViewModelProtocol? {
        middleOutcomeSubject.value
    }

    public var currentRightOutcomeViewModel: OutcomeItemViewModelProtocol? {
        rightOutcomeSubject.value
    }

    // MARK: - Initialization
    public init(
        displayMode: CompactOutcomesDisplayMode,
        leftOutcome: OutcomeItemData?,
        middleOutcome: OutcomeItemData? = nil,
        rightOutcome: OutcomeItemData?
    ) {
        let state = CompactOutcomesLineDisplayState(
            displayMode: displayMode,
            leftOutcome: leftOutcome,
            middleOutcome: middleOutcome,
            rightOutcome: rightOutcome
        )
        self.displayStateSubject = CurrentValueSubject(state)

        // Create child view models
        self.leftOutcomeSubject = CurrentValueSubject(
            leftOutcome.map { MockOutcomeItemViewModel(outcomeData: $0) }
        )
        self.middleOutcomeSubject = CurrentValueSubject(
            middleOutcome.map { MockOutcomeItemViewModel(outcomeData: $0) }
        )
        self.rightOutcomeSubject = CurrentValueSubject(
            rightOutcome.map { MockOutcomeItemViewModel(outcomeData: $0) }
        )
    }

    // MARK: - Protocol Methods
    public func onOutcomeSelected(outcomeId: String, outcomeType: OutcomeType) {
        updateOutcomeSelection(outcomeType: outcomeType, selected: true)
    }

    public func onOutcomeDeselected(outcomeId: String, outcomeType: OutcomeType) {
        updateOutcomeSelection(outcomeType: outcomeType, selected: false)
    }

    public func setOutcomeSelected(outcomeType: OutcomeType) {
        updateOutcomeSelection(outcomeType: outcomeType, selected: true)
    }

    public func setOutcomeDeselected(outcomeType: OutcomeType) {
        updateOutcomeSelection(outcomeType: outcomeType, selected: false)
    }

    // MARK: - Private Methods
    private func updateOutcomeSelection(outcomeType: OutcomeType, selected: Bool) {
        switch outcomeType {
        case .left:
            if let vm = leftOutcomeSubject.value as? MockOutcomeItemViewModel {
                vm.setSelected(selected)
            }
        case .middle:
            if let vm = middleOutcomeSubject.value as? MockOutcomeItemViewModel {
                vm.setSelected(selected)
            }
        case .right:
            if let vm = rightOutcomeSubject.value as? MockOutcomeItemViewModel {
                vm.setSelected(selected)
            }
        }
    }
}

// MARK: - Factory Methods
extension MockCompactOutcomesLineViewModel {

    // MARK: - 3-Way Markets (Football)

    /// Standard 3-way market (1X2)
    public static var threeWayMarket: MockCompactOutcomesLineViewModel {
        MockCompactOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: OutcomeItemData(
                id: "home",
                bettingOfferId: "offer1",
                title: "1",
                value: "2.90"
            ),
            middleOutcome: OutcomeItemData(
                id: "draw",
                bettingOfferId: "offer2",
                title: "X",
                value: "3.05"
            ),
            rightOutcome: OutcomeItemData(
                id: "away",
                bettingOfferId: "offer3",
                title: "2",
                value: "2.68"
            )
        )
    }

    /// 3-way market with selected home outcome
    public static var withSelectedOutcome: MockCompactOutcomesLineViewModel {
        MockCompactOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: OutcomeItemData(
                id: "home",
                bettingOfferId: "offer1",
                title: "1",
                value: "2.90",
                displayState: .normal(isSelected: true, isBoosted: false)
            ),
            middleOutcome: OutcomeItemData(
                id: "draw",
                bettingOfferId: "offer2",
                title: "X",
                value: "3.05"
            ),
            rightOutcome: OutcomeItemData(
                id: "away",
                bettingOfferId: "offer3",
                title: "2",
                value: "2.68"
            )
        )
    }

    /// 3-way market with higher odds
    public static var highOdds: MockCompactOutcomesLineViewModel {
        MockCompactOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: OutcomeItemData(
                id: "home",
                bettingOfferId: "offer1",
                title: "1",
                value: "5.50"
            ),
            middleOutcome: OutcomeItemData(
                id: "draw",
                bettingOfferId: "offer2",
                title: "X",
                value: "4.20"
            ),
            rightOutcome: OutcomeItemData(
                id: "away",
                bettingOfferId: "offer3",
                title: "2",
                value: "1.45"
            )
        )
    }

    // MARK: - 2-Way Markets (Tennis, Basketball)

    /// Standard 2-way market (Tennis)
    public static var twoWayMarket: MockCompactOutcomesLineViewModel {
        MockCompactOutcomesLineViewModel(
            displayMode: .double,
            leftOutcome: OutcomeItemData(
                id: "player1",
                bettingOfferId: "offer1",
                title: "1",
                value: "2.90"
            ),
            rightOutcome: OutcomeItemData(
                id: "player2",
                bettingOfferId: "offer2",
                title: "2",
                value: "3.05"
            )
        )
    }

    /// Over/Under market
    public static var overUnderMarket: MockCompactOutcomesLineViewModel {
        MockCompactOutcomesLineViewModel(
            displayMode: .double,
            leftOutcome: OutcomeItemData(
                id: "over",
                bettingOfferId: "offer1",
                title: "Over",
                value: "1.85"
            ),
            rightOutcome: OutcomeItemData(
                id: "under",
                bettingOfferId: "offer2",
                title: "Under",
                value: "1.95"
            )
        )
    }

    /// 2-way with selection
    public static var twoWayWithSelection: MockCompactOutcomesLineViewModel {
        MockCompactOutcomesLineViewModel(
            displayMode: .double,
            leftOutcome: OutcomeItemData(
                id: "player1",
                bettingOfferId: "offer1",
                title: "1",
                value: "2.90",
                displayState: .normal(isSelected: true, isBoosted: false)
            ),
            rightOutcome: OutcomeItemData(
                id: "player2",
                bettingOfferId: "offer2",
                title: "2",
                value: "3.05"
            )
        )
    }

    // MARK: - Special States

    /// Market with locked outcomes
    public static var lockedMarket: MockCompactOutcomesLineViewModel {
        MockCompactOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: OutcomeItemData(
                id: "home",
                bettingOfferId: nil,
                title: "1",
                value: "-",
                displayState: .locked
            ),
            middleOutcome: OutcomeItemData(
                id: "draw",
                bettingOfferId: nil,
                title: "X",
                value: "-",
                displayState: .locked
            ),
            rightOutcome: OutcomeItemData(
                id: "away",
                bettingOfferId: nil,
                title: "2",
                value: "-",
                displayState: .locked
            )
        )
    }

    /// Market with odds change indicators
    public static var withOddsChanges: MockCompactOutcomesLineViewModel {
        MockCompactOutcomesLineViewModel(
            displayMode: .triple,
            leftOutcome: OutcomeItemData(
                id: "home",
                bettingOfferId: "offer1",
                title: "1",
                value: "2.95",
                oddsChangeDirection: .up
            ),
            middleOutcome: OutcomeItemData(
                id: "draw",
                bettingOfferId: "offer2",
                title: "X",
                value: "3.00",
                oddsChangeDirection: .down
            ),
            rightOutcome: OutcomeItemData(
                id: "away",
                bettingOfferId: "offer3",
                title: "2",
                value: "2.70"
            )
        )
    }

    // MARK: - Custom Factory

    /// Create custom outcomes configuration
    public static func custom(
        displayMode: CompactOutcomesDisplayMode,
        leftOutcome: OutcomeItemData?,
        middleOutcome: OutcomeItemData? = nil,
        rightOutcome: OutcomeItemData?
    ) -> MockCompactOutcomesLineViewModel {
        MockCompactOutcomesLineViewModel(
            displayMode: displayMode,
            leftOutcome: leftOutcome,
            middleOutcome: middleOutcome,
            rightOutcome: rightOutcome
        )
    }
}
