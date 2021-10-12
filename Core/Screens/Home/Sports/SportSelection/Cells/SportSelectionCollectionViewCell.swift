//
//  SportSelectionCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 11/10/2021.
//

import UIKit

class SportSelectionCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var label: UILabel!
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
    var sport: [Discipline] = []

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

        imageView.backgroundColor = UIColor.App.secondaryBackground
        imageView.image = UIImage(named: "sport_type_soccer_icon")
        imageView.contentMode = .scaleAspectFill

        label.text = "Sport"
        label.font = AppFont.with(type: .bold, size: 12)
        label.textColor = UIColor.App.headingMain
        label.numberOfLines = 0
    }

    func setSport(sport: Discipline) {
        self.sport.append(sport)
        label.text = sport.name
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sport = []
    }

}
