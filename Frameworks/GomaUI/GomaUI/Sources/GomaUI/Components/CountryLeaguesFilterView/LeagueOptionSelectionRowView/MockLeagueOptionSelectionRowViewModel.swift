//
//  MockLeagueOptionSelectionRowViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 29/05/2025.
//

import Foundation

public class MockLeagueOptionSelectionRowViewModel: LeagueOptionSelectionRowViewModelProtocol {
    
    public var leagueOption: LeagueOption
    
    init(leagueOption: LeagueOption) {
        
        self.leagueOption = leagueOption
    }
    
}
