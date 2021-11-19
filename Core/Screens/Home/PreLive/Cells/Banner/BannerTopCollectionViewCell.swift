//
//  BannerTopCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2021.
//

import UIKit
import Kingfisher

class BannerTopCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var imageView: UIImageView!

    var viewModel: BannerCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.baseView.clipsToBounds = true
        self.baseView.layer.masksToBounds = true
        self.baseView.layer.cornerRadius = 8

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.imageView.kf.cancelDownloadTask()
        self.imageView.image = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.baseView.backgroundColor = .clear
    }

    func setupWithViewModel(_ viewModel: BannerCellViewModel) {
        self.viewModel = viewModel

        switch viewModel.presentationType {
        case .image:
            if let url = viewModel.imageURL {
                self.imageView.kf.setImage(with: url)
            }
        case .match:
            if let url = viewModel.imageURL {
                self.imageView.kf.setImage(with: url)
            }
        }
    }

}
