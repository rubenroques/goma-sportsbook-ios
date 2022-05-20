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

    var manager: SocketManager?
    var socket: SocketIOClient?

    let websocketURL = "https://sportsbook-api.gomagaming.com/"
    private let authToken = "9g7rp9760c33c6g1f19mn5ut3asd67"

    init() {
        
    }

    func setupGomaSocket() {
        guard let jwtToken = Env.gomaNetworkClient.getCurrentToken() else { return }

        let configs = SocketIOClientConfiguration.init(arrayLiteral: .log(true),
                                                       .forceWebsockets(true),
                                                       .forcePolling(false),
                                                       .secure(true),
                                                       .path("/socket/socket.io"),
                                                       .connectParams([ "EIO": "4", "jwt": jwtToken.hash]),
                                                       .extraHeaders(["token": "\(authToken)"]))

        let websocketURL = self.websocketURL
        self.manager = SocketManager(socketURL: URL(string: websocketURL)!, config: configs)
        self.manager?.reconnects = true
        self.manager?.reconnectWait = 10
        self.manager?.reconnectWaitMax = 40

        self.socket = manager?.defaultSocket

        self.socket?.on(clientEvent: .connect) { data, ack in
            print("Socket connected to Goma Social Server!")
        }

        self.socket?.on(clientEvent: .error) { data, ack in
            print("Socket error data: \(data)")
            print("Socket error: \(ack.description)")
        }

        self.socket?.on(clientEvent: .disconnect) { data, ack  in
            print("Socket disconnect data: \(data)")
            print("Socket disconnect error: \(ack.description)")
        }

        self.socket?.on(clientEvent: .websocketUpgrade) { data, _ in
            print("Socket: WebsocketUpgrade \(data)")
        }

        self.socket?.on(clientEvent: .statusChange) { data, _ in
            print("Socket: statusChange \(data)")
        }

        self.connectSocket()
    }

    func connectSocket() {

        self.socket?.connect()
    }

    func disconnectSocket() {
        self.socket?.disconnect()
    }

    func getChatMessages(data: [Any], completion: @escaping ([ChatMessagesResponse]?) -> Void)  {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: []) else { return }

        let decoder = JSONDecoder()

        do {
            let messages = try? decoder.decode([ChatMessagesResponse].self, from: json)

            completion(messages)

        } catch {
            print(error.localizedDescription)

            completion(nil)

        }
    }

    func getChatMessagesTest(data: [Any], completion: @escaping ([JSON]?) -> Void)  {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: []) else { return }

        let decoder = JSONDecoder()

        do {
            let messages = try? decoder.decode([JSON].self, from: json)

            completion(messages)

        } catch {
            print(error.localizedDescription)

            completion(nil)

        }
    }

}
