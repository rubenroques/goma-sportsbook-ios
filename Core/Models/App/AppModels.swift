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

struct Competition {
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

struct Location {
    var id: String
    var name: String
    var isoCode: String
}

struct Participant {
    var id: String
    var name: String
}

struct Market {
    var id: String
    var typeId: String
    var name: String
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

    var startDate: String?
    var homeParticipant: String?
    var awayParticipant: String?

    var eventId: String?

    init(id: String,
         typeId: String,
         name: String,
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
         startDate: String? = nil,
         homeParticipant: String? = nil,
         awayParticipant: String? = nil,
         eventId: String? = nil) {
        
        self.id = id
        self.typeId = typeId
        self.name = name
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
    }
}

struct Outcome {
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
                //let decimalCharacters = CharacterSet.decimalDigits

//                if self.codeName.rangeOfCharacter(from: decimalCharacters) != nil {
//                    return self.codeName.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789. "))
//                }
                if let orderValue = self.orderValue {
                    return orderValue
                }
                if self.orderValue == nil && self.codeName == "other" {
                    return "D"
                }
//                if let externalReference = self.externalReference {
//                    if externalReference == "1727" {
//                        return "1724"
//                    }
//                    if externalReference == "1728" {
//                        return "1725"
//                    }
//                    if externalReference == "1729" {
//                        return "1726"
//                    }
//                    return externalReference
//                }
                return self.codeName
            }
        }

        return self.codeName
    }
}

enum OddFormat: Codable, Hashable, CustomStringConvertible {
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
}

struct BettingOffer {

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
    var type: String
    var id: String
    var matchId: String?
    var imageURL: String?
    var priorityOrder: Int?
    var marketId: String?
}


struct Country: Codable {
    var name: String
    var capital: String?
    var region: String
    var iso2Code: String
    var iso3Code: String
    var numericCode: String
    var phonePrefix: String
}

enum KnowYourCustomerStatus: String, Codable {
    case request
    case passConditional
    case pass
}

struct UserProfile: Codable {
    
    var userIdentifier: String
    var username: String
    var email: String
    var firstName: String?
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

    var avatarName: String?
    var godfatherCode: String?
    var placeOfBirth: String?
    var additionalStreetLine: String?

    var isEmailVerified: Bool
    var isRegistrationCompleted: Bool

    var kycStatus: KnowYourCustomerStatus

    var currency: String?
    
    init(userIdentifier: String, username: String, email: String, firstName: String? = nil, lastName: String? = nil, birthDate: Date,
         nationality: Country?, country: Country?, gender: UserGender, title: UserTitle?, personalIdNumber: String?, address: String?,
         province: String?, city: String?, postalCode: String?, birthDepartment: String?, streetNumber: String?, avatarName: String?,
         godfatherCode: String?, placeOfBirth: String?, additionalStreetLine: String?,
         isEmailVerified: Bool, isRegistrationCompleted: Bool, kycStatus: KnowYourCustomerStatus, currency: String?) {
        self.userIdentifier = userIdentifier
        self.username = username
        self.email = email
        self.firstName = firstName
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

        self.avatarName = avatarName
        self.godfatherCode = godfatherCode
        self.placeOfBirth = placeOfBirth
        self.additionalStreetLine = additionalStreetLine

        self.isEmailVerified = isEmailVerified
        self.isRegistrationCompleted = isRegistrationCompleted
        self.kycStatus = kycStatus
        self.currency = currency
    }
    
}

struct UserWallet {

    let total: Double
    let bonus: Double?
    let totalWithdrawable: Double?
    let currency: String

}
