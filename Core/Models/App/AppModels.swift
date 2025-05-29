//
//  Market.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/10/2021.
//

import Foundation
import GameController
import ServicesProvider

struct CompetitionGroup {
    var id: String
    var name: String
    var aggregationType: AggregationType
    var competitions: [Competition]
    var country: Country?

    enum AggregationType {
        case popular
        case region
    }
}

struct Competition: Hashable {
    var id: String
    var name: String
    var matches: [Match]
    var venue: Location?
    var sport: Sport?
    var numberOutrightMarkets: Int
    var outrightMarkets: [Market]?
    var competitionInfo: SportCompetitionInfo?

    init(id: String, name: String, matches: [Match] = [],
         venue: Location? = nil, sport: Sport?, numberOutrightMarkets: Int,
         outrightMarkets: [Market]? = nil, competitionInfo: SportCompetitionInfo? = nil) {

        self.id = id
        self.name = name
        self.matches = matches
        self.venue = venue
        self.sport = sport
        self.numberOutrightMarkets = numberOutrightMarkets
        self.outrightMarkets = outrightMarkets
        self.competitionInfo = competitionInfo
    }
}

struct Location: Codable, Hashable {
    var id: String
    var name: String
    var isoCode: String
}

struct Participant: Codable, Hashable {
    var id: String
    var name: String
}

struct Market: Hashable {

    enum OutcomesOrder: Codable, Hashable {
        case none
        case odds // by odd
        case name // by name
        case setup // The original order that the server sends us
    }

    var id: String
    var typeId: String
    var name: String
    var isMainMarket: Bool

    var nameDigit1: Double?
    var nameDigit2: Double?
    var nameDigit3: Double?

    var eventPartId: String?
    var bettingTypeId: String?

    var outcomes: [Outcome]

    var marketTypeId: String?
    var eventName: String?
    var isMainOutright: Bool?
    var eventMarketCount: Int?
    var isAvailable: Bool

    var startDate: Date?
    var homeParticipant: String?
    var awayParticipant: String?

    var eventId: String?

    var competitionName: String?

    var statsTypeId: String?

    var outcomesOrder: OutcomesOrder

    var customBetAvailable: Bool?

    var sport: Sport?
    var sportIdCode: String?

    var venueCountry: Country?

    init(id: String,
         typeId: String,
         name: String,
         isMainMarket: Bool = false,
         nameDigit1: Double?,
         nameDigit2: Double?,
         nameDigit3: Double?,
         eventPartId: String?,
         bettingTypeId: String?,
         outcomes: [Outcome],
         marketTypeId: String? = nil,
         eventName: String? = nil,
         isMainOutright: Bool? = nil,
         eventMarketCount: Int? = nil,
         isAvailable: Bool = true,
         startDate: Date? = nil,
         homeParticipant: String? = nil,
         awayParticipant: String? = nil,
         eventId: String? = nil,
         statsTypeId: String? = nil,
         outcomesOrder: OutcomesOrder,
         customBetAvailable: Bool? = nil,
         competitionName: String? = nil,
         sport: Sport? = nil,
         sportIdCode: String? = nil,
         venueCountry: Country? = nil
    ) {

        self.id = id
        self.typeId = typeId
        self.name = name
        self.isMainMarket = isMainMarket
        self.nameDigit1 = nameDigit1
        self.nameDigit2 = nameDigit2
        self.nameDigit3 = nameDigit3
        self.eventPartId = eventPartId
        self.bettingTypeId = bettingTypeId
        self.outcomes = outcomes
        self.marketTypeId = marketTypeId
        self.eventName = eventName
        self.isMainOutright = isMainOutright
        self.eventMarketCount = eventMarketCount
        self.isAvailable = isAvailable
        self.startDate = startDate
        self.homeParticipant = homeParticipant
        self.awayParticipant = awayParticipant
        self.eventId = eventId
        self.statsTypeId = statsTypeId
        self.outcomesOrder = outcomesOrder
        self.customBetAvailable = customBetAvailable
        self.competitionName = competitionName
        self.sport = sport
        self.sportIdCode = sportIdCode
        self.venueCountry = venueCountry
    }
}

