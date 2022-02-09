//
//  HomeViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/02/2022.
//

import Foundation
import Combine

class HomeViewModel {

    enum Content {
        case userMessage
        case userFavorites
        case bannerLine
        case sport(Sport)
    }

    var title = CurrentValueSubject<String, Never>.init("Init")
    var contentList = CurrentValueSubject<[Content], Never>.init([])

    private var userMessages: [String] = []
    private var userFavorites: [String] = []
    private var banners: [String] = []

    private var sportsToFetch: [Sport] = []

    private var popularMatchesForSport: [String: [Match]] = [:]
    private var liveMatchesForSport: [String: [Match]] = [:]
    private var popularCompetitionForSport: [String: Competition] = [:]
    private var competitionMatchesForSport: [String: [Match]] = [:]

    private var cancellables: Set<AnyCancellable> = []

    init() {
        title.send("Home")

        self.requestSports()
    }

    func requestSports() {

        let language = "en"
        Env.everyMatrixClient.getDisciplines(language: language)
            .map(\.records)
            .compactMap({ $0 })
            .sink(receiveCompletion: { completion in

            }, receiveValue: { response in
                self.sportsToFetch = Array(response.map(Sport.init(discipline:)).prefix(10))
            })
            .store(in: &cancellables)

    }

    func numberOfSections() -> Int {
        return 0
    }

    func numberOfRows(forSectionIndex section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1

        default: return 0
        }
    }

}
