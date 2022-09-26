//
//  CountrySelectorTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 23/09/2021.
//

import UIKit

class CountrySelectorTableViewCell: UITableViewCell {

    @IBOutlet private weak var containerView: UIView!

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var prefixLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.nameLabel.text = localized("empty_value")
        self.prefixLabel.text = localized("empty_value")

        self.setupWithTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.nameLabel.text = localized("empty_value")
        
        self.prefixLabel.isHidden = true
        self.prefixLabel.text = localized("empty_value")

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        self.nameLabel.textColor = UIColor.App.textPrimary
        self.prefixLabel.textColor = UIColor.App.textPrimary
    }

    func setupWithCountry(country: EveryMatrix.Country, showPrefix: Bool) {
        if showPrefix, country.phonePrefix.isNotEmpty {
            self.prefixLabel.isHidden = false
            self.prefixLabel.text = "(\(country.phonePrefix))"
        }

        self.nameLabel.text = formatIndicativeCountry(country)
    }

    private func formatIndicativeCountry(_ country: EveryMatrix.Country) -> String {
        var stringCountry = "\(country.name)"
        if let isoCode = country.isoCode {
            stringCountry = "\(isoCode) - \(country.name)"
            if let flag = CountryFlagHelper.flag(forCode: isoCode) {
                stringCountry = "\(flag) \(country.name)"
            }
        }
        return stringCountry
    }

}
