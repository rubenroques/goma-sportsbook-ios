//
//  GomaGamingSocialServiceClient.swift
//  Sportsbook
//
//  Created by André Lascas on 29/04/2022.
//

import Foundation
import Combine
// import SocketIO

class GomaGamingSocialServiceClient {

//    var manager: SocketManager?
//    var socket: SocketIOClient?
//
//    let websocketURL = "https://sportsbook-api.gomagaming.com/"
//    private let authToken = "9g7rp9760c33c6g1f19mn5ut3asd67"
//
//    init() {
//
//        if let jwtToken = Env.gomaNetworkClient.getCurrentToken() {
//
//            let configs = SocketIOClientConfiguration.init(arrayLiteral: .log(true),
//                                                             .forceWebsockets(true),
//                                                             .forcePolling(false),
//                                                            .secure(true),
//                                                            .path("/socket/socket.io"),
//                                                           .connectParams([ "EIO": "4", "jwt": jwtToken.hash]),
//                                                            .extraHeaders(["token": "\(authToken)"]))
//
//            let websocketURL = self.websocketURL
//            manager = SocketManager(socketURL: URL(string: websocketURL)!, config: configs)
//            manager?.reconnects = false
//            manager?.reconnectWait = 10
//            manager?.reconnectWaitMax = 40
//
//            socket = manager?.defaultSocket
//
//        }
//
//    }
//
//    func connectSocket() {
//
//        self.socket?.on(clientEvent: .connect) {data, ack in
//            print("Socket connected to Goma Social Server!")
//        }
//
//        self.socket?.on(clientEvent: .error) {data, ack in
//            print("Socket error data: \(data)")
//            print("Socket error: \(ack.description)")
//
//        }
//
//        self.socket?.on(clientEvent: .disconnect) {data, ack  in
//            print("Socket disconnect data: \(data)")
//            print("Socket disconnect error: \(ack.description)")
//        }
//
//        self.socket?.on(clientEvent: .websocketUpgrade) {data, _ in
//            print("Socket: WebsocketUpgrade \(data)")
//        }
//
//        self.socket?.on(clientEvent: .statusChange) {data, _ in
//            print("Socket: statusChange \(data)")
//        }
//
//        self.socket?.connect()
//    }
//
//    func disconnectSocket() {
//        self.socket?.disconnect()
//    }
}
