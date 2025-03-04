//
//  RegisterSuccessViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 13/09/2023.
//

import UIKit
import Kingfisher

class RegisterSuccessViewController: UIViewController {

    private lazy var containerGradientView: GradientView = Self.createContainerGradientView()
    private lazy var headerView: UIView = Self.createHeaderView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var avatarImageView: UIImageView = Self.createAvatarImageView()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    var hasContinueFlow: Bool = false

    var didTapContinueAction: (() -> Void)?
    var didTapCloseAction: (() -> Void)?
    
    var avatarHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let percentage: CGFloat = 0.6 // Adjust this value as needed (e.g., 0.2 for 20%)
        let imageViewHeight = screenHeight * percentage
        return imageViewHeight
    }
    
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

        self.closeButton.isHidden = true
        
        // CAN'T FETCH FROM WEBSITE ATM
//        if let avatarUrl = URL(string: "\(TargetVariables.clientBaseUrl)/public/assets/imgs/success-reg-portrait_2.png") {
//            
//            self.avatarImageView.kf.setImage(with: avatarUrl)
//        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.containerGradientView.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.containerGradientView.endPoint = CGPoint(x: 2.0, y: 0.0)

    }

    private func setupWithTheme() {
        self.containerGradientView.colors = [(UIColor.App.backgroundHeaderGradient1, NSNumber(0.0)),
                                              (UIColor.App.backgroundHeaderGradient2, NSNumber(1.0))]

        self.containerGradientView.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.containerGradientView.endPoint = CGPoint(x: 2.0, y: 0.0)

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.avatarImageView.backgroundColor = .clear

        StyleHelper.styleButton(button: self.continueButton)

    }

    @objc private func didTapCloseButton() {

        self.didTapCloseAction?()

    }

    @objc private func didTapContinueButton() {

        self.didTapContinueAction?()

    }
}

extension RegisterSuccessViewController {

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

    private static func createAvatarImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "register_sucess_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
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

        self.containerGradientView.addSubview(self.avatarImageView)

        self.containerGradientView.addSubview(self.continueButton)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.containerGradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerGradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerGradientView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.containerGradientView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.headerView.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.containerGradientView.topAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 60),

            self.closeButton.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -34),
            self.closeButton.centerYAnchor.constraint(equalTo: self.headerView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40),

          self.avatarImageView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 40),
            self.avatarImageView.heightAnchor.constraint(equalToConstant: self.avatarHeight),
            self.avatarImageView.bottomAnchor.constraint(equalTo: self.continueButton.topAnchor),
            self.avatarImageView.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor, constant: 15),
            self.avatarImageView.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor, constant: -15),
            // self.avatarImageView.centerXAnchor.constraint(equalTo: self.containerGradientView.centerXAnchor),

            self.continueButton.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor, constant: 30),
            self.continueButton.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor, constant: -30),
            self.continueButton.bottomAnchor.constraint(lessThanOrEqualTo: self.containerGradientView.bottomAnchor, constant: -50),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
}
