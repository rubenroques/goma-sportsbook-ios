//
//  ToastCustom.swift
//  Sportsbook
//
//  Created by André Lascas on 17/06/2022.
//

import Foundation
import UIKit

public class ToastCustom {

    public let view: ToastCustomView
    private let config: ToastCustomConfiguration

    public required init(view: ToastCustomView, config: ToastCustomConfiguration) {
        self.config = config
        self.view = view

        view.transform = initialTransform
    }

    private var initialTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: -100)
    }

    // Initiate toast with custom text and config
    public static func text(
        title: String,
        config: ToastCustomConfiguration = ToastCustomConfiguration()
    ) -> ToastCustom {
        let view = ToastCustomView(childView: TextToastCustomView(title: title), backgroundColor: UIColor.App.backgroundPrimary)
        return self.init(view: view, config: config)
    }

    // Show toast
    public func show(after delay: TimeInterval = 0) {
        self.config.view?.addSubview(view) ?? topController()?.view.addSubview(view)
        self.view.createView(for: self)

        UIView.animate(withDuration: config.animationTime, delay: delay, options: [.curveEaseOut, .allowUserInteraction]) {
            self.view.transform = .identity
        } completion: { [self] _ in
            if config.autoHide {
                self.close(after: config.displayTime)
            }
        }
    }

    // Close toast
    @objc public func close(after time: TimeInterval = 0, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: config.animationTime, delay: time, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.view.transform = self.initialTransform
        }, completion: { _ in
            self.view.removeFromSuperview()
            completion?()
        })
    }

    // Return the appropriate view controller to display toast
    private func topController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class ToastCustomView: UIView {

    private let minHeight: CGFloat
    private let minWidth: CGFloat
    private let toastBackgroundColor: UIColor
    private let childView: UIView
    private var toast: ToastCustom?

    public init(
        childView: UIView,
        minHeight: CGFloat = 58,
        minWidth: CGFloat = 150,
        backgroundColor: UIColor
    ) {
        self.minHeight = minHeight
        self.minWidth = minWidth
        self.toastBackgroundColor = backgroundColor
        self.childView = childView
        super.init(frame: .zero)

        self.addSubview(childView)
    }

    public func createView(for toast: ToastCustom) {
        self.toast = toast
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight),
            widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth),
            leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: 10),
            trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -10),
            topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor, constant: 0),
            centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        ])

        self.addSubviewConstraints()

        self.styleView()

    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        UIView.animate(withDuration: 0.5) {
//            self.styleView()
//        }
    }

    private func styleView() {
        self.layoutIfNeeded()
        self.clipsToBounds = true
        self.layer.cornerRadius = frame.height / 2
        self.backgroundColor = toastBackgroundColor
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        self.addShadow()
    }

    private func addShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 8
    }

    private func addSubviewConstraints() {
        self.childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.childView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            self.childView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            self.childView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            self.childView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct ToastCustomConfiguration {
    public let autoHide: Bool
    public let displayTime: TimeInterval
    public let animationTime: TimeInterval

    public let view: UIView?

    public init(
        autoHide: Bool = true,
        displayTime: TimeInterval = 4,
        animationTime: TimeInterval = 0.2,
        attachTo view: UIView? = nil
    ) {
        self.autoHide = autoHide
        self.displayTime = displayTime
        self.animationTime = animationTime
        self.view = view
    }
}

public class TextToastCustomView: UILabel {
    public init(title: String) {
        super.init(frame: CGRect.zero)

        self.text = title
        self.font = AppFont.with(type: .bold, size: 14)
        self.numberOfLines = 1

    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
