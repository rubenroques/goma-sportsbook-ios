//
//  SportsradarProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Starscream

class SportsradarProvider: NSObject {
    
    private var webSocket : URLSessionWebSocketTask?
    
    private let socket: WebSocket
    private var isConnected: Bool
    
    override init() {
        self.isConnected = false
        
        // var request = URLRequest(url: URL(string: "https://velnt-spor-int.optimahq.com/notification/listen/websocket")!)
        
        let wssURLString = "wss://velnt-spor-int.optimahq.com/notification/listen/websocket"
        //let wssURLString = "wss://ws.postman-echo.com/raw"
        
        
        var request = URLRequest(url: URL(string: wssURLString)!)
        
        // request.timeoutInterval = 10 // Sets the timeout for the connection
        // request.setValue("someother protocols", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        // request.setValue("14", forHTTPHeaderField: "Sec-WebSocket-Version")
        // request.setValue("Upgrade", forHTTPHeaderField: "Connection")
        // request.setValue("websocket", forHTTPHeaderField: "Upgrade")
        
        //request.setValue("chat,superchat", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        
        // request.setValue("Everything is Awesome!", forHTTPHeaderField: "My-Awesome-Header")
        // let pinner = FoundationSecurity(allowSelfSigned: true) // don't validate SSL certificates
        
        
        /*
         request.setValue("websocket", forHTTPHeaderField: "Upgrade")
         request.setValue("Upgrade", forHTTPHeaderField: "Connection")
         
         request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
         request.setValue("pt-PT,pt;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
         request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
         request.setValue("no-cache", forHTTPHeaderField: "Pragma")
         
         request.setValue("permessage-deflate; client_max_window_bits", forHTTPHeaderField: "Sec-WebSocket-Extensions")
         request.setValue("13", forHTTPHeaderField: "Sec-WebSocket-Version")
         request.setValue("uJYwUwH4A3WIaHBmGX3bmA==", forHTTPHeaderField: "Sec-WebSocket-Key")
         */
        
        let pinner = FoundationSecurity(allowSelfSigned: true)
        let compression = WSCompression()
        self.socket = WebSocket.init(request: request, useCustomEngine: false) //,
        // certPinner: pinner,
        // compressionHandler: compression,
        // useCustomEngine: false)
        
        super.init()
        
    }
    
    func connectSocket() {
        
        self.socket.delegate = self
        self.socket.connect()
        
        // self.openWebSocket()
        
    }
    
    func openWebSocket() {
        let urlString = "wss://velnt-spor-int.optimahq.com/notification/listen/websocket"
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            self.webSocket = session.webSocketTask(with: request)
            self.webSocket?.resume()
            
            isConnected = true
        }
    }
    
    func receiveMessage() {
        
        if !isConnected {
            self.openWebSocket()
        }
        
        self.webSocket?.receive(completionHandler: { [weak self] result in
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let message):
                switch message {
                case .string(let messageString):
                    print(messageString)
                case .data(let data):
                    print(data.description)
                default:
                    print("Unknown type received from WebSocket")
                }
            }
            self?.receiveMessage()
        })
    }
    
    func sendListeningStarted() {
        return
        let string = """
  {"subscriberId":null,"versionList":[],"clientContext":{"language":"UK","ipAddress":""}}
  """
        
        let message = URLSessionWebSocketTask.Message.string(string)
        
        self.webSocket?.send(message, completionHandler: { [weak self] error in
            if let error = error {
                print("Failed with Error \(error.localizedDescription)")
            } else {
                // no-op
            }
        })
    }
}

extension SportsradarProvider: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Connected to server")
        // self.sendListeningStarted()
        self.receiveMessage()
        
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Disconnect from Server \(reason)")
    }
    
}

extension SportsradarProvider: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            self.isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            self.isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
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
            print("Socket Error \(error)")
        }
    }
    
}

extension SportsradarProvider: PrivilegedAccessManager {
    
}

extension SportsradarProvider: BettingProvider {
    
}

extension SportsradarProvider: EventsProvider {
    func connect() {
        self.connectSocket()
    }
}
