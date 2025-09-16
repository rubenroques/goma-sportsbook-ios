//
//  WebSocketSSWampTransport.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation
import Starscream

class WebSocketSSWampTransport: SSWampTransport, WebSocketDelegate {
    
    enum WebsocketMode {
        case binary, text
    }
    
    weak var delegate: SSWampTransportDelegate?
    var socket: WebSocket?
    let mode: WebsocketMode

    var messageCounter = 1
    var isConnected = false

    fileprivate var disconnectionReason: String?
    
    public init(wsEndpoint: URL, userAgent: String, origin: String) {

        var request = URLRequest(url: wsEndpoint)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue(origin, forHTTPHeaderField: "Origin")
        request.addValue("wamp.2.json", forHTTPHeaderField: "Sec-WebSocket-Protocol")

        //request.addValue("Upgrade", forHTTPHeaderField: "websocket")
        //request.addValue("Upgrade", forHTTPHeaderField: "Connection")
        
        //request.addValue("13", forHTTPHeaderField: "Sec-WebSocket-Version")
        
        // "Upgrade: websocket"
        // "Origin: https://sportsbook-stage.gomagaming.com"
        // "Cache-Control: no-cache"
        // "Accept-Language: pt-PT,pt;q=0.9,en;q=0.8"
        // "Pragma: no-cache"
        // "Connection: Upgrade"
        // "Sec-WebSocket-Key: O1PkxwXzKV4I17AOCQ++aA=="
        // "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36"
        // "Sec-WebSocket-Version: 13"
        // "Sec-WebSocket-Protocol: wamp.2.json, wamp.2.msgpack"
        // "Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bit
        
        
        // request.addValue("13", forHTTPHeaderField: "Sec-WebSocket-Version")
        // wamp.2.json, wamp.2.msgpack, my.protocol
        

        socket = WebSocket(request: request)
        socket?.callbackQueue = DispatchQueue(label: "com.goma.games.SSWampQueue")
        mode = .text
        socket?.delegate = self
    }
        
    open func connect() {
        socket?.connect()
    }
    
    open func disconnect(_ reason: String) {
        disconnectionReason = reason
        socket?.disconnect()
    }
    
    open func sendData(_ data: Data) {
        if mode == .text {
            let textData = String(data: data, encoding: .utf8)!
            //print("TSWebSocketClient sendData \(textData)")
            socket?.write(string: textData)
        }
        else {
            socket?.write(data: data)
        }
    }
        
    public func websocketDidConnect(socket: WebSocketClient) {
        print("TSWebSocketClient connect")
        isConnected = true
        delegate?.ssWampTransportDidConnectWithSerializer(JSONSSWampSerializer())
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("TSWebSocketClient disconnect")
        if isConnected {
            delegate?.ssWampTransportDidDisconnect(error, reason: disconnectionReason)
        }
        isConnected = false
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        //print("TSWebSocketClient receiveMessage [\(messageCounter)] with \(text.prefix(500))")
        messageCounter += 1
        if let data = text.data(using: .utf8) {
            websocketDidReceiveData(socket: socket, data: data)
        }
    }

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        delegate?.ssWampTransportReceivedData(data)
    }

    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {

        switch event {
        case .connected:
            isConnected = true
            delegate?.ssWampTransportDidConnectWithSerializer(JSONSSWampSerializer())

        case .text(let text): // String

            // print("TSWebSocketClient receiveMessage text with \(text))")

            messageCounter += 1
            if let data = text.data(using: .utf8) {
                websocketDidReceiveData(socket: client, data: data)
            }
        case .binary(let data):
            delegate?.ssWampTransportReceivedData(data)

        case .disconnected, .reconnectSuggested, .cancelled:
            print("TSWebSocketClient disconnect")
            if isConnected {
                delegate?.ssWampTransportDidDisconnect(nil, reason: disconnectionReason)
            }
            isConnected = false

        case .error(let error):
            print("TSWebSocketClient disconnect")
            if isConnected {
                delegate?.ssWampTransportDidDisconnect(error, reason: disconnectionReason)
            }
            isConnected = false
            
        case .pong, .ping, .viabilityChanged:
            ()
        case .peerClosed:
            ()
        }

    }

}


