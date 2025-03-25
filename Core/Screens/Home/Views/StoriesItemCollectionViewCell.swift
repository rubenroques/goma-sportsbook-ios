//
//  StoriesItemCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/06/2023.
//

import Foundation
import UIKit

struct StoriesItemCellViewModel {
    
    let id: String
    // The title of the button story cell
    let buttonTitle: String
    // The small icon in the button story cell
    let buttonIconUrl: String
    // The (optional) background image in th button story cell
    let buttonBackgroungImageUrl: String?
    // The media content that will show in the fullscreen
    let contentMediaUrl: String
    // the link (internal or external) of the full screen bottom button
    let ctaUrl: String
    // the link (internal or external) of the full screen bottom button
    let ctaText: String
    // marks if the story is read
    var isRead: Bool
    
    init(promotionalStory: PromotionalStory, isRead: Bool) {
        self.id = promotionalStory.id
        self.buttonTitle = promotionalStory.buttonTitle
        self.buttonIconUrl = promotionalStory.buttonIconUrl
        self.buttonBackgroungImageUrl = promotionalStory.buttonBackgroungImageUrl
        self.contentMediaUrl = promotionalStory.contentMediaUrl
        self.ctaUrl = promotionalStory.ctaUrl
        self.ctaText = promotionalStory.ctaText
        self.isRead = isRead
    }
    
    init(id: String,
         buttonTitle: String,
         buttonIconUrl: String,
         buttonBackgroungImageUrl: String?,
         contentMediaUrl: String,
         ctaUrl: String,
         ctaText: String,
         isRead: Bool) {
        self.id = id
        self.buttonTitle = buttonTitle
        self.buttonIconUrl = buttonIconUrl
        self.buttonBackgroungImageUrl = buttonBackgroungImageUrl
        self.contentMediaUrl = contentMediaUrl
        self.ctaUrl = ctaUrl
        self.ctaText = ctaText
        self.isRead = isRead
    }
    
    func copy(isRead: Bool) -> StoriesItemCellViewModel {
        return StoriesItemCellViewModel(
            id: self.id,
            buttonTitle: self.buttonTitle,
            buttonIconUrl: self.buttonIconUrl,
            buttonBackgroungImageUrl: self.buttonBackgroungImageUrl,
            contentMediaUrl: self.contentMediaUrl,
            ctaUrl: self.ctaUrl,
            ctaText: self.ctaText,
            isRead: isRead)
    }
    
}

class StoriesItemCollectionViewCell: UICollectionViewCell {

    var selectedItemAction: (StoriesItemCellViewModel) -> Void = { _ in }

    private let backgroundGradientView: UIView = {
        let backgroundGradientView = UIView()
        backgroundGradientView.layer.cornerRadius = 11
        backgroundGradientView.layer.masksToBounds = true
        backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
        backgroundGradientView.clipsToBounds = true
        return backgroundGradientView
    }()

