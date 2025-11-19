import UIKit
import Combine
import GomaUI

/// Production implementation of ScoreViewModelProtocol for live match scores
final class ScoreViewModel: ScoreViewModelProtocol {

    // MARK: - Publishers
    private let scoreCellsSubject = CurrentValueSubject<[ScoreDisplayData], Never>([])
    private let visualStateSubject = CurrentValueSubject<ScoreViewVisualState, Never>(.idle)

    public var scoreCellsPublisher: AnyPublisher<[ScoreDisplayData], Never> {
        scoreCellsSubject.eraseToAnyPublisher()
    }

    public var visualStatePublisher: AnyPublisher<ScoreViewVisualState, Never> {
        visualStateSubject.eraseToAnyPublisher()
    }

    public var currentVisualState: ScoreViewVisualState {
        visualStateSubject.value
    }

    // MARK: - Initialization
    init(scoreCells: [ScoreDisplayData] = [], visualState: ScoreViewVisualState = .idle) {
        scoreCellsSubject.send(scoreCells)
        visualStateSubject.send(visualState)
    }

    // MARK: - Protocol Methods
    func updateScoreCells(_ cells: [ScoreDisplayData]) {
        scoreCellsSubject.send(cells)
        if cells.isEmpty {
            visualStateSubject.send(.empty)
        } else {
            visualStateSubject.send(.display)
        }
    }

    func setVisualState(_ state: ScoreViewVisualState) {
        visualStateSubject.send(state)
    }

    func clearScores() {
        scoreCellsSubject.send([])
        visualStateSubject.send(.empty)
    }

    func setLoading() {
        visualStateSubject.send(.loading)
    }

    func setEmpty() {
        scoreCellsSubject.send([])
        visualStateSubject.send(.empty)
    }
}
