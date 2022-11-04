//
//  SelectChatroomTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 05/07/2022.
//

import UIKit
import Combine

class SelectChatroomCellViewModel {

    private var cancellables = Set<AnyCancellable>()

    var chatroomData: ChatroomData
    var users: [GomaFriend]
    var isCheckboxSelected: Bool
    var isOnlinePublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init(chatroomData: ChatroomData) {
        self.chatroomData = chatroomData

        self.users = chatroomData.users

        self.isCheckboxSelected = false

        self.setupPublishers()
    }

    private func setupPublishers() {
        if let onlineUsersPublisher = Env.gomaSocialClient.onlineUsersPublisher() {

            onlineUsersPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] onlineUsersResponse in
                    guard let self = self else {return}

                    let isUserOnline = onlineUsersResponse.values.contains { value -> Bool in

                        if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {
                            for user in self.users {
                                if user.id != loggedUserId {
                                    if value.users.contains("\(user.id)") {
                                        return true
                                    }
                                }
                            }
                        }

                        return false
                    }

                    if isUserOnline {

                        self.isOnlinePublisher.send(true)

                    }
                    else {
                        self.isOnlinePublisher.send(false)
                    }

                })
                .store(in: &cancellables)
        }
    }

    func getChatroomName() -> String {

        if self.chatroomData.chatroom.type == "individual",
           let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {
            for user in self.users {
                if user.id != loggedUserId {
                    return user.username
                }
            }
        }

        return self.chatroomData.chatroom.name

    }

    func getChatroomUsernames() -> String {
        var usernames = ""
        for (index, user) in self.users.enumerated() {
            if index == self.users.count - 1 {
                usernames += "\(user.username)"
            }
            else {
                usernames += "\(user.username), "
            }
        }

        return usernames
    }

    func getGroupInitials() -> String {
        var initials = ""

        for letter in self.chatroomData.chatroom.name {
            if letter.isUppercase {
                if initials.count < 2 {
                    initials = "\(initials)\(letter)"
                }
            }
        }

        if initials == "" {
            if let firstChar = self.chatroomData.chatroom.name.first {
                initials = "\(firstChar.uppercased())"
            }
        }

        return initials
    }
}

class SelectChatroomTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconView: UIView = Self.createIconView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var iconGroupInitials: UILabel = Self.createIconGroupInitials()
    private lazy var chatroomInfoStackView: UIStackView = Self.createChatroomInfoStackView()
    private lazy var userInfoStackView: UIStackView = Self.createUserInfoStackView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var userStateBaseView: UIView = Self.createUserStateBaseView()
    private lazy var userStateView: UIView = Self.createUserStateView()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var checkboxBaseView: UIView = Self.createCheckboxBaseView()
    private lazy var checkboxImageView: UIImageView = Self.createCheckboxImageView()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private var cancellables = Set<AnyCancellable>()

    var viewModel: SelectChatroomCellViewModel?
    var didTapCheckboxAction: (() -> Void)?

    // MARK: Public Properties
    var isCheckboxSelected: Bool = false {
        didSet {
            if isCheckboxSelected {
                self.checkboxImageView.image = UIImage(named: "checkbox_selected_icon")
            }
            else {
                self.checkboxImageView.image = UIImage(named: "checkbox_unselected_icon")
            }
        }
    }

    var hasSeparatorLine: Bool = true {
        didSet {
            self.separatorLineView.isHidden = !hasSeparatorLine
        }
    }

    var isOnline: Bool = false {
        didSet {
            self.userStateBaseView.isHidden = !isOnline
        }
    }

    var isGroup: Bool = false {
        didSet {
            self.subtitleLabel.isHidden = !isGroup
            self.iconImageView.isHidden = isGroup
            self.iconGroupInitials.isHidden = !isGroup
        }
    }

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.isCheckboxSelected = false

        self.setNeedsLayout()
        self.layoutIfNeeded()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.isCheckboxSelected = false

        self.titleLabel.text = localized("empty_value")

        self.subtitleLabel.text = localized("empty_value")

        self.isOnline = false

        self.hasSeparatorLine = true

        self.isGroup = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconBaseView.layer.masksToBounds = true

        self.iconView.layer.cornerRadius = self.iconView.frame.height / 2
        self.iconView.layer.masksToBounds = true

        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
        self.iconImageView.layer.masksToBounds = true

        self.userStateView.layer.cornerRadius = self.userStateView.frame.height / 2
    }

    func setupWithTheme() {

        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconBaseView.backgroundColor = UIColor.App.highlightSecondary

        self.iconView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconImageView.backgroundColor = UIColor.App.backgroundTertiary

        self.iconGroupInitials.textColor = UIColor.App.highlightSecondary

        self.chatroomInfoStackView.backgroundColor = UIColor.App.backgroundPrimary

        self.userInfoStackView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textSecondary

        self.userStateBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.userStateView.backgroundColor = UIColor.App.alertSuccess

        self.checkboxBaseView.backgroundColor = .clear

        self.checkboxImageView.backgroundColor = .clear

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

    }

    func configure(viewModel: SelectChatroomCellViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.getChatroomName()

        if viewModel.chatroomData.chatroom.type == "group" {
            self.subtitleLabel.text = viewModel.getChatroomUsernames()
            self.iconGroupInitials.text = viewModel.getGroupInitials()
            self.isGroup = true
        }
        else {
            self.isGroup = false
        }

        self.isCheckboxSelected = viewModel.isCheckboxSelected

        viewModel.isOnlinePublisher
            .sink(receiveValue: { [weak self] isOnline in
                self?.isOnline = isOnline
            })
            .store(in: &cancellables)

    }

    // MARK: Actions
    @objc func didTapCheckbox(_ sender: UITapGestureRecognizer) {

        if let viewModel = self.viewModel {
            viewModel.isCheckboxSelected = !self.isCheckboxSelected
            self.isCheckboxSelected = viewModel.isCheckboxSelected
            self.didTapCheckboxAction?()
        }

    }
}

