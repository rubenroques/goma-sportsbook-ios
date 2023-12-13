//
//  TextSubsectionView.swift
//  Sportsbook
//
//  Created by André Lascas on 13/12/2023.
//

import UIKit

class TextSubsectionView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

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

    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func commonInit() {
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = .clear

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

    }
    
    func configure(title: String, icon: String) {
        self.titleLabel.text = title
        
        self.iconImageView.image = UIImage(named: icon)
    }
}

extension TextSubsectionView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "arrow_section_icon")
        imageView.contentMode = .center
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("lorem_ipsum")
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.titleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 5),
            self.iconImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -10),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 40),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 5),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -5),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),

        ])

    }

}
