//
//  SportSelectionCollectionViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 11/10/2021.
//

import UIKit
import Combine

class SportSelectionCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var eventCountView: UIView!
    @IBOutlet private var eventCountLabel: UILabel!

    // Variables
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                containerView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            }
            else {
                containerView.layer.borderColor = UIColor.App.backgroundSecondary.cgColor
            }
        }
    }
    var sport: EveryMatrix.Discipline?
    private var cancellable = Set<AnyCancellable>()
    private var currentLiveSportsPublisher: AnyCancellable?
    var viewModel: SportSelectionCollectionViewCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.iconImageView.image = nil
        self.nameLabel.text = ""
        self.sport = nil
        self.eventCountLabel.text = ""
        self.currentLiveSportsPublisher?.cancel()
    }

    func commonInit() {

        //self.backgroundColor = UIColor.App.backgroundSecondary

        containerView.layer.cornerRadius = containerView.frame.size.height/2
        containerView.backgroundColor = UIColor.App.backgroundSecondary
        containerView.layer.borderColor = UIColor.App.backgroundSecondary.cgColor
        containerView.layer.borderWidth = 2

        iconImageView.backgroundColor = UIColor.App.backgroundSecondary
        iconImageView.image = UIImage(named: "sport_type_icon")
        iconImageView.contentMode = .scaleAspectFit

        nameLabel.text = localized("sport")
        nameLabel.font = AppFont.with(type: .bold, size: 12)
        nameLabel.textColor = UIColor.App.textPrimary
        nameLabel.numberOfLines = 2

        eventCountView.isHidden = true
        eventCountView.layer.cornerRadius = eventCountView.frame.size.width/2
        eventCountView.backgroundColor = UIColor.App.alertError

        eventCountLabel.font = AppFont.with(type: .semibold, size: 9)
        eventCountLabel.textColor = UIColor.App.buttonTextPrimary
        
    }

    func configureCell(viewModel: SportSelectionCollectionViewCellViewModel) {

        self.viewModel = viewModel

        self.sport = viewModel.sport

        nameLabel.text = viewModel.sportName

        if let sportIconName = viewModel.sportIconName, let sportIconImage = UIImage(named: sportIconName) {
            iconImageView.image = sportIconImage
        }
        else {
            iconImageView.image = UIImage(named: "sport_type_icon_default")
        }

        self.viewModel?.updateLiveEvents = {
            self.eventCountView.isHidden = false

            self.eventCountLabel.text = self.viewModel?.numberOfLiveEvents

        }
    }

}
