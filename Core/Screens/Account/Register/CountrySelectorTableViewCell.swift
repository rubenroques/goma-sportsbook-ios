//
//  CountrySelectorTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 23/09/2021.
//

import UIKit

class CountrySelectorTableViewCell: UITableViewCell {

    @IBOutlet private weak var containerView: UIView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var prefixLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.nameLabel.text = ""
        
        self.prefixLabel.isHidden = true
        self.prefixLabel.text = ""

        self.setupTheme()
    }

    func setupTheme(){

        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.mainBackgroundColor
        self.nameLabel.textColor = UIColor.App.headingMain
        self.prefixLabel.textColor = UIColor.App.headingMain
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
