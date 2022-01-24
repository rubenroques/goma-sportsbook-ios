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
        self.sportIconName =  "sport_type_icon_\(sport.id)"
    }

    func setSportPublisher(sportsRepository: SportsAggregatorRepository) {
        if let sportPublisher = sportsRepository.sportsLivePublisher[self.sport.id] {
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
