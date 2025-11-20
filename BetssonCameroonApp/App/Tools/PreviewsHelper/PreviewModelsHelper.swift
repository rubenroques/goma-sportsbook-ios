//
//  PreviewModelsHelper.swift
//  Sportsbook
//
//  Created by
//

import Foundation
import ServicesProvider

/**
 # PreviewModelsHelper

 This helper struct provides a comprehensive collection of mock models for SwiftUI previews in the Sportsbook app.
 Use these methods to quickly create realistic test data for UI development without needing backend connections.

 ## Available Mock Data Categories:

 ### Participants
 - `createHomeParticipant()` - Creates a mock home team/player
 - `createAwayParticipant()` - Creates a mock away team/player

 ### Betting Offers
 - `createHomeBettingOffer()` - Betting offer for home team (1.5 odds)
 - `createDrawBettingOffer()` - Betting offer for draw (3.5 odds)
 - `createAwayBettingOffer()` - Betting offer for away team (5.0 odds)
 - `createCustomBettingOffer(id:odd:isLive:)` - Custom betting offer with specified parameters
 - `createSuspendedBettingOffer()` - Unavailable betting offer

 ### Outcomes
 - `createHomeOutcome()` - Home win outcome
 - `createDrawOutcome()` - Draw outcome
 - `createAwayOutcome()` - Away win outcome
 - `createCustomOutcome(id:codeName:typeName:translatedName:odd:)` - Custom outcome with specified parameters

 ### Markets
 - `create1X2Market()` - Standard 1X2 (home/draw/away) market
 - `createOverUnderMarket(value:)` - Over/Under market with customizable threshold
 - `createDoubleChanceMarket()` - Double Chance market (1X, 12, X2)
 - `createMultipleMarkets()` - Collection of common markets
 - `createBothTeamsToScoreMarket()` - Both Teams To Score market (Yes/No)
 - `createCorrectScoreMarket()` - Correct Score market with multiple score options
 - `createFirstGoalscorerMarket()` - First Goalscorer market with player options
 - `createComprehensiveFootballMarkets()` - Complete set of football markets

 ### Venues/Locations
 - `createVenue()` - Basic venue with name and country code

 ### Sports
 - `createFootballSport()` - Football/Soccer sport
 - `createBasketballSport()` - Basketball sport
 - `createTennisSport()` - Tennis sport
 - `createHockeySport()` - Ice Hockey sport
 - `createRugbySport()` - Rugby sport
 - `createCricketSport()` - Cricket sport
 - `createVolleyballSport()` - Volleyball sport

 ### Matches
 - `createFootballMatch()` - Standard football match
 - `createLiveFootballMatch()` - Football match in progress
 - `createCompletedFootballMatch()` - Finished football match with final score
 - `createFootballMatchWithMultipleMarkets()` - Football match with various market types
 - `createFootballMatchWithComprehensiveMarkets()` - Football match with all available market types
 - `createTennisMatch()` - Tennis match with set scores
 - `createBasketballMatch()` - Basketball match with quarter scores
 - `createHockeyMatch()` - Ice Hockey match
 - `createRugbyMatch()` - Rugby match
 - `createCricketMatch()` - Cricket match

 ### Competitions
 - `createPremierLeagueCompetition()` - Premier League football competition
 - `createLaLigaCompetition()` - La Liga football competition
 - `createSerieACompetition()` - Serie A football competition
 - `createNBACompetition()` - NBA basketball competition
 - `createNHLCompetition()` - NHL ice hockey competition
 - `createSixNationsCompetition()` - Six Nations rugby competition
 - `createIPLCompetition()` - IPL cricket competition

 ### Competition Groups
 - `createPopularCompetitionsGroup()` - Group of popular competitions
 - `createUKCompetitionsGroup()` - UK-based competitions group
 - `createNorthAmericanCompetitionsGroup()` - North American competitions group
 - `createInternationalCompetitionsGroup()` - International competitions group

 ### Countries
 - `createFranceCountry()` - France country data
 - `createUKCountry()` - United Kingdom country data
 - `createSpainCountry()` - Spain country data
 - `createGermanyCountry()` - Germany country data
 - `createItalyCountry()` - Italy country data

 ### Detailed Scores
 - `createFootballDetailedScores()` - Detailed scores for football match
 - `createTennisDetailedScores()` - Set-by-set scores for tennis match
 - `createBasketballDetailedScores()` - Quarter scores for basketball match

 ### User Profiles
 - `createUserProfile()` - Standard verified user profile
 - `createPendingVerificationUserProfile()` - User with pending KYC verification
 - `createNewUserProfile()` - Newly registered user
 - `createLockedUserProfile()` - User with locked account

 ### User Wallets
 - `createGBPUserWallet()` - Wallet with GBP currency
 - `createEURUserWallet()` - Wallet with EUR currency
 - `createUSDUserWallet()` - Wallet with USD currency
 - `createEmptyUserWallet()` - Empty wallet with zero balance

 ### Promotional Content
 - `createPromotionalStory()` - Single promotional story  [missing]
 - `createPromotionalStories()` - Collection of promotional stories [missing]


 ## Usage Example:
 ```swift
 struct MatchCardPreview: PreviewProvider {
     static var previews: some View {
         VStack {
             MatchCard(match: PreviewModelsHelper.createLiveFootballMatch())
             MatchCard(match: PreviewModelsHelper.createTennisMatch())
             MatchCard(match: PreviewModelsHelper.createCompletedFootballMatch())
         }
     }
 }
 ```
 */

