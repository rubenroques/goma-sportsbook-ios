//
//  GroupFriendManagementTableViewCell.swift
//  MultiBet
//
//  Created by André Lascas on 11/11/2024.
//

import UIKit
import Combine

class GroupFriendManagementTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var innerContainerView: UIView = Self.createInnerContainerView()
    private lazy var topBackgroundView: UIView = Self.createTopBackgroundView()
    private lazy var bottomBackgroundView: UIView = Self.createBottomBackgroundView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var userInfoStackView: UIStackView = Self.createUserInfoStackView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var userStateBaseView: UIView = Self.createUserStateBaseView()
    private lazy var userStateView: UIView = Self.createUserStateView()
    private lazy var deleteButton: UIButton = Self.createDeleteButton()

    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private var cancellables = Set<AnyCancellable>()

    var viewModel: GroupUserManagementCellViewModel?
    var didTapDeleteAction: (() -> Void)?

    // MARK: Public Properties
    var hasSeparatorLine: Bool = true {
        didSet {
            self.separatorLineView.isHidden = !hasSeparatorLine
        }
    }

    var isOnline: Bool = false {
        didSet {
//            self.userStateBaseView.isHidden = !isOnline
            self.userStateBaseView.isHidden = true
        }
    }
    
    var canDeleteUser: Bool = true {
        didSet {
            self.deleteButton.isHidden = !canDeleteUser
        }
    }
    
    var roundCornerType: RoundCornerType = .none {
        didSet {
            switch roundCornerType {
            case .all:
                self.topBackgroundView.backgroundColor = UIColor.App.backgroundSecondary
                self.bottomBackgroundView.backgroundColor = UIColor.App.backgroundSecondary
            case .top:
                self.topBackgroundView.backgroundColor = UIColor.App.backgroundSecondary
                self.bottomBackgroundView.backgroundColor = UIColor.App.backgroundPrimary
            case .bottom:
                self.topBackgroundView.backgroundColor = UIColor.App.backgroundPrimary
                self.bottomBackgroundView.backgroundColor = UIColor.App.backgroundSecondary
            case .none:
                self.topBackgroundView.backgroundColor = UIColor.App.backgroundPrimary
                self.bottomBackgroundView.backgroundColor = UIColor.App.backgroundPrimary
            }
            
        }
    }

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()


        self.setNeedsLayout()
        self.layoutIfNeeded()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""

        self.isOnline = false

        self.hasSeparatorLine = true
        
        self.canDeleteUser = true

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.innerContainerView.layer.cornerRadius = CornerRadius.status

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconBaseView.clipsToBounds = true

        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2

        self.userStateView.layer.cornerRadius = self.userStateView.frame.height / 2
                
    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundSecondary

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.innerContainerView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = .clear
        self.iconBaseView.layer.borderColor = UIColor.App.highlightTertiary.cgColor

        self.iconImageView.backgroundColor = .clear

        self.userInfoStackView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.userStateBaseView.backgroundColor = .clear

        self.userStateView.backgroundColor = UIColor.App.alertSuccess

        self.deleteButton.backgroundColor = .clear
        self.deleteButton.tintColor = UIColor.App.iconSecondary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

    }

    func configure(viewModel: GroupUserManagementCellViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.username
        
        if let avatar = viewModel.userContact.avatar {
            self.iconImageView.image = UIImage(named: avatar)
        }

        viewModel.isOnlinePublisher
            .sink(receiveValue: { [weak self] isOnline in
                self?.isOnline = isOnline
            })
            .store(in: &cancellables)

    }

    // MARK: Actions
    @objc func didTapDeleteButton() {
        self.didTapDeleteAction?()
    }
}

extension GroupFriendManagementTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }
    
    private static func createInnerContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }
    
    private static func createTopBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBottomBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 2
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "empty_user_image")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createUserInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@User"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private static func createUserStateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }

    private static func createUserStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createDeleteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "trash_icon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        return button
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)
        
        self.containerView.addSubview(self.topBackgroundView)
        self.containerView.addSubview(self.bottomBackgroundView)
        
        self.containerView.addSubview(self.innerContainerView)

        self.innerContainerView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.innerContainerView.addSubview(self.userInfoStackView)

        self.userInfoStackView.addArrangedSubview(self.titleLabel)
        self.userInfoStackView.addArrangedSubview(self.userStateBaseView)

        self.userStateBaseView.addSubview(self.userStateView)

        self.innerContainerView.addSubview(self.deleteButton)

        self.innerContainerView.addSubview(self.separatorLineView)

        self.initConstraints()

        self.deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .primaryActionTriggered)
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 62),
            
            self.topBackgroundView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.topBackgroundView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.topBackgroundView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.topBackgroundView.bottomAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            
            self.bottomBackgroundView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.bottomBackgroundView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.bottomBackgroundView.topAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.bottomBackgroundView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            
            self.innerContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.innerContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.innerContainerView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.innerContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.innerContainerView.leadingAnchor, constant: 25),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 30),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.innerContainerView.centerYAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 25),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor, constant: 3),

            self.deleteButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.userInfoStackView.trailingAnchor, constant: 8),
            self.deleteButton.trailingAnchor.constraint(equalTo: self.innerContainerView.trailingAnchor, constant: -25),
            self.deleteButton.widthAnchor.constraint(equalToConstant: 40),
            self.deleteButton.heightAnchor.constraint(equalTo: self.deleteButton.widthAnchor),
            self.deleteButton.centerYAnchor.constraint(equalTo: self.innerContainerView.centerYAnchor),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.deleteButton.trailingAnchor, constant: -10),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.innerContainerView.bottomAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)

        ])

        // Stackview
        NSLayoutConstraint.activate([
            self.userInfoStackView.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 15),
            self.userInfoStackView.centerYAnchor.constraint(equalTo: self.innerContainerView.centerYAnchor),
            self.userInfoStackView.heightAnchor.constraint(equalToConstant: 30),

            self.userStateBaseView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10),

            self.userStateView.widthAnchor.constraint(equalToConstant: 8),
            self.userStateView.heightAnchor.constraint(equalTo: self.userStateView.widthAnchor),
            self.userStateView.leadingAnchor.constraint(equalTo: self.userStateBaseView.leadingAnchor),
            self.userStateView.centerYAnchor.constraint(equalTo: self.userStateBaseView.centerYAnchor)
        ])

    }
}
