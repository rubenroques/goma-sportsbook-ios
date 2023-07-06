//
//  GenericSuccessViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 21/06/2023.
//

import UIKit
import Lottie

class GenericSuccessViewController: UIViewController {

    private lazy var containerGradientView: GradientView = Self.createContainerGradientView()
    private lazy var headerView: UIView = Self.createHeaderView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var successAnimationView: LottieAnimationView = Self.createSuccessAnimationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    var hasContinueFlow: Bool = false

    var didTapContinueAction: (() -> Void)?
    var didTapCloseAction: (() -> Void)?

    init() {

        super.init(nibName: nil, bundle: nil)

    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)

        self.hasContinueFlow = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.successAnimationView.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    private func setupWithTheme() {
        self.containerGradientView.colors = [(UIColor(red: 1.0 / 255.0, green: 2.0 / 255.0, blue: 91.0 / 255.0, alpha: 1), NSNumber(0.0)),
                                              (UIColor(red: 64.0 / 255.0, green: 76.0 / 255.0, blue: 255.0 / 255.0, alpha: 1), NSNumber(1.0))]
        
        self.containerGradientView.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.containerGradientView.endPoint = CGPoint(x: 2.0, y: 0.0)

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.successAnimationView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.buttonTextPrimary

        self.subtitleLabel.textColor = UIColor.App.buttonTextPrimary

        StyleHelper.styleButton(button: self.continueButton)

    }

    func setTextInfo(title: String, subtitle: String) {

        self.titleLabel.text = title

        self.subtitleLabel.text = subtitle
    }

    @objc private func didTapCloseButton() {

        self.didTapCloseAction?()

    }

    @objc private func didTapContinueButton() {

        self.didTapContinueAction?()

    }

}

extension GenericSuccessViewController {

    private static func createContainerGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createSuccessAnimationView() -> LottieAnimationView {
        let animationView = LottieAnimationView()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit

        let starAnimation = LottieAnimation.named("success_thumbs_up")

        animationView.animation = starAnimation
        animationView.loopMode = .playOnce

        return animationView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 30)
        label.text = "\(localized("success"))!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.text = localized("first_deposit_success")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createContinueButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("continue_"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.containerGradientView)

        self.containerGradientView.addSubview(self.headerView)

        self.headerView.addSubview(self.closeButton)

        self.containerGradientView.addSubview(self.successAnimationView)
        self.containerGradientView.addSubview(self.titleLabel)
        self.containerGradientView.addSubview(self.subtitleLabel)
        self.containerGradientView.addSubview(self.continueButton)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.containerGradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerGradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerGradientView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.containerGradientView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.headerView.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.containerGradientView.topAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 60),

            self.closeButton.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -34),
            self.closeButton.centerYAnchor.constraint(equalTo: self.headerView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40),

            self.successAnimationView.centerXAnchor.constraint(equalTo: self.containerGradientView.centerXAnchor),
            self.successAnimationView.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor, constant: 30),
            self.successAnimationView.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor, constant: -30),
            self.successAnimationView.heightAnchor.constraint(equalTo: self.successAnimationView.widthAnchor, multiplier: 0.8),
            self.successAnimationView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 40),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor, constant: 30),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor, constant: -30),
            self.titleLabel.topAnchor.constraint(equalTo: self.successAnimationView.bottomAnchor, constant: 35),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor, constant: 30),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor, constant: -30),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 12),

            self.continueButton.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor, constant: 30),
            self.continueButton.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor, constant: -30),
            self.continueButton.bottomAnchor.constraint(equalTo: self.containerGradientView.bottomAnchor, constant: -50),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
}