/// Helper struct containing mock models for SwiftUI previews
struct PreviewModelsHelper {

    // MARK: - Participants

    /// Creates a mock home participant
    static func createHomeParticipant() -> Participant {
        return Participant(
            id: "1",
            name: "Real Madrid"
        )
    }

    /// Creates a mock away participant
    static func createAwayParticipant() -> Participant {
        return Participant(
            id: "2",
            name: "SL Benfica"
        )
    }

    // MARK: - Betting Offers

    /// Creates a mock betting offer for the home team
    static func createHomeBettingOffer() -> BettingOffer {
        return BettingOffer(
            id: "bo1",
            decimalOdd: 1.5,
            statusId: "ACTIVE",
            isLive: false,
            isAvailable: true
        )
    }

    /// Creates a mock betting offer for a draw
    static func createDrawBettingOffer() -> BettingOffer {
        return BettingOffer(
            id: "bo2",
            decimalOdd: 3.5,
            statusId: "ACTIVE",
            isLive: false,
            isAvailable: true
        )
    }

    /// Creates a mock betting offer for the away team
    static func createAwayBettingOffer() -> BettingOffer {
        return BettingOffer(
            id: "bo3",
            decimalOdd: 5.0,
            statusId: "ACTIVE",
            isLive: false,
            isAvailable: true
        )
    }

    /// Creates a custom betting offer with specified odd
    static func createCustomBettingOffer(id: String = UUID().uuidString, odd: Double, isLive: Bool = false) -> BettingOffer {
        return BettingOffer(
            id: id,
            decimalOdd: odd,
            statusId: "ACTIVE",
            isLive: isLive,
            isAvailable: true
        )
    }

    /// Creates a suspended betting offer
    static func createSuspendedBettingOffer() -> BettingOffer {
        return BettingOffer(
            id: "suspended",
            decimalOdd: 0.0,
            statusId: "SUSPENDED",
            isLive: false,
            isAvailable: false
        )
    }

    // MARK: - Outcomes

    /// Creates a mock home win outcome
    static func createHomeOutcome() -> Outcome {
        return Outcome(
            id: "1",
            codeName: "1",
            typeName: "1",
            translatedName: "Home",
            bettingOffer: createHomeBettingOffer()
        )
    }

    /// Creates a mock draw outcome
    static func createDrawOutcome() -> Outcome {
        return Outcome(
            id: "2",
            codeName: "X",
            typeName: "X",
            translatedName: "Draw",
            bettingOffer: createDrawBettingOffer()
        )
    }

    /// Creates a mock away win outcome
    static func createAwayOutcome() -> Outcome {
        return Outcome(
            id: "3",
            codeName: "2",
            typeName: "2",
            translatedName: "Away",
            bettingOffer: createAwayBettingOffer()
        )
    }

    /// Creates a custom outcome with specified parameters
    static func createCustomOutcome(id: String, codeName: String, typeName: String, translatedName: String, odd: Double) -> Outcome {
        return Outcome(
            id: id,
            codeName: codeName,
            typeName: typeName,
            translatedName: translatedName,
            bettingOffer: createCustomBettingOffer(odd: odd)
        )
    }

    // MARK: - Markets

    /// Creates a mock 1X2 market
    static func create1X2Market() -> Market {
        return Market(
            id: "1",
            typeId: "1X2",
            name: "1X2",
            isMainMarket: true,
            nameDigit1: nil,
            nameDigit2: nil,
            nameDigit3: nil,
            eventPartId: nil,
            bettingTypeId: nil,
            outcomes: [createHomeOutcome(), createDrawOutcome(), createAwayOutcome()],
            outcomesOrder: .setup
        )
    }

