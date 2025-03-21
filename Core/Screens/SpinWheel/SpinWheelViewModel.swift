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
    case hostError

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
        case .hostError:
            return "error"
        }
    }

    var jsonData: [String: Any] {
        switch self {
        case .widgetLoaded, .removeLoader, .wheelGotClicked, .exitWheel:
            return ["action": action]
        case .wonPrize(let prize):
            return ["action": action, "prize": prize]
        case .hostError:
            return ["action": action]
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
            return .hostError
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
    private var widgetLoadedTriggered = false

    // MARK: - Initialization
    init(url: URL) {
        self.url = url
    }

    // MARK: - Public Methods
    func handleMessageFromWebView(_ message: SpinWheelMessage) {
        print("SpinWheelVM: Handling message from WebView: \(message)")

        switch message {
        case .widgetLoaded:
            // Ensure widgetLoaded is processed only once
            guard !widgetLoadedTriggered else {
                print("SpinWheelVM: Ignoring duplicate widgetLoaded message")
                return
            }

            widgetLoadedTriggered = true
            print("SpinWheelVM: Widget loaded message received, will send removeLoader after delay")
            // Wait 2 seconds before sending remove-loader message
            Just(())
                .delay(for: .milliseconds(1200), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    print("SpinWheelVM: Delay completed, sending removeLoader message")
                    self?.messageToWebViewPublisher.send(.removeLoader)
                }
                .store(in: &self.cancellables)
        case .wheelGotClicked:
            print("SpinWheelVM: Wheel clicked message received, will send prize after delay")
            // Wait 2 seconds before sending won-prize message with hardcoded 20% prize
            Just(())
                .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    print("SpinWheelVM: Delay completed, sending wonPrize message with 20%")
                    self?.messageToWebViewPublisher.send(.wonPrize(prize: "20%"))
                }
                .store(in: &self.cancellables)
        case .exitWheel:
            print("SpinWheelVM: Exit wheel message received, sending exit command")
            exitPublisher.send()
        case .removeLoader:
            print("SpinWheelVM: Remove loader message received (no action needed)")
        case .wonPrize(let prize):
            print("SpinWheelVM: Won prize message received with prize: \(prize) (no action needed)")
        case .hostError:
            print("SpinWheelVM: Host error message received (no action needed)")
        }
    }
}
