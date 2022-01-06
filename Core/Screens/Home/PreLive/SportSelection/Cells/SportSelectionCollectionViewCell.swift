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
                containerView.layer.borderColor = UIColor.App.mainTint.cgColor
            }
            else {
                containerView.layer.borderColor = UIColor.App.headerTextField.cgColor
            }
        }
    }
    var sport: EveryMatrix.Discipline?
    private var cancellable = Set<AnyCancellable>()

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

        eventCountView.isHidden = true
        eventCountView.layer.cornerRadius = eventCountView.frame.size.width/2
    }

    func setSport(sport: EveryMatrix.Discipline) {
        self.sport = sport
        nameLabel.text = sport.name
        iconImageView.image = UIImage(named: "sport_type_icon_\(sport.id ?? "")")
    }

    func setLiveSportCount() {
        if let sportId = self.sport?.id, let sportPublisher = Env.everyMatrixStorage.sportsLivePublisher[sportId] {

            self.eventCountView.isHidden = false

            sportPublisher.receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] sport in
                    if let sportCount = sport.numberOfLiveEvents {
                        self?.eventCountLabel.text = "\(sportCount)"
                    }

                })
                .store(in: &cancellable)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        nameLabel.text = ""
        sport = nil
    }

}