extension SelectChatroomTableViewCell {

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createIconGroupInitials() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "G"
        label.font = AppFont.with(type: .bold, size: 18)
        return label
    }

    private static func createChatroomInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
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

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@User"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private static func createCheckboxBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCheckboxImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "checkbox_unselected_icon")
        imageView.contentMode = .scaleToFill
        return imageView
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconView)

        self.iconView.addSubview(self.iconImageView)
        self.iconView.addSubview(self.iconGroupInitials)

        self.contentView.addSubview(self.chatroomInfoStackView)

        self.chatroomInfoStackView.addArrangedSubview(self.userInfoStackView)

        self.userInfoStackView.addArrangedSubview(self.titleLabel)
        self.userInfoStackView.addArrangedSubview(self.userStateBaseView)

        self.userStateBaseView.addSubview(self.userStateView)

        self.chatroomInfoStackView.addArrangedSubview(self.subtitleLabel)

        self.contentView.addSubview(self.checkboxBaseView)

        self.checkboxBaseView.addSubview(self.checkboxImageView)

        self.contentView.addSubview(self.separatorLineView)

        self.initConstraints()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapCheckbox(_:)))
        self.checkboxBaseView.addGestureRecognizer(tapGesture)

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.iconBaseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            self.iconView.widthAnchor.constraint(equalToConstant: 38),
            self.iconView.heightAnchor.constraint(equalTo: self.iconView.widthAnchor),
            self.iconView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

            self.iconImageView.widthAnchor.constraint(equalToConstant: 38),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerXAnchor.constraint(equalTo: self.iconView.centerXAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.iconView.centerYAnchor),

            self.iconGroupInitials.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconGroupInitials.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

//            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 10),
//            self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            self.checkboxBaseView.leadingAnchor.constraint(equalTo: self.chatroomInfoStackView.trailingAnchor, constant: 20),
            self.checkboxBaseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            self.checkboxBaseView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.checkboxBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.checkboxBaseView.heightAnchor.constraint(equalTo: self.checkboxBaseView.widthAnchor),

            self.checkboxImageView.widthAnchor.constraint(equalToConstant: 20),
            self.checkboxImageView.heightAnchor.constraint(equalTo: self.checkboxImageView.widthAnchor),
            self.checkboxImageView.centerXAnchor.constraint(equalTo: self.checkboxBaseView.centerXAnchor),
            self.checkboxImageView.centerYAnchor.constraint(equalTo: self.checkboxBaseView.centerYAnchor),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.checkboxBaseView.trailingAnchor, constant: -10),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)

        ])

        // Stackview
        NSLayoutConstraint.activate([

            self.chatroomInfoStackView.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 15),
            self.chatroomInfoStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.chatroomInfoStackView.heightAnchor.constraint(equalToConstant: 40),

            self.userInfoStackView.leadingAnchor.constraint(equalTo: self.chatroomInfoStackView.trailingAnchor),
            self.userInfoStackView.heightAnchor.constraint(equalToConstant: 20),

            self.userStateBaseView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10),

            self.userStateView.widthAnchor.constraint(equalToConstant: 8),
            self.userStateView.heightAnchor.constraint(equalTo: self.userStateView.widthAnchor),
            self.userStateView.leadingAnchor.constraint(equalTo: self.userStateBaseView.leadingAnchor),
            self.userStateView.centerYAnchor.constraint(equalTo: self.userStateBaseView.centerYAnchor)
        ])

    }
}

