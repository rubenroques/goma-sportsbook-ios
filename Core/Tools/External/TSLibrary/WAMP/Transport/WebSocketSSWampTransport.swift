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
    
    fileprivate var disconnectionReason: String?
    
    public init(wsEndpoint: URL, userAgent: String, origin: String){
        var request = URLRequest(url: wsEndpoint)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue(origin, forHTTPHeaderField: "Origin")
        request.addValue("wamp.2.json", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        socket = WebSocket(request: request)
        socket?.callbackQueue = DispatchQueue(label: "com.tipico.games.SSWampQueue")
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
            socket?.write(string: String(data: data, encoding: String.Encoding.utf8)!)
        } else {
            socket?.write(data: data)
        }
    }
        
    public func websocketDidConnect(socket: WebSocketClient) {
        delegate?.ssWampTransportDidConnectWithSerializer(JSONSSWampSerializer())
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        delegate?.ssWampTransportDidDisconnect(error, reason: disconnectionReason)
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data = text.data(using: .utf8) {
            websocketDidReceiveData(socket: socket, data: data)
        }
    }

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        delegate?.ssWampTransportReceivedData(data)
    }


}
