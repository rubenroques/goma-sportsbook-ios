//
//  SearchViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 20/01/2022.
//

import Foundation
import Combine

class SearchViewModel: NSObject {

    var recentSearchesPublisher: CurrentValueSubject<[String], Never> = .init([])
    var searchInfoPublisher: CurrentValueSubject<[String: Any], Never> = .init([:])
    var searchInfo: [Int: [Any]] = [:]

    override init() {
       
    }

    func fetchSearchInfo() {
        searchInfoPublisher.value["1"] = "FOOTBALL"
        searchInfoPublisher.value["8"] = "BASKETBALL"
        searchInfoPublisher.send(searchInfoPublisher.value)

    }

    func addRecentSearch(search: String) {
        recentSearchesPublisher.value.append(search)
        recentSearchesPublisher.send(recentSearchesPublisher.value)
    }
}
