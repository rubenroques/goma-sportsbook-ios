//
//  SportRadarConnector.swift
//
//
//  Created by Ruben Roques on 07/10/2022.
//

import Foundation
import Combine

protocol SportRadarConnectorSubscriber: AnyObject {
    func liveEventsUpdated(forContentIdentifier identifier: ContentIdentifier, withEvents: [EventsGroup])
    func preLiveEventsUpdated(forContentIdentifier identifier: ContentIdentifier, withEvents: [EventsGroup])

    func liveSportsUpdated(withSportTypes: [SportRadarModels.SportType])
    func preLiveSportsUpdated(withSportTypes: [SportRadarModels.SportType])
    func allSportsUpdated(withSportTypes: [SportRadarModels.SportType])

    func updateSportLiveCount(nodeId: String, liveCount: Int)
    func updateSportEventCount(nodeId: String, eventCount: Int)

    func eventDetailsUpdated(forContentIdentifier identifier: ContentIdentifier, event: Event)
    func eventDetailsLiveData(contentIdentifier: ContentIdentifier, eventLiveDataExtended: SportRadarModels.EventLiveDataExtended)

    func eventGroups(forContentIdentifier identifier: ContentIdentifier, withEvents: [EventsGroup])
    func outrightEventGroups(events: [EventsGroup])

    func marketDetails(forContentIdentifier identifier: ContentIdentifier, market: Market)

    func didReceiveGenericUpdate(content: SportRadarModels.ContentContainer)
}

class SportRadarSocketConnector: NSObject, Connector {
    
    var token: SportRadarSessionAccessToken? {
        return self.tokenSubject.value
    }

    private var tokenSubject: CurrentValueSubject<SportRadarSessionAccessToken?, Never> = .init(nil)
    var tokenPublisher: AnyPublisher<SportRadarSessionAccessToken?, Never> {
        return tokenSubject.eraseToAnyPublisher()
    }

