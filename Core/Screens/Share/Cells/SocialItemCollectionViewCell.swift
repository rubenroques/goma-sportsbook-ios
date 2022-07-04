//
//  SocialItemCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2022.
//

import UIKit

struct SocialItemCellViewModel {

    private var chatroomData: ChatroomData

    init(chatroomData: ChatroomData) {
        self.chatroomData = chatroomData
    }

    func getChatroomId() -> Int {
        return self.chatroomData.chatroom.id
    }

    func getChatroomName() -> String {
        return self.chatroomData.chatroom.name
    }

    func getChatroomType() -> String {
        return self.chatroomData.chatroom.type
    }

    func getChatroomUsername() -> String {
        for user in self.chatroomData.users {

            if let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {

                if user.id != loggedUserId {
                    return "\(user.username)"
                }
            }
        }

        return ""
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

class SocialItemCollectionViewCell: UICollectionViewCell {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconView: UIView = Self.createIconView()
    private lazy var iconIdentifierLabel: UILabel = Self.createIconIdentifierLabel()
    private lazy var iconUserImageView: UIImageView = Self.createIconUserImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private var viewModel: SocialItemCellViewModel?

    var isChatGroup: Bool = false {
        didSet {
            self.iconIdentifierLabel.isHidden = !isChatGroup
            self.iconUserImageView.isHidden = isChatGroup
        }
    }

    var isMoreOptionTheme: Bool = false {
        didSet {
            if isMoreOptionTheme {
                self.iconBaseView.backgroundColor = UIColor.App.highlightPrimary
                self.iconIdentifierLabel.textColor = UIColor.App.highlightPrimary
            }
            else {
                self.iconBaseView.backgroundColor = UIColor.App.highlightSecondary
                self.iconIdentifierLabel.textColor = UIColor.App.highlightSecondary
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapItem))
        self.contentView.addGestureRecognizer(tapGesture)

        self.isMoreOptionTheme = false
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.viewModel = nil

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconBaseView.layer.masksToBounds = true

        self.iconView.layer.cornerRadius = self.iconView.frame.height / 2
        self.iconView.layer.masksToBounds = true

        self.iconUserImageView.layer.cornerRadius = self.iconUserImageView.frame.height / 2
        self.iconUserImageView.layer.masksToBounds = true

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.iconBaseView.backgroundColor = UIColor.App.highlightSecondary

        self.iconView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconUserImageView.backgroundColor = UIColor.App.backgroundTertiary

        self.iconIdentifierLabel.textColor = UIColor.App.highlightSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: Functions

    func configure(withViewModel viewModel: SocialItemCellViewModel) {

        self.viewModel = viewModel

        if viewModel.getChatroomType() == "individual" {
            self.titleLabel.text = viewModel.getChatroomUsername()
            self.isChatGroup = false
        }
        else {
            self.iconIdentifierLabel.text = viewModel.getGroupInitials()
            self.titleLabel.text = viewModel.getChatroomName()
            self.isChatGroup = true
        }

        self.isMoreOptionTheme = false
    }

    func simpleConfigure() {
        self.iconIdentifierLabel.text = "..."
        self.titleLabel.text = localized("more")
        self.isChatGroup = true
        self.isMoreOptionTheme = true
    }

    // MARK: Actions
    @objc func didTapItem() {
        if let viewModel = self.viewModel {
            print("TAPPED SOCIAL CHAT: \(viewModel.getChatroomName())")
        }

    }
}

extension SocialItemCollectionViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

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

    private static func createIconIdentifierLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "C"
        label.font = AppFont.with(type: .bold, size: 18)
        return label
    }

    private static func createIconUserImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "Social"
        label.font = AppFont.with(type: .semibold, size: 14)
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconView)

        self.iconView.addSubview(self.iconIdentifierLabel)
        self.iconView.addSubview(self.iconUserImageView)

        self.containerView.addSubview(self.titleLabel)

        self.initConstraints()

        self.containerView.layoutIfNeeded()
        self.containerView.layoutSubviews()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.iconBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),
            self.iconBaseView.heightAnchor.constraint(equalToConstant: 50),
            self.iconBaseView.widthAnchor.constraint(equalTo: self.iconBaseView.heightAnchor),
            self.iconBaseView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),

            self.iconView.widthAnchor.constraint(equalToConstant: 47),
            self.iconView.heightAnchor.constraint(equalTo: self.iconView.widthAnchor),
            self.iconView.centerXAnchor.constraint(equalTo: self.iconBaseView.centerXAnchor),
            self.iconView.centerYAnchor.constraint(equalTo: self.iconBaseView.centerYAnchor),

            self.iconIdentifierLabel.centerXAnchor.constraint(equalTo: self.iconView.centerXAnchor),
            self.iconIdentifierLabel.centerYAnchor.constraint(equalTo: self.iconView.centerYAnchor),

            self.iconUserImageView.centerXAnchor.constraint(equalTo: self.iconView.centerXAnchor),
            self.iconUserImageView.centerYAnchor.constraint(equalTo: self.iconView.centerYAnchor),
            self.iconUserImageView.widthAnchor.constraint(equalToConstant: 47),
            self.iconUserImageView.heightAnchor.constraint(equalTo: self.iconUserImageView.widthAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.titleLabel.topAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor, constant: 8),
//            self.titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -8)

        ])
    }
}
