//
//  PromotionTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 11/03/2025.
//

import UIKit

class PromotionCellViewModel {
    
    var promotionInfo: PromotionInfo
    
    init(promotionInfo: PromotionInfo) {
        self.promotionInfo = promotionInfo
    }
}

class PromotionTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var backgroundImageView: UIImageView = Self.createBackgroundImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()

    var didTapPromotionAction: (() -> Void)?

    // MARK: Public properties
    var viewModel: PromotionCellViewModel?

    let dateFormatter = DateFormatter()

    // MARK: - Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView))
        self.containerView.addGestureRecognizer(backgroundTapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout and Theme
    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.card
        self.containerView.layer.masksToBounds = true

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.contentView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundCards
        
        self.backgroundImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.highlightPrimary
        
        self.dateLabel.textColor = UIColor.App.textSecondary
        
        self.descriptionLabel.textColor = UIColor.App.textPrimary
        
    }
    
    // MARK: Function
    func configure(viewModel: PromotionCellViewModel) {
        
        self.viewModel = viewModel
        
        self.titleLabel.text = viewModel.promotionInfo.title
        
        if let endDate = viewModel.promotionInfo.endDate {
            self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let formattedDate = dateFormatter.string(from: endDate)
            self.dateLabel.text = "Available until \(formattedDate)"
        }
        else {
            self.dateLabel.text = "Permanent offer"
        }
        
        self.descriptionLabel.text = viewModel.promotionInfo.listDisplayDescription ?? ""
        
        if let imageUrl = URL(string: viewModel.promotionInfo.listDisplayImageUrl) {
            self.backgroundImageView.kf.setImage(with: imageUrl)
        }
        
    }
    
    // MARK: Actions
    @objc func didTapBackgroundView() {
        print("TAPPED PROMOTION!")
        self.didTapPromotionAction?()
    }
}

extension PromotionTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Promotion"
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .left
        return label
    }
    
    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01/01/2025"
        label.font = AppFont.with(type: .semibold, size: 15)
        label.textAlignment = .left
        return label
    }
    
    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Promotion"
        label.font = AppFont.with(type: .regular, size: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.backgroundImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.dateLabel)
        self.containerView.addSubview(self.descriptionLabel)

        self.initConstraints()

        self.containerView.layoutIfNeeded()
        self.containerView.layoutSubviews()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5)
        ])

        // Top Info stackview
        NSLayoutConstraint.activate([
            
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.backgroundImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.backgroundImageView.heightAnchor.constraint(equalToConstant: 190),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.titleLabel.topAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor, constant: 12),
            
            self.dateLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.dateLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.dateLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 5),
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -16)
        ])
        
    }
}
