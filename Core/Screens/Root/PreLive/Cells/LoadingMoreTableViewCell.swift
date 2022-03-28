//
//  LoadingMoreTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/10/2021.
//

import UIKit

class LoadingMoreTableViewCell: UITableViewCell {

    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.hidesWhenStopped = true

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.stopAnimating()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }

    func startAnimating() {
        self.activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
    }

}