    /// Creates a mock Over/Under market
    static func createOverUnderMarket(value: Double = 2.5) -> Market {
        let over = createCustomOutcome(id: "ou1", codeName: "Over", typeName: "Over", translatedName: "Over \(value)", odd: 1.85)
        let under = createCustomOutcome(id: "ou2", codeName: "Under", typeName: "Under", translatedName: "Under \(value)", odd: 1.95)

        return Market(
            id: "2",
            typeId: "OVER_UNDER",
            name: "Total Goals",
            isMainMarket: false,
            nameDigit1: value,
            nameDigit2: nil,
            nameDigit3: nil,
            eventPartId: nil,
            bettingTypeId: nil,
            outcomes: [over, under],
            outcomesOrder: .setup
        )
    }

    /// Creates a mock Double Chance market
    static func createDoubleChanceMarket() -> Market {
        let homeDraw = createCustomOutcome(id: "dc1", codeName: "1X", typeName: "1X", translatedName: "Home or Draw", odd: 1.25)
        let homeAway = createCustomOutcome(id: "dc2", codeName: "12", typeName: "12", translatedName: "Home or Away", odd: 1.30)
        let drawAway = createCustomOutcome(id: "dc3", codeName: "X2", typeName: "X2", translatedName: "Draw or Away", odd: 1.40)

        return Market(
            id: "3",
            typeId: "DOUBLE_CHANCE",
            name: "Double Chance",
            isMainMarket: false,
            nameDigit1: nil,
            nameDigit2: nil,
            nameDigit3: nil,
            eventPartId: nil,
            bettingTypeId: nil,
            outcomes: [homeDraw, homeAway, drawAway],
            outcomesOrder: .setup
        )
    }

    /// Creates a list of multiple markets for a comprehensive match view
    static func createMultipleMarkets() -> [Market] {
        return [
            create1X2Market(),
            createOverUnderMarket(),
            createDoubleChanceMarket()
        ]
    }

    // MARK: - Location/Venue

    /// Creates a mock venue
    static func createVenue() -> Location {
        return Location(id: "venue1", name: "Stadium", isoCode: "GB")
    }

    // MARK: - Sport

    /// Creates a mock Football sport
    static func createFootballSport() -> Sport {
        return Sport(
            id: "1",
            name: "Football",
            alphaId: "FB",
            numericId: "01",
            showEventCategory: true,
            liveEventsCount: 0
        )
    }

    /// Creates a mock Basketball sport
    static func createBasketballSport() -> Sport {
        return Sport(
            id: "2",
            name: "Basketball",
            alphaId: "BB",
            numericId: "02",
            showEventCategory: true,
            liveEventsCount: 0
        )
    }

    /// Creates a mock Tennis sport
    static func createTennisSport() -> Sport {
        return Sport(
            id: "3",
            name: "Tennis",
            alphaId: "TN",
            numericId: "03",
            showEventCategory: true,
            liveEventsCount: 0
        )
    }

    // MARK: - Match

    /// Creates a mock football match with complete data
    static func createFootballMatch() -> Match {
        return Match(
            id: "123",
            competitionId: "comp1",
            competitionName: "Premier League",
            homeParticipant: createHomeParticipant(),
            awayParticipant: createAwayParticipant(),
            homeParticipantScore: 0,
            awayParticipantScore: 0,
            date: Date(timeIntervalSince1970: 1741210200),
            sport: createFootballSport(),
            sportIdCode: "football",
            venue: createVenue(),
            numberTotalOfMarkets: 10,
            markets: [create1X2Market()],
            rootPartId: "root1",
            status: .notStarted,
            trackableReference: nil,
            matchTime: nil,
            promoImageURL: nil,
            oldMainMarketId: nil,
            activePlayerServe: nil,
            detailedScores: nil
        )
    }

    /// Creates a mock football match that is currently live
    static func createLiveFootballMatch() -> Match {
        var match = createFootballMatch()
        // Set the match to live status and add scores
        match.status = .inProgress("21")
        match.homeParticipantScore = 1
        match.awayParticipantScore = 0
        match.matchTime = "21'"
        return match
    }

    /// Creates a mock football match that is completed
    static func createCompletedFootballMatch() -> Match {
        var match = createFootballMatch()
        // Set the match to completed status with final score
        match.status = .ended
        match.homeParticipantScore = 2
        match.awayParticipantScore = 1
        return match
    }

    /// Creates a football match with multiple markets
    static func createFootballMatchWithMultipleMarkets() -> Match {
        var match = createFootballMatch()
        match.markets = createMultipleMarkets()
        match.numberTotalOfMarkets = match.markets.count
        return match
    }

    // MARK: - Countries

