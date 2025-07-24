//
//  SearchFriendTableViewCell.swift
//  MultiBet
//
//  Created by André Lascas on 15/11/2024.
//

import UIKit
import Combine

class SearchFriendTableViewCell: UITableViewCell {

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
    private lazy var addFriendButton: UIButton = Self.createAddFriendButton()
    
    private lazy var successBaseView: UIView = Self.createSuccessBaseView()
    private lazy var successIconImageView: UIImageView = Self.createSuccessIconImageView()
    private lazy var successTitleLabel: UILabel = Self.createSuccessTitleLabel()
    private lazy var successSubtitleLabel: UILabel = Self.createSuccessSubtitleLabel()

    private var cancellables = Set<AnyCancellable>()

    var viewModel: AddFriendCellViewModel?
    
    var errorAddingFriend: (() -> Void)?
    var chatListNeedsReload: (() -> Void)?
    
    var isOnline: Bool = false {
        didSet {
            self.userStateBaseView.isHidden = !isOnline
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
    
    var addedFriendSuccess: Bool = false {
        didSet {
            self.successBaseView.isHidden = !addedFriendSuccess
        }
    }
    
    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
        
        self.addFriendButton.addTarget(self, action: #selector(didTapAddFriendButton), for: .primaryActionTriggered)
        
        self.addedFriendSuccess = false

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
        
        self.addedFriendSuccess = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.innerContainerView.layer.cornerRadius = CornerRadius.status

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconBaseView.clipsToBounds = true

        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2

        self.userStateView.layer.cornerRadius = self.userStateView.frame.height / 2
        
        self.successBaseView.layer.cornerRadius = CornerRadius.status
        
        self.successIconImageView.layer.cornerRadius = self.successIconImageView.frame.height / 2
                
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
        
        self.successBaseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.successIconImageView.backgroundColor = .clear
        
        self.successTitleLabel.textColor = UIColor.App.alertSuccess
        
        self.successSubtitleLabel.textColor = UIColor.App.textPrimary

    }
    
    func configure(viewModel: AddFriendCellViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.username
        
        self.successSubtitleLabel.text = localized("user_has_received_friend_request").replacingFirstOccurrence(of: "{username}", with: viewModel.username)
        
        if let avatar = viewModel.userContact.avatar {
            self.iconImageView.image = UIImage(named: avatar)
        }

        viewModel.isOnlinePublisher
            .sink(receiveValue: { [weak self] isOnline in
                self?.isOnline = isOnline
            })
            .store(in: &cancellables)
        
        viewModel.didAddFriend = { [weak self] friendAlertType in
            
            switch friendAlertType {
            case .success:
                self?.addedFriendSuccess = true
                self?.chatListNeedsReload?()
            case .error:
                self?.errorAddingFriend?()
            }
        }

    }
    
    // MARK: Actions
    @objc func didTapAddFriendButton(_ sender: UITapGestureRecognizer) {

        if let userId = self.viewModel?.userContact.id {
            self.viewModel?.addFriendFromId(id: userId)
        }
    }
}

extension SearchFriendTableViewCell {

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

    private static func createAddFriendButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "add_friend_icon")
        button.setImage(image, for: .normal)
        return button
    }
    
    private static func createSuccessBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 2
        view.isHidden = true
        return view
    }

    private static func createSuccessIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icon_active")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createSuccessTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("success")
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }
    
    private static func createSuccessSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("user_has_received_friend_request")
        label.font = AppFont.with(type: .bold, size: 14)
        return label
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

        self.innerContainerView.addSubview(self.addFriendButton)
        
        self.containerView.addSubview(self.successBaseView)
        
        self.successBaseView.addSubview(self.successIconImageView)
        self.successBaseView.addSubview(self.successTitleLabel)
        self.successBaseView.addSubview(self.successSubtitleLabel)

        self.initConstraints()

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
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.innerContainerView.centerYAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 35),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor, constant: 3),

            self.addFriendButton.leadingAnchor.constraint(equalTo: self.userInfoStackView.trailingAnchor, constant: 20),
            self.addFriendButton.trailingAnchor.constraint(equalTo: self.innerContainerView.trailingAnchor, constant: -15),
            self.addFriendButton.centerYAnchor.constraint(equalTo: self.innerContainerView.centerYAnchor),
            self.addFriendButton.widthAnchor.constraint(equalToConstant: 40),
            self.addFriendButton.heightAnchor.constraint(equalTo: self.addFriendButton.widthAnchor)

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

        // Success View
        NSLayoutConstraint.activate([
            self.successBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.successBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.successBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.successBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.successIconImageView.leadingAnchor.constraint(equalTo: self.innerContainerView.leadingAnchor, constant: 16),
            self.successIconImageView.widthAnchor.constraint(equalToConstant: 40),
            self.successIconImageView.heightAnchor.constraint(equalTo: self.successIconImageView.widthAnchor),
            self.successIconImageView.centerYAnchor.constraint(equalTo: self.innerContainerView.centerYAnchor),
            
            self.successTitleLabel.leadingAnchor.constraint(equalTo: self.successIconImageView.trailingAnchor, constant: 8),
            self.successTitleLabel.trailingAnchor.constraint(equalTo: self.successBaseView.trailingAnchor, constant: -16),
            self.successTitleLabel.topAnchor.constraint(equalTo: self.successIconImageView.topAnchor, constant: 0),
            
            self.successSubtitleLabel.leadingAnchor.constraint(equalTo: self.successIconImageView.trailingAnchor, constant: 8),
            self.successSubtitleLabel.trailingAnchor.constraint(equalTo: self.successBaseView.trailingAnchor, constant: -16),
            self.successSubtitleLabel.topAnchor.constraint(equalTo: self.successTitleLabel.bottomAnchor, constant: 4)
            
        ])
    }
}
