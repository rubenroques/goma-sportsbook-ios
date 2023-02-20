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

    func eventDetailsUpdated(events: [EventsGroup])
    func eventGroups(forContentIdentifier identifier: ContentIdentifier, withEvents: [EventsGroup])
    func outrightEventGroups(events: [EventsGroup])
    func eventSummary(events: [EventsGroup])
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
    
    var connectionStatePublisher: AnyPublisher<ConnectorState, Error> {
        connectionStateSubject.eraseToAnyPublisher()
    }
    private let connectionStateSubject: CurrentValueSubject<ConnectorState, Error>
    
    private var webSocket : URLSessionWebSocketTask?
    private var socket: WebSocket
    private var isConnected: Bool
    
    override init() {
        self.connectionStateSubject = CurrentValueSubject<ConnectorState, Error>.init(.disconnected)
        self.isConnected = false
        
        self.socket = WebSocket.init(request: Self.socketRequest(), useCustomEngine: false)
        super.init()
    }
    
    private func connectSocket() {
        self.socket.delegate = self
        self.socket.connect()
    }
    
    private static func socketRequest() -> URLRequest {
        let wssURLString = SportRadarConstants.socketURL
        return URLRequest(url: URL(string: wssURLString)!)
    }
    
    private func sendListeningStarted(toSocket socket: WebSocket) {
        
        // TODO: ipAddress is empty, and language is hardcoded
        let body = """
                   {"subscriberId":null,"versionList":[],"clientContext":{"language":"\(SportRadarConstants.socketLanguageCode)","ipAddress":""}}
                   """
        
        self.socket.write(string: body) {
            print("ServiceProvider - SportRadarSocketConnector: sendListeningStarted sent")
        }
        
    }
    
    func connect() {
        self.connectSocket()
    }
    
    func refreshConnection() {
        self.socket.forceDisconnect()
        self.socket = WebSocket.init(request: Self.socketRequest(), useCustomEngine: false)
        self.connectSocket()
    }
    
    func disconnect() {
        self.socket.forceDisconnect()
    }

}


extension SportRadarSocketConnector: WebSocketDelegate {
    
    internal func didReceive(event: WebSocketEvent, client: WebSocket) {
        
        // yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ
        // 2022-07-05T09:51:00.000+02:00
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        switch event {
        case .connected(let headers):
            self.isConnected = true
            self.sendListeningStarted(toSocket: client)
            
            print("ServiceProvider - SportRadarSocketConnector websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            self.isConnected = false
            self.refreshConnection()
            print("ServiceProvider - SportRadarSocketConnector websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            // print("ServiceProvider - SportRadarSocketConnector websocket recieved text: \(string)")
            if let data = string.data(using: .utf8),
               let sportRadarSocketResponse = try? decoder.decode(SportRadarModels.NotificationType.self, from: data) {
                self.handleContentMessage(sportRadarSocketResponse, messageData: data)
            }
        case .binary(let data):
            // print("ServiceProvider - SportRadarSocketConnector websocket recieved binary: \(String(data: data, encoding: .utf8) ?? "--")")
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
            print("ServiceProvider - SportRadarSocketConnector websocket Error \(error.debugDescription)")
            self.refreshConnection()
        }
        
    }
    
    func handleContentMessage(_ messageType: SportRadarModels.NotificationType, messageData: Data) {
        
        switch messageType {
        case .listeningStarted(let sessionTokenId):
            self.isConnected = true
            self.tokenSubject.send(SportRadarSessionAccessToken(hash: sessionTokenId))
            self.connectionStateSubject.send(.connected)

        case .contentChanges(let content):
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

            case .eventDetails(let events):
                if let subscriber = self.messageSubscriber {
                    let eventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: events)
                    subscriber.eventDetailsUpdated(events: [eventsGroup])
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
            case .eventSummary(let events):
                if let subscriber = self.messageSubscriber {
                    let eventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: events)
                    subscriber.eventSummary(events: [eventsGroup])
                }
            }
        case .unknown:
            print("Uknown Response")
        }
        
    }
    
}
