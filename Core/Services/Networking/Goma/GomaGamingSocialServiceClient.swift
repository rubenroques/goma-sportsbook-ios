//
//  GomaGamingSocialServiceClient.swift
//  Sportsbook
//
//  Created by André Lascas on 29/04/2022.
//

import Foundation
import Combine
import SocketIO

class GomaGamingSocialServiceClient {

    var manager = SocketManager(socketURL: URL(string: "https://sportsbook-api.gomagaming.com")!, config: [.log(true)])

    var socket: SocketIOClient

    init() {

        if let jwtToken = Env.gomaNetworkClient.getCurrentToken() {
            print("JWT Token: \(jwtToken.hash)")
            self.manager.config = SocketIOClientConfiguration.init(arrayLiteral: .log(true),
                                                                   .forceWebsockets(true),
                                                                   .forcePolling(false),
                                                                   .connectParams(["jwt": "\(jwtToken.hash)",
                                                                                   "EIO": "4"]),
                                                                   .extraHeaders(["token": "\(Env.deviceFCMToken)"]),
                                                                   .path("/socket/socket.io/")
                        )
            self.manager.reconnects = false
//            self.manager.reconnectWait = 10
//            self.manager.reconnectWaitMax = 40
        }

        self.socket = manager.defaultSocket
        //self.socket = manager.socket(forNamespace: "/socket/socket.io/")

        self.connectSocket()
    }

    private func connectSocket() {
        
        self.socket.on(clientEvent: .connect) {data, ack in
            print("Socket connected to Goma Social Server!")
        }

        self.socket.on(clientEvent: .error) {data, ack in
            print("Socket error data: \(data)")
            print("Socket error: \(ack.description)")

        }

        self.socket.on(clientEvent: .disconnect) {data, ack  in
            print("Socket disconnect data: \(data)")
            print("Socket disconnect error: \(ack.description)")
        }

        self.socket.on(clientEvent: .websocketUpgrade) {data, _ in
            print("Socket: WebsocketUpgrade \(data)")
        }

        self.socket.on(clientEvent: .statusChange) {data, _ in
            print("Socket: statusChange \(data)")
        }

        self.socket.connect()
    }

    func disconnectSocket() {
        self.socket.disconnect()
    }
}
