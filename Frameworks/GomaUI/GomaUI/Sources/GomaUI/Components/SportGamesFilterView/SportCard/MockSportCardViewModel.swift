//
//  MockSportCardViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 29/05/2025.
//

import Foundation

public class MockSportCardViewModel: SportCardViewModelProtocol {
    
    public var sportFilter: SportFilter
    
    init(sportFilter: SportFilter) {
        
        self.sportFilter = sportFilter
    }
    
}
