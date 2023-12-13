//
//  TextSectionView.swift
//  Sportsbook
//
//  Created by André Lascas on 12/12/2023.
//

import UIKit

class TextSectionView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var arrowIconImageView: UIImageView = Self.createArrowIconImageView()

    var isCollapsed: Bool = false {
        didSet {
            if isCollapsed {
                self.arrowIconImageView.image = UIImage(named: "arrow_collapse_icon")
            }
            else {
                self.arrowIconImageView.image = UIImage(named: "arrow_expand_icon")
            }
        }
    }

    var didTappedArrow: ((Bool) -> Void)?

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

        let arrowTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapArrowIcon))
        self.containerView.addGestureRecognizer(arrowTap)

    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = .clear

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.arrowIconImageView.backgroundColor = .clear

    }
    
    func configure(title: String, icon: String) {
        self.titleLabel.text = title
        
        self.iconImageView.image = UIImage(named: icon)
    }

    // MARK: Actions

    @objc func didTapArrowIcon() {
        self.isCollapsed = !self.isCollapsed
        self.didTappedArrow?(self.isCollapsed)
    }
}

extension TextSectionView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "roman_1_icon")
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

    
    private static func createArrowIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "arrow_expand_icon")
        imageView.contentMode = .center
        return imageView
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.arrowIconImageView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.iconImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -10),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 40),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),

            self.arrowIconImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.arrowIconImageView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 10),
            self.arrowIconImageView.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),
            self.arrowIconImageView.widthAnchor.constraint(equalToConstant: 25),
            self.arrowIconImageView.heightAnchor.constraint(equalTo: self.arrowIconImageView.widthAnchor)

        ])

    }

}
