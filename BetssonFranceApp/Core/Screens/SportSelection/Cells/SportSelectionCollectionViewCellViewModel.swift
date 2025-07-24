//
//  SportSelectionCollectionViewCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 07/01/2022.
//

import Foundation
import Combine

class SportSelectionCollectionViewCellViewModel: NSObject {

    private var sport: Sport
    var isLive: Bool
    
    var sportPublisher: AnyCancellable?
    var sportName: String?
    var sportIconName: String?
    var numberOfLiveEvents: String?

    var sportId: String {
        return self.sport.id
    }

    init(sport: Sport, isLive: Bool) {
        self.sport = sport
        self.isLive  = isLive
        
        super.init()

        self.sportName = sport.name
        self.sportIconName =  "sport_type_icon_\(sport.id)"
        
        let numberOfLiveEvents = sport.liveEventsCount
        self.numberOfLiveEvents = "\(numberOfLiveEvents)"
    }

}
