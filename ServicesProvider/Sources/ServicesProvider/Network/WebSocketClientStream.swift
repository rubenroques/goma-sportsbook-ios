//
//  WebSocketClientStream.swift
//  
//
//  Created by Ruben Roques on 30/08/2023.
//

import Foundation
import Combine

public enum WebSocketEventMessage {
    case connected
    case text(String)
    case binary(Data)
    case disconnected
}

public typealias WebSocketAsyncStream = AsyncThrowingStream<WebSocketEventMessage, Error>

public class WebSocketClientStream: NSObject, AsyncSequence {
    public typealias AsyncIterator = WebSocketAsyncStream.Iterator
    public typealias Element = WebSocketEventMessage

    private let url: URL

    private var urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?

    private var continuation: WebSocketAsyncStream.Continuation?

    private lazy var stream: WebSocketAsyncStream = {
        return WebSocketAsyncStream { continuation in
            self.continuation = continuation
            self.waitForNextValue()
        }
    }()

    private func waitForNextValue() {
        guard let webSocketTask = self.webSocketTask else {
            self.continuation?.finish()
            return
        }

        guard webSocketTask.closeCode == .invalid else {
            self.continuation?.finish()
            return
        }
        
        webSocketTask.receive { [weak self] result in
            guard let self = self else {
                return
            }
            
            do {
                let message = try result.get()
                switch message {
                case .string(let string):
                    self.continuation?.yield(.text(string))
                case .data(let data):
                    self.continuation?.yield(.binary(data))
                @unknown default:
                    break
                }
                self.waitForNextValue()
            } catch {
                self.continuation?.finish(throwing: error)
            }
            
        }

    }

    public init(url: URL) {
        self.url = url

        super.init()

        let request = URLRequest(url: self.url)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        self.webSocketTask = session.webSocketTask(with: request)

        // Set the maximum message size to 250 MB
        let maximumMessageSize: Int = 250 * 1024 * 1024 // 25 MB in bytes
        self.webSocketTask?.maximumMessageSize = maximumMessageSize
    }

    deinit {
        self.continuation?.finish()
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return self.stream.makeAsyncIterator()
    }

    public func connect() {
        self.webSocketTask?.resume()
    }

    public func close() {
        self.webSocketTask?.cancel(with: .goingAway, reason: nil)
        self.continuation?.yield(.disconnected)
        self.continuation?.finish()
    }

    public func send(remoteMessage: String) async throws {
        try await self.webSocketTask?.send(.string(remoteMessage))
    }

}

extension WebSocketClientStream: URLSessionWebSocketDelegate {

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.continuation?.yield(.connected)
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.continuation?.yield(.disconnected)
    }

}

