//
//  Router+FastTest.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/07/2025.
//

import UIKit

#if DEBUG

/*
 INSTRUCTIONS FOR FUTURE DEVELOPMENT:
 
 1. ENABLE FAST TEST MODE:
    - Change `useFastTestMode = true`
    - Choose your test target and scenario
    - Build and run to see changes immediately
 
 2. AVAILABLE TEST TARGETS:
    - .betSubmissionSuccess(scenario) - Test bet success screen with different scenarios (and share bet)
    - .shareTestView - Test share rendered view for share mytickets

 3. DEVELOPMENT WORKFLOW:
    - Enable fast test mode → Make changes → Build → Test → Iterate
    - When done testing: set useFastTestMode = false for production
 
 4. PRODUCTION DEPLOYMENT:
    - ALWAYS set useFastTestMode = false before committing
    - Verify normal app flow works correctly
*/

enum FastTestTarget {
    case betSubmissionSuccess(BetPlacementScenario)
    case shareTestView
    
    var description: String {
        switch self {
        case .betSubmissionSuccess(let scenario):
            return "BetSubmissionSuccessViewController(\(scenario))"
        case .shareTestView:
            return "ShareTestViewController"
        }
    }
}

// MARK: - Fast Test Helper Methods
extension Router {
    
    /// Creates the appropriate test view controller based on the fast test target
    func createFastTestViewController(target: FastTestTarget) -> UIViewController {
        switch target {
        case .betSubmissionSuccess(let scenario):
            return createBetSubmissionSuccessTestController(scenario: scenario)
        case .shareTestView:
            return Router.navigationController(with: ShareTestViewController())
        }
    }
    
    /// Creates BetSubmissionSuccessViewController with mock data for the specified scenario
    func createBetSubmissionSuccessTestController(scenario: BetPlacementScenario) -> UIViewController {
        let mockBetPlacedDetails = MockDataFactory.createMockBetPlacedDetails(scenario: scenario)
        let mockBettingTickets = MockDataFactory.createMockBettingTickets(scenario: scenario)
        
        // Configure cashback based on scenario
        let mockCashbackValue: Double?
        let usedCashback: Bool
        
        switch scenario {
        case .withCashback:
            mockCashbackValue = 15.50
            usedCashback = false
        case .usedCashback:
            mockCashbackValue = nil
            usedCashback = true
        default:
            mockCashbackValue = nil
            usedCashback = false
        }
        
        let betSuccessViewController = BetSubmissionSuccessViewController(
            betPlacedDetailsArray: [mockBetPlacedDetails],
            cashbackResultValue: mockCashbackValue,
            usedCashback: usedCashback,
            bettingTickets: mockBettingTickets
        )
        
        return Router.navigationController(with: betSuccessViewController)
    }
}
#endif