    /// Creates a mock country for France
    static func createFranceCountry() -> Country {
        return Country(
            name: "France",
            capital: "Paris",
            region: "Europe",
            iso2Code: "FR",
            iso3Code: "FRA",
            numericCode: "250",
            phonePrefix: "33"
        )
    }

    /// Creates a mock country for United Kingdom
    static func createUKCountry() -> Country {
        return Country(
            name: "United Kingdom",
            capital: "London",
            region: "Europe",
            iso2Code: "GB",
            iso3Code: "GBR",
            numericCode: "826",
            phonePrefix: "44"
        )
    }

    /// Creates a mock country for Spain
    static func createSpainCountry() -> Country {
        return Country(
            name: "Spain",
            capital: "Madrid",
            region: "Europe",
            iso2Code: "ES",
            iso3Code: "ESP",
            numericCode: "724",
            phonePrefix: "34"
        )
    }

    /// Creates a mock country for Germany
    static func createGermanyCountry() -> Country {
        return Country(
            name: "Germany",
            capital: "Berlin",
            region: "Europe",
            iso2Code: "DE",
            iso3Code: "DEU",
            numericCode: "276",
            phonePrefix: "49"
        )
    }

    /// Creates a mock country for Italy
    static func createItalyCountry() -> Country {
        return Country(
            name: "Italy",
            capital: "Rome",
            region: "Europe",
            iso2Code: "IT",
            iso3Code: "ITA",
            numericCode: "380",
            phonePrefix: "39"
        )
    }

    // MARK: - Competitions

    /// Creates a mock Premier League competition
    static func createPremierLeagueCompetition() -> Competition {
        return Competition(
            id: "PL1",
            name: "Premier League",
            matches: [createFootballMatch(), createLiveFootballMatch()],
            venue: createVenue(),
            sport: createFootballSport(),
            numberOutrightMarkets: 25,
            outrightMarkets: [createOverUnderMarket()],
            numberEvents: nil
        )
    }

    /// Creates a mock La Liga competition
    static func createLaLigaCompetition() -> Competition {
        return Competition(
            id: "LL1",
            name: "La Liga",
            matches: [createFootballMatch(), createCompletedFootballMatch()],
            venue: Location(id: "venue2", name: "Santiago Bernabeu", isoCode: "ES"),
            sport: createFootballSport(),
            numberOutrightMarkets: 20,
            outrightMarkets: [createOverUnderMarket()],
            numberEvents: nil
        )
    }

    /// Creates a mock Serie A competition
    static func createSerieACompetition() -> Competition {
        return Competition(
            id: "SA1",
            name: "Serie A",
            matches: [createFootballMatch()],
            venue: Location(id: "venue3", name: "San Siro", isoCode: "IT"),
            sport: createFootballSport(),
            numberOutrightMarkets: 18,
            outrightMarkets: [createOverUnderMarket()],
            numberEvents: nil
        )
    }

    /// Creates a mock NBA competition
    static func createNBACompetition() -> Competition {
        return Competition(
            id: "NBA1",
            name: "NBA",
            matches: [],
            venue: Location(id: "venue4", name: "Madison Square Garden", isoCode: "US"),
            sport: createBasketballSport(),
            numberOutrightMarkets: 30,
            outrightMarkets: [createOverUnderMarket(value: 220.5)],
            numberEvents: nil
        )
    }

    // MARK: - Detailed Scores

    /// Creates mock detailed scores for a football match
    static func createFootballDetailedScores() -> [String: Score] {
        return [
            "matchFull": .matchFull(home: 2, away: 1),
            "gamePart": .gamePart(index: nil, home: 1, away: 0)
        ]
    }

    /// Creates mock detailed scores for a tennis match
    static func createTennisDetailedScores() -> [String: Score] {
        return [
            "matchFull": .matchFull(home: 2, away: 1),
            "set1": .set(index: 1, home: 6, away: 4),
            "set2": .set(index: 2, home: 4, away: 6),
            "set3": .set(index: 3, home: 7, away: 5)
        ]
    }

    /// Creates mock detailed scores for a basketball match
    static func createBasketballDetailedScores() -> [String: Score] {
        return [
            "matchFull": .matchFull(home: 105, away: 98),
            "gamePart": .gamePart(index: nil, home: 28, away: 24)
        ]
    }

    // MARK: - User Profile