struct Outcome: Hashable {
    var id: String
    var codeName: String
    var typeName: String
    var translatedName: String
    var nameDigit1: Double?
    var nameDigit2: Double?
    var nameDigit3: Double?
    var paramBoolean1: Bool?
    var marketName: String?
    var marketId: String?
    var marketDigit1: Double?
    var bettingOffer: BettingOffer
    var orderValue: String?
    var externalReference: String?
    var customBetAvailableMarket: Bool?
    var isTerminated: Bool?

    init(id: String,
         codeName: String,
         typeName: String,
         translatedName: String,
         nameDigit1: Double? = nil,
         nameDigit2: Double? = nil,
         nameDigit3: Double? = nil,
         paramBoolean1: Bool? = nil,
         marketName: String? = nil,
         marketId: String? = nil,
         marketDigit1: Double? = nil,
         bettingOffer: BettingOffer,
         orderValue: String? = nil,
         externalReference: String? = nil,
         customBetAvailableMarket: Bool? = nil,
         isTerminated: Bool? = nil)
    {
        self.id = id
        self.codeName = codeName
        self.typeName = typeName
        self.translatedName = translatedName
        self.nameDigit1 = nameDigit1
        self.nameDigit2 = nameDigit2
        self.nameDigit3 = nameDigit3
        self.paramBoolean1 = paramBoolean1
        self.marketName = marketName
        self.marketId = marketId
        self.marketDigit1 = marketDigit1
        self.bettingOffer = bettingOffer
        self.orderValue = orderValue
        self.externalReference = externalReference
        self.customBetAvailableMarket = customBetAvailableMarket
        self.isTerminated = isTerminated
    }
}

extension Outcome {
    var headerCodeName: String {

        if self.nameDigit1 == nil && self.nameDigit2 == nil && self.nameDigit3 == nil {
            if self.codeName.isNotEmpty, let paramBoolean1 = self.paramBoolean1 {
                return "\(self.codeName)-\(paramBoolean1)"
            }
            else if let paramBoolean1 = self.paramBoolean1 {
                return "\(paramBoolean1)"
            }
            else if self.marketId != nil {
                if let orderValue = self.orderValue {
                    return orderValue
                }
                if self.orderValue == nil && (self.codeName == "other" || self.codeName == "autre") {
                    return "D"
                }
                return self.codeName
            }
        }

        return self.codeName
    }
}

enum OddFormat: Codable, Hashable, CustomStringConvertible, Equatable {
    case fraction(numerator: Int, denominator: Int)
    case decimal(odd: Double)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .fraction(let numerator, let denominator):
            hasher.combine("fraction")
            hasher.combine(numerator)
            hasher.combine(denominator)
        case .decimal(let odd):
            hasher.combine("decimal")
            hasher.combine(odd)
        }
    }

    var description: String {
        switch self {
        case .fraction(let numerator, let denominator):
            let decimal = (Double(numerator)/Double(denominator)) + 1.0
            return "OddFormat \(decimal) [\(numerator)/\(denominator)]"
        case .decimal(let odd):
            return "OddFormat \(odd)"
        }

    }

    var decimalValue: Double {
        switch self {
        case .fraction(let numerator, let denominator):
            let decimal = (Double(numerator)/Double(denominator)) + 1.0
            return decimal
        case .decimal(let odd):
            return odd
        }

    }
}

struct BettingOffer: Hashable {

    var id: String

    var statusId: String
    var isLive: Bool
    var isAvailable: Bool

    var odd: OddFormat

    var decimalOdd: Double {
        switch self.odd {
        case .fraction(let numerator, let denominator):
            let decimal = (Double(numerator)/Double(denominator)) + 1.0
            if decimal.isNaN {
                return decimal
            }
            else {
                return decimal
            }
        case .decimal(let odd):
            return odd
        }
    }

