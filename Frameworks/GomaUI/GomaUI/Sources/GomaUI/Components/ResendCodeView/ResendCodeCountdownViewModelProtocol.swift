import Foundation
import Combine

public protocol ResendCodeCountdownViewModelProtocol {
    var countdownTextPublisher: AnyPublisher<String, Never> { get }
    func startCountdown()
    func resetCountdown()
}
