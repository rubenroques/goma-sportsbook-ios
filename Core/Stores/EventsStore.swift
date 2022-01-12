//
//  EventsStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

/*
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

    var matchesPublisher = CurrentValueSubject<EveryMatrix.Matches, Never>([])
    private var matches: EveryMatrix.Matches = [] {
        didSet {
            matchesPublisher.send(self.matches)
        }
    }

    override init() {

    }

    func getEvents() -> AnyPublisher<Events, Never> {

        let payload = ["lang": "en"]
        return Env.everyMatrixClient.getEvents(payload: payload)
            .map { response in
                return (response.records ?? [])
            }
            .replaceError(with: [])
            .handleEvents(receiveOutput: { events in
                print("events \(events)")
            })
            .eraseToAnyPublisher()
    }

    func getMatches(sportType: SportType?) -> AnyPublisher<EveryMatrix.Matches, Never> {

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
*/