    var fractionalOdd: (numerator: Int, denominator: Int) {
        switch self.odd {
        case .fraction(let numerator, let denominator):
            return (numerator, denominator)
        case .decimal(let odd):
            let rational = OddConverter.rationalApproximation(originalValue: odd)
            return (rational.num, rational.den)
        }
    }

    init(id: String, decimalOdd: Double, statusId: String, isLive: Bool, isAvailable: Bool) {
        self.id = id
        self.odd = OddFormat.decimal(odd: decimalOdd)
        self.statusId = statusId
        self.isLive = isLive
        self.isAvailable = isAvailable
    }

    init(id: String, odd: OddFormat, statusId: String, isLive: Bool, isAvailable: Bool) {
        self.id = id
        self.odd = odd
        self.statusId = statusId
        self.isLive = isLive
        self.isAvailable = isAvailable
    }

}

enum MarketType {
    case homeDrawAway
    case homeDrawAwayHalfTime
    case doubleChance
    case underOver(value: Int)
    case bothTeamsToScore
}

struct BannerInfo {
    var id: String
    var title: String
    var subtitle: String?
    var ctaText: String?
    var ctaUrl: String?
    var platform: String?
    var status: String?
    var startDate: Date?
    var endDate: Date?
    var userType: String?
    var imageURL: String?
}

struct AlertBannerInfo {
    var id: String
    var title: String
    var subtitle: String?
    var ctaText: String?
    var ctaUrl: String?
    var platform: String?
    var status: String?
    var startDate: Date?
    var endDate: Date?
    var userType: String?
}


struct Country: Codable, Hashable {
    var name: String
    var capital: String?
    var region: String
    var iso2Code: String
    var iso3Code: String
    var numericCode: String
    var phonePrefix: String
}

enum KnowYourCustomerStatus: String, Codable, Hashable {
    case request
    case passConditional
    case pass

    var statusName: String {
        switch self {
        case .request: return localized("pending")
        case .passConditional: return localized("pre_validated")
        case .pass: return localized("validated")

        }
    }
}

enum LockedStatus: String, Codable, Hashable {
    case locked
    case notLocked
}

struct UserProfile: Codable, Hashable {

    var userIdentifier: String
    var sessionKey: String

    var username: String
    var email: String
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var birthDate: Date

    var nationality: Country?
    var country: Country?

    var gender: UserGender
    var title: UserTitle?

    var personalIdNumber: String?
    var address: String?
    var province: String?
    var city: String?
    var postalCode: String?

    var birthDepartment: String?
    var streetNumber: String?
    var phoneNumber: String?
    var mobilePhone: String?
    var mobileCountryCode: String?
    var mobileLocalNumber: String?

    var avatarName: String?
    var godfatherCode: String?
    var placeOfBirth: String?
    var additionalStreetLine: String?

    var isEmailVerified: Bool
    var isRegistrationCompleted: Bool

    var kycStatus: KnowYourCustomerStatus
    var lockedStatus: LockedStatus
    var hasMadeDeposit: Bool
    var kycExpire: String?

    var currency: String?

