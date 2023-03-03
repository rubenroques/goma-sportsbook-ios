//
//  File.swift
//  
//
//  Created by Ruben Roques on 26/10/2022.
//

import Foundation

extension SportRadarModels {

    struct SportRadarResponse<T: Codable>: Codable {
        var data: T
        var version: Int?

        enum CodingKeys: String, CodingKey {
            case data = "data"
            case version = "value"
        }
    }
    
    struct Event: Codable {
        
        var id: String
        var homeName: String?
        var awayName: String?
        var sportTypeName: String?
        var sportTypeCode: String?

        var competitionId: String?
        var competitionName: String?
        var startDate: Date?
        
        var markets: [Market]?

        var tournamentCountryName: String?
        
        var numberMarkets: Int?
        var name: String?

        enum CodingKeys: String, CodingKey {
            case id = "idfoevent"
            case homeName = "participantname_home"
            case awayName = "participantname_away"
            case competitionId = "idfotournament"
            case competitionName = "tournamentname"
            case sportTypeName = "sporttypename"
            case startDate = "tsstart"
            case markets = "markets"
            case tournamentCountryName = "tournamentcountryname"
            case numberMarkets = "numMarkets"
            case name = "name"
            case sportTypeCode = "idfosporttype"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.Event.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.homeName = try container.decodeIfPresent(String.self, forKey: .homeName)
            self.awayName = try container.decodeIfPresent(String.self, forKey: .awayName)
            self.competitionId = try container.decodeIfPresent(String.self, forKey: .competitionId)
            self.competitionName = try container.decodeIfPresent(String.self, forKey: .competitionName)
            self.sportTypeName = try container.decodeIfPresent(String.self, forKey: .sportTypeName)
            self.markets = try container.decodeIfPresent([SportRadarModels.Market].self, forKey: .markets)
            self.tournamentCountryName = try container.decodeIfPresent(String.self, forKey: .tournamentCountryName)

            self.numberMarkets = container.contains(.numberMarkets) ? try container.decode(Int.self, forKey: .numberMarkets) : self.markets?.first?.eventMarketCount

            self.name = try container.decodeIfPresent(String.self, forKey: .name)

            self.sportTypeCode = try container.decodeIfPresent(String.self, forKey: .sportTypeCode)

            if let startDateString = try container.decodeIfPresent(String.self, forKey: .startDate) {
                if let date = Self.dateFormatter.date(from: startDateString) {
                    self.startDate = date
                }
                else {
                    throw DecodingError.dataCorruptedError(forKey: .startDate, in: container, debugDescription: "Start date with wrong format.")
                }
            }
            else {
                throw DecodingError.dataCorruptedError(forKey: .startDate, in: container, debugDescription: "Not start date found.")
            }
        }

