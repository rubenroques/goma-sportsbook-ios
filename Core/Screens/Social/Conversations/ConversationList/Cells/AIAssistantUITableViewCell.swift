//
//  AIAssistantUITableViewCell.swift
//  MultiBet
//
//  Created by André Lascas on 10/05/2024.
//

import UIKit

class AIAssistantUITableViewCell: UITableViewCell {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var titleIconImageView: UIImageView = Self.createTitleIconImageView()
    
    private var viewModel: PreviewChatCellViewModel?

    var didTapConversationAction: ((ConversationData) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()

        let tapConversationGesture = UITapGestureRecognizer(target: self, action: #selector(didTapConversationView))
        self.addGestureRecognizer(tapConversationGesture)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.baseView.layer.cornerRadius = CornerRadius.button

        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.width / 2

    }
    
    func setupWithTheme() {
        self.backgroundView?.backgroundColor = UIColor.App.backgroundSecondary
        self.backgroundColor = UIColor.App.backgroundSecondary

        self.baseView.backgroundColor = UIColor.App.backgroundPrimary
        self.baseView.layer.borderColor = UIColor.App.separatorLine.cgColor

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.titleIconImageView.backgroundColor = .clear
    }
    
    func configure(withViewModel viewModel: PreviewChatCellViewModel) {
        self.viewModel = viewModel

    }
    
    @objc func didTapConversationView() {
        if let viewModel = self.viewModel {
            self.didTapConversationAction?(viewModel.cellData)
        }    }
    
}

extension AIAssistantUITableViewCell {

    private static func createBaseView() -> UIView {
        let baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.layer.borderWidth = 1
        return baseView
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ai_assistant_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "GOMA AI Assistant"
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .left
        return label
    }
    
    private static func createTitleIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "robot_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.iconImageView)

        self.baseView.addSubview(self.titleLabel)
        
        self.baseView.addSubview(self.titleIconImageView)
        
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.heightAnchor.constraint(equalToConstant: 70),

            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 14),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -14),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 11),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 40),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 12),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),

            self.titleIconImageView.leadingAnchor.constraint(lessThanOrEqualTo: self.titleLabel.trailingAnchor, constant: 5),
            self.titleIconImageView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.titleIconImageView.widthAnchor.constraint(equalToConstant: 20),
            self.titleIconImageView.heightAnchor.constraint(equalTo: self.titleIconImageView.widthAnchor)
        ])
    }

}
