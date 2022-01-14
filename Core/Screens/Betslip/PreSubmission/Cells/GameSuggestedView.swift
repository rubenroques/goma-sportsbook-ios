//
//  GameSuggestedView.swift
//  Sportsbook
//
//  Created by Teresa on 10/12/2021.
//

import Foundation
import UIKit

class GameSuggestedView: NibView {

    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var gameTitleLabel: UILabel!
    @IBOutlet weak var gameInfoLabel: UILabel!
    
    var gameTitle: String
    var gameInfo: String
    
    convenience init(gameTitle: String, gameInfo: String) {
        self.init(frame: .zero, gameTitle: gameTitle, gameInfo: gameInfo)
    }

    init(frame: CGRect, gameTitle: String, gameInfo: String) {
        self.gameTitle = gameTitle
        self.gameInfo = gameInfo
        super.init(frame: frame)

        self.commonInit()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gameImageView.layer.cornerRadius = self.gameImageView.frame.size.height/2

    }

    override func commonInit() {

        self.gameTitleLabel.text = self.gameTitle
        self.gameInfoLabel.text = self.gameInfo
        
        self.gameImageView.image = UIImage(named: "")
        self.gameImageView.clipsToBounds = true
        self.gameImageView.layer.masksToBounds = true
  
        self.setupWithTheme()
        
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 54)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setupWithTheme()
        
    }

    func setupWithTheme() {
    
        self.gameInfoLabel.textColor = UIColor.App.headingMain
       // self.gameInfoLabel.font = AppFont.with(type: .medium, size: 11)

        self.gameTitleLabel.textColor = UIColor.App.headingMain
        // self.gameTitleLabel.font = AppFont.with(type: .bold, size: 13)
        if let gameView = self.gameView {
            gameView.backgroundColor = UIColor.App.secondaryBackground
        }
        
    }

    func setMatchFlag(isoCode: String) {
        let gameFlag = Assets.flagName(withCountryCode: isoCode)

        if gameFlag != "country_flag_" {
            self.gameImageView.image = UIImage(named: gameFlag)
        }
        else {
            self.gameImageView.image = UIImage(named: "sport_type_soccer_icon")
        }

    }

}
