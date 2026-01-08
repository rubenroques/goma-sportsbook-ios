//
//  GamingBannerTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 11/07/2025.
//

import Foundation
import UIKit
import Kingfisher

class GamingBannerTableViewCell: UITableViewCell {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var bannerImageView: UIImageView = Self.createBannerImageView()

    private let cellHeight: CGFloat = 130.0
    private var aspectRatio: CGFloat = 1.0
    
    // Dynamic height constraint properties
    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()
    
    var didTapBannerAction: (() -> Void) = {}

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBanner))
        self.addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = .clear
        self.bannerImageView.backgroundColor = .clear
    }
    
    func configure(bannerString: String) {
        
        if let url = URL(string: bannerString) {
            self.bannerImageView.kf.setImage(with: url) { [weak self] result in
                switch result {
                case .success(let imageResult):
                    // Update aspect ratio and switch to dynamic constraint
                    self?.updateAspectRatio(with: imageResult.image)
                case .failure:
                    // Keep default aspect ratio if image loading fails
                    break
                }
            }
        }
    }
    
    private func updateAspectRatio(with image: UIImage) {
        self.aspectRatio = image.size.width / image.size.height
        
        self.bannerImageViewFixedHeightConstraint.isActive = false
        
        self.bannerImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.bannerImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)
        
        self.bannerImageViewDynamicHeightConstraint.isActive = true
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    @objc func didTapBanner() {
        self.didTapBannerAction()
    }

}

extension GamingBannerTableViewCell {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }

    private static func createBannerImageView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "gaming_default_banner")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        view.layer.cornerRadius = CornerRadius.button
        view.layer.masksToBounds = true
        return view
    }
    
    private static func createBannerImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createBannerImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.bannerImageView)

        if let bannerImage = self.bannerImageView.image {
            self.aspectRatio = bannerImage.size.width / bannerImage.size.height
        }
        
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
             
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            
            self.bannerImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.bannerImageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.bannerImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 20),
            self.bannerImageView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -20),
        ])
        
        self.bannerImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: self.cellHeight - 40) // Account for top/bottom margins
        self.bannerImageViewFixedHeightConstraint.isActive = true

        self.bannerImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.bannerImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)
        self.bannerImageViewDynamicHeightConstraint.isActive = false
    }

}
