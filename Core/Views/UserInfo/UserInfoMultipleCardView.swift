//
//  UserInfoMultipleCardView.swift
//  Sportsbook
//
//  Created by André Lascas on 23/09/2022.
//

import UIKit

class UserInfoMultipleCardView: UIView {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var leftCardsStackView: UIStackView = Self.createLeftCardsStackView()
    private lazy var rightCardsStackView: UIStackView = Self.createRightCardsStackView()


    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {

        self.setupSubviews()

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.button

    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textSecondary

        self.leftCardsStackView.backgroundColor = .clear

        self.rightCardsStackView.backgroundColor = .clear
    }

    // MARK: Functions
    func configure(title: String, iconType: UserProfileCardIconType, sportsData: [UserProfileSportsData]) {

        self.titleLabel.text = title

        switch iconType {
        case .wins:
            self.iconImageView.image = UIImage(named: "user_wins_icon")
        case .highest:
            self.iconImageView.image = UIImage(named: "user_high_icon")
        case .accumulated:
            self.iconImageView.image = UIImage(named: "user_money_icon")
        case .percentage:
            self.iconImageView.image = UIImage(named: "user_percentage_icon")
        }

        for (key, sportData) in sportsData.enumerated() {
            let sportStatisticView = SportStatisticView()

            sportStatisticView.configure(sportId: "\(sportData.sportId)", sportPercentage: Float(sportData.percentage))

            if key % 2 == 0 {
                self.leftCardsStackView.addArrangedSubview(sportStatisticView)
            }
            else {
                self.rightCardsStackView.addArrangedSubview(sportStatisticView)
            }
        }

//        for i in 1...5 {
//            let sportStatisticView = SportStatisticView()
//
//            sportStatisticView.configure(sportId: "\(i)", sportPercentage: 0.2)
//
//            if i % 2 == 0 {
//                self.rightCardsStackView.addArrangedSubview(sportStatisticView)
//            }
//            else {
//                self.leftCardsStackView.addArrangedSubview(sportStatisticView)
//            }
//
//        }

    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension UserInfoMultipleCardView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "question_circle_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Card Title"
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createLeftCardsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createRightCardsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private func setupSubviews() {

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.leftCardsStackView)
        self.containerView.addSubview(self.rightCardsStackView)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 20),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 20),
            self.iconImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 15),
            // self.iconImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -15),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),

            self.leftCardsStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 40),
            self.leftCardsStackView.trailingAnchor.constraint(equalTo: self.containerView.centerXAnchor, constant: -4),
            self.leftCardsStackView.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 20),
            self.leftCardsStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -15),

            self.rightCardsStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -25),
            self.rightCardsStackView.leadingAnchor.constraint(equalTo: self.containerView.centerXAnchor, constant: 19),
            self.rightCardsStackView.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 20)
        ])
    }
}
