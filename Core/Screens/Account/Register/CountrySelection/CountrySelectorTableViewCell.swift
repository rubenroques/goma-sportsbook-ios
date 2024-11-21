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

        self.nameLabel.text = ""
        self.prefixLabel.text = ""

        self.nameLabel.font = AppFont.with(type: .bold, size: 16)
        self.prefixLabel.font = AppFont.with(type: .bold, size: 16)
        
        self.setupWithTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.nameLabel.text = ""
        
        self.prefixLabel.isHidden = true
        self.prefixLabel.text = ""

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        self.nameLabel.textColor = UIColor.App.textPrimary
        self.prefixLabel.textColor = UIColor.App.textPrimary
    }

    func setupWithCountry(country: Country, showPrefix: Bool) {
        if showPrefix, country.phonePrefix.isNotEmpty {
            self.prefixLabel.isHidden = false
            self.prefixLabel.text = "(\(country.phonePrefix))"
        }
        self.nameLabel.text = formatIndicativeCountry(country)
    }

    private func formatIndicativeCountry(_ country: Country) -> String {
        var translatedCountryName = localized("\(country.iso2Code)")
        if translatedCountryName.isEmpty {
            translatedCountryName = country.name
        }
        var stringCountry = "\(country.iso2Code) - \(translatedCountryName)"
        if let flag = CountryFlagHelper.flag(forCode: country.iso2Code) {
            stringCountry = "\(flag) \(translatedCountryName)"
        }
        return stringCountry
    }

}
