//
//  BetSuggestedCollectionViewCell.swift
//  Sportsbook
//
//  Created by Teresa on 09/12/2021.
//

import UIKit

class BetSuggestedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var betsStackView: UIStackView!
    @IBOutlet weak var competitionTitleLabel: UILabel!
   
   
    @IBOutlet weak var informationBetView: UIView!
    
    @IBOutlet weak var numberOfSelectionsLabel: UILabel!
    @IBOutlet weak var numberOfSelectionsValueLabel: UILabel!
    @IBOutlet weak var totalOddLabel: UILabel!
    @IBOutlet weak var totalOddValueLabel: UILabel!
    @IBOutlet weak var betNowButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupWithTheme()
        
        betNowButton.layer.cornerRadius = 4.0
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.betsStackView.removeAllArrangedSubviews()

    }
    
    func setupStackBetView(betValues : [[String]]) {
     
         betsStackView.removeAllArrangedSubviews()
        
         for value in betValues {
             let gameSuggestedView = GameSuggestedView(gameTitle: value[0], gameInfo: value[1])
             betsStackView.addArrangedSubview(gameSuggestedView)
         }
        
        
        
     }
    
    func setupInfoBetValues(betValues : [[String]]) {
     
        totalOddValueLabel.text = String("---")
        numberOfSelectionsValueLabel.text = String(betValues.count)
        
        
     }
    
}


