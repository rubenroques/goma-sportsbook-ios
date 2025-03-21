//
//  SpinWheelViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/03/2025
//

import Foundation
import Combine

enum SpinWheelMessage: Codable {
    case widgetLoaded
    case removeLoader
    case wheelGotClicked
    case wonPrize(prize: String)
    case exitWheel
    case error(message: String)

    var action: String {
        switch self {
        case .widgetLoaded:
            return "widget-loaded"
        case .removeLoader:
            return "remove-loader"
        case .wheelGotClicked:
            return "wheel-got-clicked"
        case .wonPrize:
            return "won-prize"
        case .exitWheel:
            return "exit-wheel"
        case .error:
            return "error"
        }
    }

    var jsonData: [String: Any] {
        switch self {
        case .widgetLoaded, .removeLoader, .wheelGotClicked, .exitWheel:
            return ["action": action]
        case .wonPrize(let prize):
            return ["action": action, "prize": prize]
        case .error(let message):
            return ["action": action, "msg": message]
        }
    }

    static func from(dictionary: [String: Any]) -> SpinWheelMessage? {
        guard let action = dictionary["action"] as? String else {
            return nil
        }

        switch action {
        case "widget-loaded":
            return .widgetLoaded
        case "remove-loader":
            return .removeLoader
        case "wheel-got-clicked":
            return .wheelGotClicked
        case "won-prize":
            if let prize = dictionary["prize"] as? String {
                return .wonPrize(prize: prize)
            }
            return nil
        case "exit-wheel":
            return .exitWheel
        case "error":
            if let message = dictionary["msg"] as? String {
                return .error(message: message)
            }
            return .error(message: "Unknown error")
        default:
            return nil
        }
    }
}

class SpinWheelViewModel {
    // MARK: - Public Properties
    let url: URL

    // Action publishers
    var exitPublisher = PassthroughSubject<Void, Never>()
    var messageToWebViewPublisher = PassthroughSubject<SpinWheelMessage, Never>()

    // MARK: - Private Properties
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization
    init(url: URL) {
        self.url = url
    }

    // MARK: - Public Methods
    func handleMessageFromWebView(_ message: SpinWheelMessage) {
        switch message {
        case .widgetLoaded:
            // Wait 2 seconds before sending remove-loader message
            Just(())
                .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.messageToWebViewPublisher.send(.removeLoader)
                }
                .store(in: &cancellables)
        case .wheelGotClicked:
            // Wait 2 seconds before sending won-prize message with hardcoded 20% prize
            Just(())
                .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.messageToWebViewPublisher.send(.wonPrize(prize: "20%"))
                }
                .store(in: &cancellables)
        case .exitWheel:
            exitPublisher.send()
        case .error(let message):
            print("Error received from wheel: \(message)")
            // Here you could handle the error, perhaps show an alert or log it
        default:
            break
        }
    }
}
