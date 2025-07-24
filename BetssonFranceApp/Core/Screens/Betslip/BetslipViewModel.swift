//
//  BetslipViewModel.swift
//  MultiBet
//
//  Created by André Lascas on 21/01/2025.
//

import Foundation

class BetslipViewModel: NSObject {
    
    enum StartScreen {
        case bets
        case sharedBet(String)
        case myTickets(MyTicketsType, String)
    }
    
    var startScreen: StartScreen
    
    init(startScreen: StartScreen = .bets) {
        
        self.startScreen = startScreen
    }
}