    weak var messageSubscriber: SportRadarConnectorSubscriber?
    
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }
    private let connectionStateSubject: CurrentValueSubject<ConnectorState, Never>
    
    private var webSocketClientStream: WebSocketClientStream?

    private var isConnected: Bool {
        didSet {
            if self.isConnected {
                self.connectionStateSubject.send(.connected)
            }
            else {
                self.connectionStateSubject.send(.disconnected)
            }
        }
    }
    
    override init() {
        self.connectionStateSubject = .init(.disconnected)
        self.isConnected = false

        super.init()

        self.createWebSocketClientStream()
        self.watchSocketStream()
    }

    private func createWebSocketClientStream() {
        let urlString = SportRadarConfiguration.shared.socketURL
        let url = URL(string: urlString)!
        self.webSocketClientStream = WebSocketClientStream(url: url)
    }

    private func watchSocketStream() {

        Task {
            do {
                guard
                    let webSocketClientStream = self.webSocketClientStream
                else {
                    return
                }

                for try await message in webSocketClientStream {
                    switch message {
                    case .connected:
                        self.sendListeningStarted()
                        print("ServiceProvider - SportRadarSocketConnector websocket is connected")

                    case .text(let stringContent):
                        print("☁️ SP debugbetslip WS recieved text: \(stringContent.prefix(125)) \n----------------- \n")
                        if let data = stringContent.data(using: .utf8),
                           let sportRadarSocketResponse = try? Self.decoder.decode(SportRadarModels.NotificationType.self, from: data) {
                            self.handleContentMessage(sportRadarSocketResponse, messageData: data)
                        }

                    case .binary(let dataContent):
                        if let sportRadarSocketResponse = try? Self.decoder.decode(SportRadarModels.NotificationType.self, from: dataContent) {
                            self.handleContentMessage(sportRadarSocketResponse, messageData: dataContent)
                        }
                    case .disconnected:
                        print("ServiceProvider - SportRadarSocketConnector websocket is disconnected")
                        self.isConnected = false
                        self.refreshConnection()
                    }
                }
            } catch {
                print("ServiceProvider - SportRadarSocketConnector terminated with error: \(error)")
                self.refreshConnection()
            }

            print("ServiceProvider - SportRadarSocketConnector stream ended")
        }

    }
    
    private func connectSocket() {
        self.webSocketClientStream?.connect()
    }
    
    private func sendListeningStarted() {
        
        let body = """
                   {
                     "subscriberId": null, "versionList": [],
                     "clientContext": { "language":"\(SportRadarConfiguration.shared.socketLanguageCode)", "ipAddress":"" }
                   }
                   """
        Task {
            do {
                try await self.webSocketClientStream?.send(remoteMessage: body)
            }
            catch {
                print("ServiceProvider - SportRadarSocketConnector sendListeningStarted failed \(error)")
            }
        }
        
    }
    
    func connect() {
        self.connectSocket()
    }
    
    func refreshConnection() {
        self.isConnected = false

        self.createWebSocketClientStream()
        self.watchSocketStream()

        self.connectSocket()
    }
    
    func disconnect() {
        self.webSocketClientStream?.close()
    }

    private static var decoder: JSONDecoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }

    func handleContentMessage(_ messageType: SportRadarModels.NotificationType, messageData: Data) {
        
        switch messageType {
        case .listeningStarted(let sessionTokenId):
            self.tokenSubject.send(SportRadarSessionAccessToken(hash: sessionTokenId))
            self.isConnected = true

        case .contentChanges(let contents):
            for content in contents {
                switch content {
                case .liveEvents(let contentIdentifier, let events):
                    if let subscriber = self.messageSubscriber {
                        let eventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: events)
                        subscriber.liveEventsUpdated(forContentIdentifier: contentIdentifier, withEvents: [eventsGroup])
                    }
                case .preLiveEvents(let contentIdentifier, let events):
                    if let subscriber = self.messageSubscriber {
                        let eventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: events)
                        subscriber.preLiveEventsUpdated(forContentIdentifier: contentIdentifier, withEvents: [eventsGroup])
                    }

                case .liveSports(let sportsTypes):
                    if let subscriber = self.messageSubscriber {
                        subscriber.liveSportsUpdated(withSportTypes: sportsTypes)
                    }
                case .preLiveSports(let sportsTypes):
                    if let subscriber = self.messageSubscriber {
                        subscriber.preLiveSportsUpdated(withSportTypes: sportsTypes)
                    }
                case .allSports(let sportTypes):
                    if let subscriber = self.messageSubscriber {
                        subscriber.allSportsUpdated(withSportTypes: sportTypes)
                    }
                case .updateAllSportsLiveCount(let contentIdentifier, let nodeId, let eventCount):
                    if let subscriber = self.messageSubscriber {
                        subscriber.updateSportLiveCount(nodeId: nodeId, liveCount: eventCount)
                    }
                case .updateAllSportsEventCount(let contentIdentifier, let nodeId, let eventCount):
                    if let subscriber = self.messageSubscriber {
                        subscriber.updateSportEventCount(nodeId: nodeId, eventCount: eventCount)
                    }
                case .eventDetails(let contentIdentifier, let event):
                    if let subscriber = self.messageSubscriber, let eventValue = event {
                        let mappedEvent = SportRadarModelMapper.event(fromInternalEvent: eventValue)
                        subscriber.eventDetailsUpdated(forContentIdentifier: contentIdentifier, event: mappedEvent)
                    }
                case .eventGroup(let contentIdentifier, let events):
                    if let subscriber = self.messageSubscriber {
                        let eventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: events)
                        subscriber.eventGroups(forContentIdentifier: contentIdentifier, withEvents: [eventsGroup])
                    }
                case .outrightEventGroup(let events):
                    if let subscriber = self.messageSubscriber {
                        let eventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: events)
                        subscriber.outrightEventGroups(events: [eventsGroup])
                    }
                case .marketDetails(let contentIdentifier, let market):
                    if let subscriber = self.messageSubscriber, let marketValue = market {
                        let mappedMarket = SportRadarModelMapper.market(fromInternalMarket: marketValue)
                        subscriber.marketDetails(forContentIdentifier: contentIdentifier, market: mappedMarket)
                    }
                case .eventDetailsLiveData(let contentIdentifier, let eventLiveDataExtended):
                    if let subscriber = self.messageSubscriber, let eventLiveDataExtendedValue = eventLiveDataExtended {
                        subscriber.eventDetailsLiveData(contentIdentifier: contentIdentifier, eventLiveDataExtended: eventLiveDataExtendedValue)
                    }
                default:
                    if let subscriber = self.messageSubscriber {
                        subscriber.didReceiveGenericUpdate(content: content)
                    }
                }
            }
        case .unknown:
            ()
            print("Uknown Response \( String(data: messageData, encoding: .utf8) ?? "" )")
        }
        
    }
    
}
