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
    
}

class SportRadarConnector: NSObject, Connector  {
    
    var token: SessionAccessToken?

    var subscriberForType: [SportRadarModels.ContentType: SportRadarConnectorSubscriber] = [:]
    
    var connectionStatePublisher: AnyPublisher<ConnectorState, Error> {
        connectionStateSubject.eraseToAnyPublisher()
    }
    private let connectionStateSubject: CurrentValueSubject<ConnectorState, Error>
    
    private var webSocket : URLSessionWebSocketTask?
    private let socket: WebSocket
    private var isConnected: Bool
    
    override init() {
        self.connectionStateSubject = CurrentValueSubject<ConnectorState, Error>.init(.disconnected)
        self.isConnected = false
        
        let wssURLString = "wss://velnt-spor-int.optimahq.com/notification/listen/websocket"
        let request = URLRequest(url: URL(string: wssURLString)!)
        
        // let pinner = FoundationSecurity(allowSelfSigned: true)
        // let compression = WSCompression()
        
        self.socket = WebSocket.init(request: request, useCustomEngine: false)
        super.init()
    }
    
    private func connectSocket() {
        self.socket.delegate = self
        self.socket.connect()
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
        
    }
    
    func disconnect() {
        
    }
    
    func subscribe(_ subscriber: SportRadarConnectorSubscriber, forContentType type: SportRadarModels.ContentType) {
        self.subscriberForType[type] = subscriber
    }

    func unsubscribe(forContentType type: SportRadarModels.ContentType) {
        self.subscriberForType[type] = nil
    }
    
}


extension SportRadarConnector: WebSocketDelegate {
    
    internal func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            self.isConnected = true
            self.sendListeningStarted(toSocket: client)
            
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            self.isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            if let data = string.data(using: .utf8),
               let sportRadarSocketResponse = try? JSONDecoder().decode(SportRadarModels.NotificationType.self, from: data) {
                self.handleResponse(sportRadarSocketResponse, data: data)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
            if let sportRadarSocketResponse = try? JSONDecoder().decode(SportRadarModels.NotificationType.self, from: data) {
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
            case .liveAdvancedList(let sportType, let eventsList):
                if let subscriber = self.subscriberForType[content.type] {
                    let sport = SportRadarModelMapper.sportType(fromInternalSportType: sportType)
                    let eventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: eventsList)
                    subscriber.liveAdvancedListUpdated(forSportType: sport, withEvents: [eventsGroup])
                }
            }
            
        case .unknown:
            print("Uknown Response")
        }
        
    }
    
}
