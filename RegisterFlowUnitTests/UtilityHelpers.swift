//
//  UtilityHelpers.swift
//  Sportsbook
//
//  Created by André Lascas on 20/02/2025.
//

import Foundation
import XCTest
import Combine
import ServicesProvider

extension XCTestCase {

    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 20,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        // This time, we use Swift's Result type to keep track
        // of the result of our Combine pipeline:
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }

                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        // Just like before, we await the expectation that we
        // created at the top of our test, and once done, we
        // also cancel our cancellable to avoid getting any
        // unused variable warnings:
        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        // Here we pass the original file and line number that
        // our utility was called at, to tell XCTest to report
        // any encountered errors at that original call site:
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try unwrappedResult.get()
    }

    func awaitWebSocketSubscription<T: Publisher, Content>(
            _ publisher: T,
            timeout: TimeInterval = 20,
            file: StaticString = #file,
            line: UInt = #line,
            connectedAssertion: @escaping (ServicesProvider.Subscription) -> Void,
            contentUpdateAssertion: @escaping ([Content]) -> Void
        ) throws where T.Output == SubscribableContent<[Content]>, T.Failure: Error {

            var didReceiveConnected = false
            var didReceiveContentUpdate = false

            let expectation = self.expectation(description: "Awaiting WebSocket subscription")

            let cancellable = publisher.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail("Subscription failed with error: \(error)", file: file, line: line)
                        expectation.fulfill()
                    case .finished:
                        ()
                    }
                },
                receiveValue: { subscribableContent in
                    switch subscribableContent {
                    case .connected(let subscription):
                        connectedAssertion(subscription)
                        didReceiveConnected = true
                    case .contentUpdate(let contents):
                        contentUpdateAssertion(contents)
                        didReceiveContentUpdate = true
                    case .disconnected:
                        // Handle disconnected case if needed
                        ()
                    }
                    if didReceiveConnected && didReceiveContentUpdate {
                        expectation.fulfill()
                    }
                }
            )

            waitForExpectations(timeout: timeout)
            cancellable.cancel()
        }
}