    /// Creates a mock user profile
    static func createUserProfile() -> UserProfile {
        return UserProfile(
            userIdentifier: "user123",
            sessionKey: "session-key-xyz",
            username: "johndoe",
            email: "john.doe@example.com",
            firstName: "John",
            middleName: nil,
            lastName: "Doe",
            birthDate: Calendar.current.date(from: DateComponents(year: 1990, month: 5, day: 15))!,
            nationality: createUKCountry(),
            country: createUKCountry(),
            gender: .male,
            title: .mister,
            personalIdNumber: "AB123456C",
            address: "123 Main Street",
            province: "Greater London",
            city: "London",
            postalCode: "SW1A 1AA",
            birthDepartment: nil,
            streetNumber: "123",
            phoneNumber: "+44 20 1234 5678",
            mobilePhone: "+44 7700 900123",
            mobileCountryCode: "44",
            mobileLocalNumber: "7700900123",
            avatarName: nil,
            godfatherCode: nil,
            placeOfBirth: "London",
            additionalStreetLine: "Apartment 4B",
            isEmailVerified: true,
            isRegistrationCompleted: true,
            kycStatus: .pass,
            lockedStatus: .notLocked,
            hasMadeDeposit: true,
            kycExpire: nil,
            currency: "GBP"
        )
    }

    /// Creates a mock user profile with pending verification
    static func createPendingVerificationUserProfile() -> UserProfile {
        return UserProfile(
            userIdentifier: "user456",
            sessionKey: "session-key-abc",
            username: "janedoe",
            email: "jane.doe@example.com",
            firstName: "Jane",
            middleName: nil,
            lastName: "Doe",
            birthDate: Calendar.current.date(from: DateComponents(year: 1992, month: 8, day: 21))!,
            nationality: createFranceCountry(),
            country: createFranceCountry(),
            gender: .female,
            title: .miss,
            personalIdNumber: "123456789012",
            address: "45 Rue de Paris",
            province: "Île-de-France",
            city: "Paris",
            postalCode: "75001",
            birthDepartment: "Paris",
            streetNumber: "45",
            phoneNumber: "+33 1 23 45 67 89",
            mobilePhone: "+33 6 12 34 56 78",
            mobileCountryCode: "33",
            mobileLocalNumber: "612345678",
            avatarName: nil,
            godfatherCode: nil,
            placeOfBirth: "Lyon",
            additionalStreetLine: "Apt 12",
            isEmailVerified: true,
            isRegistrationCompleted: true,
            kycStatus: .request,
            lockedStatus: .notLocked,
            hasMadeDeposit: false,
            kycExpire: nil,
            currency: "EUR"
        )
    }

    // MARK: - User Wallet

    /// Creates a mock user wallet with GBP currency
    static func createGBPUserWallet() -> UserWallet {
        return UserWallet(
            total: 250.75,
            totalRealAmount: 225.75,
            bonus: 25.0,
            totalWithdrawable: 225.75,
            currency: "GBP"
        )
    }

    /// Creates a mock user wallet with EUR currency
    static func createEURUserWallet() -> UserWallet {
        return UserWallet(
            total: 300.50,
            totalRealAmount: 250.50,
            bonus: 50.0,
            totalWithdrawable: 250.50,
            currency: "EUR"
        )
    }

    // MARK: - Promotional Stories
    // MISSING
    
    // MARK: - BannerInfo
    // MISSING

    // MARK: - Tennis Match

    /// Creates a mock tennis match
    static func createTennisMatch() -> Match {
        return Match(
            id: "tennis123",
            competitionId: "wimbledon",
            competitionName: "Wimbledon",
            homeParticipant: Participant(id: "player1", name: "Roger Federer"),
            awayParticipant: Participant(id: "player2", name: "Rafael Nadal"),
            homeParticipantScore: 2,
            awayParticipantScore: 1,
            date: Date(),
            sport: createTennisSport(),
            sportIdCode: "tennis",
            venue: Location(id: "venue5", name: "All England Club", isoCode: "GB"),
            numberTotalOfMarkets: 8,
            markets: [createOverUnderMarket(value: 3.5)],
            rootPartId: "root2",
            status: .inProgress("3set"),
            trackableReference: nil,
            matchTime: "01:45:22",
            promoImageURL: nil,
            oldMainMarketId: nil,
            activePlayerServe: .home,
            detailedScores: createTennisDetailedScores()
        )
    }

    // MARK: - Basketball Match

    /// Creates a mock basketball match
    static func createBasketballMatch() -> Match {
        return Match(
            id: "bball123",
            competitionId: "nba",
            competitionName: "NBA",
            homeParticipant: Participant(id: "team1", name: "Los Angeles Lakers"),
            awayParticipant: Participant(id: "team2", name: "Boston Celtics"),
            homeParticipantScore: 105,
            awayParticipantScore: 98,
            date: Date(),
            sport: createBasketballSport(),
            sportIdCode: "basketball",
            venue: Location(id: "venue6", name: "Staples Center", isoCode: "US"),
            numberTotalOfMarkets: 15,
            markets: [createOverUnderMarket(value: 220.5)],
            rootPartId: "root3",
            status: .inProgress("4q"),
            trackableReference: nil,
            matchTime: "10:45",
            promoImageURL: nil,
            oldMainMarketId: nil,
            activePlayerServe: nil,
            detailedScores: createBasketballDetailedScores()
        )
    }

