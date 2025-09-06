//
//  BetDetailResultSummaryViewModel.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 04/09/2025.
//

import Foundation
import Combine
import GomaUI

final class BetDetailResultSummaryViewModel: BetDetailResultSummaryViewModelProtocol {
    
    // MARK: - Properties
    
    private let dataSubject = CurrentValueSubject<BetDetailResultSummaryData, Never>(
        BetDetailResultSummaryData(
            matchDetails: "",
            betType: "",
            resultState: .lost
        )
    )
    
    var dataPublisher: AnyPublisher<BetDetailResultSummaryData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Public Methods
    
    func updateData(_ data: BetDetailResultSummaryData) {
        dataSubject.send(data)
    }
    
    // MARK: - Factory Methods
    
    static func create(from myBetSelection: MyBetSelection) -> BetDetailResultSummaryViewModel {
        let viewModel = BetDetailResultSummaryViewModel()
        
        // Format match details
        let matchDetails: String
        if let homeTeam = myBetSelection.homeTeamName, let awayTeam = myBetSelection.awayTeamName {
            matchDetails = "\(homeTeam) x \(awayTeam)"
        } else {
            matchDetails = myBetSelection.eventName
        }
        
        // Format bet type (market and outcome)
        let betType = "\(myBetSelection.marketName) - \(myBetSelection.outcomeName)"
        
        // Map result to result state
        let resultState = mapResultToState(myBetSelection.result)
        
        let data = BetDetailResultSummaryData(
            matchDetails: matchDetails,
            betType: betType,
            resultState: resultState
        )
        
        viewModel.updateData(data)
        return viewModel
    }
    
    // MARK: - Helper Methods
    
    private static func mapResultToState(_ result: MyBetResult) -> BetDetailResultState {
        switch result {
        case .won:
            return .won
        case .lost:
            return .lost
        case .drawn:
            return .draw
        case .open, .pending, .void, .notSpecified:
            return .open
        }
    }
}