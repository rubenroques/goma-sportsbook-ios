//
//  SportSelectionCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 11/10/2021.
//

import UIKit

class SportSelectionCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!

    // Variables
    override var isSelected: Bool {
        didSet{
            if self.isSelected {
                containerView.layer.borderColor = UIColor.App.mainTint.cgColor
            }
            else {
                containerView.layer.borderColor = UIColor.App.headerTextField.cgColor
            }
        }
    }
    var sport: EveryMatrix.Discipline?

    override func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
    }

    func commonInit() {

        self.backgroundColor = UIColor.App.mainBackground

        containerView.layer.cornerRadius = containerView.frame.size.height/2
        containerView.backgroundColor = UIColor.App.secondaryBackground
        containerView.layer.borderColor = UIColor.App.secondaryBackground.cgColor
        containerView.layer.borderWidth = 2

        iconImageView.backgroundColor = UIColor.App.secondaryBackground
        iconImageView.image = UIImage(named: "sport_type_icon")
        iconImageView.contentMode = .scaleAspectFit

        nameLabel.text = "Sport"
        nameLabel.font = AppFont.with(type: .bold, size: 12)
        nameLabel.textColor = UIColor.App.headingMain
        nameLabel.numberOfLines = 2
    }

    func setSport(sport: EveryMatrix.Discipline) {
        self.sport = sport
        nameLabel.text = sport.name
        iconImageView.image = UIImage(named: "sport_type_icon_\(sport.id ?? "")")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        nameLabel.text = ""
        sport = nil
    }

}
