//
//  CardOptionRadioView.swift
//  Sportsbook
//
//  Created by André Lascas on 07/06/2023.
//

import UIKit

class CardOptionRadioView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var radioImageView: UIImageView = Self.createRadioImageView()
    private lazy var separatorView: UIView = Self.createSeparatorView()

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

    var hasSeparator: Bool = false {
        didSet {
            self.separatorView.isHidden = !hasSeparator
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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.radioImageView.layer.borderWidth = 2.0
        self.radioImageView.layer.cornerRadius = self.radioImageView.frame.size.width / 2

    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = .clear

        self.radioImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.separatorView.backgroundColor = UIColor.App.separatorLine

    }

    private func commonInit() {

        self.isChecked = false

        self.hasSeparator = false

        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(self.tappedView))
        self.addGestureRecognizer(gestureTap)

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

extension CardOptionRadioView {

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
        imageView.contentMode = .center
        imageView.image = nil
        return imageView
    }

    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.radioImageView)

        self.containerView.addSubview(self.separatorView)

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
            self.radioImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 14),
            self.radioImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -14),
            self.radioImageView.widthAnchor.constraint(equalToConstant: 17),
            self.radioImageView.heightAnchor.constraint(equalTo: self.radioImageView.widthAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.radioImageView.trailingAnchor, constant: 10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -4),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.radioImageView.centerYAnchor),

            self.separatorView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.separatorView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.separatorView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.separatorView.heightAnchor.constraint(equalToConstant: 1)

        ])

    }
}
