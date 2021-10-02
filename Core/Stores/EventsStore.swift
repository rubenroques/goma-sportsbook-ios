//
//  EventsStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import Foundation
import Combine

enum EventListType {
    case all
    case today
    case popular
    case favorites
}


struct SearchFilters {
    var sport: SportType
    var listType: EventListType
}

class EventsStore: NSObject {

    private var cancellable = Set<AnyCancellable>()

    var eventsPublisher = CurrentValueSubject<Events, Never>([])
    private var events: Events = [] {
        didSet {
            eventsPublisher.send(self.events)
        }
    }

    var matchesPublisher = CurrentValueSubject<Matches, Never>([])
    private var matches: Matches = [] {
        didSet {
            matchesPublisher.send(self.matches)
        }
    }

    override init() {

    }

    func getEvents() -> AnyPublisher<Events, Never> {

        let payload = ["lang": "en"]
        return Env.everyMatrixAPIClient.getEvents(payload: payload)
            .map { response in
                return (response.records ?? [])
            }
            .replaceError(with: [])
            .handleEvents(receiveOutput: { events in
                print("events \(events)")
            })
            .eraseToAnyPublisher()
    }


    func getMatches(sportType: SportType?) -> AnyPublisher<Matches, Never> {

        var payload = [
            "lang": localized("languange_code")
        ]

        if let sportType = sportType {
            payload["sportId"] = sportType.rawValue
        }

        return Env.everyMatrixAPIClient.getMatches(payload: payload)
            .map { response in
                return (response.records ?? [])
            }
            .replaceError(with: [])
            .handleEvents(receiveOutput: { events in
                print("events \(events)")
            })
            .eraseToAnyPublisher()
    }

}


enum SportType: String {
    case football = "1"
    case basketball = "8"
    case tennis = "3"
    case futsal = "49"
    case footballSimulated = "140"
    case tennisSimulated = "141"
    case americanFootball = "5"
    case baseball = "9"
    case chess = "52"
    case cricket = "26"
    case cycling = "37"
    case darts = "45"
    case fighting = "25"
    case golf = "2"
    case greyhounds = "27"
    case handball = "7"
    case harnessRacing = "74"
    case horseRacing = "24"
    case iceHockey = "6"
    case kabaddi = "155"
    case motorRacing = "23"
    case rugbyLeague = "28"
    case rugbyUnion = "39"
    case snooker = "36"
    case specials = "34"
    case tableTennis = "63"
    case volleyball = "20"
    case eSports = "96"
}
