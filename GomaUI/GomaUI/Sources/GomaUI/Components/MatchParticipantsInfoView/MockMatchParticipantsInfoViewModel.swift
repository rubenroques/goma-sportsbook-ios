import Combine

/// Mock implementation of `MatchParticipantsInfoViewModelProtocol` for testing and previews.
final public class MockMatchParticipantsInfoViewModel: MatchParticipantsInfoViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<MatchParticipantsDisplayState, Never>
    private let scoreViewModelSubject: CurrentValueSubject<ScoreViewModelProtocol?, Never>
    
    public var displayStatePublisher: AnyPublisher<MatchParticipantsDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    public var scoreViewModelPublisher: AnyPublisher<ScoreViewModelProtocol?, Never> {
        return scoreViewModelSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Public Access for Testing
    public var currentDisplayState: MatchParticipantsDisplayState {
        return displayStateSubject.value
    }
    
    // MARK: - Initialization
    public init(displayState: MatchParticipantsDisplayState, scoreViewModel: ScoreViewModelProtocol? = nil) {
        self.displayStateSubject = CurrentValueSubject(displayState)
        self.scoreViewModelSubject = CurrentValueSubject(scoreViewModel)
    }
    
    // MARK: - MatchParticipantsInfoViewModelProtocol
    public func setDisplayMode(_ mode: MatchDisplayMode) {
        let currentState = displayStateSubject.value
        let newState = MatchParticipantsDisplayState(
            displayMode: mode,
            matchData: currentState.matchData
        )
        displayStateSubject.send(newState)
        updateScoreViewModel(for: mode)
    }
    
    public func updateMatchData(_ data: MatchParticipantsData) {
        let currentState = displayStateSubject.value
        let newState = MatchParticipantsDisplayState(
            displayMode: currentState.displayMode,
            matchData: data
        )
        displayStateSubject.send(newState)
    }
    
    public func updateDisplayState(_ state: MatchParticipantsDisplayState) {
        displayStateSubject.send(state)
    }
    
    // MARK: - Helper Methods
    private func updateScoreViewModel(for displayMode: MatchDisplayMode) {
        // Only provide score view model for vertical layout
        if displayMode == .vertical {
            // Keep the existing score view model or provide a default empty one
            if scoreViewModelSubject.value == nil {
                scoreViewModelSubject.send(MockScoreViewModel.empty)
            }
        } else {
            scoreViewModelSubject.send(nil)
        }
    }
}

// MARK: - Mock Factory
extension MockMatchParticipantsInfoViewModel {
    
    /// Default mock for basic horizontal layout
    public static var defaultMock: MockMatchParticipantsInfoViewModel {
        let matchData = MatchParticipantsData(
            homeParticipantName: "Real Madrid",
            awayParticipantName: "Barcelona",
            matchState: .preLive(date: "Jul 24", time: "20:30"),
            servingIndicator: .none
        )
        
        let displayState = MatchParticipantsDisplayState(
            displayMode: .horizontal,
            matchData: matchData
        )
        
        return MockMatchParticipantsInfoViewModel(displayState: displayState)
    }
    
    /// Horizontal layout - Pre-live match
    public static var horizontalPreLive: MockMatchParticipantsInfoViewModel {
        let matchData = MatchParticipantsData(
            homeParticipantName: "Manchester United",
            awayParticipantName: "Liverpool",
            matchState: .preLive(date: "Dec 15", time: "18:45"),
            servingIndicator: .none
        )
        
        let displayState = MatchParticipantsDisplayState(
            displayMode: .horizontal,
            matchData: matchData
        )
        
        return MockMatchParticipantsInfoViewModel(displayState: displayState)
    }
    
    /// Horizontal layout - Live match
    public static var horizontalLive: MockMatchParticipantsInfoViewModel {
        let matchData = MatchParticipantsData(
            homeParticipantName: "Bayern Munich",
            awayParticipantName: "Dortmund",
            matchState: .live(score: "2 - 1", matchTime: "67'"),
            servingIndicator: .none
        )
        
        let displayState = MatchParticipantsDisplayState(
            displayMode: .horizontal,
            matchData: matchData
        )
        
        return MockMatchParticipantsInfoViewModel(displayState: displayState)
    }
    
    /// Horizontal layout - Ended match
    public static var horizontalEnded: MockMatchParticipantsInfoViewModel {
        let matchData = MatchParticipantsData(
            homeParticipantName: "Arsenal",
            awayParticipantName: "Chelsea",
            matchState: .ended(score: "3 - 2"),
            servingIndicator: .none
        )
        
        let displayState = MatchParticipantsDisplayState(
            displayMode: .horizontal,
            matchData: matchData
        )
        
        return MockMatchParticipantsInfoViewModel(displayState: displayState)
    }
    
