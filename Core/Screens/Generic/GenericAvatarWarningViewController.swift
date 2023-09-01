//
//  GenericAvatarWarningViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 30/08/2023.
//

import UIKit

class GenericAvatarWarningViewController: UIViewController {

    private lazy var containerGradientView: GradientView = Self.createContainerGradientView()
    private lazy var headerView: UIView = Self.createHeaderView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var avatarImageView: UIImageView = Self.createAvatarImageView()
    private lazy var shapeView: UIView = Self.createShapeView()
    private lazy var shadowShapeView: UIView = Self.createShadowShapeView()
    private lazy var infoContainerView: UIView = Self.createInfoContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()

    var didTapBackAction: (() -> Void)?
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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.backButton.isHidden = true

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.containerGradientView.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.containerGradientView.endPoint = CGPoint(x: 2.0, y: 0.0)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: self.shapeView.frame.size.height))
        path.addCurve(to: CGPoint(x: self.shapeView.frame.size.width, y: self.shapeView.frame.size.height),
                      controlPoint1: CGPoint(x: self.shapeView.frame.size.width*0.40, y: 0),
                      controlPoint2: CGPoint(x: self.shapeView.frame.size.width*0.60, y: 20))
        path.addLine(to: CGPoint(x: self.shapeView.frame.size.width, y: self.shapeView.frame.size.height))
        path.addLine(to: CGPoint(x: 0.0, y: self.shapeView.frame.size.height))
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor

        let shadowLayer = CAShapeLayer()
        shadowLayer.path = path.cgPath
        shadowLayer.fillColor = UIColor.black.cgColor

        shadowLayer.shadowOpacity = 0.5
        shadowLayer.shadowRadius = 5
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = .zero
        shadowLayer.shadowPath = path.cgPath

        self.shadowShapeView.layer.mask = shadowLayer
        self.shadowShapeView.layer.masksToBounds = false

        self.shapeView.layer.mask = shapeLayer
        self.shapeView.layer.masksToBounds = false

    }

    private func setupWithTheme() {
        self.containerGradientView.colors = [(UIColor(red: 1.0 / 255.0, green: 2.0 / 255.0, blue: 91.0 / 255.0, alpha: 1), NSNumber(0.0)),
                                              (UIColor(red: 64.0 / 255.0, green: 76.0 / 255.0, blue: 255.0 / 255.0, alpha: 1), NSNumber(1.0))]

        self.containerGradientView.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.containerGradientView.endPoint = CGPoint(x: 2.0, y: 0.0)

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.avatarImageView.backgroundColor = .clear

        self.shadowShapeView.backgroundColor = UIColor.App.backgroundPrimary

        self.shapeView.backgroundColor = UIColor.App.backgroundPrimary

        self.infoContainerView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.backButton)

    }

    func setTextInfo(title: String, subtitle: String) {

        self.titleLabel.text = title

        self.subtitleLabel.text = subtitle
    }

    @objc private func didTapCloseButton() {

        self.didTapCloseAction?()

    }

    @objc private func didTapBackButton() {

        self.didTapBackAction?()

    }

}

extension GenericAvatarWarningViewController {

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
        imageView.image = UIImage(named: "avatar_check")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createShapeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createShadowShapeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createInfoContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 30)
        label.text = "\(localized("hold_on"))!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.text = localized("payment_processing_hold")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("back"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.containerGradientView)

        self.containerGradientView.addSubview(self.headerView)

        self.headerView.addSubview(self.closeButton)

        self.containerGradientView.addSubview(self.avatarImageView)

        self.containerGradientView.addSubview(self.shadowShapeView)
        self.containerGradientView.addSubview(self.shapeView)

        self.view.addSubview(self.infoContainerView)

        self.infoContainerView.addSubview(self.titleLabel)
        self.infoContainerView.addSubview(self.subtitleLabel)
        self.infoContainerView.addSubview(self.backButton)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.containerGradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerGradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerGradientView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.containerGradientView.bottomAnchor.constraint(equalTo: self.view.centerYAnchor),

            self.headerView.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.containerGradientView.topAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 60),

            self.closeButton.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -34),
            self.closeButton.centerYAnchor.constraint(equalTo: self.headerView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40),

            self.avatarImageView.bottomAnchor.constraint(equalTo: self.shapeView.topAnchor, constant: 60),
            self.avatarImageView.centerXAnchor.constraint(equalTo: self.containerGradientView.centerXAnchor),

            self.shadowShapeView.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor),
            self.shadowShapeView.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor),
            self.shadowShapeView.bottomAnchor.constraint(equalTo: self.containerGradientView.bottomAnchor),
            self.shadowShapeView.heightAnchor.constraint(equalToConstant: 40),

            self.shapeView.leadingAnchor.constraint(equalTo: self.containerGradientView.leadingAnchor),
            self.shapeView.trailingAnchor.constraint(equalTo: self.containerGradientView.trailingAnchor),
            self.shapeView.bottomAnchor.constraint(equalTo: self.containerGradientView.bottomAnchor),
            self.shapeView.heightAnchor.constraint(equalToConstant: 40),

            self.infoContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.infoContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.infoContainerView.topAnchor.constraint(equalTo: self.containerGradientView.bottomAnchor),
            self.infoContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.infoContainerView.leadingAnchor, constant: 30),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.infoContainerView.trailingAnchor, constant: -30),
            self.titleLabel.topAnchor.constraint(equalTo: self.infoContainerView.topAnchor, constant: 10),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.infoContainerView.leadingAnchor, constant: 30),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.infoContainerView.trailingAnchor, constant: -30),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 12),

            self.backButton.leadingAnchor.constraint(equalTo: self.infoContainerView.leadingAnchor, constant: 30),
            self.backButton.trailingAnchor.constraint(equalTo: self.infoContainerView.trailingAnchor, constant: -30),
            self.backButton.bottomAnchor.constraint(equalTo: self.infoContainerView.bottomAnchor, constant: -50),
            self.backButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
}
