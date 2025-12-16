//
//  Debounce.swift
//  AllGoals
//
//  Created by Ruben Roques on 21/01/2021.
//  Copyright © 2021 GOMA Development. All rights reserved.
//

import Foundation

public class Debouncer {

    private let timeInterval: TimeInterval
    private var timer: Timer?

    typealias Handler = () -> Void
    var handler: Handler?

    private var clearHandler: Bool

    init(timeInterval: TimeInterval, clearHandler: Bool = true) {
        self.timeInterval = timeInterval
        self.clearHandler = clearHandler
    }

    public func call() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] timer in
            self?.timeIntervalDidFinish(for: timer)
        }
    }

    public func cancel() {
        timer?.invalidate()
        self.handler = nil
    }

    @objc private func timeIntervalDidFinish(for timer: Timer) {
        guard timer.isValid else {
            return
        }

        handler?()

        if clearHandler {
            handler = nil
        }
    }

}
