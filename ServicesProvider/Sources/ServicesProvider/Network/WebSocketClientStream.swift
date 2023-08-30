//
//  WebSocketClientStream.swift
//  
//
//  Created by Ruben Roques on 30/08/2023.
//

import Foundation
import Combine

public enum WebSocketEvent {
    case connected
    case text(String)
    case binary(Data)
    case disconnected
}

public typealias WebSocketStream = AsyncThrowingStream<WebSocketEvent, Error>

public class WebSocketClientStream: NSObject, AsyncSequence {
    public typealias AsyncIterator = WebSocketStream.Iterator
    public typealias Element = WebSocketEvent

    private let url: URL

    private var urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?

    private var continuation: WebSocketStream.Continuation?

    private lazy var stream: WebSocketStream = {
        return WebSocketStream { continuation in
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

        webSocketTask.receive(completionHandler: { [weak self] result in
            guard let continuation = self?.continuation else {
                return
            }

            do {
                let message = try result.get()
                switch message {
                case .string(let string):
                    continuation.yield(.text(string))
                case .data(let data):
                    continuation.yield(.binary(data))
                @unknown default:
                    break
                }

                self?.waitForNextValue()

            } catch {
                continuation.finish(throwing: error)
            }
        })
    }

    public init(url: URL) {
        self.url = url

        super.init()

        let request = URLRequest(url: self.url)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        self.webSocketTask = session.webSocketTask(with: request)

        // self.waitForNextValue()
    }

    private func prepareSession() {

    }

    deinit {
        self.continuation?.finish()
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return stream.makeAsyncIterator()
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

extension WebSocketClientStream: URLSessionDataDelegate, URLSessionWebSocketDelegate {

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.continuation?.yield(.connected)
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.continuation?.yield(.disconnected)
    }

}

