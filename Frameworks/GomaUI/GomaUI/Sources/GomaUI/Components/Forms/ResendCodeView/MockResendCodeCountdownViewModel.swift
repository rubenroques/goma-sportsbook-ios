import Foundation
import Combine

public class MockResendCodeCountdownViewModel: ResendCodeCountdownViewModelProtocol {
    private let countdownTextSubject = CurrentValueSubject<String, Never>("Resend Code in 00:59")
    public var countdownTextPublisher: AnyPublisher<String, Never> {
        countdownTextSubject.eraseToAnyPublisher()
    }

    private var timer: Timer?
    private var remainingSeconds: Int
    private var startSeconds: Int
    
    public init(startSeconds: Int = 59) {
        self.remainingSeconds = startSeconds
        self.startSeconds = startSeconds
    }

    public func startCountdown() {
        timer?.invalidate()
        updateLabel()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            self.updateLabel()
            if self.remainingSeconds <= 0 {
                self.timer?.invalidate()
            }
        }
    }

    public func resetCountdown() {
        timer?.invalidate()
        remainingSeconds = startSeconds
        updateLabel()
    }

    private func updateLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        let formatted = String(format: "Resend Code in %02d:%02d", minutes, seconds)
        countdownTextSubject.send(formatted)
    }

    deinit {
        timer?.invalidate()
    }
}
