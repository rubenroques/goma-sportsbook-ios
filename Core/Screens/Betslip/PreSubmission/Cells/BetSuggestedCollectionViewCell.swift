//
//  BetSuggestedCollectionViewCell.swift
//  Sportsbook
//
//  Created by Teresa on 09/12/2021.
//

import UIKit

class BetSuggestedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var betsStackView: UIStackView!
    @IBOutlet weak var betView: UIView!
    @IBOutlet weak var competitionTitleLabel: UILabel!
    @IBOutlet weak var otherInfoCompetitionLabel: UILabel!
    @IBOutlet weak var competitionImage: UIImageView!
   
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

    }
    
    private func setupBetView(competitionTitle : String, otherInfoCompetition : String) -> UIView{
        self.competitionTitleLabel.text = competitionTitle
        self.otherInfoCompetitionLabel.text = otherInfoCompetition
        //self.competitionImage.image = competitionImage
        

        return self.betView
    }

    func setupBetInfo(numberOfSelections : Int , totalOdd : Double){
        self.numberOfSelectionsValueLabel.text = String(numberOfSelections)
        self.totalOddValueLabel.text = String(totalOdd)
    }
    
    func addNewView(competitionTitle : String, otherInfoCompetition : String) -> UIView{
       let view = setupBetView(competitionTitle: competitionTitle, otherInfoCompetition: competitionTitle)
        
       let infoView = GameSuggestedView()
       return infoView
        
    }

}
