//
//  SportSelectionCollectionViewCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 07/01/2022.
//

import Foundation
import Combine

class SportSelectionCollectionViewCellViewModel: NSObject {

    var sport: EveryMatrix.Discipline
    var sportPublisher: AnyCancellable?
    var sportName: String?
    var sportIconName: String?
    var numberOfLiveEvents: String?

    var updateLiveEvents: (() -> Void)?

    init(sport: EveryMatrix.Discipline) {
        self.sport = sport
        super.init()

        setValues()

    }

    func setValues() {
        self.sportName = sport.name
        if let sportId = sport.id {
            self.sportIconName =  "sport_type_icon_\(sportId)"
        }
    }

    func setSportPublisher(sportsRepository: SportsAggregatorRepository) {
        if let sportId = self.sport.id, let sportPublisher = sportsRepository.sportsLivePublisher[sportId] {

            self.sportPublisher = sportPublisher.receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] sport in
                    if let sportCount = sport.numberOfLiveEvents {
                        self?.numberOfLiveEvents = "\(sportCount)"
                        self?.updateLiveEvents?()
                    }

                })
        }
    }
}
