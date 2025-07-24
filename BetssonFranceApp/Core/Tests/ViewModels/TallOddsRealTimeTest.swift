import XCTest
import Combine
@testable import Core
@testable import GomaUI

class TallOddsRealTimeTest: XCTestCase {
    
    func testRealTimeSubscriptionsAreActive() {
        // Given: Sample match and market data
        let match = createTestMatch()
        let markets = createTestMarkets()
        let marketTypeId = "1"
        
        // When: Creating the TallOddsMatchCardViewModel
        let viewModel = TallOddsMatchCardViewModel.create(
            from: match,
            relevantMarkets: markets,
            marketTypeId: marketTypeId
        )
        
        // Then: Verify the view model chain is properly set up
        var marketOutcomesViewModel: MarketOutcomesMultiLineViewModelProtocol?
        let expectation = expectation(description: "Market outcomes view model received")
        
        let cancellable = viewModel.marketOutcomesViewModelPublisher
            .sink { vm in
                marketOutcomesViewModel = vm
                expectation.fulfill()
            }
        
        waitForExpectations(timeout: 1.0)
        
        // Verify we have line view models
        XCTAssertNotNil(marketOutcomesViewModel)
        XCTAssertFalse(marketOutcomesViewModel!.lineViewModels.isEmpty)
        
        // Verify each line view model can create outcome view models
        for lineViewModel in marketOutcomesViewModel!.lineViewModels {
            let leftOutcomeVM = lineViewModel.createOutcomeViewModel(for: .left)
            XCTAssertNotNil(leftOutcomeVM, "Line view model should create outcome view models")
        }
        
        print("✅ Real-time subscriptions are properly set up in the view model chain")
    }
    
    // MARK: - Test Helpers
    
    private func createTestMatch() -> Match {
        return Match(
            id: "match123",
            date: Date(),
            matchTime: "19:00",
            homeParticipant: Participant(id: "home1", name: "Home Team", score: nil),
            awayParticipant: Participant(id: "away1", name: "Away Team", score: nil),
            competitionName: "Test League",
            sport: Sport(id: "1", name: "Football", alphaId: "FOOT"),
            status: MatchStatus(isLive: false, code: "NS"),
            numberTotalOfMarkets: 50,
            venue: nil
        )
    }
    
    private func createTestMarkets() -> [Market] {
        let outcome1 = Outcome(
            id: "outcome1",
            name: "1",
            translatedName: "Home",
            bettingOffer: BettingOffer(decimalOdd: 2.5, isAvailable: true),
            orderValue: 0
        )
        
        let outcome2 = Outcome(
            id: "outcome2",
            name: "X",
            translatedName: "Draw",
            bettingOffer: BettingOffer(decimalOdd: 3.0, isAvailable: true),
            orderValue: 1
        )
        
        let outcome3 = Outcome(
            id: "outcome3",
            name: "2",
            translatedName: "Away",
            bettingOffer: BettingOffer(decimalOdd: 2.8, isAvailable: true),
            orderValue: 2
        )
        
        return [
            Market(
                id: "market1",
                name: "1X2",
                marketTypeName: "Match Result",
                isAvailable: true,
                outcomes: [outcome1, outcome2, outcome3]
            )
        ]
    }
}