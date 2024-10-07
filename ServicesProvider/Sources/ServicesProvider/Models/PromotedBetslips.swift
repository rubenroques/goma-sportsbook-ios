//
//  File.swift
//
//
//  Created by Ruben Roques on 01/08/2024.
//

import Foundation
import SharedModels

public struct PromotedBetslipsBatchResponse: Codable {
    public var promotedBetslips: [PromotedBetslip]
}

public struct PromotedBetslip: Codable {
    
    public var selections: [PromotedBetslipSelection]
    public var betslipCount: Int
    
    public init(selections: [PromotedBetslipSelection], betslipCount: Int) {
        self.selections = selections
        self.betslipCount = betslipCount
    }
    
}

public struct PromotedBetslipSelection: Codable {
    
    public var id: String
    public var country: Country?
    public var competitionName: String
    
    public var eventId: String
    public var marketId: String
    public var outcomeId: String
    
    public var marketName: String
    public var outcomeName: String
        
    public var participantIds: [String]
    public var participants: [String]
    public var sport: SportType?
    public var odd: Double
  

    public var eventName: String {
        return (participants.first ?? "") + " x " + (participants.last ?? "")
    }
    
    init(id: String, countryName: String, competitionName: String, eventId: String, marketId: String, outcomeId: String, marketName: String, outcomeType: String, participantIds: [String], participants: [String], sport: SportType? = nil, odd: Double) {
        self.id = id
        self.competitionName = competitionName
        
        self.eventId = eventId
        self.marketId = marketId
        self.outcomeId = outcomeId
        
        self.marketName = marketName
        
        switch outcomeType.lowercased() {
        case "home":
            self.outcomeName = (participants.first ?? "")
        case "draw":
            self.outcomeName = "draw"
        case "away":
            self.outcomeName = (participants.last ?? "")
        default:
            self.outcomeName = ""
        }
        
        self.participantIds = participantIds
        self.participants = participants
        self.sport = sport
        self.odd = odd
        
        self.country = Country.country(withName: countryName)
    }
 
    
}

