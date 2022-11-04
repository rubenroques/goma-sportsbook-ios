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
    var isLive: Bool
    
    var sportPublisher: AnyCancellable?
    var sportName: String?
    var sportIconName: String?
    var numberOfLiveEvents: String?
    var updateLiveEvents: (() -> Void)?

    init(sport: EveryMatrix.Discipline, isLive: Bool) {
        self.sport = sport
        self.isLive  = isLive
        
        super.init()

        self.sportName = sport.name
        self.sportIconName =  "sport_type_icon_\(sport.id)"
        
        if let numberOfLiveEvents = sport.numberOfLiveEvents {
            self.numberOfLiveEvents = "\(numberOfLiveEvents)"
        }
        
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
