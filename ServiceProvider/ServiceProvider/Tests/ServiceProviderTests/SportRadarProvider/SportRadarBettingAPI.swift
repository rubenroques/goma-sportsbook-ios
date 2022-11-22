//
//  SportRadarBettingAPI.swift
//  
//
//  Created by Ruben Roques on 17/11/2022.
//

import XCTest
import Combine

@testable import ServiceProvider

final class SportRadarBettingAPI: XCTestCase {

    func testCalculeReturnsEndpoint() throws {
        
        var selections: [SportRadarModels.BetTicketSelection] = []
        
        var selection1 = SportRadarModels.BetTicketSelection(identifier: "192633096.1",
                                            eachWayReduction: "",
                                            eachWayPlaceTerms: "",
                                            idFOPriceType: "CP",
                                            isTrap: "",
                                            priceUp: "1",
                                            priceDown: "2")
        
        var selection2 = SportRadarModels.BetTicketSelection(identifier: "192633093.1",
                                            eachWayReduction: "",
                                            eachWayPlaceTerms: "",
                                            idFOPriceType: "CP",
                                            isTrap: "",
                                            priceUp: "1",
                                            priceDown: "2")
        selections.append(selection1)
        selections.append(selection2)
        
        var betTicket = SportRadarModels.BetTicket(selections: selections,
                                   betTypeCode: "D",
                                   placeStake: "",
                                   winStake: "3",
                                   pool: false)
        
        let endpoint = BettingAPIClient.calculateReturns(betTicket: betTicket)
        
        let expectedValue = """
        {
          "betLegs": [
            {
              "idFOSelection": "192633096.1",
              "eachWayReduction": "",
              "eachWayPlaceTerms": "",
              "idFOPriceType": "CP",
              "priceUp": "1",
              "isTrap": "",
              "priceDown": "2"
            },
            {
              "idFOSelection": "192633093.1",
              "eachWayReduction": "",
              "eachWayPlaceTerms": "",
              "idFOPriceType": "CP",
              "priceUp": "1",
              "isTrap": "",
              "priceDown": "2"
            }
          ],
          "idFOBetType": "D",
          "placeStake": "",
          "winStake": "3",
          "pool": false
        }
        """
        
        endpoint.request()?.httpBody
        
    }

}
