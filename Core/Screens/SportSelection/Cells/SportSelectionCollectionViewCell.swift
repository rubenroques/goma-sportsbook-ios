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

    private var cancellable = Set<AnyCancellable>()
    private var currentLiveSportsPublisher: AnyCancellable?
    var viewModel: SportSelectionCollectionViewCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.commonInit()
        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.iconImageView.image = nil
        self.nameLabel.text = ""
        self.eventCountLabel.text = ""
        self.currentLiveSportsPublisher?.cancel()
    }

    func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundSecondary
        self.containerView.layer.borderColor = UIColor.App.backgroundSecondary.cgColor

        self.iconImageView.backgroundColor = UIColor.App.backgroundSecondary

        self.nameLabel.font = AppFont.with(type: .bold, size: 12)
        self.nameLabel.textColor = UIColor.App.textPrimary

        self.eventCountView.backgroundColor = UIColor.App.highlightSecondary

        self.eventCountLabel.textColor = UIColor.App.highlightSecondaryContrast
    }
    
    func commonInit() {

        // self.backgroundColor = UIColor.App.backgroundSecondary

        self.containerView.layer.cornerRadius = self.containerView.frame.size.height/2
        self.containerView.layer.borderWidth = 2

        self.iconImageView.image = UIImage(named: "sport_type_icon")
        self.iconImageView.contentMode = .scaleAspectFit

        self.nameLabel.text = localized("sport")
        self.nameLabel.numberOfLines = 2

        self.eventCountView.isHidden = true
        self.eventCountView.layer.cornerRadius = eventCountView.frame.size.width/2
        
        self.eventCountLabel.font = AppFont.with(type: .semibold, size: 10)
        
    }

    func configureCell(viewModel: SportSelectionCollectionViewCellViewModel) {

        self.viewModel = viewModel
        self.nameLabel.text = viewModel.sportName

        if let sportName = viewModel.sportName,
            sportName.contains("Moto") {
            print("HERE!")
        }
        if let sportIconName = viewModel.sportIconName, let sportIconImage = UIImage(named: sportIconName) {
            self.iconImageView.image = sportIconImage
        }
        else {
            self.iconImageView.image = UIImage(named: "sport_type_icon_default")
        }
        
        if viewModel.isLive, let numberOfLiveEvents = viewModel.numberOfLiveEvents, (Int(numberOfLiveEvents) ?? 0) > 0 {
            self.showEventCount(numberOfLiveEvents)
        }

        self.isSelected = false
    }
    
    func showEventCount(_ count: String) {
        self.eventCountView.isHidden = false
        self.eventCountLabel.text = count
    }
    
    func hideEventCount() {
        self.eventCountView.isHidden = true
    }

}