        private static var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return formatter
        }
    }
    
    struct Market: Codable {
        
        var id: String
        var name: String
        var outcomes: [Outcome]
        var marketTypeId: String?
        var eventMarketTypeId: String?
        var eventName: String?
        var isMainOutright: Bool?
        var eventMarketCount: Int?

        enum CodingKeys: String, CodingKey {
            case id = "idfomarket"
            case name = "name"
            case outcomes = "selections"
            case marketTypeId = "idefmarkettype"
            case eventMarketTypeId = "idfomarkettype"
            case eventName = "eventname"
            case isMainOutright = "ismainoutright"
            case eventMarketCount = "eventMarketCount"
        }
        
    }
    
    struct Outcome: Codable {
        
        var id: String
        var name: String
        var hashCode: String
        var marketId: String?
        var orderValue: String?
        var externalReference: String?

        var odd: OddFormat
        
        private var priceNumerator: String?
        private var priceDenominator: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "idfoselection"
            case name = "name"
            case hashCode = "selectionhashcode"
            case priceNumerator = "currentpriceup"
            case priceDenominator = "currentpricedown"
            case marketId = "idfomarket"
            case orderValue = "hadvalue"
            case externalReference = "externalreference"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.Outcome.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.Outcome.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: SportRadarModels.Outcome.CodingKeys.id)
            self.name = try container.decode(String.self, forKey: SportRadarModels.Outcome.CodingKeys.name)
            self.hashCode = try container.decode(String.self, forKey: SportRadarModels.Outcome.CodingKeys.hashCode)
            self.priceNumerator = try container.decodeIfPresent(String.self, forKey: SportRadarModels.Outcome.CodingKeys.priceNumerator)
            self.priceDenominator = try container.decodeIfPresent(String.self, forKey: SportRadarModels.Outcome.CodingKeys.priceDenominator)
            self.marketId = try container.decodeIfPresent(String.self, forKey: SportRadarModels.Outcome.CodingKeys.marketId)
            self.orderValue = try container.decodeIfPresent(String.self, forKey: SportRadarModels.Outcome.CodingKeys.orderValue)
            self.externalReference = try container.decodeIfPresent(String.self, forKey: SportRadarModels.Outcome.CodingKeys.externalReference)

            let numerator = Double(self.priceNumerator ?? "0.0") ?? 1.0
            let denominator = Double(self.priceDenominator ?? "0.0") ?? 1.0

            self.odd = .fraction(numerator: Int(numerator), denominator: Int(denominator) )
        }

    }

    struct SportNodeInfo: Codable {
        var id: String
        var regionNodes: [SportRegion]
        var navigationTypes: [String]?
        var name: String?
        var defaultOrder: Int?
        var numMarkets: String?
        var numEvents: String?
        var numOutrightMarkets: String?
        var numOutrightEvents: String?

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case regionNodes = "bonavigationnodes"
            case navigationTypes = "idfwbonavigationtypes"
            case name = "name"
            case defaultOrder = "defaultOrder"
            case numMarkets = "nummarkets"
            case numEvents = "numevents"
            case numOutrightMarkets = "numoutrightmarkets"
            case numOutrightEvents = "numoutrightevents"
        }
    }

    struct SportRegion: Codable {
        var id: String
        var name: String?
        var numberEvents: String
        var numberOutrightEvents: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case numberEvents = "numevents"
            case numberOutrightEvents = "numoutrightevents"
        }
    }

    struct SportRegionInfo: Codable {
        var id: String
        var name: String
        var competitionNodes: [SportCompetition]

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case competitionNodes = "bonavigationnodes"
        }
    }

    struct SportCompetition: Codable {
        var id: String
        var name: String
        var numberEvents: String
        var numberOutrightEvents: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case numberEvents = "numevents"
            case numberOutrightEvents = "numoutrightevents"
        }
    }

    struct SportCompetitionInfo: Codable {
        var id: String
        var name: String
        var marketGroups: [SportCompetitionMarketGroup]
        var numberOutrightEvents: String
        var numberOutrightMarkets: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case marketGroups = "marketgroups"
            case numberOutrightEvents = "numoutrightevents"
            case numberOutrightMarkets = "numoutrightmarkets"
        }
    }

    struct SportCompetitionMarketGroup: Codable {
        var id: String
        var name: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwmarketgroup"
            case name = "name"
        }
    }

    struct CompetitionMarketGroup: Codable {
        var id: String
        var name: String
        var events: [Event]

        enum CodingKeys: String, CodingKey {
            case id = "idfwmarketgroup"
            case name = "name"
            case events = "events"
        }
    }

    struct BannerResponse: Codable {
        var bannerItems: [Banner]

        enum CodingKeys: String, CodingKey {
            case bannerItems = "headlineItems"
        }
    }

    struct Banner: Codable {
        var id: String
        var name: String
        var title: String
        var imageUrl: String
        var bodyText: String?
        var type: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwheadline"
            case name = "name"
            case title = "title"
            case imageUrl = "imageurl"
            case bodyText = "bodytext"
            case type = "idfwheadlinetype"
        }
    }

    // Favorites
    struct FavoritesListResponse: Codable {
        var favoritesList: [FavoriteList]

        enum CodingKeys: String, CodingKey {
            case favoritesList = "accountFavouriteCoupons"
        }
    }

    struct FavoriteList: Codable {
        var id: Int
        var name: String
        var customerId: Int

        enum CodingKeys: String, CodingKey {
            case id = "idfwAccountFavouriteCoupon"
            case name = "name"
            case customerId = "idmmCustomer"
        }
    }

    struct FavoritesListAddResponse: Codable {
        var listId: Int

        enum CodingKeys: String, CodingKey {
            case listId = "addAccountFavouriteCouponResult"
        }
    }

    struct FavoritesListDeleteResponse: Codable {
        var listId: String?

        enum CodingKeys: String, CodingKey {
            case listId = "addAccountFavouriteCouponResult"
        }
    }

    struct FavoriteAddResponse: Codable {
        var displayOrder: Int?
        var idAccountFavorite: Int?

        enum CodingKeys: String, CodingKey {
            case displayOrder = "displayOrder"
            case idAccountFavorite = "idAccountFavourite"
        }
    }

    struct FavoriteEventResponse: Codable {
        var favoriteEvents: [FavoriteEvent]

        enum CodingKeys: String, CodingKey {
            case favoriteEvents = "accountFavourites"
        }
    }

    struct FavoriteEvent: Codable {
        var id: String
        var name: String
        var favoriteListId: Int
        var accountFavoriteId: Int

        enum CodingKeys: String, CodingKey {
            case id = "favouriteId"
            case name = "favouriteName"
            case favoriteListId = "idfwAccountFavouriteCoupon"
            case accountFavoriteId = "idfwAccountFavourites"
        }

    }
    
}