    // MARK: - Additional Sports

    /// Creates a mock Hockey sport
    static func createHockeySport() -> Sport {
        return Sport(
            id: "4",
            name: "Ice Hockey",
            alphaId: "HKY",
            numericId: "04",
            showEventCategory: true,
            liveEventsCount: 2
        )
    }

    /// Creates a mock Rugby sport
    static func createRugbySport() -> Sport {
        return Sport(
            id: "5",
            name: "Rugby",
            alphaId: "RBY",
            numericId: "05",
            showEventCategory: true,
            liveEventsCount: 1
        )
    }

    /// Creates a mock Cricket sport
    static func createCricketSport() -> Sport {
        return Sport(
            id: "6",
            name: "Cricket",
            alphaId: "CRK",
            numericId: "06",
            showEventCategory: true,
            liveEventsCount: 3
        )
    }

    /// Creates a mock Volleyball sport
    static func createVolleyballSport() -> Sport {
        return Sport(
            id: "7",
            name: "Volleyball",
            alphaId: "VBL",
            numericId: "07",
            showEventCategory: true,
            liveEventsCount: 0
        )
    }

    // MARK: - Additional Matches

    /// Creates a mock hockey match
    static func createHockeyMatch() -> Match {
        return Match(
            id: "hockey123",
            competitionId: "nhl",
            competitionName: "NHL",
            homeParticipant: Participant(id: "team3", name: "Toronto Maple Leafs"),
            awayParticipant: Participant(id: "team4", name: "Montreal Canadiens"),
            homeParticipantScore: 3,
            awayParticipantScore: 2,
            date: Date(),
            sport: createHockeySport(),
            sportIdCode: "hockey",
            venue: Location(id: "venue7", name: "Scotiabank Arena", isoCode: "CA"),
            numberTotalOfMarkets: 12,
            markets: [createOverUnderMarket(value: 5.5)],
            rootPartId: "root4",
            status: .inProgress("2p"),
            trackableReference: nil,
            matchTime: "15:23",
            promoImageURL: nil,
            oldMainMarketId: nil,
            activePlayerServe: nil,
            detailedScores: [
                "matchFull": .matchFull(home: 3, away: 2),
                "gamePart": .gamePart(index: nil, home: 1, away: 0)
            ]
        )
    }

    /// Creates a mock rugby match
    static func createRugbyMatch() -> Match {
        return Match(
            id: "rugby123",
            competitionId: "sixnations",
            competitionName: "Six Nations",
            homeParticipant: Participant(id: "team5", name: "England"),
            awayParticipant: Participant(id: "team6", name: "France"),
            homeParticipantScore: 24,
            awayParticipantScore: 17,
            date: Date(),
            sport: createRugbySport(),
            sportIdCode: "rugby",
            venue: Location(id: "venue8", name: "Twickenham Stadium", isoCode: "GB"),
            numberTotalOfMarkets: 10,
            markets: [createOverUnderMarket(value: 45.5)],
            rootPartId: "root5",
            status: .inProgress("2p"),
            trackableReference: nil,
            matchTime: "35:12",
            promoImageURL: nil,
            oldMainMarketId: nil,
            activePlayerServe: nil,
            detailedScores: [
                "matchFull": .matchFull(home: 24, away: 17),
                "gamePart": .gamePart(index: nil, home: 14, away: 10)
            ]
        )
    }

    /// Creates a mock cricket match
    static func createCricketMatch() -> Match {
        return Match(
            id: "cricket123",
            competitionId: "ipl",
            competitionName: "Indian Premier League",
            homeParticipant: Participant(id: "team7", name: "Mumbai Indians"),
            awayParticipant: Participant(id: "team8", name: "Chennai Super Kings"),
            homeParticipantScore: 187,
            awayParticipantScore: 156,
            date: Date(),
            sport: createCricketSport(),
            sportIdCode: "cricket",
            venue: Location(id: "venue9", name: "Wankhede Stadium", isoCode: "IN"),
            numberTotalOfMarkets: 14,
            markets: [createOverUnderMarket(value: 350.5)],
            rootPartId: "root6",
            status: .inProgress("1i_at"),
            trackableReference: nil,
            matchTime: "15.2",
            promoImageURL: nil,
            oldMainMarketId: nil,
            activePlayerServe: nil,
            detailedScores: [
                "matchFull": .matchFull(home: 187, away: 156)
            ]
        )
    }

