//
//  OptionRadioView.swift
//  Sportsbook
//
//  Created by André Lascas on 17/05/2023.
//

import UIKit

class OptionRadioView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var radioImageView: UIImageView = Self.createRadioImageView()

    var isChecked: Bool = false {
        didSet {
            if isChecked {
                self.radioImageView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
                self.radioImageView.backgroundColor = UIColor.App.highlightPrimary
                self.radioImageView.image = (UIImage(named: "white_dot_icon"))
                let templateImage = self.radioImageView.image?.withRenderingMode(.alwaysTemplate)
                self.radioImageView.image = templateImage
                self.radioImageView.tintColor = UIColor.App.buttonTextPrimary
            }
            else {
                self.radioImageView.layer.borderColor = UIColor.App.separatorLine.cgColor
                self.radioImageView.backgroundColor = UIColor.App.backgroundSecondary
                self.radioImageView.image = nil
            }
        }
    }

    var didTapView: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()

        self.commonInit()

        self.setupWithTheme()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupSubviews()

        self.commonInit()

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = .clear

        self.radioImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

    }

    private func commonInit() {

        self.isChecked = false

        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(self.tappedView))
        self.addGestureRecognizer(gestureTap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.radioImageView.layer.cornerRadius = self.radioImageView.frame.width/2
        self.radioImageView.layer.borderWidth = 2.0

        self.radioImageView.layer.borderColor = UIColor.App.separatorLine.cgColor
        self.radioImageView.backgroundColor = UIColor.App.backgroundSecondary

        self.radioImageView.image = nil
        self.radioImageView.contentMode = .center

    }

    func setTitle(title: String) {
        self.titleLabel.text = title
    }

    func setChecked(_ isChecked: Bool) {

        self.isChecked = isChecked

    }

    @objc func tappedView(sender: UITapGestureRecognizer) {

        if !isChecked {
            isChecked = true
        }

        didTapView?(isChecked)
    }

}

extension OptionRadioView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 12)
        label.text = "Title"
        return label
    }

    private static func createRadioImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = nil
        return imageView
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.radioImageView)

        self.initConstraints()

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.radioImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 4),
            self.radioImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 4),
            self.radioImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -4),
            self.radioImageView.widthAnchor.constraint(equalToConstant: 17),
            self.radioImageView.heightAnchor.constraint(equalTo: self.radioImageView.widthAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.radioImageView.trailingAnchor, constant: 7),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -4),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.radioImageView.centerYAnchor)

        ])

    }
}

