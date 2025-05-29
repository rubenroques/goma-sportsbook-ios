import Foundation
import Combine

// MARK: - Sports Subscription Extension

extension TSManager {

    /// Subscribe to sports data using WAMP protocol
    /// - Parameters:
    ///   - topic: The WAMP topic to subscribe to
    ///   - initialDumpProcedure: The procedure for initial data dump
    ///   - onInitialDump: Callback for initial data dump
    ///   - onUpdate: Callback for real-time updates
    ///   - onError: Callback for errors
    /// - Returns: Subscription object that can be used to unsubscribe
    func subscribeToSports(
        topic: String,
        initialDumpProcedure: String,
        onInitialDump: @escaping ([String: Any]) -> Void,
        onUpdate: @escaping ([String: Any]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> Subscription? {

        guard let swampSession = self.swampSession, swampSession.isConnected() else {
            onError(EveryMatrix.APIError.notConnected)
            return nil
        }

        // Subscribe to the topic for real-time updates
        var subscription: Subscription?

        swampSession.subscribe(
            topic,
            onSuccess: { [weak self] sub in
                subscription = sub

                // After successful subscription, call initial dump
                self?.performInitialDump(
                    procedure: initialDumpProcedure,
                    topic: topic,
                    onSuccess: onInitialDump,
                    onError: onError
                )
            },
            onError: { details, error in
                let apiError = EveryMatrix.APIError.requestError(value: error)
                onError(apiError)
            },
            onEvent: { details, results, kwResults in
                // Handle real-time updates
                if let kwResults = kwResults {
                    onUpdate(kwResults)
                } else if let results = results, !results.isEmpty {
                    // Convert results array to dictionary format if needed
                    let updateData: [String: Any] = ["results": results]
                    onUpdate(updateData)
                }
            }
        )

        return subscription
    }

    /// Perform initial data dump for sports
    private func performInitialDump(
        procedure: String,
        topic: String,
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        guard let swampSession = self.swampSession else {
            onError(EveryMatrix.APIError.notConnected)
            return
        }

        // Call the initial dump procedure with the topic parameter
        swampSession.call(
            procedure,
            options: [:],
            args: [],
            kwargs: ["topic": topic],
            onSuccess: { details, results, kwResults, arrResults in
                if let kwResults = kwResults {
                    onSuccess(kwResults)
                } else if let arrResults = arrResults {
                    // Convert array results to expected format
                    let data: [String: Any] = ["records": arrResults]
                    onSuccess(data)
                } else {
                    // Empty response
                    onSuccess([:])
                }
            },
            onError: { details, error, args, kwargs in
                let apiError = EveryMatrix.APIError.requestError(value: error)
                onError(apiError)
            }
        )
    }
}

// MARK: - Sports-specific subscription methods

extension TSManager {

    /// Subscribe to all sports (both live and non-live)
    /// - Parameters:
    ///   - operatorId: Operator ID
    ///   - language: Language code
    ///   - onInitialDump: Callback for initial sports data
    ///   - onUpdate: Callback for real-time updates
    ///   - onError: Callback for errors
    /// - Returns: Subscription object
    func subscribeToAllSports(
        operatorId: String,
        language: String,
        onInitialDump: @escaping ([String: Any]) -> Void,
        onUpdate: @escaping ([String: Any]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> Subscription? {
        let topic = "/sports/\(operatorId)/\(language)/sports/BOTH/BOTH"

        return subscribeToSports(
            topic: topic,
            initialDumpProcedure: "/sports#initialDump",
            onInitialDump: onInitialDump,
            onUpdate: onUpdate,
            onError: onError
        )
    }

    /// Subscribe to pre-live sports (NOT_LIVE) - kept for backward compatibility
    /// - Parameters:
    ///   - operatorId: Operator ID
    ///   - language: Language code
    ///   - onInitialDump: Callback for initial sports data
    ///   - onUpdate: Callback for real-time updates
    ///   - onError: Callback for errors
    /// - Returns: Subscription object
    @available(*, deprecated, message: "Use subscribeToAllSports instead for better efficiency")
    func subscribeToPreLiveSports(
        operatorId: String,
        language: String,
        onInitialDump: @escaping ([String: Any]) -> Void,
        onUpdate: @escaping ([String: Any]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> Subscription? {
        let topic = "/sports/\(operatorId)/\(language)/sports/NOT_LIVE/BOTH"

        return subscribeToSports(
            topic: topic,
            initialDumpProcedure: "/sports#initialDump",
            onInitialDump: onInitialDump,
            onUpdate: onUpdate,
            onError: onError
        )
    }

    /// Subscribe to live sports (LIVE) - kept for backward compatibility
    /// - Parameters:
    ///   - operatorId: Operator ID
    ///   - language: Language code
    ///   - onInitialDump: Callback for initial sports data
    ///   - onUpdate: Callback for real-time updates
    ///   - onError: Callback for errors
    /// - Returns: Subscription object
    @available(*, deprecated, message: "Use subscribeToAllSports instead for better efficiency")
    func subscribeToLiveSports(
        operatorId: String,
        language: String,
        onInitialDump: @escaping ([String: Any]) -> Void,
        onUpdate: @escaping ([String: Any]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> Subscription? {
        let topic = "/sports/\(operatorId)/\(language)/sports/LIVE/BOTH"

        return subscribeToSports(
            topic: topic,
            initialDumpProcedure: "/sports#initialDump",
            onInitialDump: onInitialDump,
            onUpdate: onUpdate,
            onError: onError
        )
    }

    /// Get operator info using WAMP call
    /// - Returns: Publisher that emits operator info or error
    func getOperatorInfo() -> AnyPublisher<[String: Any], EveryMatrix.APIError> {
        return Future<[String: Any], EveryMatrix.APIError> { [weak self] promise in
            guard let self = self, let swampSession = self.swampSession else {
                promise(.failure(.notConnected))
                return
            }

            swampSession.call(
                "/sports#operatorInfo",
                options: [:],
                args: [],
                kwargs: [:],
                onSuccess: { details, results, kwResults, arrResults in
                    if let kwResults = kwResults {
                        promise(.success(kwResults))
                    } else {
                        promise(.failure(.noResultsReceived))
                    }
                },
                onError: { details, error, args, kwargs in
                    promise(.failure(.requestError(value: error)))
                }
            )
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Subscription Management

extension TSManager {

    /// Unsubscribe from a sports subscription
    /// - Parameter subscription: The subscription to cancel
    func unsubscribeFromSports(_ subscription: Subscription?) {
        subscription?.cancel(
            {
                print("TSManager: Successfully unsubscribed from sports")
            },
            onError: { details, error in
                print("TSManager: Error unsubscribing from sports: \(error)")
            }
        )
    }
}