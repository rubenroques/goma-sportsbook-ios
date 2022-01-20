//
//  SearchViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 20/01/2022.
//

import Foundation
import Combine

class SearchViewModel: NSObject {

    private var recentSearches: Int?

    override init() {
        self.recentSearches = 0
    }
}
