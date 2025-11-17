//
//  BetslipTicketsState.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 04/11/2025.
//

import Foundation

/// Represents the complete state of betslip tickets (validation and bet builder info)
public struct BetslipTicketsState: Equatable {
    public let invalidState: TicketsInvalidState
    public let betBuilderData: BetBuilderData?
    
    public init(invalidState: TicketsInvalidState, betBuilderData: BetBuilderData?) {
        self.invalidState = invalidState
        self.betBuilderData = betBuilderData
    }
    
    /// Default state with no issues and no bet builder
    public static let `default` = BetslipTicketsState(invalidState: .none, betBuilderData: nil)
}



