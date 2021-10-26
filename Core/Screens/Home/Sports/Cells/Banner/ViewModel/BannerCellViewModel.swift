//
//  BannerCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 21/10/2021.
//

import Foundation
import Combine

class BannerLineCellViewModel {

    var banners: [BannerCellViewModel]

    init(banners: [BannerCellViewModel]) {
        self.banners = banners
    }
}


class BannerCellViewModel {

    enum PresentationType {
        case image
        case match
    }

    var presentationType: PresentationType
    var matchId: String?
    var imageURL: URL?

    var match: CurrentValueSubject<EveryMatrix.Match?, Never> = .init(nil)

    var cancellables = Set<AnyCancellable>()

    init(matchId: String?, imageURL: String) {
        self.matchId = matchId
        let imageURLString = imageURL

        if let matchId = self.matchId {
            self.presentationType = .match
            self.imageURL = URL(string: EveryMatrixInfo.staticHost + imageURLString)
            self.requestMatchInfo(matchId)
        }
        else {
            self.presentationType = .image
            self.imageURL = URL(string: EveryMatrixInfo.staticHost + imageURLString)
        }

    }

    func requestMatchInfo(_ matchId: String) {
        let language = "en"
        Env.everyMatrixAPIClient.getMatchDetails(language: language, matchId: matchId)
            .sink { _ in

            } receiveValue: { response in
                if let match = response.records?.first {
                    self.match.send(match)
                }
            }
            .store(in: &cancellables)
    }
}