extension PromotedBetslipsBatchResponse {
    static var dummyData: Data {
        let dummyString = """
                            {"data":[{"body":{"data":{"betslips":[{"betslip":[{"begin":"2024-08-08T17:00:00Z","bet_offer_id":null,"count":225,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117173","event_type":null,"league":"UEFA Europa League","league_id":"sr:tournament:679","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376682.1","orako_market_id":"59886737.1","orako_selection_id":"283875899.1","outcome":"home","outcome_id":1,"participant_ids":["sr:competitor:3051","sr:competitor:2055"],"participants":["Trabzonspor","SK Rapid"],"period":null,"period_id":null,"quote":1.83,"quote_group":"1.8-2.6","selection_id":"48805a6d6cb3953cfa30dc27965a528e","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/1"},{"begin":"2024-08-08T16:30:00Z","bet_offer_id":null,"count":125,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117069","event_type":null,"league":"UEFA Conference League","league_id":"sr:tournament:34480","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376560.1","orako_market_id":"59877201.1","orako_selection_id":"283834819.1","outcome":"away","outcome_id":3,"participant_ids":["sr:competitor:2397","sr:competitor:2036"],"participants":["MFK Ruzomberok","HNK Hajduk Split"],"period":null,"period_id":null,"quote":1.74,"quote_group":"1.4-1.8","selection_id":"e0a141b9bc122f5e0a2b3f7a6bc77ad4","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/3"},{"begin":"2024-08-08T18:45:00Z","bet_offer_id":null,"count":28,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117013","event_type":null,"league":"UEFA Conference League","league_id":"sr:tournament:34480","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376577.1","orako_market_id":"59878499.1","orako_selection_id":"283841760.1","outcome":"home","outcome_id":1,"participant_ids":["sr:competitor:3169","sr:competitor:382568"],"participants":["Saint Patrick´s Athletic FC","Sabah Masazir"],"period":null,"period_id":null,"quote":3.3,"quote_group":"2.6-4.2","selection_id":"180a66c41088ac8b42303bb41d6fa2f7","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/1"},{"begin":"2024-08-08T18:15:00Z","bet_offer_id":null,"count":81,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117009","event_type":null,"league":"UEFA Conference League","league_id":"sr:tournament:34480","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376562.1","orako_market_id":"59877203.1","orako_selection_id":"283834823.1","outcome":"home","outcome_id":1,"participant_ids":["sr:competitor:2420","sr:competitor:5150"],"participants":["NK Maribor","FK Vojvodina Novi Sad"],"period":null,"period_id":null,"quote":1.82,"quote_group":"1.8-2.6","selection_id":"6cfce48e6f784a4003f8c0c6c40495bf","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/1"},{"begin":"2024-08-08T18:00:00Z","bet_offer_id":null,"count":161,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:51795749","event_type":null,"league":"UEFA Europa League","league_id":"sr:tournament:679","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376684.1","orako_market_id":"59886768.1","orako_selection_id":"283875980.1","outcome":"away","outcome_id":3,"participant_ids":["sr:competitor:3320","sr:competitor:4502"],"participants":["FC Kryvbas Kriviy Rih","FC Viktoria Plzen"],"period":null,"period_id":null,"quote":1.59,"quote_group":"1.4-1.8","selection_id":"5b7e687e0c162113f369045ae9277a0c","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/3"}],"betslip_count":3}],"count":1},"status":"success"},"name":"multigame_acca_1","status_code":200},{"body":{"data":{"betslips":[{"betslip":[{"begin":"2024-08-08T17:00:00Z","bet_offer_id":null,"count":225,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117173","event_type":null,"league":"UEFA Europa League","league_id":"sr:tournament:679","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376682.1","orako_market_id":"59886737.1","orako_selection_id":"283875899.1","outcome":"home","outcome_id":1,"participant_ids":["sr:competitor:3051","sr:competitor:2055"],"participants":["Trabzonspor","SK Rapid"],"period":null,"period_id":null,"quote":1.83,"quote_group":"1.8-2.6","selection_id":"48805a6d6cb3953cfa30dc27965a528e","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/1"},{"begin":"2024-08-08T16:30:00Z","bet_offer_id":null,"count":125,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117069","event_type":null,"league":"UEFA Conference League","league_id":"sr:tournament:34480","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376560.1","orako_market_id":"59877201.1","orako_selection_id":"283834819.1","outcome":"away","outcome_id":3,"participant_ids":["sr:competitor:2397","sr:competitor:2036"],"participants":["MFK Ruzomberok","HNK Hajduk Split"],"period":null,"period_id":null,"quote":1.74,"quote_group":"1.4-1.8","selection_id":"e0a141b9bc122f5e0a2b3f7a6bc77ad4","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/3"},{"begin":"2024-08-08T18:45:00Z","bet_offer_id":null,"count":28,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117013","event_type":null,"league":"UEFA Conference League","league_id":"sr:tournament:34480","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376577.1","orako_market_id":"59878499.1","orako_selection_id":"283841760.1","outcome":"home","outcome_id":1,"participant_ids":["sr:competitor:3169","sr:competitor:382568"],"participants":["Saint Patrick´s Athletic FC","Sabah Masazir"],"period":null,"period_id":null,"quote":3.3,"quote_group":"2.6-4.2","selection_id":"180a66c41088ac8b42303bb41d6fa2f7","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/1"},{"begin":"2024-08-08T18:15:00Z","bet_offer_id":null,"count":81,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117009","event_type":null,"league":"UEFA Conference League","league_id":"sr:tournament:34480","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376562.1","orako_market_id":"59877203.1","orako_selection_id":"283834823.1","outcome":"home","outcome_id":1,"participant_ids":["sr:competitor:2420","sr:competitor:5150"],"participants":["NK Maribor","FK Vojvodina Novi Sad"],"period":null,"period_id":null,"quote":1.82,"quote_group":"1.8-2.6","selection_id":"6cfce48e6f784a4003f8c0c6c40495bf","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/1"},{"begin":"2024-08-08T18:00:00Z","bet_offer_id":null,"count":161,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:51795749","event_type":null,"league":"UEFA Europa League","league_id":"sr:tournament:679","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376684.1","orako_market_id":"59886768.1","orako_selection_id":"283875980.1","outcome":"away","outcome_id":3,"participant_ids":["sr:competitor:3320","sr:competitor:4502"],"participants":["FC Kryvbas Kriviy Rih","FC Viktoria Plzen"],"period":null,"period_id":null,"quote":1.59,"quote_group":"1.4-1.8","selection_id":"5b7e687e0c162113f369045ae9277a0c","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/3"}],"betslip_count":3}],"count":1},"status":"success"},"name":"multigame_acca_2","status_code":200},{"body":{"data":{"betslips":[{"betslip":[{"begin":"2024-08-08T17:00:00Z","bet_offer_id":null,"count":225,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117173","event_type":null,"league":"UEFA Europa League","league_id":"sr:tournament:679","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376682.1","orako_market_id":"59886737.1","orako_selection_id":"283875899.1","outcome":"home","outcome_id":1,"participant_ids":["sr:competitor:3051","sr:competitor:2055"],"participants":["Trabzonspor","SK Rapid"],"period":null,"period_id":null,"quote":1.83,"quote_group":"1.8-2.6","selection_id":"48805a6d6cb3953cfa30dc27965a528e","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/1"},{"begin":"2024-08-08T16:30:00Z","bet_offer_id":null,"count":125,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117069","event_type":null,"league":"UEFA Conference League","league_id":"sr:tournament:34480","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376560.1","orako_market_id":"59877201.1","orako_selection_id":"283834819.1","outcome":"away","outcome_id":3,"participant_ids":["sr:competitor:2397","sr:competitor:2036"],"participants":["MFK Ruzomberok","HNK Hajduk Split"],"period":null,"period_id":null,"quote":1.74,"quote_group":"1.4-1.8","selection_id":"e0a141b9bc122f5e0a2b3f7a6bc77ad4","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/3"},{"begin":"2024-08-08T18:45:00Z","bet_offer_id":null,"count":28,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117013","event_type":null,"league":"UEFA Conference League","league_id":"sr:tournament:34480","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376577.1","orako_market_id":"59878499.1","orako_selection_id":"283841760.1","outcome":"home","outcome_id":1,"participant_ids":["sr:competitor:3169","sr:competitor:382568"],"participants":["Saint Patrick´s Athletic FC","Sabah Masazir"],"period":null,"period_id":null,"quote":3.3,"quote_group":"2.6-4.2","selection_id":"180a66c41088ac8b42303bb41d6fa2f7","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/1"},{"begin":"2024-08-08T18:15:00Z","bet_offer_id":null,"count":81,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:52117009","event_type":null,"league":"UEFA Conference League","league_id":"sr:tournament:34480","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376562.1","orako_market_id":"59877203.1","orako_selection_id":"283834823.1","outcome":"home","outcome_id":1,"participant_ids":["sr:competitor:2420","sr:competitor:5150"],"participants":["NK Maribor","FK Vojvodina Novi Sad"],"period":null,"period_id":null,"quote":1.82,"quote_group":"1.8-2.6","selection_id":"6cfce48e6f784a4003f8c0c6c40495bf","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/1"},{"begin":"2024-08-08T18:00:00Z","bet_offer_id":null,"count":161,"country":"International Clubs","country_id":"sr:category:393","event_id":"sr:match:51795749","event_type":null,"league":"UEFA Europa League","league_id":"sr:tournament:679","market":null,"market_id":null,"market_type":"1x2","market_type_id":1,"orako_event_id":"3376684.1","orako_market_id":"59886768.1","orako_selection_id":"283875980.1","outcome":"away","outcome_id":3,"participant_ids":["sr:competitor:3320","sr:competitor:4502"],"participants":["FC Kryvbas Kriviy Rih","FC Viktoria Plzen"],"period":null,"period_id":null,"quote":1.59,"quote_group":"1.4-1.8","selection_id":"5b7e687e0c162113f369045ae9277a0c","sport":"Soccer","sport_id":"sr:sport:1","status":"not_started","uof_external_id":"uof:3/sr:sport:1/1/3"}],"betslip_count":3}],"count":1},"status":"success"},"name":"multigame_acca_3","status_code":200}],"status":"success"}
                    """
        
        return dummyString.data(using: .utf8)!
    }
}