    init(userIdentifier: String, sessionKey: String, username: String, email: String, firstName: String? = nil, middleName: String? = nil, lastName: String? = nil,
         birthDate: Date, nationality: Country?, country: Country?, gender: UserGender, title: UserTitle?, personalIdNumber: String?,
         address: String?, province: String?, city: String?, postalCode: String?, birthDepartment: String?, streetNumber: String?,
         phoneNumber: String?, mobilePhone: String?, mobileCountryCode: String?, mobileLocalNumber: String?, avatarName: String?,
         godfatherCode: String?, placeOfBirth: String?, additionalStreetLine: String?, isEmailVerified: Bool,
         isRegistrationCompleted: Bool, kycStatus: KnowYourCustomerStatus, lockedStatus: LockedStatus, hasMadeDeposit: Bool, kycExpire: String?, currency: String?) {

        self.userIdentifier = userIdentifier
        self.sessionKey = sessionKey
        self.username = username
        self.email = email
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.birthDate = birthDate
        self.nationality = nationality
        self.country = country
        self.gender = gender
        self.title = title
        self.personalIdNumber = personalIdNumber
        self.address = address
        self.province = province
        self.city = city
        self.postalCode = postalCode
        self.birthDepartment = birthDepartment
        self.streetNumber = streetNumber
        self.phoneNumber = phoneNumber
        self.mobilePhone = mobilePhone
        self.mobileCountryCode = mobileCountryCode
        self.mobileLocalNumber = mobileLocalNumber

        self.avatarName = avatarName
        self.godfatherCode = godfatherCode
        self.placeOfBirth = placeOfBirth
        self.additionalStreetLine = additionalStreetLine

        self.isEmailVerified = isEmailVerified
        self.isRegistrationCompleted = isRegistrationCompleted
        self.kycStatus = kycStatus
        self.lockedStatus = lockedStatus
        self.hasMadeDeposit = hasMadeDeposit
        self.kycExpire = kycExpire
        self.currency = currency
    }

}

struct UserWallet: Codable, Hashable {

    let total: Double
    let bonus: Double?
    let totalWithdrawable: Double?
    let currency: String

}

struct PromotionalStory: Codable, Hashable {

    let id: String
    // The title of the button story cell
    let buttonTitle: String
    // The small icon in the button story cell
    let buttonIconUrl: String
    // The (optional) background image in th button story cell
    let buttonBackgroungImageUrl: String?
    // The media content that will show in the fullscreen
    let contentMediaUrl: String
    // the link (internal or external) of the full screen bottom button
    let ctaUrl: String
    // the link (internal or external) of the full screen bottom button
    let ctaText: String
    
}

struct RegionCountry: Codable, Hashable {
    var id: Int
    var isoCode: String
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case isoCode = "iso_code"
        case name = "name"
    }
}

enum TopCompetitionWidgetVersion: Codable, Hashable {
    case version1
    case version2
}

struct Tournament: Decodable {
        
        let type: String
        let id: String
        let idAsString: String?
        let typeId: String?
        let name: String?
        let shortName: String?
        let numberOfEvents: Int?
        let numberOfMarkets: Int?
        let numberOfBettingOffers: Int?
        let numberOfLiveEvents: Int?
        let numberOfLiveMarkets: Int?
        let numberOfLiveBettingOffers: Int?
        let numberOfOutrightMarkets: Int?
        let numberOfUpcomingMatches: Int?
        let sportId: String?
        let sportName: String?
        let shortSportName: String?
        let venueId: String?
        let venueName: String?
        let shortVenueName: String?
        let categoryId: String?
        let templateId: String?
        let templateName: String?
        let rootPartId: String?
        let rootPartName: String?
        let shortRootPartName: String?
        
        enum CodingKeys: String, CodingKey {
            case type = "_type"
            case id = "id"
            case idAsString = "idAsString"
            case typeId = "typeId"
            case name = "name"
            case shortName = "shortName"
            case numberOfEvents = "numberOfEvents"
            case numberOfMarkets = "numberOfMarkets"
            case numberOfBettingOffers = "numberOfBettingOffers"
            case numberOfLiveEvents = "numberOfLiveEvents"
            case numberOfLiveMarkets = "numberOfLiveMarkets"
            case numberOfLiveBettingOffers = "numberOfLiveBettingOffers"
            case numberOfOutrightMarkets = "numberOfOutrightMarkets"
            case numberOfUpcomingMatches = "numberOfUpcomingMatches"
            case sportId = "sportId"
            case sportName = "sportName"
            case shortSportName = "shortSportName"
            case venueId = "venueId"
            case venueName = "venueName"
            case shortVenueName = "shortVenueName"
            case categoryId = "categoryId"
            case templateId = "templateId"
            case templateName = "templateName"
            case rootPartId = "rootPartId"
            case rootPartName = "rootPartName"
            case shortRootPartName = "shortRootPartName"
        }
    }