    // MARK: - Additional Competitions

    /// Creates a mock NHL competition
    static func createNHLCompetition() -> Competition {
        return Competition(
            id: "NHL1",
            name: "National Hockey League",
            matches: [createHockeyMatch()],
            venue: Location(id: "venue10", name: "Madison Square Garden", isoCode: "US"),
            sport: createHockeySport(),
            numberOutrightMarkets: 22,
            outrightMarkets: [createOverUnderMarket(value: 5.5)],
            numberEvents: nil
        )
    }

    /// Creates a mock Six Nations competition
    static func createSixNationsCompetition() -> Competition {
        return Competition(
            id: "SIX1",
            name: "Six Nations Championship",
            matches: [createRugbyMatch()],
            venue: Location(id: "venue11", name: "Twickenham Stadium", isoCode: "GB"),
            sport: createRugbySport(),
            numberOutrightMarkets: 15,
            outrightMarkets: [createOverUnderMarket(value: 45.5)],
            numberEvents: nil
        )
    }

    /// Creates a mock IPL competition
    static func createIPLCompetition() -> Competition {
        return Competition(
            id: "IPL1",
            name: "Indian Premier League",
            matches: [createCricketMatch()],
            venue: Location(id: "venue12", name: "Wankhede Stadium", isoCode: "IN"),
            sport: createCricketSport(),
            numberOutrightMarkets: 18,
            outrightMarkets: [createOverUnderMarket(value: 350.5)],
            numberEvents: nil
        )
    }

    // MARK: - Additional Markets

    /// Creates a mock Both Teams To Score market
    static func createBothTeamsToScoreMarket() -> Market {
        let yesOutcome = createCustomOutcome(id: "btts1", codeName: "Yes", typeName: "Yes", translatedName: "Yes", odd: 1.75)
        let noOutcome = createCustomOutcome(id: "btts2", codeName: "No", typeName: "No", translatedName: "No", odd: 2.05)

        return Market(
            id: "4",
            typeId: "BTTS",
            name: "Both Teams To Score",
            isMainMarket: false,
            nameDigit1: nil,
            nameDigit2: nil,
            nameDigit3: nil,
            eventPartId: nil,
            bettingTypeId: nil,
            outcomes: [yesOutcome, noOutcome],
            outcomesOrder: .setup
        )
    }

    /// Creates a mock Correct Score market
    static func createCorrectScoreMarket() -> Market {
        let outcomes = [
            createCustomOutcome(id: "cs1", codeName: "1-0", typeName: "1-0", translatedName: "1-0", odd: 7.0),
            createCustomOutcome(id: "cs2", codeName: "2-0", typeName: "2-0", translatedName: "2-0", odd: 9.0),
            createCustomOutcome(id: "cs3", codeName: "2-1", typeName: "2-1", translatedName: "2-1", odd: 8.5),
            createCustomOutcome(id: "cs4", codeName: "0-0", typeName: "0-0", translatedName: "0-0", odd: 10.0),
            createCustomOutcome(id: "cs5", codeName: "1-1", typeName: "1-1", translatedName: "1-1", odd: 6.5),
            createCustomOutcome(id: "cs6", codeName: "0-1", typeName: "0-1", translatedName: "0-1", odd: 9.5),
            createCustomOutcome(id: "cs7", codeName: "0-2", typeName: "0-2", translatedName: "0-2", odd: 12.0),
            createCustomOutcome(id: "cs8", codeName: "1-2", typeName: "1-2", translatedName: "1-2", odd: 10.5)
        ]

        return Market(
            id: "5",
            typeId: "CORRECT_SCORE",
            name: "Correct Score",
            isMainMarket: false,
            nameDigit1: nil,
            nameDigit2: nil,
            nameDigit3: nil,
            eventPartId: nil,
            bettingTypeId: nil,
            outcomes: outcomes,
            outcomesOrder: .odds
        )
    }