    /// Vertical layout - Tennis match with serving and detailed scores
    public static var verticalTennisLive: MockMatchParticipantsInfoViewModel {
        let matchData = MatchParticipantsData(
            homeParticipantName: "Novak Djokovic",
            awayParticipantName: "Rafael Nadal",
            matchState: .live(score: "1 - 1", matchTime: "3rd Set"),
            servingIndicator: .home
        )
        
        let displayState = MatchParticipantsDisplayState(
            displayMode: .vertical,
            matchData: matchData
        )
        
        // Create tennis score display data
        let tennisScores = [
            ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple),
            ScoreDisplayData(id: "set2", homeScore: "3", awayScore: "6", style: .simple),
            ScoreDisplayData(id: "set3", homeScore: "40", awayScore: "30", style: .background)
        ]
        
        let scoreViewModel = MockScoreViewModel(scoreCells: tennisScores, visualState: .display)
        
        return MockMatchParticipantsInfoViewModel(displayState: displayState, scoreViewModel: scoreViewModel)
    }
    
    /// Vertical layout - Basketball with detailed scores
    public static var verticalBasketballLive: MockMatchParticipantsInfoViewModel {
        let matchData = MatchParticipantsData(
            homeParticipantName: "Lakers",
            awayParticipantName: "Warriors",
            matchState: .live(score: "103 - 95", matchTime: "Q4 8:45"),
            servingIndicator: .none
        )
        
        let displayState = MatchParticipantsDisplayState(
            displayMode: .vertical,
            matchData: matchData
        )
        
        // Create basketball quarter score display data
        let basketballScores = [
            ScoreDisplayData(id: "q1", homeScore: "28", awayScore: "24", style: .simple),
            ScoreDisplayData(id: "q2", homeScore: "22", awayScore: "31", style: .simple),
            ScoreDisplayData(id: "q3", homeScore: "35", awayScore: "28", style: .simple),
            ScoreDisplayData(id: "q4", homeScore: "18", awayScore: "12", style: .background)
        ]
        
        let scoreViewModel = MockScoreViewModel(scoreCells: basketballScores, visualState: .display)
        
        return MockMatchParticipantsInfoViewModel(displayState: displayState, scoreViewModel: scoreViewModel)
    }
    
    /// Vertical layout - Volleyball with serving indicator
    public static var verticalVolleyballLive: MockMatchParticipantsInfoViewModel {
        let matchData = MatchParticipantsData(
            homeParticipantName: "Brazil",
            awayParticipantName: "Italy",
            matchState: .live(score: "1 - 1", matchTime: "3rd Set"),
            servingIndicator: .away
        )
        
        let displayState = MatchParticipantsDisplayState(
            displayMode: .vertical,
            matchData: matchData
        )
        
        // Create volleyball set score display data
        let volleyballScores = [
            ScoreDisplayData(id: "set1", homeScore: "25", awayScore: "23", style: .simple),
            ScoreDisplayData(id: "set2", homeScore: "22", awayScore: "25", style: .simple),
            ScoreDisplayData(id: "set3", homeScore: "18", awayScore: "21", style: .background)
        ]
        
        let scoreViewModel = MockScoreViewModel(scoreCells: volleyballScores, visualState: .display)
        
        return MockMatchParticipantsInfoViewModel(displayState: displayState, scoreViewModel: scoreViewModel)
    }
    
    /// Vertical layout - Pre-live football match
    public static var verticalFootballPreLive: MockMatchParticipantsInfoViewModel {
        let matchData = MatchParticipantsData(
            homeParticipantName: "Real Madrid",
            awayParticipantName: "FC Barcelona",
            matchState: .preLive(date: "El Clasico", time: "21:00"),
            servingIndicator: .none
        )
        
        let displayState = MatchParticipantsDisplayState(
            displayMode: .vertical,
            matchData: matchData
        )
        
        // No scores for pre-live match
        let scoreViewModel = MockScoreViewModel(scoreCells: [], visualState: .empty)
        
        return MockMatchParticipantsInfoViewModel(displayState: displayState, scoreViewModel: scoreViewModel)
    }
    
    /// Edge case - Long team names
    public static var longTeamNames: MockMatchParticipantsInfoViewModel {
        let matchData = MatchParticipantsData(
            homeParticipantName: "Borussia Mönchengladbach",
            awayParticipantName: "Eintracht Frankfurt am Main",
            matchState: .live(score: "1 - 0", matchTime: "23'"),
            servingIndicator: .none
        )
        
        let displayState = MatchParticipantsDisplayState(
            displayMode: .horizontal,
            matchData: matchData
        )
        
        return MockMatchParticipantsInfoViewModel(displayState: displayState)
    }
    
    /// Edge case - No match time in live state
    public static var liveWithoutTime: MockMatchParticipantsInfoViewModel {
        let matchData = MatchParticipantsData(
            homeParticipantName: "Team A",
            awayParticipantName: "Team B",
            matchState: .live(score: "0 - 0", matchTime: nil),
            servingIndicator: .none
        )
        
        let displayState = MatchParticipantsDisplayState(
            displayMode: .horizontal,
            matchData: matchData
        )
        
        return MockMatchParticipantsInfoViewModel(displayState: displayState)
    }
}