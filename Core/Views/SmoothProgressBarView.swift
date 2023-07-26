//
//  SmoothProgressBarView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 06/06/2023.
//

import Foundation
import UIKit
import Combine

class SmoothProgressBarView: UIView {

    var progressBarFinishedAction: (() -> Void) = { }
    var shouldTriggerFinish: Bool = false

    private var animator = SmoothProgressBarAnimator(duration: 5.0)
    private var animatorCancellable: AnyCancellable?

    private let backgroundBar: UIView = {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    private let foregroundBar: UIView = {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    var backgroundBarColor: UIColor = .gray {
        didSet {
            self.backgroundBar.backgroundColor = self.backgroundBarColor
        }
    }

    var foregroundBarColor: UIColor = .gray {
        didSet {
            self.foregroundBar.backgroundColor = self.foregroundBarColor
        }
    }

    private var foregroundBarWidthConstraint: NSLayoutConstraint?

    init(backgroundColor: UIColor, foregroundColor: UIColor) {
        super.init(frame: .zero)

        self.clipsToBounds = true
        self.layer.masksToBounds = true

        self.backgroundBarColor = backgroundColor
        self.foregroundBarColor = foregroundColor
        
        self.setupView(backgroundColor: backgroundColor, foregroundColor: foregroundColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(backgroundColor: UIColor, foregroundColor: UIColor) {
        self.addSubview(self.backgroundBar)
        self.addSubview(self.foregroundBar)

        // Background bar constraints
        NSLayoutConstraint.activate([
            self.backgroundBar.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundBar.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.backgroundBar.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        // Foreground bar constraints
        self.foregroundBarWidthConstraint = foregroundBar.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            self.foregroundBar.topAnchor.constraint(equalTo: self.topAnchor),
            self.foregroundBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.foregroundBar.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.foregroundBarWidthConstraint!
        ])

        // Setup colors
        self.backgroundBar.backgroundColor = backgroundColor
        self.foregroundBar.backgroundColor = foregroundColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = self.frame.size.height / 2
    }

    func startProgress(duration: TimeInterval? = nil) {

        self.animatorCancellable?.cancel()
        self.animatorCancellable = nil

        self.animatorCancellable = self.animator.completionSubject
            .sink { [weak self] in
                print("completionSubject called")
                self?.progressBarFinishedAction()
            }

        self.animator.animate(constraint: self.foregroundBarWidthConstraint!,
                                      toValue: self.backgroundBar.frame.size.width,
                                      duration: duration)
    }

    func resetProgress() {
        self.animator.reset()
    }

    func pauseAnimation() {
        self.animator.pause()
    }

    func resumeAnimation() {
        self.animator.resume()
    }

}

class SmoothProgressBarAnimator {

    var timer: Timer?
    var currentProgress: CGFloat = 0.0
    var targetProgress: CGFloat = 1.0
    var originalDuration: TimeInterval = 0.0
    var duration: TimeInterval = 0.0

    let completionSubject = PassthroughSubject<Void, Never>()
    var constraint: NSLayoutConstraint?

    init(duration: TimeInterval) {
        self.originalDuration = duration
        self.duration = duration
    }

    func animate(constraint: NSLayoutConstraint, fromValue: CGFloat = 0.0, toValue: CGFloat, duration: TimeInterval? = nil) {

        self.constraint = constraint
        self.targetProgress = toValue

        // Invalidate any existing timer
        self.timer?.invalidate()
        self.timer = nil

        // Reset progress
        self.currentProgress = fromValue

        constraint.constant = fromValue
        constraint.firstItem?.superview?.layoutIfNeeded()

        self.duration = duration ?? self.originalDuration

        // Calculate the progress increment per timer tick (assuming timer ticks every 0.01 second)
        let incrementPerTick = targetProgress / (self.duration * 100)

        // Start a new timer
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            self.currentProgress += incrementPerTick

            if self.currentProgress >= self.targetProgress {
                timer.invalidate()
                self.constraint?.constant = self.targetProgress
                self.constraint?.firstItem?.superview?.layoutIfNeeded()
                self.completionSubject.send(())
            }
            else {
                self.constraint?.constant = self.currentProgress
                self.constraint?.firstItem?.superview?.layoutIfNeeded()
            }
        }
    }

    func pause() {
        // Invalidate any existing timer
        self.timer?.invalidate()
        self.timer = nil
    }

    func resume() {
        guard let constraint = self.constraint else { return }

        let remainingProgress = self.targetProgress - self.currentProgress
        let remainingTime = self.duration * Double(remainingProgress / self.targetProgress)

        self.animate(constraint: constraint,
                     fromValue: self.currentProgress,
                     toValue: self.targetProgress,
                     duration: remainingTime)
    }

    func reset() {
        guard let constraint = self.constraint else { return }

        // Invalidate any existing timer
        self.timer?.invalidate()
        self.timer = nil

        // Reset the constraint to its initial value
        constraint.constant = 0.0
        constraint.firstItem?.superview?.layoutIfNeeded()
    }
}
