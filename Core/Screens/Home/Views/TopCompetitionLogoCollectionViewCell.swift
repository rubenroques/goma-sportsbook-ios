//
//  TopCompetitionLogoCollectionViewCell.swift
//  MultiBet
//
//  Created by André Lascas on 11/12/2024.
//

import UIKit

class TopCompetitionLogoCollectionViewCell: UICollectionViewCell {
    
    private lazy var gradientView: GradientView = Self.createGradientView()
    private lazy var backgroundImageView: UIImageView = Self.createBackgroundImageView()
    private lazy var imageGradientView: GradientView = Self.createImageGradientView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    
    private var viewModel: TopCompetitionItemCellViewModel?

    var selectedItemAction: (TopCompetitionItemCellViewModel) -> Void = { _ in }

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

    }

    private func commonInit() {

        let nextTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapItemView))
        self.addGestureRecognizer(nextTapGesture)

        self.setupSubviews()
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.gradientView.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.gradientView.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        self.imageGradientView.startPoint = CGPoint(x: 0.5, y: 1.0)
        self.imageGradientView.endPoint = CGPoint(x: 0.5, y: 0.0)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.gradientView.colors = [(UIColor.App.highlightPrimary, NSNumber(0.0)),
                                    (UIColor.App.highlightTertiary, NSNumber(1.0))]
        
        self.imageGradientView.backgroundColor = .clear
        self.imageGradientView.colors = [(.black.withAlphaComponent(0.76), NSNumber(0.0)),
                                         (.black.withAlphaComponent(0.33), NSNumber(1.0))]
        
        self.backgroundImageView.backgroundColor = .clear
        
        self.titleLabel.textColor = UIColor.App.buttonTextSecondary

    }
    
    func configureWithViewModel(_ viewModel: TopCompetitionItemCellViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.name

        if let country = viewModel.country {
            if country.iso2Code != "" {
                self.backgroundImageView.image = UIImage(named: Assets.flagName(withCountryCode: country.iso2Code))
            }
            else {
                self.backgroundImageView.image = UIImage(named: "top_competition_banner")
                self.imageGradientView.isHidden = true
            }
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    @objc func didTapItemView() {
        if let viewModel = self.viewModel {
            self.selectedItemAction(viewModel)
        }
    }
}

extension TopCompetitionLogoCollectionViewCell {
    
    private static func createGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.button
        view.clipsToBounds = true
        return view
    }
    
    private static func createBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = CornerRadius.button
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createImageGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.button
        view.clipsToBounds = true
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Competition"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    private func setupSubviews() {

        self.addSubview(self.gradientView)

        self.gradientView.addSubview(self.backgroundImageView)

        self.gradientView.addSubview(self.imageGradientView)
        
        self.gradientView.addSubview(self.titleLabel)

        self.initConstraints()

    }
    
    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.gradientView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.gradientView.topAnchor.constraint(equalTo: self.topAnchor),
            self.gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.gradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.gradientView.leadingAnchor, constant: 1),
            self.backgroundImageView.topAnchor.constraint(equalTo: self.gradientView.topAnchor, constant: 1),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.gradientView.trailingAnchor, constant: -1),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.gradientView.bottomAnchor, constant: -1),
            
            self.imageGradientView.leadingAnchor.constraint(equalTo: self.backgroundImageView.leadingAnchor),
            self.imageGradientView.trailingAnchor.constraint(equalTo: self.backgroundImageView.trailingAnchor),
            self.imageGradientView.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor),
            self.imageGradientView.bottomAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.gradientView.leadingAnchor, constant: 30),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.gradientView.trailingAnchor, constant: -30),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.gradientView.centerYAnchor)
        ])
        
    }
}