    /// Creates a mock First Goalscorer market
    static func createFirstGoalscorerMarket() -> Market {
        let outcomes = [
            createCustomOutcome(id: "fg1", codeName: "Player1", typeName: "Player1", translatedName: "Harry Kane", odd: 4.5),
            createCustomOutcome(id: "fg2", codeName: "Player2", typeName: "Player2", translatedName: "Mohamed Salah", odd: 5.0),
            createCustomOutcome(id: "fg3", codeName: "Player3", typeName: "Player3", translatedName: "Erling Haaland", odd: 3.75),
            createCustomOutcome(id: "fg4", codeName: "Player4", typeName: "Player4", translatedName: "Kylian Mbappé", odd: 4.25),
            createCustomOutcome(id: "fg5", codeName: "Player5", typeName: "Player5", translatedName: "Robert Lewandowski", odd: 4.0),
            createCustomOutcome(id: "fg6", codeName: "No Goalscorer", typeName: "No Goalscorer", translatedName: "No Goalscorer", odd: 12.0)
        ]

        return Market(
            id: "6",
            typeId: "FIRST_GOALSCORER",
            name: "First Goalscorer",
            isMainMarket: false,
            nameDigit1: nil,
            nameDigit2: nil,
            nameDigit3: nil,
            eventPartId: nil,
            bettingTypeId: nil,
            outcomes: outcomes,
            outcomesOrder: .odds
        )
    }

    /// Creates a comprehensive list of football markets
    static func createComprehensiveFootballMarkets() -> [Market] {
        return [
            create1X2Market(),
            createOverUnderMarket(),
            createDoubleChanceMarket(),
            createBothTeamsToScoreMarket(),
            createCorrectScoreMarket(),
            createFirstGoalscorerMarket()
        ]
    }

    /// Creates a football match with comprehensive markets
    static func createFootballMatchWithComprehensiveMarkets() -> Match {
        var match = createFootballMatch()
        match.markets = createComprehensiveFootballMarkets()
        match.numberTotalOfMarkets = match.markets.count
        return match
    }

    // MARK: - Additional User Profiles

    /// Creates a mock user profile for a new user
    static func createNewUserProfile() -> UserProfile {
        return UserProfile(
            userIdentifier: "user789",
            sessionKey: "session-key-new",
            username: "newuser",
            email: "new.user@example.com",
            firstName: "Alex",
            middleName: nil,
            lastName: "Smith",
            birthDate: Calendar.current.date(from: DateComponents(year: 1995, month: 3, day: 10))!,
            nationality: createGermanyCountry(),
            country: createGermanyCountry(),
            gender: .male,
            title: .mister,
            personalIdNumber: "DE123456789",
            address: "123 Hauptstrasse",
            province: "Berlin",
            city: "Berlin",
            postalCode: "10115",
            birthDepartment: nil,
            streetNumber: "123",
            phoneNumber: "+49 30 1234567",
            mobilePhone: "+49 151 12345678",
            mobileCountryCode: "49",
            mobileLocalNumber: "15112345678",
            avatarName: nil,
            godfatherCode: "REF123",
            placeOfBirth: "Munich",
            additionalStreetLine: nil,
            isEmailVerified: false,
            isRegistrationCompleted: false,
            kycStatus: .request,
            lockedStatus: .notLocked,
            hasMadeDeposit: false,
            kycExpire: nil,
            currency: "EUR"
        )
    }

    /// Creates a mock user profile for a locked account
    static func createLockedUserProfile() -> UserProfile {
        return UserProfile(
            userIdentifier: "user999",
            sessionKey: "session-key-locked",
            username: "lockeduser",
            email: "locked.user@example.com",
            firstName: "Maria",
            middleName: nil,
            lastName: "Garcia",
            birthDate: Calendar.current.date(from: DateComponents(year: 1988, month: 7, day: 22))!,
            nationality: createSpainCountry(),
            country: createSpainCountry(),
            gender: .female,
            title: .misses,
            personalIdNumber: "ES12345678Z",
            address: "45 Calle Mayor",
            province: "Madrid",
            city: "Madrid",
            postalCode: "28013",
            birthDepartment: nil,
            streetNumber: "45",
            phoneNumber: "+34 91 123 4567",
            mobilePhone: "+34 612 345 678",
            mobileCountryCode: "34",
            mobileLocalNumber: "612345678",
            avatarName: nil,
            godfatherCode: nil,
            placeOfBirth: "Barcelona",
            additionalStreetLine: "Piso 3",
            isEmailVerified: true,
            isRegistrationCompleted: true,
            kycStatus: .pass,
            lockedStatus: .locked,
            hasMadeDeposit: true,
            kycExpire: nil,
            currency: "EUR"
        )
    }

    // MARK: - Additional Wallets

    /// Creates a mock user wallet with USD currency
    static func createUSDUserWallet() -> UserWallet {
        return UserWallet(
            total: 500.00,
            totalRealAmount: 400.00,
            bonus: 100.0,
            totalWithdrawable: 400.00,
            currency: "USD"
        )
    }

    /// Creates a mock empty user wallet
    static func createEmptyUserWallet() -> UserWallet {
        return UserWallet(
            total: 0.00,
            totalRealAmount: 0.00,
            bonus: 0.0,
            totalWithdrawable: 0.00,
            currency: "EUR"
        )
    }
}
