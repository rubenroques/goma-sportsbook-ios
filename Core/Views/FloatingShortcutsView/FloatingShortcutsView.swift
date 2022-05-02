//
//  FloatingShortcutsView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/04/2022.
//

import UIKit

class FloatingShortcutsView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    
    private lazy var betslipButtonView: UIView = Self.createBetslipButtonView()
    private lazy var chatButtonView: UIView = Self.createChatButtonView()
    private lazy var betslipCountLabel: UILabel = Self.createBetslipCountLabel()

    init() {
        super.init(frame: .zero)

        self.commonInit()
    }

    @available(iOS, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.setupSubviews()
        self.setupWithTheme()

        self.addAnimations()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = .red

        self.betslipCountLabel.backgroundColor = UIColor.App.alertError
        self.betslipButtonView.backgroundColor = UIColor.App.highlightPrimary
        self.betslipCountLabel.textColor = UIColor.App.buttonTextPrimary

        self.chatButtonView.backgroundColor = UIColor.App.buttonActiveHoverSecondary
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2

        self.chatButtonView.layer.cornerRadius = self.chatButtonView.frame.height / 2
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
    }

    func addAnimations() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.betslipCountLabel.layer.add(rotation, forKey: "rotationAnimation")

//        UIView.animate(withDuration: 3.0, delay: 5, options: UIView.AnimationOptions.beginFromCurrentState,
//                       animations: {
//            self.betslipCountLabel.backgroundColor = .orange
//        }, completion: { finished in
//            UIView.animate(withDuration: 3.0) {
//                self.betslipCountLabel.backgroundColor = UIColor.App.alertError
//            }
//        })
        
    }
}

extension FloatingShortcutsView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBetslipButtonView() -> UIView {
        let betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "betslip_button_icon")
        betslipButtonView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            betslipButtonView.widthAnchor.constraint(equalToConstant: 56),
            betslipButtonView.widthAnchor.constraint(equalTo: betslipButtonView.heightAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: betslipButtonView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: betslipButtonView.centerYAnchor),
        ])

        return betslipButtonView
    }

    private static func createChatButtonView() -> UIView {
        let betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "chat_float_icon")
        betslipButtonView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            betslipButtonView.widthAnchor.constraint(equalToConstant: 46),
            betslipButtonView.widthAnchor.constraint(equalTo: betslipButtonView.heightAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: betslipButtonView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: betslipButtonView.centerYAnchor),
        ])

        return betslipButtonView
    }

    private static func createBetslipCountLabel() -> UILabel {
        let betslipCountLabel = UILabel()
        betslipCountLabel.translatesAutoresizingMaskIntoConstraints = false
        betslipCountLabel.textColor = UIColor.App.textPrimary
        betslipCountLabel.backgroundColor = UIColor.App.bubblesPrimary
        betslipCountLabel.font = AppFont.with(type: .semibold, size: 10)
        betslipCountLabel.textAlignment = .center
        betslipCountLabel.clipsToBounds = true
        betslipCountLabel.layer.masksToBounds = true
        betslipCountLabel.text = "0"
        return betslipCountLabel
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.betslipButtonView.addSubview(self.betslipCountLabel)

        self.containerView.addSubview(self.betslipButtonView)
        self.containerView.addSubview(self.chatButtonView)

        // Initialize constraints
        self.initConstraints()

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.chatButtonView.topAnchor, constant: -1),
            self.containerView.leadingAnchor.constraint(equalTo: self.betslipButtonView.leadingAnchor, constant: -1),
        ])

        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -1),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -1),

            self.betslipCountLabel.widthAnchor.constraint(equalToConstant: 20),
            self.betslipCountLabel.widthAnchor.constraint(equalTo: self.betslipCountLabel.heightAnchor),
        ])

        NSLayoutConstraint.activate([
            self.chatButtonView.centerXAnchor.constraint(equalTo: self.betslipButtonView.centerXAnchor),
            self.chatButtonView.bottomAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -10),
        ])

    }

}
