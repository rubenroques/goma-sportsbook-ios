//
//  SportRadarConnector.swift
//  
//
//  Created by Ruben Roques on 07/10/2022.
//

import Foundation
import Starscream
import Combine

protocol SportRadarConnectorSubscriber {

    func liveAdvancedListUpdated(forSportType sportType: SportType, withEvents: [EventsGroup])
    func inplaySportListUpdated(withSportTypes: [SportType])
    func sportTypeByDate(withSportTypes: [SportType])
    func eventListBySportTypeDate(forSportType sportType: SportType, withEvents: [EventsGroup])
    func eventDetails(events: [EventsGroup])
}

class SportRadarSocketConnector: NSObject, Connector {
    
    var token: SessionAccessToken?

    var subscriberForType: [SportRadarModels.ContentType: SportRadarConnectorSubscriber] = [:]
    
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
        
        // let pinner = FoundationSecurity(allowSelfSigned: true)
        // let compression = WSCompression()
        self.socket = WebSocket.init(request: Self.socketRequest(), useCustomEngine: false)
        super.init()
    }
    
    private func connectSocket() {
        self.socket.delegate = self
        self.socket.connect()
    }
    
    private static func socketRequest() -> URLRequest {
        //let wssURLString = "wss://velnt-spor-int.optimahq.com/notification/listen/websocket"
        let wssURLString = "wss://velnt-spor-uat.optimahq.com/notification/listen/websocket"
        return URLRequest(url: URL(string: wssURLString)!)
    }
    
    private func sendListeningStarted(toSocket socket: WebSocket) {
        
        // TODO: ipAddress is empty, and language is hardcoded
        let body = """
                   {"subscriberId":null,"versionList":[],"clientContext":{"language":"UK","ipAddress":""}}
                   """
        
        self.socket.write(string: body) {
            print("sendListeningStarted - sent")
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
    
    func subscribe(_ subscriber: SportRadarConnectorSubscriber, forContentType type: SportRadarModels.ContentType) {
        self.subscriberForType[type] = subscriber
    }

    func unsubscribe(forContentType type: SportRadarModels.ContentType) {
        self.subscriberForType[type] = nil
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
            
            print("SportRadarSocketConnector websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            self.isConnected = false
            print("SportRadarSocketConnector websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("SportRadarSocketConnector websocket received text: \(string)")
            if let data = string.data(using: .utf8),
               let sportRadarSocketResponse = try? decoder.decode(SportRadarModels.NotificationType.self, from: data) {
                self.handleResponse(sportRadarSocketResponse, data: data)
            }
        case .binary(let data):
            print("SportRadarSocketConnector websocket Received data: \(data.count)")
            
            if let sportRadarSocketResponse = try? decoder.decode(SportRadarModels.NotificationType.self, from: data) {
                self.handleResponse(sportRadarSocketResponse, data: data)
            }
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            self.isConnected = false
        case .error(let error):
            self.isConnected = false
            print("Socket Error \(error.debugDescription)")
            // TEMP SOCKET SHUTDOWN ERROR
//            if error.debugDescription.contains("Code=57") {
//                print("Socket Error DISCONNECTED")
//                self.refreshConnection()
//            }
            self.refreshConnection()
        }
    }
    
    func handleResponse(_ messageType: SportRadarModels.NotificationType, data: Data) {
        
        switch messageType {
        case .listeningStarted(let sessionTokenId):
            self.isConnected = true
            self.token = SportRadarSessionAccessToken(hash: sessionTokenId)
            self.connectionStateSubject.send(.connected)
        case .contentChanges(let content):
            switch content {
            case .liveAdvancedList(let sportType, let events):
                if let subscriber = self.subscriberForType[content.code]
                {
                    let eventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: events)
                    subscriber.liveAdvancedListUpdated(forSportType: sportType, withEvents: [eventsGroup])
                }
            case .inplaySportList(let sportsTypes):
                if let subscriber = self.subscriberForType[content.code] {
                    subscriber.inplaySportListUpdated(withSportTypes: sportsTypes)
                }
            case .sportTypeByDate(let sportsTypes):
                if let subscriber = self.subscriberForType[content.code] {
                    subscriber.sportTypeByDate(withSportTypes: sportsTypes)
                }
            case .eventListBySportTypeDate(let sportType, let events):
                if let subscriber = self.subscriberForType[content.code]
                {
                    let eventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: events)
                    subscriber.eventListBySportTypeDate(forSportType: sportType, withEvents: [eventsGroup])
                }
            case .eventDetails(let events):
                if let subscriber = self.subscriberForType[content.code] {
                    let eventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: events)

                    subscriber.eventDetails(events: [eventsGroup])
                }
            }
            
        case .unknown:
            print("Uknown Response")
        }
        
    }
    
}
