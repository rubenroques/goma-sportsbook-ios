//
//  SportRadarConnector.swift
//
//
//  Created by Ruben Roques on 07/10/2022.
//

import Foundation
import Starscream
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
    
    private var webSocket : URLSessionWebSocketTask?
    private var socket: WebSocket
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
        
        self.socket = WebSocket.init(request: Self.socketRequest(), useCustomEngine: true)
        super.init()
    }
    
    private func connectSocket() {

        self.socket.delegate = self
        self.socket.connect()

    }
    
    private static func socketRequest() -> URLRequest {
        let wssURLString = SportRadarConfiguration.shared.socketURL
        return URLRequest(url: URL(string: wssURLString)!)
    }
    
    private func sendListeningStarted() {
        
        // TODO: ipAddress is empty, and language is hardcoded
        var body: String = ""
        
        if let previousSessionId = self.token {
            body = """
                   {
                     "subscriberId": "\(previousSessionId.hash)",
                     "versionList": [],
                     "clientContext": {
                       "language":"\(SportRadarConfiguration.shared.socketLanguageCode)",
                       "ipAddress":""
                     }
                   }
                   """
        }
        else {
            body = """
                   {
                     "subscriberId": null,
                     "versionList": [],
                     "clientContext": {
                       "language":"\(SportRadarConfiguration.shared.socketLanguageCode)",
                       "ipAddress":""
                     }
                   }
                   """
        }
        
        self.socket.write(string: body) {
            print("ServiceProvider - SportRadarSocketConnector: sendListeningStarted sent")
        }
        
    }
    
    func connect() {
        self.connectSocket()
    }
    
    func refreshConnection() {
        self.isConnected = false
        self.socket.forceDisconnect()
        self.socket = WebSocket.init(request: Self.socketRequest(), useCustomEngine: false)
        self.connectSocket()
    }
    
    func disconnect() {
        self.socket.forceDisconnect()
    }

}


extension SportRadarSocketConnector: Starscream.WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        
        // yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ
        // 2022-07-05T09:51:00.000+02:00
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        switch event {
        case .connected(let headers):
            self.sendListeningStarted()
            print("ServiceProvider - SportRadarSocketConnector websocket 🟢 is connected : \(headers)")

        case .disconnected(let reason, let code):
            self.isConnected = false
            self.refreshConnection()
            print("ServiceProvider - SportRadarSocketConnector websocket is disconnected: \(reason) with code: \(code)")

        case .text(let string):
            print("\n▶️ServiceProvider - SportRadarSocketConnector received text: \(string.prefix(800))◀️")
            if let data = string.data(using: .utf8),
               let sportRadarSocketResponse = try? decoder.decode(SportRadarModels.NotificationType.self, from: data) {
                self.handleContentMessage(sportRadarSocketResponse, messageData: data)
            }

        case .binary(let data):
            if let sportRadarSocketResponse = try? decoder.decode(SportRadarModels.NotificationType.self, from: data) {
                self.handleContentMessage(sportRadarSocketResponse, messageData: data)
            }

        case .ping(_):
            print("ServiceProvider - SportRadarSocketConnector ping")
            break
        case .pong(_):
            print("ServiceProvider - SportRadarSocketConnector pong")
            break
        case .viabilityChanged(_):
            print("ServiceProvider - SportRadarSocketConnector viabilityChanged")
            break
        case .reconnectSuggested(_):
            self.refreshConnection()
            print("ServiceProvider - SportRadarSocketConnector reconnectSuggested")
        case .cancelled:
            self.isConnected = false
            print("ServiceProvider - SportRadarSocketConnector cancelled")
        case .error(let error):
            self.isConnected = false
            print("ServiceProvider - SportRadarSocketConnector websocket ❌ Error \(error.debugDescription)")
            if error.debugDescription.lowercased().contains("message too long") {
                self.tokenSubject.send(nil) // Clear old token
            }
            self.refreshConnection()
        case .peerClosed:
            self.isConnected = false
            print("ServiceProvider - SportRadarSocketConnector peerClosed")
        }
        
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
                case .updateAllSportsLiveCount(_, let nodeId, let eventCount):
                    if let subscriber = self.messageSubscriber {
                        subscriber.updateSportLiveCount(nodeId: nodeId, liveCount: eventCount)
                    }
                case .updateAllSportsEventCount(_, let nodeId, let eventCount):
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
                case .unknown:
                    print("❓SportRadarSocketConnector handleContentMessage unknown: \(content)")
                    
                default:
                    if let subscriber = self.messageSubscriber {
                        print("*️⃣SportRadarSocketConnector handleContentMessage didReceiveGenericUpdate: \n  - \(content)")
                        subscriber.didReceiveGenericUpdate(content: content)
                    }
                }
            }
            
        case .subscriberIdNotFoundError(let oldId):
            print("SportRadarSocketConnector subscriberIdNotFoundError error: \(oldId ?? "no id returned")")
            self.tokenSubject.send(nil) // Clear old token
            self.refreshConnection()
            
        case .genericError:
            print("SportRadarSocketConnector Uknown error")
            
        case .unknown:
            print("SportRadarSocketConnector Uknown Response \( String(data: messageData, encoding: .utf8) ?? "" )")
        }
        
    }
    
}

//
//class LargeNativeEngine: Starscream.NativeEngine {
//    
//    override func start(request: URLRequest) {
//        super.start(request: request)
//        
//        let maximumMessageSize: Int = 250 * 1024 * 1024 // 25 MB in bytes
//        self.task?.maximumMessageSize = maximumMessageSize
//        
//    }
//    
//}
