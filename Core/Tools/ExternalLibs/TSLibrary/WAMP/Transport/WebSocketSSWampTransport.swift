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

    let concurrentQueue = DispatchQueue(label: "websocket.swamp.queue", attributes: .concurrent)

    var messageCounter = 1
    
    fileprivate var disconnectionReason: String?
    
    public init(wsEndpoint: URL, userAgent: String, origin: String) {

        var request = URLRequest(url: wsEndpoint)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue(origin, forHTTPHeaderField: "Origin")
        request.addValue("wamp.2.json", forHTTPHeaderField: "Sec-WebSocket-Protocol")

        // request.addValue("Upgrade", forHTTPHeaderField: "WebSocket")
        // request.addValue("Upgrade", forHTTPHeaderField: "Connection")
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
            print("TSWebSocketClient sendData \(textData)")
            socket?.write(string: textData)
        }
        else {
            socket?.write(data: data)
        }
    }
        
    public func websocketDidConnect(socket: WebSocketClient) {
        print("TSWebSocketClient connect")
        delegate?.ssWampTransportDidConnectWithSerializer(JSONSSWampSerializer())
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("TSWebSocketClient disconnect")
        delegate?.ssWampTransportDidDisconnect(error, reason: disconnectionReason)
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("TSWebSocketClient receiveMessage [\(messageCounter)] with \(text.prefix(500))")
        messageCounter += 1
        if let data = text.data(using: .utf8) {
            websocketDidReceiveData(socket: socket, data: data)
        }
    }

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {

        concurrentQueue.sync {
            delegate?.ssWampTransportReceivedData(data)
        }

    }

}