    private let gradientBorderView: UIView = {
        let gradientBorderView = UIView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.layer.cornerRadius = 11
        gradientBorderView.layer.masksToBounds = true
        gradientBorderView.layer.borderWidth = 2
        gradientBorderView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        return gradientBorderView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 11)
        return label
    }()

    private let newPillBaseView: UIView = {
        let newPillBaseView = UIView()
        newPillBaseView.layer.masksToBounds = true
        newPillBaseView.translatesAutoresizingMaskIntoConstraints = false
        newPillBaseView.clipsToBounds = true
        newPillBaseView.backgroundColor = .lightGray.withAlphaComponent(0.6)
        return newPillBaseView
    }()

    private let newPillForegroundView: UIView = {
        let newPillForegroundView = UIView()
        newPillForegroundView.layer.masksToBounds = true
        newPillForegroundView.translatesAutoresizingMaskIntoConstraints = false
        newPillForegroundView.clipsToBounds = true
        newPillForegroundView.backgroundColor = .gray
        return newPillForegroundView
    }()

    private let newPillLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 9)
        label.text = "NEW"
        return label
    }()

    private var viewModel: StoriesItemCellViewModel?

    var isRead: Bool = false {
        didSet {
            self.viewModel?.isRead = isRead

            if isRead {
                self.newPillBaseView.isHidden = true

            }
            else {
                self.newPillBaseView.isHidden = false

            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.isRead = false
    }

    private func commonInit() {

        let nextTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapItemView))
        self.addGestureRecognizer(nextTapGesture)

        self.setupViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.newPillBaseView.layer.cornerRadius = 4
        self.newPillForegroundView.layer.cornerRadius = 4

    }

    private func setupViews() {

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(hex: 0xF1681E, alpha: 1.0).cgColor, // UIColor(hex: 0xD60000, alpha: 1.0).cgColor,
            UIColor(hex: 0xF8C633, alpha: 1.0).cgColor, // UIColor(hex: 0xFF2600, alpha: 1.0).cgColor,
        ]

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 0.0)
        gradientLayer.frame = bounds

        self.addSubview(self.backgroundGradientView)
        self.addSubview(self.gradientBorderView)

        self.backgroundGradientView.layer.addSublayer(gradientLayer)

        self.addSubview(self.imageView)
        self.addSubview(self.label)

        self.newPillForegroundView.addSubview(self.newPillLabel)
        self.newPillBaseView.addSubview(self.newPillForegroundView)

        self.addSubview(self.newPillBaseView)

        NSLayoutConstraint.activate([

            self.topAnchor.constraint(equalTo: self.newPillBaseView.topAnchor, constant: 4),
            self.trailingAnchor.constraint(equalTo: self.newPillBaseView.trailingAnchor, constant: 6),

            self.newPillLabel.leadingAnchor.constraint(equalTo: self.newPillForegroundView.leadingAnchor, constant: 4),
            self.newPillLabel.topAnchor.constraint(equalTo: self.newPillForegroundView.topAnchor, constant: 3),
            self.newPillLabel.centerXAnchor.constraint(equalTo: self.newPillForegroundView.centerXAnchor),
            self.newPillLabel.centerYAnchor.constraint(equalTo: self.newPillForegroundView.centerYAnchor),

            self.newPillForegroundView.leadingAnchor.constraint(equalTo: self.newPillBaseView.leadingAnchor, constant: 1),
            self.newPillForegroundView.topAnchor.constraint(equalTo: self.newPillBaseView.topAnchor, constant: 1),
            self.newPillForegroundView.centerXAnchor.constraint(equalTo: self.newPillBaseView.centerXAnchor),
            self.newPillForegroundView.centerYAnchor.constraint(equalTo: self.newPillBaseView.centerYAnchor),

        ])

        NSLayoutConstraint.activate([
            self.backgroundGradientView.leadingAnchor.constraint(equalTo: self.gradientBorderView.leadingAnchor),
            self.backgroundGradientView.trailingAnchor.constraint(equalTo: self.gradientBorderView.trailingAnchor),
            self.backgroundGradientView.topAnchor.constraint(equalTo: self.gradientBorderView.topAnchor),
            self.backgroundGradientView.bottomAnchor.constraint(equalTo: self.gradientBorderView.bottomAnchor),

            self.backgroundGradientView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.backgroundGradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.backgroundGradientView.widthAnchor.constraint(equalToConstant: 82),
            self.backgroundGradientView.heightAnchor.constraint(equalToConstant: 102),

            self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -4),
            self.imageView.widthAnchor.constraint(equalToConstant: 60),
            self.imageView.heightAnchor.constraint(equalToConstant: 60),

            self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
            self.label.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 3),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3),
        ])
    }

    // Configure the cell with your data
    func configureWithViewModel(viewModel: StoriesItemCellViewModel) {
        self.viewModel = viewModel

        if let url = URL(string: viewModel.buttonIconUrl) {
            self.imageView.kf.setImage(with: url)
        }

        self.label.text = viewModel.buttonTitle

        self.gradientBorderView.isHidden = true
        self.backgroundGradientView.isHidden = false
        self.label.textColor = UIColor.App.buttonTextPrimary

        self.newPillLabel.textColor = UIColor.App.buttonTextPrimary
        self.newPillBaseView.backgroundColor = UIColor.App.highlightSecondary.withAlphaComponent(0.6)
        self.newPillForegroundView.backgroundColor = UIColor.App.highlightSecondary

        if viewModel.isRead {
            self.newPillBaseView.isHidden = true
        }
        else {
            self.newPillBaseView.isHidden = false
        }
    }

    @objc func didTapItemView() {
        if let viewModel = self.viewModel {
            self.selectedItemAction(viewModel)
            self.isRead = true
        }
    }

}
