//
//  Competition.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation

struct Competition: Hashable {
    var id: String
    var name: String
    var matches: [Match]
    var venue: Location?
    var sport: Sport?
    var numberOutrightMarkets: Int
    var outrightMarkets: [Market]?
    var numberEvents: Int?
    var numberLiveEvents: Int?

    init(id: String,
         name: String,
         matches: [Match],
         venue: Location?,
         sport: Sport?,
         numberOutrightMarkets: Int,
         outrightMarkets: [Market]?,
         numberEvents: Int?,
         numberLiveEvents: Int? = nil) {

        self.id = id
        self.name = name
        self.matches = matches
        self.venue = venue
        self.sport = sport
        self.numberOutrightMarkets = numberOutrightMarkets
        self.outrightMarkets = outrightMarkets
        self.numberEvents = numberEvents
        self.numberLiveEvents = numberLiveEvents
    }
}
