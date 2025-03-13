//
//  BannerMatchCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/10/2021.
//

import UIKit

class BannerMatchCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var imageBaseView: UIView!
    @IBOutlet private weak var imageView: UIImageView!

    var viewModel: BannerCellViewModel?
    var didTapBanner: ((String?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.clipsToBounds = true
        self.baseView.alpha = 1.0
        self.baseView.isUserInteractionEnabled = true

        let tapBannerBaseView = UITapGestureRecognizer(target: self, action: #selector(didTapBannerView))
        self.baseView.addGestureRecognizer(tapBannerBaseView)

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.baseView.layer.cornerRadius = 8
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.viewModel = nil
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.imageBaseView.backgroundColor = .clear
        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
    }

    func setupWithViewModel(_ viewModel: BannerCellViewModel) {
        self.viewModel = viewModel
        
        // Set image
        if let url = viewModel.imageURL {
            self.imageView.kf.setImage(with: url)
        }
    }

    @objc func didTapBannerView() {
        self.didTapBanner?(self.viewModel?.ctaUrl)
    }
}
