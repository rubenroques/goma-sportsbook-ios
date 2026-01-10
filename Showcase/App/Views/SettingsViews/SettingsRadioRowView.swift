//
//  SettingsRadioRowView.swift
//  Sportsbook
//
//  Created by André Lascas on 18/02/2022.
//

import UIKit
import Combine

class SettingsRadioRowView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var radioButtonImageView: UIImageView = Self.createRadioButtonImageView()

    // MARK: Public Properties
    var hasSeparatorLineView: Bool = false {
        didSet {
            if hasSeparatorLineView {
                self.separatorLineView.isHidden = false
            }
            else {
                self.separatorLineView.isHidden = true
            }
        }
    }

    var isChecked: Bool = false {
        didSet {
            if isChecked {

                self.radioButtonImageView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
                self.radioButtonImageView.backgroundColor = UIColor.App.highlightPrimary
                self.radioButtonImageView.image = (UIImage(named: "white_dot_icon"))

            }
            else {

                self.radioButtonImageView.layer.borderColor = UIColor.App.separatorLine.cgColor
                self.radioButtonImageView.backgroundColor = UIColor.App.backgroundSecondary
                self.radioButtonImageView.image = nil

            }
        }
    }

    var viewId: Int = 0
    var didTapView: ((Bool) -> Void)?

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {

        self.isChecked = false
        self.hasSeparatorLineView = false

        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(self.tappedView))
        self.addGestureRecognizer(gestureTap)

        // Round imageView
        radioButtonImageView.layoutIfNeeded()
        radioButtonImageView.layer.masksToBounds = true
        radioButtonImageView.layer.cornerRadius = radioButtonImageView.frame.width/2
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.radioButtonImageView.layer.borderColor = UIColor.App.separatorLine.cgColor
        self.radioButtonImageView.backgroundColor = UIColor.App.backgroundSecondary

    }

    func setTitle(title: String) {
        self.titleLabel.text = title
    }
}

//
// MARK: Action
//
extension SettingsRadioRowView {
    @objc func tappedView(sender: UITapGestureRecognizer) {

        if !isChecked {
            isChecked = true
        }

        didTapView?(isChecked)
    }
}

//
// MARK: Subviews initialization and setup
//
extension SettingsRadioRowView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("title")
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRadioButtonImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderWidth = 2.0
        imageView.image = nil
        imageView.contentMode = .center
        return imageView
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.separatorLineView)
        self.containerView.addSubview(self.radioButtonImageView)

        self.initConstraints()

    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 60),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.radioButtonImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.radioButtonImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.radioButtonImageView.widthAnchor.constraint(equalToConstant: 20),
            self.radioButtonImageView.heightAnchor.constraint(equalToConstant: 20),

            self.separatorLineView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)

        ])

    }

}
